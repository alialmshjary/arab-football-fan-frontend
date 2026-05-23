import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_response.dart';
import 'auth_model.dart';

class AuthService {
  AuthService(this._api);

  final ApiClient _api;

  Future<ApiResponse<AuthUser>> login({required String email, required String password}) {
    return _api.post<AuthUser>(
      '${ApiConstants.auth}/login',
      body: {
        'email': email.trim(),
        'password': password,
      },
      decoder: (json) => AuthUser.fromJson(Map<String, dynamic>.from(json as Map)),
    );
  }

  Future<ApiResponse<AuthUser>> register({required String username, required String email, required String password}) {
    return _api.post<AuthUser>(
      '${ApiConstants.auth}/register',
      body: {
        'username': username.trim(),
        'email': email.trim(),
        'password': password,
      },
      decoder: (json) => AuthUser.fromJson(Map<String, dynamic>.from(json as Map)),
    );
  }

  Future<void> logout() async {
    try {
      await _api.post<bool>('${ApiConstants.auth}/logout');
    } catch (_) {
      // الجلسة المحلية ستنحذف حتى لو كان السيرفر غير متاح.
    }
  }
}
