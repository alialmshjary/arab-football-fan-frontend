import 'package:get/get.dart';

import '../posts/post_model.dart';
import 'bookmarks_service.dart';
import '../../core/utils/app_snackbar.dart';

class BookmarksController extends GetxController {
  BookmarksController(this._service);

  final BookmarksService _service;

  final savedPosts = <PostModel>[].obs;
  final isLoading = false.obs;

  @override
  void onReady() {
    super.onReady();
    loadSavedPosts();
  }

  Future<void> loadSavedPosts() async {
    isLoading.value = true;
    try {
      final response = await _service.getSavedPosts();
      savedPosts.assignAll(response.data ?? const []);
    } catch (error) {
      _toast('خطأ', _cleanError(error));
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> toggleLike(PostModel post) async {
    final index = savedPosts.indexWhere((item) => item.id == post.id);
    final current = index >= 0 ? savedPosts[index] : post;
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
    final oldPosts = List<PostModel>.from(savedPosts);
    savedPosts.removeWhere((item) => item.id == post.id);

    try {
      final response = await _service.toggleBookmark(post.id);
      final result = response.data;
      if (result != null && result.isBookmarked) {
        _replacePost(post.copyWith(isBookmarked: true, bookmarkCount: result.newBookmarkCount));
      }
    } catch (error) {
      savedPosts.assignAll(oldPosts);
      _toast('خطأ', _cleanError(error));
    }
  }

  void _replacePost(PostModel updated) {
    final index = savedPosts.indexWhere((item) => item.id == updated.id);
    if (index >= 0) {
      savedPosts[index] = updated;
    } else if (updated.isBookmarked) {
      savedPosts.insert(0, updated);
    }
  }

  String _cleanError(Object error) => AppSnackbar.cleanError(error);

  void _toast(String title, String message) {
    AppSnackbar.show(title, message);
  }
}
