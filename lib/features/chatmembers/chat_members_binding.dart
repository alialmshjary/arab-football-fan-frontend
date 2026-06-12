import 'package:get/get.dart';

import '../../core/network/api_client.dart';
import 'chat_members_controller.dart';
import 'chat_members_service.dart';

class ChatMembersBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ApiClient>()) {
      Get.put<ApiClient>(ApiClient(), permanent: true);
    }

    if (!Get.isRegistered<ChatMembersService>()) {
      Get.put<ChatMembersService>(
        ChatMembersService(Get.find<ApiClient>()),
        permanent: true,
      );
    }

    Get.lazyPut<ChatMembersController>(
      () => ChatMembersController(Get.find<ChatMembersService>()),
    );
  }
}