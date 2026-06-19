import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constants/app_colors.dart';
import '../../core/widgets/app_chrome.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_text_field.dart';
import 'auth_controller.dart';

class AuthScreen extends GetView<AuthController> {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) => controller.applyRouteMode());
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Obx(() {
          final login = controller.isLogin.value;
          return Column(
            children: [
              const SaduStrip(height: 24),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(22, 22, 22, 28),
                  child: Column(
                    children: [
                      const SizedBox(height: 6),
                      const MadrajLogo(size: 72, showTitle: false),
                      const SizedBox(height: 12),
                      const Text(
                        'مدرج',
                        style: TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w900,
                          height: 1,
                        ),
                      ),
                      const SizedBox(height: 7),
                      const Text(
                        'حيث يجتمع الشغف',
                        style: TextStyle(
                          color: AppColors.red,
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 26),
                      MadrajCard(
                        padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
                        child: Column(
                          children: [
                            Text(
                              login ? 'مرحباً بعودتك' : 'إنشاء حساب جديد',
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 24,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              login
                                  ? 'سجل دخولك لمتابعة فريقك ومجتمعك'
                                  : 'انضم إلى جمهور مدرج وابدأ التفاعل',
                              style: const TextStyle(
                                color: AppColors.muted,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 220),
                              child: login
                                  ? const SizedBox.shrink(
                                      key: ValueKey('login_name_empty'),
                                    )
                                  : Column(
                                      key: const ValueKey(
                                        'register_name_field',
                                      ),
                                      children: [
                                        CustomTextField(
                                          controller:
                                              controller.usernameController,
                                          hint: 'اسم المستخدم',
                                          icon: Icons.person_outline,
                                          textInputAction: TextInputAction.next,
                                        ),
                                        const SizedBox(height: 12),
                                      ],
                                    ),
                            ),
                            CustomTextField(
                              controller: controller.emailController,
                              hint: 'البريد الإلكتروني',
                              icon: Icons.alternate_email_rounded,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                            ),
                            const SizedBox(height: 12),
                            CustomTextField(
                              controller: controller.passwordController,
                              hint: 'كلمة المرور',
                              icon: Icons.lock_outline,
                              obscureText: controller.hidePassword.value,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  controller.hidePassword.value
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                ),
                                onPressed: () =>
                                    controller.hidePassword.toggle(),
                              ),
                              textInputAction: login
                                  ? TextInputAction.done
                                  : TextInputAction.next,
                            ),
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 220),
                              child: login
                                  ? const SizedBox.shrink(
                                      key: ValueKey('confirm_empty'),
                                    )
                                  : Column(
                                      key: const ValueKey('confirm_field'),
                                      children: [
                                        const SizedBox(height: 12),
                                        CustomTextField(
                                          controller: controller
                                              .confirmPasswordController,
                                          hint: 'تأكيد كلمة المرور',
                                          icon: Icons.lock_outline,
                                          obscureText: controller
                                              .hideConfirmPassword
                                              .value,
                                          suffixIcon: IconButton(
                                            icon: Icon(
                                              controller
                                                      .hideConfirmPassword
                                                      .value
                                                  ? Icons.visibility_outlined
                                                  : Icons
                                                        .visibility_off_outlined,
                                            ),
                                            onPressed: () => controller
                                                .hideConfirmPassword
                                                .toggle(),
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                            if (login) ...[
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Checkbox(
                                    value: controller.rememberMe.value,
                                    activeColor: AppColors.red,
                                    onChanged: (value) =>
                                        controller.rememberMe.value =
                                            value ?? true,
                                  ),
                                  const Text(
                                    'تذكرني',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const Spacer(),
                                ],
                              ),
                            ],
                            const SizedBox(height: 14),
                            CustomButton(
                              label: login ? 'تسجيل الدخول' : 'إنشاء حساب',
                              isLoading: controller.isLoading.value,
                              onPressed: controller.submit,
                            ),
                            const SizedBox(height: 18),
                            Row(
                              children: [
                                const Expanded(child: Divider()),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                  child: Text(
                                    login ? 'أو' : 'لديك حساب بالفعل؟',
                                    style: const TextStyle(
                                      color: AppColors.muted,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                const Expanded(child: Divider()),
                              ],
                            ),
                            const SizedBox(height: 18),
                            CustomButton(
                              label: login ? 'إنشاء حساب جديد' : 'تسجيل الدخول',
                              isOutlined: true,
                              onPressed: () => controller.toggleMode(!login),
                            ),
                            if (login) ...[
                              const SizedBox(height: 10),
                              TextButton.icon(
                                onPressed: controller.isLoading.value ? null : controller.continueAsGuest,
                                icon: const Icon(Icons.visibility_outlined, color: AppColors.red),
                                label: const Text(
                                  'الدخول كضيف',
                                  style: TextStyle(
                                    color: AppColors.red,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                    ],
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
