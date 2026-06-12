import 'package:get/get.dart';

import '../../core/network/api_client.dart';
import 'chat_controller.dart';
import 'chat_list_controller.dart';
import 'chat_service.dart';

class ChatBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ApiClient>()) {
      Get.put<ApiClient>(ApiClient(), permanent: true);
    }

    if (!Get.isRegistered<ChatService>()) {
      Get.put<ChatService>(
        ChatService(Get.find<ApiClient>()),
        permanent: true,
      );
    }

    if (!Get.isRegistered<ChatListController>()) {
      Get.lazyPut<ChatListController>(
        () => ChatListController(Get.find<ChatService>()),
        fenix: true,
      );
    }

    Get.lazyPut<ChatController>(
      () => ChatController(Get.find<ChatService>()),
    );
  }
}