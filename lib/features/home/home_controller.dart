import 'package:get/get.dart';

class HomeController extends GetxController {
  final currentIndex = 0.obs;

  void setTab(int index) {
    if (index == 2) return;
    currentIndex.value = index;
  }
}
