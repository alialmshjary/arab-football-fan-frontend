import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_response.dart';
import 'comment_model.dart';

class CommentsService {
  CommentsService(this._api);

  final ApiClient _api;

  Future<ApiResponse<List<CommentModel>>> getPostComments(int postId) {
    return _api.get<List<CommentModel>>(
      '${ApiConstants.comments}/post/$postId',
      decoder: (json) => (json as List)
          .whereType<Map>()
          .map((item) => CommentModel.fromJson(Map<String, dynamic>.from(item)))
          .toList(),
    );
  }

  Future<ApiResponse<CommentModel>> addComment({required int postId, required String content}) {
    return _api.post<CommentModel>(
      ApiConstants.comments,
      body: {'postId': postId, 'content': content.trim()},
      decoder: (json) => CommentModel.fromJson(Map<String, dynamic>.from(json as Map)),
    );
  }

  Future<void> deleteComment(int commentId) async {
    await _api.delete<dynamic>('${ApiConstants.comments}/$commentId');
  }
}
