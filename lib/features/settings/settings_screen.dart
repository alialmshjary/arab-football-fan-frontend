import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../core/constants/app_colors.dart';
import '../../core/storage/storage_service.dart';
import '../../core/widgets/app_chrome.dart';
import '../auth/auth_controller.dart';
import '../auth/auth_service.dart';
import '../fans/fans_controller.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late ThemeMode themeMode;

  @override
  void initState() {
    super.initState();
    themeMode = StorageService.themeMode;
  }

  Future<void> _setTheme(ThemeMode mode) async {
    setState(() => themeMode = mode);
    await StorageService.saveThemeMode(mode);
    Get.changeThemeMode(mode);
  }

  Future<void> _copyUserId(String id) async {
    if (id.trim().isEmpty || id == 'غير متوفر') return;
    await Clipboard.setData(ClipboardData(text: id));
    Get.snackbar(
      'تم النسخ',
      'تم نسخ ID المستخدم.',
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 14,
      backgroundColor: Colors.black87,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  Future<void> _logout() async {
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('تسجيل الخروج؟'),
        content: const Text('سيتم إنهاء الجلسة الحالية والرجوع إلى شاشة الدخول.'),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: const Text('إلغاء')),
          TextButton(onPressed: () => Get.back(result: true), child: const Text('تسجيل الخروج')),
        ],
      ),
    );
    if (confirm != true) return;

    if (Get.isRegistered<AuthService>()) {
      try {
        await Get.find<AuthService>().logout();
      } catch (_) {}
    }
    await StorageService.clearSession();
    if (Get.isRegistered<AuthController>()) {
      Get.delete<AuthController>(force: true);
    }
    Get.offAllNamed(Routes.auth);
  }

  @override
  Widget build(BuildContext context) {
    final email = StorageService.email?.trim().isNotEmpty == true ? StorageService.email!.trim() : 'غير متوفر';
    final username = StorageService.username?.trim().isNotEmpty == true ? StorageService.username!.trim() : 'مشجع مدرج';
    final profile = Get.isRegistered<FansController>() ? Get.find<FansController>().profile.value : null;
    final userId = StorageService.userId ?? profile?.id;
    final userIdText = userId == null || userId == 0 ? 'غير متوفر' : '$userId';

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppScreenHeader(
        title: 'الإعدادات',
        leading: IconButton(onPressed: Get.back, icon: const Icon(Icons.arrow_back_ios_new_rounded)),
        actions: const [],
      ),
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          MadrajCard(
            child: Row(
              children: [
                const CircleAvatar(radius: 26, backgroundColor: AppColors.red, child: Icon(Icons.person_rounded, color: Colors.white)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(username, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                      const SizedBox(height: 4),
                      Text(email, style: const TextStyle(color: AppColors.muted, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          MadrajCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('ثيم التطبيق', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                const SizedBox(height: 12),
                _ThemeOption(
                  title: 'فاتح',
                  icon: Icons.light_mode_outlined,
                  selected: themeMode == ThemeMode.light,
                  onTap: () => _setTheme(ThemeMode.light),
                ),
                _ThemeOption(
                  title: 'داكن',
                  icon: Icons.dark_mode_outlined,
                  selected: themeMode == ThemeMode.dark,
                  onTap: () => _setTheme(ThemeMode.dark),
                ),
                _ThemeOption(
                  title: 'حسب النظام',
                  icon: Icons.phone_android_outlined,
                  selected: themeMode == ThemeMode.system,
                  onTap: () => _setTheme(ThemeMode.system),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          MadrajCard(
            child: _InfoRow(
              icon: Icons.badge_outlined,
              title: 'ID',
              value: userIdText,
              trailing: IconButton(
                tooltip: 'نسخ ID',
                onPressed: userIdText == 'غير متوفر' ? null : () => _copyUserId(userIdText),
                icon: const Icon(Icons.copy_rounded, size: 20),
              ),
            ),
          ),
          const SizedBox(height: 12),

          MadrajCard(
            padding: EdgeInsets.zero,
            child: ListTile(
              onTap: () => Get.toNamed(Routes.bookmarks),
              leading: const Icon(Icons.bookmarks_outlined, color: AppColors.red),
              title: const Text('المحفوظات', style: TextStyle(fontWeight: FontWeight.w900)),
              subtitle: const Text('عرض المنشورات التي قمت بحفظها'),
              trailing: const Icon(Icons.chevron_left_rounded),
            ),
          ),
          const SizedBox(height: 12),
          MadrajCard(
            padding: EdgeInsets.zero,
            child: ListTile(
              onTap: _logout,
              leading: const Icon(Icons.logout_rounded, color: AppColors.red),
              title: const Text('تسجيل الخروج', style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.red)),
              subtitle: const Text('إنهاء الجلسة الحالية'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  const _ThemeOption({required this.title, required this.icon, required this.selected, required this.onTap});

  final String title;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Icon(icon, color: selected ? AppColors.red : AppColors.muted),
            const SizedBox(width: 10),
            Expanded(child: Text(title, style: TextStyle(fontWeight: selected ? FontWeight.w900 : FontWeight.w700))),
            Icon(selected ? Icons.radio_button_checked : Icons.radio_button_off, color: selected ? AppColors.red : AppColors.softMuted),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.title, required this.value, this.trailing});

  final IconData icon;
  final String title;
  final String value;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final titleColor = Theme.of(context).textTheme.bodyLarge?.color;
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(color: AppColors.red.withOpacity(.08), borderRadius: BorderRadius.circular(14)),
          child: Icon(icon, color: AppColors.red),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(color: titleColor, fontWeight: FontWeight.w900)),
              const SizedBox(height: 4),
              Text(value, style: const TextStyle(color: AppColors.muted, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}
