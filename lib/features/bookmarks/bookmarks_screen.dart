import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/app_chrome.dart';
import 'bookmarks_controller.dart';
import '../posts/widgets/post_card.dart';

class BookmarksScreen extends GetView<BookmarksController> {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppScreenHeader(
        title: 'المحفوظات',
        leading: IconButton(onPressed: Get.back, icon: const Icon(Icons.arrow_back_ios_new_rounded)),
        actions: [IconButton(onPressed: controller.loadSavedPosts, icon: const Icon(Icons.refresh_rounded))],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.savedPosts.isEmpty) {
          return const Center(child: CircularProgressIndicator(color: AppColors.red));
        }

        if (controller.savedPosts.isEmpty) {
          return RefreshIndicator(
            onRefresh: controller.loadSavedPosts,
            color: AppColors.red,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [
                SizedBox(height: 160),
                EmptyState(
                  title: 'لا توجد محفوظات',
                  subtitle: 'عند حفظ أي منشور سيظهر هنا مباشرة.',
                  icon: Icons.bookmarks_outlined,
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.loadSavedPosts,
          color: AppColors.red,
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 12),
            itemCount: controller.savedPosts.length,
            itemBuilder: (context, index) {
              final post = controller.savedPosts[index];
              return PostCard(
                post: post,
                onTap: () => Get.toNamed(Routes.postDetails, arguments: {'postId': post.id, 'post': post}),
                onLike: () => controller.toggleLike(post),
                onComment: () => Get.toNamed(Routes.postDetails, arguments: {'postId': post.id, 'post': post}),
                onBookmark: () => controller.toggleBookmark(post),
              );
            },
          ),
        );
      }),
    );
  }
}
