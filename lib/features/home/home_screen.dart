import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../core/constants/app_assets.dart';
import '../../core/constants/app_colors.dart';
import '../../core/storage/storage_service.dart';
import '../../core/widgets/app_chrome.dart';
import '../auth/auth_controller.dart';
import '../auth/auth_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0;

  final List<String> titles = const [
    'الرئيسية',
    'المباريات',
    '',
    'المجتمع',
    'الملف الشخصي',
  ];

  void _onNavTap(int index) {
    if (index == 2) {
      Get.bottomSheet(
        const _CreateSheet(),
        isScrollControlled: true,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        ),
      );
      return;
    }

    setState(() {
      currentIndex = index;
    });
  }

  Future<void> _logout() async {
    final authService = Get.find<AuthService>();

    try {
      await authService.logout();
    } catch (_) {
      // حتى لو فشل تسجيل الخروج من السيرفر، نحذف الجلسة محلياً
    }

    await StorageService.clearSession();

    if (Get.isRegistered<AuthController>()) {
      Get.delete<AuthController>(force: true);
    }

    Get.offAllNamed(Routes.auth);
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      const _HomeContent(),
      const _CenterText(text: 'المباريات'),
      const SizedBox.shrink(),
      const _CenterText(text: 'المجتمع'),
      const _CenterText(text: 'الملف الشخصي'),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            AppScreenHeader(
              title: titles[currentIndex],
              leading: IconButton(
                onPressed: () {
                  Get.toNamed(Routes.notifications);
                },
                icon: const Icon(Icons.notifications_none),
              ),
              actions: [
                IconButton(
                  onPressed: () {
                    Get.toNamed(Routes.chats);
                  },
                  icon: const Icon(Icons.chat_bubble_outline),
                ),
                IconButton(onPressed: _logout, icon: const Icon(Icons.logout)),
              ],
            ),
            Expanded(
              child: IndexedStack(index: currentIndex, children: pages),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _BottomNav(index: currentIndex, onTap: _onNavTap),
    );
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent();

  @override
  Widget build(BuildContext context) {
    final String username = StorageService.username ?? 'يوزر';

    return Center(
      child: Text(
        'هاي $username',
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.w900,
          color: AppColors.black,
        ),
      ),
    );
  }
}

class _CenterText extends StatelessWidget {
  const _CenterText({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.w900,
          color: AppColors.black,
        ),
      ),
    );
  }
}

class _CreateSheet extends StatelessWidget {
  const _CreateSheet();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 18,
        right: 18,
        top: 18,
        bottom: MediaQuery.of(context).viewInsets.bottom + 18,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 5,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(99),
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'إضافة جديدة',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'اربط هذا الزر لاحقاً بإنشاء منشور أو توقع.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.muted, height: 1.5),
          ),
          const SizedBox(height: 18),
        ],
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  const _BottomNav({required this.index, required this.onTap});

  final int index;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final List<_NavItem> items = [
      const _NavItem(
        inactiveIcon: Icons.home_outlined,
        activeIcon: Icons.home,
        label: 'الرئيسية',
      ),
      const _NavItem(
        inactiveIcon: Icons.calendar_month_outlined,
        activeIcon: Icons.calendar_month,
        label: 'المباريات',
      ),
      const _NavItem(inactiveIcon: Icons.add, activeIcon: Icons.add, label: ''),
      const _NavItem(
        inactiveIcon: Icons.groups_2_outlined,
        activeIcon: Icons.groups_2,
        label: 'المجتمع',
      ),
      const _NavItem(
        inactiveIcon: Icons.person_outline,
        activeIcon: Icons.person,
        label: 'الملف الشخصي',
      ),
    ];

    return Container(
      height: 76,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: Row(
        children: List.generate(items.length, (i) {
          if (i == 2) {
            return Expanded(
              child: GestureDetector(
                onTap: () => onTap(i),
                child: Center(
                  child: Image.asset(
                    AppAssets.addButton,
                    height: 62,
                    width: 62,
                  ),
                ),
              ),
            );
          }

          final bool active = i == index;
          final item = items[i];

          return Expanded(
            child: InkWell(
              onTap: () => onTap(i),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    active ? item.activeIcon : item.inactiveIcon,
                    color: active ? AppColors.red : AppColors.black,
                    size: 25,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.label,
                    style: TextStyle(
                      color: active ? AppColors.red : AppColors.black,
                      fontSize: 10,
                      fontWeight: active ? FontWeight.w900 : FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _NavItem {
  final IconData inactiveIcon;
  final IconData activeIcon;
  final String label;

  const _NavItem({
    required this.inactiveIcon,
    required this.activeIcon,
    required this.label,
  });
}
