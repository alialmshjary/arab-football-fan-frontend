import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../features/auth/auth_binding.dart';
import '../../features/auth/auth_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/home/home_binding.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/matches/matches_screen.dart';
import '../../features/matches/matches_binding.dart';
import '../../features/matches/match_details_screen.dart';
import 'app_routes.dart';

class AppPages {
  AppPages._();

  static final routes = <GetPage<dynamic>>[
    GetPage(name: Routes.splash, page: () => const SplashScreen()),

    GetPage(
      name: Routes.auth,
      page: () => const AuthScreen(),
      binding: AuthBinding(),
    ),

    GetPage(
      name: Routes.home,
      page: () => const HomeScreen(),
      binding: HomeBinding(),
    ),

    GetPage(
      name: Routes.fanProfile,
      page: () => const _EmptyRoutePage(title: 'الملف الشخصي'),
    ),

    GetPage(
      name: Routes.posts,
      page: () => const _EmptyRoutePage(title: 'المجتمع'),
    ),

    GetPage(
      name: Routes.comments,
      page: () => const _EmptyRoutePage(title: 'التعليقات'),
    ),

    GetPage(
      name: Routes.bookmarks,
      page: () => const _EmptyRoutePage(title: 'المحفوظات'),
    ),

    GetPage(
      name: Routes.predictions,
      page: () => const _EmptyRoutePage(title: 'التوقعات'),
    ),

    GetPage(
      name: Routes.followers,
      page: () => const _EmptyRoutePage(title: 'المتابعون'),
    ),

    GetPage(
      name: Routes.following,
      page: () => const _EmptyRoutePage(title: 'أتابعهم'),
    ),

    GetPage(
      name: Routes.teams,
      page: () => const _EmptyRoutePage(title: 'الفرق'),
    ),

    GetPage(
      name: Routes.notifications,
      page: () => const _EmptyRoutePage(title: 'الإشعارات'),
    ),

    GetPage(
      name: Routes.settings,
      page: () => const _EmptyRoutePage(title: 'الإعدادات'),
    ),

    GetPage(
      name: Routes.matches,
      page: () => const MatchesScreen(),
      binding: MatchBinding(),
    ),

    GetPage(
      name: Routes.matchDetails,
      page: () => const MatchDetailsScreen(),
    ),

    GetPage(
      name: Routes.chats,
      page: () => const _EmptyRoutePage(title: 'الدردشات'),
    ),
  ];
}

class _EmptyRoutePage extends StatelessWidget {
  const _EmptyRoutePage({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text(
          title,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
        ),
      ),
    );
  }
}
