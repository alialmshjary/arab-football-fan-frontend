import '../../core/utils/date_time_utils.dart';
import '../posts/post_model.dart';
import 'favorite_player.dart';
import 'favorite_team.dart';

class FanBasicProfile {
  const FanBasicProfile({
    required this.id,
    required this.username,
    required this.displayName,
    this.bio,
    this.profilePicUrl,
    this.favoriteTeamCode,
    this.favoritePlayerCode,
    required this.followersCount,
    required this.followingCount,
    required this.points,
    this.createdAt,
  });

  final int id;
  final String username;
  final String displayName;
  final String? bio;
  final String? profilePicUrl;
  final String? favoriteTeamCode;
  final String? favoritePlayerCode;
  final int followersCount;
  final int followingCount;
  final int points;
  final DateTime? createdAt;

  FavoriteTeam? get favoriteTeam => FavoriteTeamsCatalog.byCode(favoriteTeamCode);
  FavoritePlayer? get favoritePlayer => FavoritePlayersCatalog.byCode(favoritePlayerCode);

  factory FanBasicProfile.fromJson(Map<String, dynamic> json) {
    return FanBasicProfile(
      id: _readInt(json, ['id', 'Id', 'fanId', 'FanId']),
      username: _readString(json, ['username', 'Username']),
      displayName: _readString(json, ['displayName', 'DisplayName'], fallback: _readString(json, ['username', 'Username'])),
      bio: _readNullableString(json, ['bio', 'Bio']),
      profilePicUrl: _readNullableString(json, ['profilePicUrl', 'ProfilePicUrl', 'fanProfilePicUrl', 'FanProfilePicUrl']),
      favoriteTeamCode: _readNullableString(json, ['favoriteTeamCode', 'FavoriteTeamCode', 'favTeamCode', 'FavTeamCode', 'teamCode', 'TeamCode', 'favoriteTeam', 'FavoriteTeam']),
      favoritePlayerCode: _readNullableString(json, ['favoritePlayerCode', 'FavoritePlayerCode', 'favPlayerCode', 'FavPlayerCode', 'playerCode', 'PlayerCode', 'favoritePlayer', 'FavoritePlayer']),
      followersCount: _readInt(json, ['followersCount', 'FollowersCount']),
      followingCount: _readInt(json, ['followingCount', 'FollowingCount']),
      points: _readInt(json, ['points', 'Points']),
      createdAt: _readDate(json, ['createdAt', 'CreatedAt']),
    );
  }
}

class FanProfile extends FanBasicProfile {
  const FanProfile({
    required super.id,
    required super.username,
    required super.displayName,
    super.bio,
    super.profilePicUrl,
    super.favoriteTeamCode,
    super.favoritePlayerCode,
    required super.followersCount,
    required super.followingCount,
    required super.points,
    super.createdAt,
    required this.posts,
  });

  final List<PostModel> posts;

  factory FanProfile.fromJson(Map<String, dynamic> json) {
    final basic = FanBasicProfile.fromJson(json);
    final postsJson = json['posts'] ?? json['Posts'];
    return FanProfile(
      id: basic.id,
      username: basic.username,
      displayName: basic.displayName,
      bio: basic.bio,
      profilePicUrl: basic.profilePicUrl,
      favoriteTeamCode: basic.favoriteTeamCode,
      favoritePlayerCode: basic.favoritePlayerCode,
      followersCount: basic.followersCount,
      followingCount: basic.followingCount,
      points: basic.points,
      createdAt: basic.createdAt,
      posts: postsJson is List
          ? postsJson
              .whereType<Map>()
              .map((post) => PostModel.fromJson(Map<String, dynamic>.from(post)))
              .toList()
          : const [],
    );
  }
}

int _readInt(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is int) return value;
    final parsed = int.tryParse('$value');
    if (parsed != null) return parsed;
  }
  return 0;
}

String _readString(Map<String, dynamic> json, List<String> keys, {String fallback = ''}) {
  for (final key in keys) {
    final value = json[key];
    if (value != null && value.toString().trim().isNotEmpty) return value.toString();
  }
  return fallback;
}

String? _readNullableString(Map<String, dynamic> json, List<String> keys) {
  final value = _readString(json, keys);
  return value.trim().isEmpty ? null : value;
}

DateTime? _readDate(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value == null) continue;
    final parsed = DateTimeUtils.parseApiUtcDate(value, fallback: DateTime.fromMillisecondsSinceEpoch(0));
    if (parsed.millisecondsSinceEpoch != 0) return parsed;
  }
  return null;
}
