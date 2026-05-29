import '../../core/constants/api_constants.dart';
import '../../core/models/paginated_result.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_response.dart';
import 'match_model.dart';

class MatchesService {
  MatchesService(this._api);

  final ApiClient _api;

  Future<ApiResponse<PaginatedResult<MatchModel>>> getMatches({
    int pageNumber = 1,
    int pageSize = 10,
    String? search,
  }) {
    return _api.get<PaginatedResult<MatchModel>>(
      ApiConstants.matches,
      query: {
        'pageNumber': pageNumber,
        'pageSize': pageSize,
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
      },
      decoder: (json) => PaginatedResult<MatchModel>.fromJson(
        Map<String, dynamic>.from(json as Map),
        (item) => MatchModel.fromJson(Map<String, dynamic>.from(item as Map)),
      ),
    );
  }

  Future<ApiResponse<MatchModel>> getMatchById(int id) {
    return _api.get<MatchModel>(
      '${ApiConstants.matches}/$id',
      decoder: (json) =>
          MatchModel.fromJson(Map<String, dynamic>.from(json as Map)),
    );
  }
}
