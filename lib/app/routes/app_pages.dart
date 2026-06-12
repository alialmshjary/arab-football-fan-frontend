import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../features/auth/auth_binding.dart';
import '../../features/auth/auth_screen.dart';
import '../../features/bookmarks/bookmarks_binding.dart';
import '../../features/bookmarks/bookmarks_screen.dart';
import '../../features/fans/fan_profile_screen.dart';
import '../../features/fans/fans_binding.dart';
import '../../features/fans/follow_list_screen.dart';
import '../../features/home/home_binding.dart';
import '../../features/home/home_screen.dart';
import '../../features/posts/posts_binding.dart';
import '../../features/posts/posts_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/matches/matches_screen.dart';
import '../../features/matches/matches_binding.dart';
import '../../features/matches/match_details_screen.dart';
import '../../features/chats/chat_binding.dart';
import '../../features/chats/chat_screen.dart';
import '../../features/chats/chat_list_screen.dart';
import '../../features/chatmembers/create_group_chat_screen.dart';
import '../../features/chatmembers/chat_members_screen.dart';
import '../../features/chatmembers/chat_members_binding.dart';
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
      page: () => const FanProfileScreen(),
      binding: FansBinding(),
    ),

    GetPage(
      name: Routes.posts,
      page: () => const PostsScreen(),
      binding: PostsBinding(),
    ),

    GetPage(
      name: Routes.postDetails,
      page: () => const PostDetailsScreen(),
      binding: PostsBinding(),
    ),

    GetPage(
      name: Routes.comments,
      page: () => const _EmptyRoutePage(title: 'التعليقات'),
    ),

    GetPage(
      name: Routes.bookmarks,
      page: () => const BookmarksScreen(),
      binding: BookmarksBinding(),
    ),

    GetPage(
      name: Routes.followers,
      page: () => const FollowListScreen(mode: 'followers'),
      binding: FansBinding(),
    ),

    GetPage(
      name: Routes.following,
      page: () => const FollowListScreen(mode: 'following'),
      binding: FansBinding(),
    ),

    GetPage(
      name: Routes.teams,
      page: () => const _EmptyRoutePage(title: 'الفرق'),
    ),

    GetPage(
      name: Routes.matches,
      page: () => const MatchesScreen(),
      binding: MatchBinding(),
    ),

    GetPage(
      name: Routes.matchDetails,
      page: () => const MatchDetailsScreen(),
      binding: MatchBinding(),
    ),

    GetPage(
      name: Routes.chats,
      page: () => const ChatScreen(),
      binding: ChatBinding(),
    ),

    GetPage(
      name: Routes.chatList,
      page: () => const ChatListScreen(),
      binding: ChatBinding(),
    ),

    GetPage(
      name: Routes.chatMembers,
      page: () => const ChatMembersScreen(),
      binding: ChatMembersBinding(),
    ),
    
    GetPage(
      name: Routes.createGroupChat,
      page: () => const CreateGroupChatScreen(),
      binding: ChatBinding(),
    ),

    GetPage(
      name: Routes.settings, 
      page: () => const SettingsScreen()
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
