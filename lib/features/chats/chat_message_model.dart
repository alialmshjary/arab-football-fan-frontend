import '../../core/utils/date_time_utils.dart';
class ChatMessageModel {
  const ChatMessageModel({
    required this.messageId,
    required this.chatId,
    required this.senderId,
    this.senderName,
    required this.content,
    required this.messageType,
    required this.createdAt,
    this.attachmentUrl,
    this.isRead = false,
  });

  final int messageId;
  final int? senderId;
  final String? senderName;
  final int chatId;
  final String? content;
  final String? attachmentUrl;
  final int messageType;
  final DateTime createdAt;
  final bool isRead;

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      messageId: json['messageId'],
      senderId: json['senderId'],
      senderName: json['senderName'],
      chatId: json['chatId'],
      content: json['content'],
      attachmentUrl: json['attachmentUrl'],
      messageType: json['messageType'],
      createdAt: DateTimeUtils.parseApiUtcDate(json['createdAt']),
      isRead: json['isRead'] ?? false,
    );
  }
}