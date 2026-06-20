import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../constants/app_colors.dart';
import '../storage/storage_service.dart';

class AuthGuard {
  AuthGuard._();

  static bool get canInteract => StorageService.canInteract;

  static bool requireLogin({
    String message = 'يجب عليك تسجيل الدخول أولاً للاستفادة من هذه الميزة.',
  }) {
    if (canInteract) return true;
    showLoginRequiredDialog(message: message);
    return false;
  }

  static Future<void> showLoginRequiredDialog({
    String message = 'يجب عليك تسجيل الدخول أولاً.',
  }) async {
    await Get.dialog<void>(
      AlertDialog(
        title: const Text('يجب تسجيل الدخول'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Get.back<void>();
              Get.offAllNamed(Routes.auth, arguments: {'mode': 'register'});
            },
            child: const Text('إنشاء حساب'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Get.back<void>();
              Get.offAllNamed(Routes.auth, arguments: {'mode': 'login'});
            },
            child: const Text('تسجيل الدخول'),
          ),
        ],
      ),
    );
  }
}
