import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../core/storage/storage_service.dart';
import '../../core/utils/app_snackbar.dart';
import 'chat_member_model.dart';
import 'chat_members_service.dart';

class ChatMembersController extends GetxController {
  ChatMembersController(this._service);

  final ChatMembersService _service;

  final members = <ChatMemberModel>[].obs;

  final isLoading = false.obs;
  final isLeaving = false.obs;

  late final int chatId;
  late final String chatTitle;
  late final int chatType;

  @override
  void onInit() {
    super.onInit();

    final args = Get.arguments as Map<String, dynamic>;

    chatId = args['chatId'];
    chatTitle = args['chatTitle'] ?? '';
    chatType = args['chatType'] ?? 0;

    loadMembers();
  }

  Future<void> loadMembers() async {
    try {
      isLoading.value = true;

      final result = await _service.getChatMembers(chatId);

      members.assignAll(result);
    } catch (e) {
      AppSnackbar.show('خطأ', 'تعذر تحميل الأعضاء. تحقق من اتصالك وحاول مرة أخرى.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> leaveGroup() async {
    final fanId = StorageService.userId;

    if (fanId == null) {
      AppSnackbar.show('خطأ', 'يجب تسجيل الدخول أولًا');
      return;
    }

    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('الخروج من المجموعة'),
        content: const Text('هل أنت متأكد أنك تريد الخروج من هذه المجموعة؟'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('خروج'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      isLeaving.value = true;

      await _service.leaveChat(chatId: chatId, fanId: fanId);

      Get.offAllNamed(Routes.home);
      AppSnackbar.show('تم', 'خرجت من المجموعة');
    } catch (e) {
      AppSnackbar.show('خطأ', 'تعذر الخروج من المجموعة حاليًا. حاول مرة أخرى.');
    } finally {
      isLeaving.value = false;
    }
  }
}