import 'package:http/http.dart' as http;

import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_response.dart';
import 'fan_model.dart';

class FansService {
  FansService(this._api);

  final ApiClient _api;

  Future<ApiResponse<FanProfile>> getProfile(int fanId) {
    return _api.get<FanProfile>(
      '${ApiConstants.fans}/$fanId',
      decoder: (json) => FanProfile.fromJson(Map<String, dynamic>.from(json as Map)),
    );
  }

  Future<ApiResponse<FanBasicProfile>> updateProfile({
    String? displayName,
    String? bio,
    String? imagePath,
    String? favoriteTeamCode,
    String? favoritePlayerCode,
    bool includeFavoriteTeam = false,
    bool includeFavoritePlayer = false,
  }) async {
    final files = <http.MultipartFile>[];
    if (imagePath != null && imagePath.isNotEmpty) {
      files.add(await http.MultipartFile.fromPath('ProfileImage', imagePath));
    }

    final fields = <String, String>{};
    if (displayName != null) fields['DisplayName'] = displayName.trim();
    if (bio != null) fields['Bio'] = bio.trim();

    // The backend receives UpdateFanProfileDto using [FromForm].
    // Send an empty string when the user clears a favorite value, and omit
    // the field when it should remain unchanged.
    if (includeFavoriteTeam) fields['FavoriteTeamCode'] = favoriteTeamCode?.trim() ?? '';
    if (includeFavoritePlayer) fields['FavoritePlayerCode'] = favoritePlayerCode?.trim() ?? '';

    return _api.multipart<FanBasicProfile>(
      '${ApiConstants.fans}/me',
      method: 'PATCH',
      fields: fields,
      files: files,
      decoder: (json) => FanBasicProfile.fromJson(Map<String, dynamic>.from(json as Map)),
    );
  }

  Future<ApiResponse<List<FanBasicProfile>>> searchFans(String query) {
    return _api.get<List<FanBasicProfile>>(
      '${ApiConstants.fans}/search',
      query: {'query': query},
      decoder: _decodeFanList,
    );
  }

  Future<ApiResponse<List<FanBasicProfile>>> getFollowers(int fanId) {
    return _api.get<List<FanBasicProfile>>(
      '${ApiConstants.fans}/$fanId/followers',
      decoder: _decodeFanList,
    );
  }

  Future<ApiResponse<List<FanBasicProfile>>> getFollowing(int fanId) {
    return _api.get<List<FanBasicProfile>>(
      '${ApiConstants.fans}/$fanId/following',
      decoder: _decodeFanList,
    );
  }

  Future<ApiResponse<bool>> isFollowing(int targetId) {
    return _api.get<bool>('${ApiConstants.fans}/$targetId/is-following');
  }

  Future<void> follow(int targetId) async {
    await _api.post<dynamic>('${ApiConstants.fans}/$targetId/follow');
  }

  Future<void> unfollow(int targetId) async {
    await _api.delete<dynamic>('${ApiConstants.fans}/$targetId/unfollow');
  }

  List<FanBasicProfile> _decodeFanList(dynamic json) {
    return (json as List)
        .whereType<Map>()
        .map((item) => FanBasicProfile.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }
}
