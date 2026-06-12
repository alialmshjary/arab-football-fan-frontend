import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import 'chat_member_model.dart';

class ChatMembersService {
  ChatMembersService(this._apiClient);

  final ApiClient _apiClient;

  Future<List<ChatMemberModel>> getChatMembers(int chatId) async {
    final response = await _apiClient.get<List<ChatMemberModel>>(
      '${ApiConstants.chatMembers}/chats/$chatId',
      decoder: (json) {
        final list = json as List;
        return list.map((e) => ChatMemberModel.fromJson(e)).toList();
      },
    );

    return response.data ?? [];
  }

  Future<void> leaveChat({required int chatId, required int fanId}) async {
    await _apiClient.delete<void>(
      '${ApiConstants.chatMembers}/chats/$chatId/members/$fanId/leave',
    );
  }

}
