import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({super.key, this.message = 'جاري التحميل...'});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(color: AppColors.red, strokeWidth: 2.5),
          const SizedBox(height: 12),
          Text(message, style: const TextStyle(color: AppColors.muted, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
