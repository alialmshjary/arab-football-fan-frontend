import 'package:get/get.dart';

import '../../core/network/api_client.dart';
import 'comments_controller.dart';
import 'comments_service.dart';

class CommentsBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ApiClient>()) {
      Get.put<ApiClient>(ApiClient(), permanent: true);
    }
    if (!Get.isRegistered<CommentsService>()) {
      Get.lazyPut<CommentsService>(() => CommentsService(Get.find<ApiClient>()), fenix: true);
    }
    if (!Get.isRegistered<CommentsController>()) {
      Get.lazyPut<CommentsController>(() => CommentsController(Get.find<CommentsService>()), fenix: true);
    }
  }
}
