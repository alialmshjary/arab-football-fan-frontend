import 'package:http/http.dart' as http;

import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_response.dart';
import 'post_model.dart';

class PostsService {
  PostsService(this._api);

  final ApiClient _api;

  Future<ApiResponse<List<PostModel>>> getFeed() {
    return _api.get<List<PostModel>>(
      '${ApiConstants.posts}/feed',
      decoder: (json) => (json as List)
          .whereType<Map>()
          .map((item) => PostModel.fromJson(Map<String, dynamic>.from(item)))
          .toList(),
    );
  }

  Future<ApiResponse<PostModel>> getPostById(int postId) {
    return _api.get<PostModel>(
      '${ApiConstants.posts}/$postId',
      decoder: (json) => PostModel.fromJson(Map<String, dynamic>.from(json as Map)),
    );
  }

  Future<ApiResponse<PostModel>> createPost({required String caption, required String mediaPath}) async {
    return _api.multipart<PostModel>(
      ApiConstants.posts,
      fields: {'Caption': caption.trim()},
      files: [await http.MultipartFile.fromPath('MediaFile', mediaPath)],
      decoder: (json) => PostModel.fromJson(Map<String, dynamic>.from(json as Map)),
    );
  }

  Future<ApiResponse<PostModel>> updatePost({required int postId, required String caption, String? mediaPath}) async {
    return _api.multipart<PostModel>(
      '${ApiConstants.posts}/$postId',
      method: 'PATCH',
      fields: {'Caption': caption.trim()},
      files: mediaPath == null || mediaPath.isEmpty ? const [] : [await http.MultipartFile.fromPath('Media', mediaPath)],
      decoder: (json) => PostModel.fromJson(Map<String, dynamic>.from(json as Map)),
    );
  }

  Future<void> deletePost(int postId) async {
    await _api.delete<dynamic>('${ApiConstants.posts}/$postId');
  }

  Future<ApiResponse<LikeResult>> toggleLike(int postId) {
    return _api.post<LikeResult>(
      '${ApiConstants.likes}/toggle/$postId',
      decoder: (json) => LikeResult.fromJson(Map<String, dynamic>.from(json as Map)),
    );
  }

  Future<ApiResponse<BookmarkResult>> toggleBookmark(int postId) {
    return _api.post<BookmarkResult>(
      '${ApiConstants.bookmarks}/toggle/$postId',
      decoder: (json) => BookmarkResult.fromJson(Map<String, dynamic>.from(json as Map)),
    );
  }
}
