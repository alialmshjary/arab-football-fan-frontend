import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../core/constants/app_colors.dart';
import '../../core/storage/storage_service.dart';
import '../../core/widgets/app_chrome.dart';
import '../auth/auth_controller.dart';
import '../auth/auth_service.dart';
import '../fans/fan_model.dart';
import '../fans/fan_profile_screen.dart';
import '../fans/fans_controller.dart';
import '../posts/posts_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0;

  final List<String> titles = const ['الرئيسية', 'المباريات', '', 'المجتمع', 'الملف الشخصي'];

  void _onNavTap(int index) {
    if (index == 2) {
      showCreatePostSheet(context);
      return;
    }
    if (index == 4 && Get.isRegistered<FansController>()) {
      Get.find<FansController>().loadMe();
    }
    setState(() => currentIndex = index);
  }

  Future<void> _logout() async {
    final authService = Get.find<AuthService>();
    try {
      await authService.logout();
    } catch (_) {}
    await StorageService.clearSession();
    if (Get.isRegistered<AuthController>()) {
      Get.delete<AuthController>(force: true);
    }
    Get.offAllNamed(Routes.auth);
  }

  List<Widget> _headerActions() {
    if (currentIndex == 3) {
      return [
        IconButton(onPressed: () => _showFanSearchSheet(context), icon: const Icon(Icons.search_rounded)),
        IconButton(onPressed: () => showCreatePostSheet(context), icon: const Icon(Icons.add_circle_outline)),
      ];
    }

    if (currentIndex == 4) {
      return [
        IconButton(onPressed: () => Get.toNamed(Routes.settings), icon: const Icon(Icons.settings_outlined)),
        IconButton(onPressed: () => Get.find<FansController>().refreshCurrent(), icon: const Icon(Icons.refresh_rounded)),
      ];
    }

    return [IconButton(onPressed: _logout, icon: const Icon(Icons.logout_rounded))];
  }

  void _showFanSearchSheet(BuildContext context) {
    final fansController = Get.find<FansController>();
    fansController.clearSearch();
    Get.bottomSheet(
      _FanSearchSheet(controller: fansController),
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _HomeContent(onGoCommunity: () => setState(() => currentIndex = 3), onGoProfile: () => _onNavTap(4)),
      const _MatchesPlaceholder(),
      const SizedBox.shrink(),
      const PostsScreen(embedded: true),
      const FanProfileScreen(embedded: true),
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            AppScreenHeader(
              title: titles[currentIndex],
              actions: _headerActions(),
              showPattern: currentIndex != 4,
            ),
            Expanded(child: IndexedStack(index: currentIndex, children: pages)),
          ],
        ),
      ),
      bottomNavigationBar: _BottomNav(index: currentIndex, onTap: _onNavTap),
    );
  }
}

class _FanSearchSheet extends StatelessWidget {
  const _FanSearchSheet({required this.controller});

  final FansController controller;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: SizedBox(
        height: MediaQuery.of(context).size.height * .76,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
          child: Column(
            children: [
              Container(width: 50, height: 5, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(99))),
              const SizedBox(height: 16),
              const Text('البحث عن مستخدمين', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
              const SizedBox(height: 14),
              TextField(
                controller: controller.searchController,
                textInputAction: TextInputAction.search,
                onChanged: controller.searchFans,
                onSubmitted: controller.searchFans,
                decoration: InputDecoration(
                  hintText: 'اكتب اسم المستخدم أو اسم العرض...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: Obx(() => controller.isSearching.value
                      ? const Padding(
                          padding: EdgeInsets.all(14),
                          child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.red)),
                        )
                      : const SizedBox.shrink()),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Obx(() {
                  if (controller.searchText.value.isEmpty) {
                    return const EmptyState(title: 'ابدأ بالبحث', subtitle: 'يمكنك البحث عن المشجعين ثم فتح بروفايل أي حساب.', icon: Icons.search_rounded);
                  }
                  if (controller.isSearching.value && controller.searchResults.isEmpty) {
                    return const Center(child: CircularProgressIndicator(color: AppColors.red));
                  }
                  if (controller.searchResults.isEmpty) {
                    return const EmptyState(title: 'لا توجد نتائج', subtitle: 'جرّب اسم مستخدم آخر.', icon: Icons.person_search_outlined);
                  }
                  return ListView.separated(
                    itemCount: controller.searchResults.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) => _FanSearchResultTile(fan: controller.searchResults[index]),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FanSearchResultTile extends StatelessWidget {
  const _FanSearchResultTile({required this.fan});

  final FanBasicProfile fan;

  @override
  Widget build(BuildContext context) {
    return MadrajCard(
      padding: EdgeInsets.zero,
      child: ListTile(
        onTap: () {
          Get.back<void>();
          Get.toNamed(Routes.fanProfile, arguments: {'fanId': fan.id, 'fan': fan});
        },
        leading: AppAvatar(imageUrl: fan.profilePicUrl, name: fan.displayName, radius: 22),
        title: Text(fan.displayName, style: const TextStyle(fontWeight: FontWeight.w900)),
        subtitle: Text(fan.bio?.trim().isNotEmpty == true ? fan.bio! : 'مشجع في مجتمع مدرج', maxLines: 1, overflow: TextOverflow.ellipsis),
        trailing: const Icon(Icons.chevron_left_rounded),
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent({required this.onGoCommunity, required this.onGoProfile});

  final VoidCallback onGoCommunity;
  final VoidCallback onGoProfile;

  @override
  Widget build(BuildContext context) {
    final username = StorageService.username ?? 'مشجع';
    final team = StorageService.favoriteTeam;
    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [AppColors.black, AppColors.red], begin: Alignment.topRight, end: Alignment.bottomLeft),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(.10), blurRadius: 20, offset: const Offset(0, 12))],
          ),
          child: Stack(
            children: [
              Positioned(left: -6, bottom: -12, child: Icon(Icons.sports_soccer, color: Colors.white.withOpacity(.16), size: 96)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('حياك في مدرج', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 6),
                  Text(username, style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 10),
                  Text(team == null ? 'اختر فريقك المفضل من البروفايل لإظهاره في خانة الفريق.' : 'فريقك المفضل: ${team.name}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, height: 1.45)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(child: _QuickCard(icon: Icons.groups_2_outlined, title: 'المجتمع', subtitle: 'منشورات وتفاعل', onTap: onGoCommunity)),
            const SizedBox(width: 10),
            Expanded(child: _QuickCard(icon: Icons.person_outline, title: 'البروفايل', subtitle: 'فريقك ومنشوراتك', onTap: onGoProfile)),
          ],
        ),
        const SizedBox(height: 10),
        _QuickCard(icon: Icons.bookmarks_outlined, title: 'المحفوظات', subtitle: 'منشورات حفظتها', onTap: () => Get.toNamed(Routes.bookmarks)),
      ],
    );
  }
}

class _QuickCard extends StatelessWidget {
  const _QuickCard({required this.icon, required this.title, required this.subtitle, required this.onTap});

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return MadrajCard(
      padding: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(width: 42, height: 42, decoration: BoxDecoration(color: AppColors.red.withOpacity(.08), borderRadius: BorderRadius.circular(14)), child: Icon(icon, color: AppColors.red)),
              const SizedBox(height: 12),
              Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
              const SizedBox(height: 3),
              Text(subtitle, style: const TextStyle(color: AppColors.muted, fontSize: 12, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}

class _MatchesPlaceholder extends StatelessWidget {
  const _MatchesPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const EmptyState(
      title: 'واجهة المباريات جاهزة للتوصيل',
      subtitle: 'قسم المباريات خارج الجزء المطلوب منك حالياً، وتم تركه بدون تغيير جوهري.',
      icon: Icons.calendar_month_outlined,
    );
  }
}

class _BottomNav extends StatelessWidget {
  const _BottomNav({required this.index, required this.onTap});

  final int index;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final items = [
      const _NavItem(inactiveIcon: Icons.home_outlined, activeIcon: Icons.home, label: 'الرئيسية'),
      const _NavItem(inactiveIcon: Icons.calendar_month_outlined, activeIcon: Icons.calendar_month, label: 'المباريات'),
      const _NavItem(inactiveIcon: Icons.add, activeIcon: Icons.add, label: ''),
      const _NavItem(inactiveIcon: Icons.groups_2_outlined, activeIcon: Icons.groups_2, label: 'المجتمع'),
      const _NavItem(inactiveIcon: Icons.person_outline, activeIcon: Icons.person, label: 'الملف الشخصي'),
    ];

    return Container(
      height: 76,
      decoration: BoxDecoration(color: Theme.of(context).cardColor, boxShadow: [BoxShadow(color: Colors.black.withOpacity(.06), blurRadius: 18, offset: const Offset(0, -6))]),
      child: Row(
        children: List.generate(items.length, (i) {
          if (i == 2) {
            return Expanded(
              child: Center(
                child: _CreatePostNavButton(onTap: () => onTap(i)),
              ),
            );
          }
          final active = i == index;
          final item = items[i];
          return Expanded(
            child: InkWell(
              onTap: () => onTap(i),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(active ? item.activeIcon : item.inactiveIcon, color: active ? AppColors.red : Theme.of(context).textTheme.bodyLarge?.color, size: 25),
                  const SizedBox(height: 4),
                  Text(item.label, style: TextStyle(color: active ? AppColors.red : Theme.of(context).textTheme.bodyLarge?.color, fontSize: 10, fontWeight: active ? FontWeight.w900 : FontWeight.w600)),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}


class _CreatePostNavButton extends StatelessWidget {
  const _CreatePostNavButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: isDark
                  ? [const Color(0xFF24242B), const Color(0xFF17171C)]
                  : [Colors.white, const Color(0xFFF5F5F5)],
            ),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.red.withOpacity(.30), width: 1.2),
            boxShadow: [
              BoxShadow(color: AppColors.red.withOpacity(.10), blurRadius: 18, offset: const Offset(0, 8)),
              BoxShadow(color: Colors.black.withOpacity(isDark ? .25 : .06), blurRadius: 10, offset: const Offset(0, 4)),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(width: 30, height: 30, decoration: BoxDecoration(color: AppColors.red.withOpacity(.10), shape: BoxShape.circle)),
              const Icon(Icons.add_rounded, color: AppColors.red, size: 30),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  const _NavItem({required this.inactiveIcon, required this.activeIcon, required this.label});

  final IconData inactiveIcon;
  final IconData activeIcon;
  final String label;
}
