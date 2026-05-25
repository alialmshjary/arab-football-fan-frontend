import 'package:get/get.dart';

import '../../core/network/api_client.dart';
import 'bookmarks_controller.dart';
import 'bookmarks_service.dart';

class BookmarksBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ApiClient>()) {
      Get.put<ApiClient>(ApiClient(), permanent: true);
    }
    if (!Get.isRegistered<BookmarksService>()) {
      Get.lazyPut<BookmarksService>(() => BookmarksService(Get.find<ApiClient>()), fenix: true);
    }
    if (!Get.isRegistered<BookmarksController>()) {
      Get.lazyPut<BookmarksController>(() => BookmarksController(Get.find<BookmarksService>()), fenix: true);
    }
  }
}
