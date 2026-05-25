import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

import '../../features/fans/favorite_player.dart';
import '../../features/fans/favorite_team.dart';

class StorageService {
  StorageService._();

  static final GetStorage _box = GetStorage();

  static const String _tokenKey = 'auth_token';
  static const String _userIdKey = 'auth_user_id';
  static const String _usernameKey = 'auth_username';
  static const String _emailKey = 'auth_email';
  static const String _roleKey = 'auth_role';
  static const String _rememberKey = 'remember_me';
  static const String _favoriteTeamKey = 'favorite_team';
  static const String _favoritePlayerKey = 'favorite_player';
  static const String _themeModeKey = 'theme_mode';

  static String? get token => _box.read<String>(_tokenKey);
  static int? get userId => _box.read<int>(_userIdKey);
  static String? get username => _box.read<String>(_usernameKey);
  static String? get email => _box.read<String>(_emailKey);
  static String? get role => _box.read<String>(_roleKey);
  static bool get rememberMe => _box.read<bool>(_rememberKey) ?? true;

  static FavoriteTeam? get favoriteTeam {
    final stored = _box.read(_favoriteTeamKey);
    if (stored is Map) {
      return FavoriteTeam.fromJson(Map<String, dynamic>.from(stored));
    }
    if (stored is String) {
      return FavoriteTeamsCatalog.byCode(stored);
    }
    return null;
  }

  static FavoritePlayer? get favoritePlayer {
    final stored = _box.read(_favoritePlayerKey);
    if (stored is Map) {
      return FavoritePlayer.fromJson(Map<String, dynamic>.from(stored));
    }
    if (stored is String) {
      return FavoritePlayersCatalog.byCode(stored);
    }
    return null;
  }

  static ThemeMode get themeMode {
    final value = (_box.read<String>(_themeModeKey) ?? 'light').toLowerCase();
    switch (value) {
      case 'dark':
        return ThemeMode.dark;
      case 'system':
        return ThemeMode.system;
      default:
        return ThemeMode.light;
    }
  }

  static String get themeModeName {
    final mode = themeMode;
    if (mode == ThemeMode.dark) return 'dark';
    if (mode == ThemeMode.system) return 'system';
    return 'light';
  }

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

  static Future<void> saveFavoriteTeam(FavoriteTeam team) async {
    await _box.write(_favoriteTeamKey, team.toJson());
  }

  static Future<void> clearFavoriteTeam() async {
    await _box.remove(_favoriteTeamKey);
  }

  static Future<void> saveFavoritePlayer(FavoritePlayer player) async {
    await _box.write(_favoritePlayerKey, player.toJson());
  }

  static Future<void> clearFavoritePlayer() async {
    await _box.remove(_favoritePlayerKey);
  }

  static Future<void> saveThemeMode(ThemeMode mode) async {
    final value = mode == ThemeMode.dark
        ? 'dark'
        : mode == ThemeMode.system
            ? 'system'
            : 'light';
    await _box.write(_themeModeKey, value);
  }

  static Future<void> clearSession() async {
    await _box.remove(_tokenKey);
    await _box.remove(_userIdKey);
    await _box.remove(_usernameKey);
    await _box.remove(_emailKey);
    await _box.remove(_roleKey);
  }
}
