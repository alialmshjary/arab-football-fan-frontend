class ChatMemberModel {
  const ChatMemberModel({
    required this.chatMemberId,
    required this.fanId,
    required this.fanName,
    required this.joinedAt,
    required this.isModerator,
    required this.isMuted,
  });

  final int chatMemberId;
  final int fanId;
  final String fanName;
  final DateTime joinedAt;
  final bool isModerator;
  final bool isMuted;

  factory ChatMemberModel.fromJson(Map<String, dynamic> json) {
    return ChatMemberModel(
      chatMemberId: json['chatMemberId'],
      fanId: json['fanId'],
      fanName: (json['fanName'] ?? '').toString(),
      joinedAt: DateTime.parse(json['joinedAt']),
      isModerator: json['isModerator'] ?? false,
      isMuted: json['isMuted'] ?? false,
    );
  }
}