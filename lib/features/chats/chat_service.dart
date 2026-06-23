import 'package:signalr_netcore/signalr_client.dart';

import '../../core/network/api_client.dart';
import '../../core/constants/api_constants.dart';
import 'chat_model.dart';
import 'chat_message_model.dart';
import 'dart:io';
import 'package:http/http.dart' as http;

class ChatService {
  ChatService(this._apiClient);

  final ApiClient _apiClient;
  HubConnection? _hubConnection;

  Future<ChatModel> createPrivateChat({
    required int fan1Id,
    required int fan2Id,
  }) async {
    final response = await _apiClient.post<ChatModel>(
      '${ApiConstants.chats}/create-private',
      body: {'fan1Id': fan1Id, 'fan2Id': fan2Id},
      decoder: (json) => ChatModel.fromJson(json),
    );

    final data = response.data;

    if (data == null) {
      throw Exception('لم يتم استلام بيانات الشات');
    }

    return data;
  }

  Future<ChatModel> createGroupChat({
    required String title,
    required List<int> memberIds,
  }) async {
    final response = await _apiClient.post<ChatModel>(
      '${ApiConstants.chats}/create-group',
      body: {'title': title, 'memberIds': memberIds},
      decoder: (json) => ChatModel.fromJson(json),
    );

    final data = response.data;

    if (data == null) {
      throw Exception('لم يتم استلام بيانات الشات');
    }

    return data;
  }

  Future<List<ChatModel>> getMyChats() async {
    final response = await _apiClient.get<List<ChatModel>>(
      '${ApiConstants.chats}/my-chats',
      decoder: (json) {
        final list = json as List;

        return list.map((e) => ChatModel.fromJson(e)).toList();
      },
    );

    return response.data ?? [];
  }

  Future<ChatModel> getMatchChat(int matchId) async {
    final response = await _apiClient.get<ChatModel>(
      '${ApiConstants.chats}/match/$matchId',
      decoder: (json) => ChatModel.fromJson(json),
    );

    final data = response.data;

    if (data == null) {
      throw Exception('لم يتم استلام بيانات الشات');
    }

    return data;
  }

  Future<List<ChatMessageModel>> getMessages(int chatId) async {
    final response = await _apiClient.get<List<ChatMessageModel>>(
      '${ApiConstants.messages}/$chatId',
      decoder: (json) =>
          (json as List).map((e) => ChatMessageModel.fromJson(e)).toList(),
    );

    return response.data ?? [];
  }

  Future<void> connect({
    required String token,
    required void Function(ChatMessageModel message) onMessageReceived,
    required void Function(String error) onError,
  }) async {
    if (_hubConnection != null) {
      await disconnect();
    }

    _hubConnection = HubConnectionBuilder()
        .withUrl(
          '${ApiConstants.serverUrl}/chatHub',
          options: HttpConnectionOptions(accessTokenFactory: () async => token),
        )
        .build();

    _hubConnection!.on('ReceiveMessage', (arguments) {
      if (arguments == null || arguments.isEmpty) return;

      final json = Map<String, dynamic>.from(arguments[0] as Map);
      onMessageReceived(ChatMessageModel.fromJson(json));
    });

    _hubConnection!.on('Error', (arguments) {
      onError(arguments?.first.toString() ?? 'حدث خطأ في الشات');
    });

    try {
      await _hubConnection!.start();
    } catch (e) {
      await disconnect();
      onError('فشل الاتصال بالشات');
    }
  }

  Future<void> joinChat(int chatId) async {
    await _hubConnection?.invoke('JoinChat', args: [chatId]);
  }

  Future<void> leaveHubChat(int chatId) async {
    await _hubConnection?.invoke('LeaveChat', args: [chatId]);
  }

  Future<void> disconnect() async {
    await _hubConnection?.stop();
    _hubConnection = null;
  }

  Future<void> sendTextMessage({
    required int chatId,
    required String content,
  }) async {
    await _hubConnection?.invoke(
      'SendMessage',
      args: [
        {
          'chatId': chatId,
          'content': content,
          'attachmentUrl': null,
          'messageType': 0,
        },
      ],
    );
  }

  Future<void> sendMediaMessage({
    required int chatId,
    required String attachmentUrl,
    required int messageType,
  }) async {
    await _hubConnection?.invoke(
      'SendMessage',
      args: [
        {
          'chatId': chatId,
          'content': null,
          'attachmentUrl': attachmentUrl,
          'messageType': messageType,
        },
      ],
    );
  }

  Future<String> uploadAttachment(File file) async {
    final response = await _apiClient.multipart<String>(
      '${ApiConstants.messages}/upload',
      files: [await http.MultipartFile.fromPath('File', file.path)],
      decoder: (json) => json.toString(),
    );

    final data = response.data;

    if (data == null || data.isEmpty) {
      throw Exception('فشل رفع الملف');
    }

    return data;
  }

  Future<void> deleteMessage(int messageId) async {
    await _apiClient.delete<dynamic>('${ApiConstants.messages}/$messageId');
  }
}
