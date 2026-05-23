import 'package:get/get.dart';

import '../../core/network/api_client.dart';
import '../../features/auth/auth_controller.dart';
import '../../features/auth/auth_service.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<ApiClient>(ApiClient(), permanent: true);
    Get.lazyPut<AuthService>(() => AuthService(Get.find<ApiClient>()), fenix: true);
    Get.lazyPut<AuthController>(() => AuthController(Get.find<AuthService>()), fenix: true);
  }
}
