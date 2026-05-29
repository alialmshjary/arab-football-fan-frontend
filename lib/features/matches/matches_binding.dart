import 'package:get/get.dart';

import '../../core/network/api_client.dart';
import 'matches_controller.dart';
import 'matches_service.dart';

class MatchBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ApiClient>()) {
      Get.put<ApiClient>(ApiClient(), permanent: true);
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
  }
}
