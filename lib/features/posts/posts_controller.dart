import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/storage/storage_service.dart';
import '../../core/media/media_compressor.dart';
import '../fans/fans_controller.dart';
import 'post_model.dart';
import 'posts_service.dart';
import '../../core/utils/app_snackbar.dart';

class PostsController extends GetxController {
  PostsController(this._service);

  final PostsService _service;

  final posts = <PostModel>[].obs;
  final selectedPost = Rxn<PostModel>();
  final isLoading = false.obs;
  final isPostLoading = false.obs;
  final isCreating = false.obs;
  final isUpdating = false.obs;
  final selectedMediaPath = RxnString();

  final captionController = TextEditingController();

  @override
  void onReady() {
    super.onReady();
    if (posts.isEmpty) loadFeed();
  }

  int? get currentUserId => StorageService.userId;

  File? get selectedMediaFile {
    final path = selectedMediaPath.value;
    return path == null ? null : File(path);
  }

  Future<void> loadFeed() async {
    isLoading.value = true;
    try {
      final response = await _service.getFeed();
      posts.assignAll(_communityOnly(response.data ?? const []));
    } catch (error) {
      _toast('خطأ', _cleanError(error));
    } finally {
      isLoading.value = false;
    }
  }

  Future<PostModel?> loadPostById(int postId, {PostModel? seed}) async {
    if (seed != null) {
      selectedPost.value = seed;
    } else if (selectedPost.value?.id != postId) {
      selectedPost.value = null;
    }
    if (postId <= 0) return selectedPost.value;

    isPostLoading.value = true;
    try {
      final response = await _service.getPostById(postId);
      final post = response.data;
      if (post != null) {
        _replacePost(post);
        return post;
      }
    } catch (error) {
      _toast('خطأ', _cleanError(error));
    } finally {
      isPostLoading.value = false;
    }
    return selectedPost.value;
  }

  Future<void> pickMedia() async {
    final picker = ImagePicker();
    final media = await picker.pickMedia(imageQuality: 86);
    if (media == null) return;

    final compressedPath = await MediaCompressor.compressMedia(media.path);
    selectedMediaPath.value = compressedPath;
  }

  Future<void> createPost() async {
    final path = selectedMediaPath.value;
    if (path == null || path.isEmpty) {
      _toast('تنبيه', 'اختر صورة أو فيديو للمنشور.');
      return;
    }

    isCreating.value = true;
    try {
      final response = await _service.createPost(caption: captionController.text, mediaPath: path);
      final created = response.data;
      if (created != null && created.fanId != StorageService.userId) {
        posts.insert(0, created);
      }
      if (Get.isRegistered<FansController>()) {
        await Get.find<FansController>().refreshCurrent();
      }
      captionController.clear();
      selectedMediaPath.value = null;
      Get.back<void>();
      _toast('تم', response.message.isNotEmpty ? response.message : 'تم إنشاء المنشور.');
    } catch (error) {
      _toast('خطأ', _cleanError(error));
    } finally {
      isCreating.value = false;
    }
  }

  Future<bool> updatePost(PostModel post, {required String caption, String? mediaPath}) async {
    if (post.fanId != StorageService.userId) return false;

    isUpdating.value = true;
    try {
      final response = await _service.updatePost(postId: post.id, caption: caption, mediaPath: mediaPath);
      final updated = response.data;
      if (updated != null) {
        _replacePost(updated);
      }
      if (Get.isRegistered<FansController>()) {
        await Get.find<FansController>().refreshCurrent();
      }
      _toast('تم', response.message.isNotEmpty ? response.message : 'تم تعديل المنشور.');
      return true;
    } catch (error) {
      _toast('خطأ', _cleanError(error));
      return false;
    } finally {
      isUpdating.value = false;
    }
  }

  Future<void> toggleLike(PostModel post) async {
    final current = _currentPost(post);
    final optimistic = current.copyWith(
      isLiked: !current.isLiked,
      likeCount: current.isLiked ? (current.likeCount - 1).clamp(0, 1 << 30).toInt() : current.likeCount + 1,
    );
    _replacePost(optimistic);
    try {
      final response = await _service.toggleLike(post.id);
      final result = response.data;
      if (result != null) {
        _replacePost(optimistic.copyWith(isLiked: result.isLiked, likeCount: result.newLikeCount));
      }
    } catch (error) {
      _replacePost(current);
      _toast('خطأ', _cleanError(error));
    }
  }

  Future<void> toggleBookmark(PostModel post) async {
    final current = _currentPost(post);
    final optimistic = current.copyWith(
      isBookmarked: !current.isBookmarked,
      bookmarkCount: current.isBookmarked ? (current.bookmarkCount - 1).clamp(0, 1 << 30).toInt() : current.bookmarkCount + 1,
    );
    _replacePost(optimistic);
    try {
      final response = await _service.toggleBookmark(post.id);
      final result = response.data;
      if (result != null) {
        _replacePost(optimistic.copyWith(isBookmarked: result.isBookmarked, bookmarkCount: result.newBookmarkCount));
      }
    } catch (error) {
      _replacePost(current);
      _toast('خطأ', _cleanError(error));
    }
  }

  Future<void> deletePost(PostModel post) async {
    if (post.fanId != StorageService.userId) return;
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('حذف المنشور؟'),
        content: const Text('لا يمكن التراجع عن هذه العملية.'),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: const Text('إلغاء')),
          TextButton(onPressed: () => Get.back(result: true), child: const Text('حذف')),
        ],
      ),
    );
    if (confirm != true) return;

    final oldPosts = List<PostModel>.from(posts);
    final oldSelectedPost = selectedPost.value;
    posts.removeWhere((item) => item.id == post.id);
    if (selectedPost.value?.id == post.id) selectedPost.value = null;

    try {
      await _service.deletePost(post.id);
      if (Get.isRegistered<FansController>()) {
        await Get.find<FansController>().refreshCurrent();
      }
      await loadFeed();
      if (Get.currentRoute == '/post-details') Get.back<void>();
    } catch (error) {
      posts.assignAll(oldPosts);
      selectedPost.value = oldSelectedPost;
      _toast('خطأ', _cleanError(error));
    }
  }

  void openPost(PostModel post) {
    Get.toNamed('/post-details', arguments: {'postId': post.id, 'post': post});
  }

  List<PostModel> _communityOnly(List<PostModel> source) {
    final currentUserId = StorageService.userId;
    if (currentUserId == null || currentUserId <= 0) return source;
    return source.where((post) => post.fanId != currentUserId).toList(growable: false);
  }

  PostModel _currentPost(PostModel fallback) {
    final selected = selectedPost.value;
    if (selected != null && selected.id == fallback.id) return selected;
    final index = posts.indexWhere((item) => item.id == fallback.id);
    return index >= 0 ? posts[index] : fallback;
  }

  void _replacePost(PostModel updated) {
    final index = posts.indexWhere((item) => item.id == updated.id);
    if (index >= 0) posts[index] = updated;
    if (selectedPost.value?.id == updated.id || selectedPost.value == null) {
      selectedPost.value = updated;
    }
  }

  String _cleanError(Object error) => AppSnackbar.cleanError(error);

  void _toast(String title, String message) {
    AppSnackbar.show(title, message);
  }

  @override
  void onClose() {
    captionController.dispose();
    MediaCompressor.clearTempVideos();
    super.onClose();
  }
}
