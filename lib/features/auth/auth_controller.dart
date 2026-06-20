import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../core/storage/storage_service.dart';
import 'auth_service.dart';
import '../../core/utils/app_snackbar.dart';

class AuthController extends GetxController {
  AuthController(this._service);

  final AuthService _service;

  final isLogin = true.obs;
  final isLoading = false.obs;
  final rememberMe = true.obs;
  final hidePassword = true.obs;
  final hideConfirmPassword = true.obs;

  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  String? _appliedRouteMode;

  @override
  void onReady() {
    super.onReady();
    applyRouteMode();
  }

  void applyRouteMode() {
    final args = Get.arguments;
    final mode = args is Map ? args['mode']?.toString() : null;
    if (mode == null || mode == _appliedRouteMode) return;

    _appliedRouteMode = mode;
    if (mode == 'register') {
      isLogin.value = false;
    } else if (mode == 'login') {
      isLogin.value = true;
    }
  }

  void toggleMode([bool? login]) {
    isLogin.value = login ?? !isLogin.value;

    passwordController.clear();
    confirmPasswordController.clear();

    hidePassword.value = true;
    hideConfirmPassword.value = true;
  }

  Future<void> submit() async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _toast('تنبيه', 'يرجى إدخال البريد الإلكتروني وكلمة المرور.');
      return;
    }

    if (!GetUtils.isEmail(email)) {
      _toast('تنبيه', 'صيغة البريد الإلكتروني غير صحيحة.');
      return;
    }

    if (!isLogin.value) {
      final username = usernameController.text.trim();

      if (username.isEmpty) {
        _toast('تنبيه', 'يرجى إدخال اسم المستخدم.');
        return;
      }

      if (password.length < 6) {
        _toast('تنبيه', 'كلمة المرور يجب أن تكون 6 أحرف على الأقل.');
        return;
      }

      if (password != confirmPasswordController.text) {
        _toast('تنبيه', 'كلمة المرور وتأكيدها غير متطابقين.');
        return;
      }
    }

    isLoading.value = true;

    try {
      final response = isLogin.value
          ? await _service.login(email: email, password: password)
          : await _service.register(
              username: usernameController.text.trim(),
              email: email,
              password: password,
            );

      final user = response.data;

      if (!response.isSuccess || user == null || user.token.isEmpty) {
        _toast(
          'لم تكتمل العملية',
          response.message.isNotEmpty
              ? response.message
              : 'تعذر تسجيل الدخول حاليًا. حاول مرة أخرى.',
        );
        return;
      }

      await StorageService.saveSession(
        token: user.token,
        userId: user.userId,
        username: user.username,
        email: user.email,
        role: user.role,
        remember: rememberMe.value,
      );

      _clearFields();

      Get.offAllNamed(Routes.home);
    } catch (error) {
      _toast('خطأ', error.toString().replaceFirst('Exception: ', ''));
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> continueAsGuest() async {
    await StorageService.saveGuestSession();
    _clearFields();
    Get.offAllNamed(Routes.home);
  }

  Future<void> logout() async {
    try {
      await _service.logout();
    } catch (_) {
      // حتى لو فشل تسجيل الخروج من الخدمة، نحذف الجلسة محلياً.
    }

    await StorageService.clearSession();

    _clearFields();

    isLogin.value = true;
    hidePassword.value = true;
    hideConfirmPassword.value = true;

    Get.offAllNamed(Routes.auth);
  }

  void _clearFields() {
    usernameController.clear();
    emailController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
  }

  void _toast(String title, String message) {
    AppSnackbar.show(title, message);
  }
}
