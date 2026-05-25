import '../../core/utils/date_time_utils.dart';

class CommentModel {
  const CommentModel({
    required this.id,
    required this.content,
    required this.createdAt,
    required this.fanId,
    required this.fanName,
    this.fanProfilePic,
  });

  final int id;
  final String content;
  final DateTime createdAt;
  final int fanId;
  final String fanName;
  final String? fanProfilePic;

  factory CommentModel.fromJson(Map<String, dynamic> json) {
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

    return CommentModel(
      id: readInt(['id', 'Id']),
      content: readString(['content', 'Content']),
      createdAt: DateTimeUtils.parseApiUtcDate(json['createdAt'] ?? json['CreatedAt']),
      fanId: readInt(['fanId', 'FanId']),
      fanName: readString(['fanName', 'FanName'], fallback: 'مشجع'),
      fanProfilePic: readString(['fanProfilePic', 'FanProfilePic']).trim().isEmpty ? null : readString(['fanProfilePic', 'FanProfilePic']),
    );
  }
}
