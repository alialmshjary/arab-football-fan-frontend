import 'package:get_storage/get_storage.dart';

class StorageService {
  StorageService._();

  static final GetStorage _box = GetStorage();

  static const String _tokenKey = 'auth_token';
  static const String _userIdKey = 'auth_user_id';
  static const String _usernameKey = 'auth_username';
  static const String _emailKey = 'auth_email';
  static const String _roleKey = 'auth_role';
  static const String _rememberKey = 'remember_me';

  static String? get token => _box.read<String>(_tokenKey);
  static int? get userId => _box.read<int>(_userIdKey);
  static String? get username => _box.read<String>(_usernameKey);
  static String? get email => _box.read<String>(_emailKey);
  static String? get role => _box.read<String>(_roleKey);
  static bool get rememberMe => _box.read<bool>(_rememberKey) ?? true;

  static bool get isLoggedIn {
    final savedToken = token;
    return savedToken != null && savedToken.isNotEmpty;
  }

  static Future<void> saveSession({
    required String token,
    required int userId,
    required String username,
    required String email,
    required String role,
    bool remember = true,
  }) async {
    await _box.write(_tokenKey, token);
    await _box.write(_userIdKey, userId);
    await _box.write(_usernameKey, username);
    await _box.write(_emailKey, email);
    await _box.write(_roleKey, role);
    await _box.write(_rememberKey, remember);
  }

  static Future<void> clearSession() async {
    await _box.remove(_tokenKey);
    await _box.remove(_userIdKey);
    await _box.remove(_usernameKey);
    await _box.remove(_emailKey);
    await _box.remove(_roleKey);
  }
}
