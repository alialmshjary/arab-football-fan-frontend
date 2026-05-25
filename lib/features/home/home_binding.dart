import 'package:get/get.dart';

import '../../core/network/api_client.dart';
import '../auth/auth_controller.dart';
import '../auth/auth_service.dart';
import '../comments/comments_controller.dart';
import '../comments/comments_service.dart';
import '../fans/fans_controller.dart';
import '../fans/fans_service.dart';
import '../posts/posts_controller.dart';
import '../posts/posts_service.dart';
import 'home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ApiClient>()) {
      Get.put<ApiClient>(ApiClient(), permanent: true);
    }
    if (!Get.isRegistered<AuthService>()) {
      Get.lazyPut<AuthService>(() => AuthService(Get.find<ApiClient>()), fenix: true);
    }
    if (!Get.isRegistered<AuthController>()) {
      Get.lazyPut<AuthController>(() => AuthController(Get.find<AuthService>()), fenix: true);
    }
    if (!Get.isRegistered<FansService>()) {
      Get.lazyPut<FansService>(() => FansService(Get.find<ApiClient>()), fenix: true);
    }
    if (!Get.isRegistered<FansController>()) {
      Get.lazyPut<FansController>(() => FansController(Get.find<FansService>()), fenix: true);
    }
    if (!Get.isRegistered<PostsService>()) {
      Get.lazyPut<PostsService>(() => PostsService(Get.find<ApiClient>()), fenix: true);
    }
    if (!Get.isRegistered<PostsController>()) {
      Get.lazyPut<PostsController>(() => PostsController(Get.find<PostsService>()), fenix: true);
    }
    if (!Get.isRegistered<CommentsService>()) {
      Get.lazyPut<CommentsService>(() => CommentsService(Get.find<ApiClient>()), fenix: true);
    }
    if (!Get.isRegistered<CommentsController>()) {
      Get.lazyPut<CommentsController>(() => CommentsController(Get.find<CommentsService>()), fenix: true);
    }
    if (!Get.isRegistered<HomeController>()) {
      Get.lazyPut<HomeController>(() => HomeController(), fenix: true);
    }
  }
}
