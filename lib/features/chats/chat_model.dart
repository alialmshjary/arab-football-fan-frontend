import '../../core/utils/date_time_utils.dart';

class ChatModel {
  const ChatModel({
    required this.id,
    required this.title,
    required this.chatType,
    required this.createdAt,
    this.lastMessage,
    this.lastMessageAt,
    this.lastMessageType,
  });

  final int id;
  final String? title;
  final int chatType;
  final DateTime createdAt;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final int? lastMessageType;

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(
      id: json['id'],
      title: json['title'],
      chatType: json['chatType'],
      createdAt: DateTimeUtils.parseApiUtcDate(json['createdAt']),
      lastMessage: json['lastMessage'],
      lastMessageAt: json['lastMessageAt'] != null
          ? DateTimeUtils.parseApiUtcDate(json['lastMessageAt'])
          : null,
      lastMessageType: json['lastMessageType'],
    );
  }
}
