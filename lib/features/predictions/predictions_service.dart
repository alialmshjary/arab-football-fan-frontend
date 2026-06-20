import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_response.dart';
import 'prediction_model.dart';

class PredictionsService {
  PredictionsService(this._api);

  final ApiClient _api;

  Future<ApiResponse<PredictionModel>> submitPrediction({
    required int matchId,
    required int homeScore,
    required int awayScore,
  }) {
    return _api.post<PredictionModel>(
      '${ApiConstants.predictions}/submit',
      body: {
        'matchId': matchId,
        'homeScore': homeScore,
        'awayScore': awayScore,
      },
      decoder: (json) =>
          PredictionModel.fromJson(Map<String, dynamic>.from(json as Map)),
    );
  }

  Future<ApiResponse<List<PredictionModel>>> getMyPredictions() {
    return _api.get<List<PredictionModel>>(
      '${ApiConstants.predictions}/me',
      decoder: (json) {
        final list = json as List;
        return list
            .map(
              (item) => PredictionModel.fromJson(
                Map<String, dynamic>.from(item as Map),
              ),
            )
            .toList();
      },
    );
  }

  Future<PredictionModel?> getMyPredictionForMatch(int matchId) async {
    final response = await getMyPredictions();
    final predictions = response.data ?? [];

    for (final prediction in predictions) {
      if (prediction.matchId == matchId) {
        return prediction;
      }
    }

    return null;
  }
}
