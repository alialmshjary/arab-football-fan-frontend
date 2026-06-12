import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constants/app_colors.dart';
import '../../core/widgets/app_chrome.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../core/widgets/loading_widget.dart';
import 'match_model.dart';
import 'matches_controller.dart';
import '../../app/routes/app_routes.dart';
import '../../core/constants/api_constants.dart';

class MatchesScreen extends GetView<MatchesController> {
  const MatchesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value && controller.matches.isEmpty) {
        return const LoadingWidget(message: 'جاري تحميل المباريات...');
      }

      return RefreshIndicator(
        color: AppColors.red,
        onRefresh: () => controller.fetchMatches(refresh: true),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            MadrajCard(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: controller.searchController,
                      hint: 'ابحث عن فريق أو دوري',
                      icon: Icons.search_rounded,
                      textInputAction: TextInputAction.search,
                      onChanged: (value) => controller.searchText.value = value,
                      suffixIcon: Obx(
                        () => controller.searchText.value.isNotEmpty
                            ? IconButton(
                                onPressed: controller.clearSearch,
                                icon: const Icon(Icons.close_rounded),
                              )
                            : const SizedBox.shrink(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: controller.searchMatches,
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.red,
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            if (controller.matches.isEmpty)
              const SizedBox(
                height: 420,
                child: EmptyState(
                  title: 'لا توجد مباريات',
                  subtitle: 'عند إضافة مباريات جديدة ستظهر هنا.',
                  icon: Icons.sports_soccer_outlined,
                ),
              )
            else ...[
              ...controller.matches.map((match) => _MatchCard(match: match)),

              if (controller.hasNextPage) ...[
                const SizedBox(height: 10),
                OutlinedButton(
                  onPressed: controller.isLoadingMore.value
                      ? null
                      : controller.loadMore,
                  child: controller.isLoadingMore.value
                      ? const CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.red,
                        )
                      : const Text(
                          'تحميل المزيد',
                          style: TextStyle(fontWeight: FontWeight.w900),
                        ),
                ),
              ],
            ],
          ],
        ),
      );
    });
  }
}

class _MatchCard extends StatelessWidget {
  const _MatchCard({required this.match});

  final MatchModel match;

  @override
  Widget build(BuildContext context) {
    return MadrajCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      child: Column(
        children: [
          Row(
            children: [
              _Badge(text: match.league),
              const Spacer(),
              _StatusBadge(text: match.status),
            ],
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _TeamName(
                  name: match.homeTeam,
                  logoUrl: match.homeTeamLogoUrl,
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'VS',
                  style: TextStyle(
                    color: AppColors.red,
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
                ),
              ),
              Expanded(
                child: _TeamName(
                  name: match.awayTeam,
                  logoUrl: match.awayTeamLogoUrl,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 12),

          Row(
            children: [
              const Icon(
                Icons.calendar_month_outlined,
                size: 18,
                color: AppColors.muted,
              ),
              const SizedBox(width: 6),
              Text(
                match.matchDate,
                style: const TextStyle(
                  color: AppColors.muted,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              const Icon(
                Icons.schedule_rounded,
                size: 18,
                color: AppColors.muted,
              ),
              const SizedBox(width: 6),
              Text(
                match.formattedTime,
                style: const TextStyle(
                  color: AppColors.muted,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Get.toNamed(Routes.matchDetails, arguments: match);
                  },
                  icon: const Icon(Icons.visibility_outlined, size: 18),
                  label: const Text('التفاصيل'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.black,
                    side: const BorderSide(color: AppColors.border),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TeamName extends StatelessWidget {
  const _TeamName({required this.name, this.logoUrl});

  final String name;
  final String? logoUrl;

  String get fullLogoUrl {
    if (logoUrl == null) return '';

    if (logoUrl!.startsWith('http')) {
      return logoUrl!;
    }

    return '${ApiConstants.serverUrl}$logoUrl';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: AppColors.background,
          child: logoUrl != null
              ? ClipOval(
                  child: Image.network(
                    fullLogoUrl,
                    width: 36,
                    height: 36,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) {
                      return const Icon(
                        Icons.shield_outlined,
                        color: AppColors.black,
                      );
                    },
                  ),
                )
              : const Icon(Icons.shield_outlined, color: AppColors.black),
        ),
        const SizedBox(height: 8),
        Text(
          name,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
        ),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.black,
          fontWeight: FontWeight.w800,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final color = text == 'Live' || text == 'مباشرة'
        ? AppColors.red
        : text == 'Finished' || text == 'منتهية'
        ? AppColors.muted
        : AppColors.success;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(.09),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w900,
          fontSize: 12,
        ),
      ),
    );
  }
}
