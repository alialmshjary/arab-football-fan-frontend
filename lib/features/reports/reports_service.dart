import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import 'create_report_dto.dart';

class ReportsService {
  ReportsService(this._api);

  final ApiClient _api;

  Future<void> createReport(CreateReportDto dto) async {
    await _api.post<dynamic>(
      ApiConstants.reports,
      body: dto.toJson(),
    );
  }
}