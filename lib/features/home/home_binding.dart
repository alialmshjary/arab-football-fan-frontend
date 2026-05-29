import 'package:get/get.dart';

import '../../core/network/api_client.dart';
import '../auth/auth_controller.dart';
import '../auth/auth_service.dart';
import '../matches/matches_controller.dart';
import '../matches/matches_service.dart';
import 'home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ApiClient>()) {
      Get.put<ApiClient>(ApiClient(), permanent: true);
    }
    if (!Get.isRegistered<AuthService>()) {
      Get.lazyPut<AuthService>(
        () => AuthService(Get.find<ApiClient>()),
        fenix: true,
      );
    }
    if (!Get.isRegistered<AuthController>()) {
      Get.lazyPut<AuthController>(
        () => AuthController(Get.find<AuthService>()),
        fenix: true,
      );
    }
    if (!Get.isRegistered<MatchesService>()) {
      Get.lazyPut<MatchesService>(
        () => MatchesService(Get.find<ApiClient>()),
        fenix: true,
      );
    }
    if (!Get.isRegistered<MatchesController>()) {
      Get.lazyPut<MatchesController>(
        () => MatchesController(Get.find<MatchesService>()),
        fenix: true,
      );
    }
    if (!Get.isRegistered<HomeController>()) {
      Get.lazyPut<HomeController>(() => HomeController(), fenix: true);
    }
  }
}
