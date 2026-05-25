import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_response.dart';
import '../posts/post_model.dart';

class BookmarksService {
  BookmarksService(this._api);

  final ApiClient _api;

  Future<ApiResponse<List<PostModel>>> getSavedPosts() {
    return _api.get<List<PostModel>>(
      '${ApiConstants.bookmarks}/me',
      decoder: (json) => (json as List)
          .whereType<Map>()
          .map((item) => PostModel.fromJson(Map<String, dynamic>.from(item)))
          .toList(),
    );
  }

  Future<ApiResponse<BookmarkResult>> toggleBookmark(int postId) {
    return _api.post<BookmarkResult>(
      '${ApiConstants.bookmarks}/toggle/$postId',
      decoder: (json) => BookmarkResult.fromJson(Map<String, dynamic>.from(json as Map)),
    );
  }

  Future<ApiResponse<LikeResult>> toggleLike(int postId) {
    return _api.post<LikeResult>(
      '${ApiConstants.likes}/toggle/$postId',
      decoder: (json) => LikeResult.fromJson(Map<String, dynamic>.from(json as Map)),
    );
  }
}
