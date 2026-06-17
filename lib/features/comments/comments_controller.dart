import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'comment_model.dart';
import 'comments_service.dart';
import '../../core/utils/app_snackbar.dart';

class CommentsController extends GetxController {
  CommentsController(this._service);

  final CommentsService _service;

  final comments = <CommentModel>[].obs;
  final isLoading = false.obs;
  final isSending = false.obs;
  final deletingCommentIds = <int>{}.obs;
  final commentController = TextEditingController();

  Future<void> loadComments(int postId) async {
    isLoading.value = true;
    try {
      final response = await _service.getPostComments(postId);
      comments.assignAll(response.data ?? const []);
    } catch (error) {
      _toast('خطأ', _cleanError(error));
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> deleteComment(CommentModel comment) async {
    if (deletingCommentIds.contains(comment.id)) return false;

    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('حذف التعليق؟'),
        content: const Text('سيتم حذف التعليق نهائياً.'),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: const Text('إلغاء')),
          TextButton(onPressed: () => Get.back(result: true), child: const Text('حذف')),
        ],
      ),
    );
    if (confirm != true) return false;

    deletingCommentIds.add(comment.id);
    final oldComments = List<CommentModel>.from(comments);
    comments.removeWhere((item) => item.id == comment.id);
    try {
      await _service.deleteComment(comment.id);
      _toast('تم', 'تم حذف التعليق بنجاح.');
      return true;
    } catch (error) {
      comments.assignAll(oldComments);
      _toast('خطأ', _cleanError(error));
      return false;
    } finally {
      deletingCommentIds.remove(comment.id);
    }
  }

  Future<bool> addComment(int postId) async {
    final content = commentController.text.trim();
    if (content.isEmpty) return false;
    isSending.value = true;
    try {
      final response = await _service.addComment(postId: postId, content: content);
      final created = response.data;
      if (created != null) comments.insert(0, created);
      commentController.clear();
      return true;
    } catch (error) {
      _toast('خطأ', _cleanError(error));
      return false;
    } finally {
      isSending.value = false;
    }
  }

  String _cleanError(Object error) => AppSnackbar.cleanError(error);

  void _toast(String title, String message) {
    AppSnackbar.show(title, message);
  }

  @override
  void onClose() {
    commentController.dispose();
    super.onClose();
  }
}
