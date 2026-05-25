import '../../core/utils/date_time_utils.dart';

class PostModel {
  const PostModel({
    required this.id,
    this.caption,
    required this.mediaUrl,
    required this.mediaType,
    required this.likeCount,
    required this.commentCount,
    required this.bookmarkCount,
    required this.createdAt,
    required this.fanId,
    required this.fanDisplayName,
    this.fanProfilePicUrl,
    this.isLiked = false,
    this.isBookmarked = false,
  });

  final int id;
  final String? caption;
  final String mediaUrl;
  final String mediaType;
  final int likeCount;
  final int commentCount;
  final int bookmarkCount;
  final DateTime createdAt;
  final int fanId;
  final String fanDisplayName;
  final String? fanProfilePicUrl;
  final bool isLiked;
  final bool isBookmarked;

  bool get isVideo => mediaType.toLowerCase().contains('video');

  PostModel copyWith({
    String? caption,
    String? mediaUrl,
    String? mediaType,
    int? likeCount,
    int? commentCount,
    int? bookmarkCount,
    DateTime? createdAt,
    int? fanId,
    String? fanDisplayName,
    String? fanProfilePicUrl,
    bool? isLiked,
    bool? isBookmarked,
  }) {
    return PostModel(
      id: id,
      caption: caption ?? this.caption,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      mediaType: mediaType ?? this.mediaType,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      bookmarkCount: bookmarkCount ?? this.bookmarkCount,
      createdAt: createdAt ?? this.createdAt,
      fanId: fanId ?? this.fanId,
      fanDisplayName: fanDisplayName ?? this.fanDisplayName,
      fanProfilePicUrl: fanProfilePicUrl ?? this.fanProfilePicUrl,
      isLiked: isLiked ?? this.isLiked,
      isBookmarked: isBookmarked ?? this.isBookmarked,
    );
  }

  factory PostModel.fromJson(Map<String, dynamic> json) {
    int readInt(List<String> keys) {
      for (final key in keys) {
        final value = json[key];
        if (value is int) return value;
        final parsed = int.tryParse('$value');
        if (parsed != null) return parsed;
      }
      return 0;
    }

    String readString(List<String> keys, {String fallback = ''}) {
      for (final key in keys) {
        final value = json[key];
        if (value != null && value.toString().isNotEmpty) return value.toString();
      }
      return fallback;
    }

    String? readNullableString(List<String> keys) {
      final value = readString(keys).trim();
      return value.isEmpty ? null : value;
    }

    bool readBool(List<String> keys) {
      for (final key in keys) {
        final value = json[key];
        if (value is bool) return value;
        if (value is num) return value != 0;
        if (value is String) {
          final normalized = value.toLowerCase().trim();
          if (normalized == 'true') return true;
          if (normalized == 'false') return false;
        }
      }
      return false;
    }

    DateTime readDate() {
      final raw = json['createdAt'] ?? json['CreatedAt'];
      return DateTimeUtils.parseApiUtcDate(raw);
    }

    return PostModel(
      id: readInt(['id', 'Id']),
      caption: readNullableString(['caption', 'Caption']),
      mediaUrl: readString(['mediaUrl', 'MediaUrl']),
      mediaType: readString(['mediaType', 'MediaType'], fallback: 'Image'),
      likeCount: readInt(['likeCount', 'LikeCount']),
      commentCount: readInt(['commentCount', 'CommentCount']),
      bookmarkCount: readInt(['bookmarkCount', 'BookmarkCount']),
      createdAt: readDate(),
      fanId: readInt(['fanId', 'FanId']),
      fanDisplayName: readString(['fanDisplayName', 'FanDisplayName'], fallback: 'مشجع'),
      fanProfilePicUrl: readNullableString(['fanProfilePicUrl', 'FanProfilePicUrl']),
      isLiked: readBool(['isLiked', 'IsLiked']),
      isBookmarked: readBool(['isBookmarked', 'IsBookmarked']),
    );
  }
}

class LikeResult {
  const LikeResult({required this.isLiked, required this.newLikeCount});

  final bool isLiked;
  final int newLikeCount;

  factory LikeResult.fromJson(Map<String, dynamic> json) {
    return LikeResult(
      isLiked: (json['isLiked'] ?? json['IsLiked']) == true,
      newLikeCount: _readInt(json['newLikeCount'] ?? json['NewLikeCount']),
    );
  }
}

class BookmarkResult {
  const BookmarkResult({required this.isBookmarked, required this.newBookmarkCount});

  final bool isBookmarked;
  final int newBookmarkCount;

  factory BookmarkResult.fromJson(Map<String, dynamic> json) {
    return BookmarkResult(
      isBookmarked: (json['isBookmarked'] ?? json['IsBookmarked']) == true,
      newBookmarkCount: _readInt(json['newBookmarkCount'] ?? json['NewBookmarkCount']),
    );
  }
}

int _readInt(dynamic value) {
  if (value is int) return value;
  return int.tryParse('$value') ?? 0;
}
