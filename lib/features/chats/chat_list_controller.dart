import 'package:get/get.dart';

import '../../core/storage/storage_service.dart';
import 'chat_model.dart';
import 'chat_service.dart';

class ChatListController extends GetxController {
  ChatListController(this._service);

  final ChatService _service;

  final chats = <ChatModel>[].obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchChats();
  }

  Future<void> fetchChats() async {
    if (StorageService.isGuest) {
      chats.clear();
      errorMessage.value = 'يجب تسجيل الدخول لعرض المحادثات';
      isLoading.value = false;
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';

      final result = await _service.getMyChats();

      chats.assignAll(
        result
            .where((chat) => chat.chatType == 1 || chat.chatType == 2)
            .toList(),
      );
    } catch (e) {
      errorMessage.value = 'تعذر تحميل المحادثات';
    } finally {
      isLoading.value = false;
    }
  }
}
