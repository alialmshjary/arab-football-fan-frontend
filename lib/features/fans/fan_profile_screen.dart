import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../core/constants/app_colors.dart';
import '../../core/network/api_client.dart';
import '../../core/widgets/app_chrome.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_text_field.dart';
import '../posts/post_model.dart';
import 'fan_model.dart';
import 'fans_controller.dart';
import 'favorite_player.dart';
import 'favorite_team.dart';
import '../../core/storage/storage_service.dart';
import '../chats/chat_service.dart';
part 'widgets/fan_profile_hero.dart';
part 'widgets/favorite_profile_cards.dart';
part 'widgets/profile_post_grid.dart';
part 'widgets/profile_sheets.dart';

class FanProfileScreen extends StatefulWidget {
  const FanProfileScreen({super.key, this.embedded = false, this.fanId});

  final bool embedded;
  final int? fanId;

  @override
  State<FanProfileScreen> createState() => _FanProfileScreenState();
}

class _FanProfileScreenState extends State<FanProfileScreen> {
  late final FansController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<FansController>();
    _loadProfileAfterBuild();
  }

  @override
  Widget build(BuildContext context) {
    final body = Obx(_buildBody);
    if (widget.embedded) return body;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppScreenHeader(
        title: 'الملف الشخصي',
        showPattern: false,
        leading: IconButton(
          onPressed: Get.back,
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        actions: [
          IconButton(
            onPressed: () => Get.toNamed(Routes.settings),
            icon: const Icon(Icons.settings_outlined),
          ),
          IconButton(
            onPressed: controller.refreshCurrent,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: body,
    );
  }

  // تحميل البروفايل بعد بناء الصفحة حتى تكون Get.arguments جاهزة.
  void _loadProfileAfterBuild() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final data = _readProfileRouteData();
      if (data.fanId != null && data.fanId! > 0) {
        controller.loadProfile(data.fanId!, preview: data.preview);
      } else {
        controller.loadMe();
      }
    });
  }

  // تقرأ رقم المشجع وبياناته المختصرة من arguments أو من widget.fanId.
  _ProfileRouteData _readProfileRouteData() {
    final arg = Get.arguments;
    FanBasicProfile? preview;
    dynamic rawFanId = widget.fanId ?? arg;

    if (arg is Map) {
      rawFanId = widget.fanId ?? arg['fanId'] ?? arg['id'];
      preview = _readPreviewFan(arg['fan'] ?? arg['preview']);
    } else if (arg is FanBasicProfile) {
      preview = arg;
      rawFanId = widget.fanId ?? arg.id;
    }

    return _ProfileRouteData(_toInt(rawFanId), preview);
  }

  FanBasicProfile? _readPreviewFan(Object? value) {
    if (value is FanBasicProfile) return value;
    if (value is Map) return FanBasicProfile.fromJson(Map<String, dynamic>.from(value));
    return null;
  }

  int? _toInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse('$value');
  }

  Widget _buildBody() {
    final profile = controller.profile.value;
    final team = controller.selectedTeam.value;
    final player = controller.selectedPlayer.value;

    if (controller.isLoading.value && profile == null) {
      return const Center(child: CircularProgressIndicator(color: AppColors.red));
    }

    if (profile == null) return _buildLoadError();

    return RefreshIndicator(
      onRefresh: controller.refreshCurrent,
      color: AppColors.red,
      child: ListView(
        padding: const EdgeInsets.only(bottom: 20),
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          _ProfileHero(profile: profile, controller: controller),
          _buildFavoritesSection(team, player),
          const SizedBox(height: 6),
          _ProfilePostsGrid(posts: profile.posts, onOpenPost: controller.openPost),
        ],
      ),
    );
  }

  Widget _buildLoadError() {
    return RefreshIndicator(
      onRefresh: controller.loadMe,
      color: AppColors.red,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 120),
          EmptyState(
            title: 'تعذر تحميل الملف الشخصي',
            subtitle: 'تأكد من تشغيل الباك اند ثم اسحب للتحديث.',
            icon: Icons.person_off_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildFavoritesSection(FavoriteTeam? team, FavoritePlayer? player) {
    if (!controller.isMyProfile && team == null && player == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 122,
                child: _FavoriteTeamCard(
                  team: team,
                  isMe: controller.isMyProfile,
                  onChoose: () => _showTeamPicker(context),
                  onClear: controller.clearTeam,
                  margin: EdgeInsets.zero,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: SizedBox(
                height: 122,
                child: _FavoritePlayerCard(
                  player: player,
                  isMe: controller.isMyProfile,
                  onChoose: () => _showPlayerPicker(context),
                  onClear: controller.clearPlayer,
                  margin: EdgeInsets.zero,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTeamPicker(BuildContext context) {
    Get.bottomSheet(
      _TeamPickerSheet(controller: controller),
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
    );
  }

  void _showPlayerPicker(BuildContext context) {
    Get.bottomSheet(
      _PlayerPickerSheet(controller: controller),
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
    );
  }
}

class _ProfileRouteData {
  const _ProfileRouteData(this.fanId, this.preview);

  final int? fanId;
  final FanBasicProfile? preview;
}
