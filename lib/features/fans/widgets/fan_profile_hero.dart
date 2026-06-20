part of '../fan_profile_screen.dart';

class _ProfileHero extends StatelessWidget {
  const _ProfileHero({required this.profile, required this.controller});

  final FanProfile profile;
  final FansController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final team = controller.selectedTeam.value;
      final primary = team?.primary ?? AppColors.black;
      final secondary = team?.secondary ?? AppColors.red;
      final heroColors = _heroColors(
        primary,
        secondary,
        Theme.of(context).brightness,
      );
      final readable = _readableTextColor(heroColors.last);

      return Container(
        color: Theme.of(context).cardColor,
        child: Column(
          children: [
            SizedBox(
              height: 170,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    height: 126,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: heroColors,
                        stops: const [0, .52, 1],
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                      ),
                    ),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Opacity(
                            opacity: .16,
                            child: Image.asset(
                              'assets/sadu_pattern.jpeg',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          left: -28,
                          top: -20,
                          child: Icon(
                            Icons.auto_awesome_rounded,
                            color: readable.withOpacity(.14),
                            size: 116,
                          ),
                        ),
                        Positioned(
                          right: 18,
                          top: 22,
                          child: Icon(
                            Icons.sports_soccer,
                            color: readable.withOpacity(.22),
                            size: 74,
                          ),
                        ),
                        if (team != null)
                          Positioned(
                            left: 22,
                            bottom: 16,
                            child: TeamBadge(
                              shortName: team.shortName,
                              logoUrl: team.logoUrl,
                              primary: team.primary,
                              secondary: team.secondary,
                              size: 52,
                            ),
                          ),
                        if (!controller.isMyProfile)
                          Positioned(
                            right: 12,
                            top: 12,
                            child: PopupMenuButton<String>(
                              icon: Icon(Icons.more_vert, color: readable),
                              onSelected: (value) {
                                if (value == 'report') {
                                  ReportDialog.show(
                                    targetType: 0,
                                    targetId: profile.id,
                                  );
                                }
                              },
                              itemBuilder: (context) => const [
                                PopupMenuItem(
                                  value: 'report',
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.flag_outlined,
                                        color: AppColors.red,
                                      ),
                                      SizedBox(width: 8),
                                      Text('إبلاغ عن المستخدم'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  Positioned(
                    right: 22,
                    top: 74,
                    child: AppAvatar(
                      imageUrl: profile.profilePicUrl,
                      name: profile.displayName,
                      radius: 48,
                      borderColor: Colors.white,
                    ),
                  ),
                  Positioned(
                    left: 16,
                    right: 140,
                    top: 132,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (controller.isMyProfile)
                          _HeroAction(
                            label: 'تعديل',
                            icon: Icons.edit_rounded,
                            onTap: () => _showEditSheet(context, controller),
                          )
                        else
                          Row(
                            children: [
                              Obx(
                                () => _HeroAction(
                                  label: controller.isFollowing.value
                                      ? 'أتابعه'
                                      : 'متابعة',
                                  icon: controller.isFollowing.value
                                      ? Icons.check_rounded
                                      : Icons.person_add_alt_1_rounded,
                                  onTap: controller.toggleFollow,
                                ),
                              ),

                              const SizedBox(width: 8),

                              _HeroAction(
                                label: 'مراسلة',
                                icon: Icons.message_outlined,
                                onTap: () async {
                                  try {
                                    final currentUserId = StorageService.userId;

                                    if (currentUserId == null) {
                                      Get.snackbar(
                                        'خطأ',
                                        'يجب تسجيل الدخول أولًا',
                                      );
                                      return;
                                    }

                                    final chat = await Get.find<ChatService>()
                                        .createPrivateChat(
                                          fan1Id: currentUserId,
                                          fan2Id: profile.id,
                                        );

                                    Get.toNamed(
                                      Routes.chats,
                                      arguments: {
                                        'chatId': chat.id,
                                        'chatTitle': profile.displayName,
                                        'chatType': chat.chatType,
                                      },
                                    );
                                  } catch (e) {
                                    Get.snackbar('خطأ', e.toString());
                                  }
                                },
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          profile.displayName,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Builder(
                    builder: (_) {
                      final subtitle = _profileSubtitle(profile);
                      if (subtitle.isEmpty) return const SizedBox.shrink();
                      return Text(
                        subtitle,
                        style: const TextStyle(
                          color: AppColors.muted,
                          fontWeight: FontWeight.w700,
                        ),
                      );
                    },
                  ),
                  if (profile.bio?.trim().isNotEmpty == true) ...[
                    const SizedBox(height: 8),
                    Text(
                      profile.bio!,
                      style: const TextStyle(
                        height: 1.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _StatBox(
                          label: 'المتابعون',
                          value: _formatNumber(profile.followersCount),
                          onTap: () => Get.toNamed(
                            Routes.followers,
                            arguments: {
                              'fanId': profile.id,
                              'mode': 'followers',
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _StatBox(
                          label: 'يتابع',
                          value: _formatNumber(profile.followingCount),
                          onTap: () => Get.toNamed(
                            Routes.following,
                            arguments: {
                              'fanId': profile.id,
                              'mode': 'following',
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _StatBox(
                          label: 'المنشورات',
                          value: _formatNumber(profile.posts.length),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  List<Color> _heroColors(
    Color primary,
    Color secondary,
    Brightness brightness,
  ) {
    final lightPrimary = primary.computeLuminance() > .78;
    final base = lightPrimary
        ? Color.alphaBlend(secondary.withOpacity(.16), Colors.white)
        : primary;
    final start = Color.alphaBlend(
      Colors.white.withOpacity(brightness == Brightness.dark ? .08 : .20),
      base,
    );
    final middle = Color.alphaBlend(
      secondary.withOpacity(lightPrimary ? .36 : .58),
      base,
    );
    final end = lightPrimary
        ? Color.alphaBlend(secondary.withOpacity(.24), Colors.white)
        : primary;
    return [start, middle, end];
  }

  Color _readableTextColor(Color color) =>
      color.computeLuminance() > .54 ? AppColors.black : Colors.white;

  String _profileSubtitle(FanProfile profile) {
    return '';
  }

  static String _formatNumber(int value) {
    if (value >= 1000000) return '${(value / 1000000).toStringAsFixed(1)}M';
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(1)}K';
    return '$value';
  }

  void _showEditSheet(BuildContext context, FansController controller) {
    Get.bottomSheet(
      _EditProfileSheet(controller: controller),
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
    );
  }
}

class _HeroAction extends StatelessWidget {
  const _HeroAction({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).cardColor,
      elevation: 4,
      shadowColor: Colors.black12,
      borderRadius: BorderRadius.circular(99),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(99),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          child: Row(
            children: [
              Icon(icon, size: 18, color: AppColors.red),
              const SizedBox(width: 6),
              Text(label, style: const TextStyle(fontWeight: FontWeight.w900)),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  const _StatBox({required this.label, required this.value, this.onTap});

  final String label;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fill = isDark ? const Color(0xFF23232A) : AppColors.background;
    final border = isDark ? const Color(0xFF34343D) : AppColors.border;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        decoration: BoxDecoration(
          color: fill,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: border),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w900,
                color: textColor,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.muted,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
