import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import 'app_chrome.dart';

class FeaturePlaceholderScreen extends StatelessWidget {
  const FeaturePlaceholderScreen({
    super.key,
    required this.title,
    required this.description,
    this.icon = Icons.extension_outlined,
  });

  final String title;
  final String description;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppScreenHeader(title: title),
      body: EmptyState(title: 'هذه الميزة جاهزة للبدء', subtitle: description, icon: icon),
    );
  }
}

class FeatureInlinePlaceholder extends StatelessWidget {
  const FeatureInlinePlaceholder({super.key, required this.title, required this.description, required this.icon});

  final String title;
  final String description;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return MadrajCard(
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          Container(
            height: 52,
            width: 52,
            decoration: BoxDecoration(color: AppColors.red.withOpacity(.08), borderRadius: BorderRadius.circular(16)),
            child: Icon(icon, color: AppColors.red),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
                const SizedBox(height: 4),
                Text(description, style: const TextStyle(color: AppColors.muted, fontSize: 12, height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
