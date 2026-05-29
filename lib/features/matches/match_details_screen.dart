import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constants/app_colors.dart';
import '../../core/widgets/app_chrome.dart';
import 'match_model.dart';

class MatchDetailsScreen extends StatelessWidget {
  const MatchDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final match = Get.arguments as MatchModel?;

    if (match == null) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppScreenHeader(title: 'تفاصيل المباراة'),
        body: EmptyState(
          title: 'لا توجد بيانات',
          subtitle: 'لم يتم إرسال بيانات المباراة لهذه الصفحة.',
          icon: Icons.error_outline,
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppScreenHeader(
        title: 'تفاصيل المباراة',
        subtitle: match.league,
        leading: IconButton(
          onPressed: Get.back,
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          MadrajCard(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
            child: Column(
              children: [
                _StatusBadge(text: match.status),
                const SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(child: _TeamBlock(name: match.homeTeam)),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        'VS',
                        style: TextStyle(
                          color: AppColors.red,
                          fontWeight: FontWeight.w900,
                          fontSize: 22,
                        ),
                      ),
                    ),
                    Expanded(child: _TeamBlock(name: match.awayTeam)),
                  ],
                ),

                const SizedBox(height: 18),
                const Divider(),
                const SizedBox(height: 10),

                _InfoRow(
                  icon: Icons.emoji_events_outlined,
                  title: 'الدوري',
                  value: match.league,
                ),
                _InfoRow(
                  icon: Icons.calendar_month_outlined,
                  title: 'التاريخ',
                  value: match.matchDate,
                ),
                _InfoRow(
                  icon: Icons.schedule_rounded,
                  title: 'الوقت',
                  value: match.formattedTime,
                ),
                _InfoRow(
                  icon: Icons.insights_rounded,
                  title: 'حالة التوقعات',
                  value: match.predictionState,
                ),
                _InfoRow(
                  icon: Icons.chat_bubble_outline,
                  title: 'رابط المحادثة',
                  value: match.chatUrl?.isNotEmpty == true
                      ? match.chatUrl!
                      : 'غير مربوط',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TeamBlock extends StatelessWidget {
  const _TeamBlock({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const CircleAvatar(
          radius: 34,
          backgroundColor: Colors.white,
          child: Icon(Icons.shield_outlined, color: AppColors.black, size: 34),
        ),
        const SizedBox(height: 10),
        Text(
          name,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 16,
            color: AppColors.black,
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.red, size: 21),
          const SizedBox(width: 10),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.muted,
              fontWeight: FontWeight.w800,
            ),
          ),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.left,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.black,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final color = text == 'مباشرة'
        ? AppColors.red
        : text == 'منتهية'
        ? AppColors.muted
        : AppColors.success;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: color.withOpacity(.09),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w900,
          fontSize: 13,
        ),
      ),
    );
  }
}
