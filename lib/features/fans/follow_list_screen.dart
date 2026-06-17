import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../core/constants/app_colors.dart';
import '../../core/storage/storage_service.dart';
import '../../core/widgets/app_chrome.dart';
import '../../core/widgets/custom_text_field.dart';
import 'fan_model.dart';
import 'fans_controller.dart';

class FollowListScreen extends StatefulWidget {
  const FollowListScreen({super.key, required this.mode});

  final String mode;

  @override
  State<FollowListScreen> createState() => _FollowListScreenState();
}

class _FollowListScreenState extends State<FollowListScreen> {
  late final FansController controller;
  late final String mode;
  late final int fanId;

  @override
  void initState() {
    super.initState();
    controller = Get.find<FansController>();

    final args = Get.arguments;
    mode = args is Map && args['mode'] != null ? args['mode'].toString() : widget.mode;
    final rawFanId = args is Map ? args['fanId'] : null;
    fanId = rawFanId is int
        ? rawFanId
        : int.tryParse('${rawFanId ?? controller.profile.value?.id ?? StorageService.userId ?? 0}') ?? 0;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadFollowList(fanId: fanId, mode: mode);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isFollowers = mode == 'followers';
    final title = isFollowers ? 'المتابعون' : 'يتابعهم';
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppScreenHeader(
        title: title,
        subtitle: isFollowers ? 'قائمة المتابعين' : 'قائمة الأشخاص الذين يتابعهم',
        leading: IconButton(onPressed: Get.back, icon: const Icon(Icons.arrow_back_ios_new_rounded)),
        actions: [IconButton(onPressed: controller.refreshFollowList, icon: const Icon(Icons.refresh_rounded))],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: CustomTextField(
              controller: controller.searchController,
              hint: 'ابحث داخل القائمة...',
              icon: Icons.search_rounded,
              onChanged: controller.filterFollowList,
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isFollowListLoading.value && controller.followList.isEmpty) {
                return const Center(child: CircularProgressIndicator(color: AppColors.red));
              }

              final fans = controller.visibleFollowList;
              if (fans.isEmpty) {
                final hasSearch = controller.followSearchText.value.trim().isNotEmpty;
                return RefreshIndicator(
                  onRefresh: controller.refreshFollowList,
                  color: AppColors.red,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      const SizedBox(height: 90),
                      EmptyState(
                        title: hasSearch ? 'لا توجد نتائج مطابقة' : (isFollowers ? 'لا يوجد متابعون بعد' : 'لا يتابع أحداً بعد'),
                        subtitle: hasSearch ? 'جرّب كتابة اسم أو معرّف آخر.' : 'سيظهر المستخدمون هنا مباشرة من endpoint الخاص بالقائمة.',
                        icon: Icons.people_alt_outlined,
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: controller.refreshFollowList,
                color: AppColors.red,
                child: ListView.builder(
                  padding: const EdgeInsets.only(bottom: 18),
                  itemCount: fans.length,
                  itemBuilder: (context, index) => _FanTile(fan: fans[index]),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _FanTile extends StatelessWidget {
  const _FanTile({required this.fan});

  final FanBasicProfile fan;

  @override
  Widget build(BuildContext context) {
    return MadrajCard(
      margin: const EdgeInsets.fromLTRB(14, 6, 14, 4),
      padding: EdgeInsets.zero,
      child: InkWell(
        onTap: () => Get.toNamed(Routes.fanProfile, arguments: {'fanId': fan.id, 'fan': fan}),
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              AppAvatar(imageUrl: fan.profilePicUrl, name: fan.displayName, radius: 23),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(fan.displayName, style: const TextStyle(fontWeight: FontWeight.w900)),
                    const SizedBox(height: 2),
                    Text('@${fan.username}', style: const TextStyle(color: AppColors.muted, fontSize: 12, fontWeight: FontWeight.w700)),
                    if (fan.bio?.trim().isNotEmpty == true) ...[
                      const SizedBox(height: 4),
                      Text(fan.bio!, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppColors.muted, fontSize: 11)),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                children: [
                  Text('${fan.followersCount}', style: const TextStyle(fontWeight: FontWeight.w900)),
                  const Text('متابع', style: TextStyle(color: AppColors.muted, fontSize: 10)),
                ],
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.muted, size: 15),
            ],
          ),
        ),
      ),
    );
  }
}
