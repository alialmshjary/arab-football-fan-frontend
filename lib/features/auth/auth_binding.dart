import 'package:get/get.dart';

import '../../core/network/api_client.dart';
import 'auth_controller.dart';
import 'auth_service.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ApiClient>()) {
      Get.put<ApiClient>(ApiClient(), permanent: true);
    }

    if (!Get.isRegistered<AuthService>()) {
      Get.put<AuthService>(AuthService(Get.find<ApiClient>()), permanent: true);
    }

    if (!Get.isRegistered<AuthController>()) {
      Get.lazyPut<AuthController>(
        () => AuthController(Get.find<AuthService>()),
        fenix: true,
      );
    }
  }
}
