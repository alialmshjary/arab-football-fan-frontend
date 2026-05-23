import 'package:flutter/material.dart';

import '../constants/app_assets.dart';
import '../constants/app_colors.dart';

class SaduStrip extends StatelessWidget {
  const SaduStrip({super.key, this.height = 22});

  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: Image.asset(AppAssets.saduPattern, fit: BoxFit.cover),
    );
  }
}

class MadrajLogo extends StatelessWidget {
  const MadrajLogo({super.key, this.size = 96, this.showTitle = true});

  final double size;
  final bool showTitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              height: size,
              width: size,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: AppColors.black, width: size * .055),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(size * .36),
                  topRight: Radius.circular(size * .36),
                  bottomLeft: Radius.circular(size * .12),
                  bottomRight: Radius.circular(size * .12),
                ),
                boxShadow: [
                  BoxShadow(color: AppColors.red.withOpacity(.14), blurRadius: 22, offset: const Offset(0, 10)),
                ],
              ),
            ),
            Container(
              height: size * .56,
              width: size * .56,
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              child: Icon(Icons.sports_soccer, size: size * .45, color: AppColors.black),
            ),
            Positioned(bottom: size * .03, left: size * .12, child: Container(height: size * .35, width: size * .08, color: AppColors.red)),
            Positioned(bottom: size * .03, right: size * .12, child: Container(height: size * .35, width: size * .08, color: AppColors.red)),
          ],
        ),
        if (showTitle) ...[
          const SizedBox(height: 12),
          Text('مدرج', style: TextStyle(color: AppColors.black, fontSize: size * .34, fontWeight: FontWeight.w900, height: 1)),
          const SizedBox(height: 4),
          Text('حيث يجتمع الشغف', style: TextStyle(color: AppColors.red, fontSize: size * .12, fontWeight: FontWeight.w900)),
        ],
      ],
    );
  }
}

class AppScreenHeader extends StatelessWidget implements PreferredSizeWidget {
  const AppScreenHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.actions = const [],
    this.showPattern = true,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final List<Widget> actions;
  final bool showPattern;

  double get _toolbarHeight => subtitle == null ? 58 : 74;
  double get _patternHeight => showPattern ? 20 : 0;

  @override
  Size get preferredSize => Size.fromHeight(_toolbarHeight + _patternHeight);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: _toolbarHeight,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                children: [
                  SizedBox(width: 48, child: leading ?? const SizedBox.shrink()),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                        if (subtitle != null) ...[
                          const SizedBox(height: 3),
                          Text(subtitle!, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: AppColors.muted, fontWeight: FontWeight.w600)),
                        ],
                      ],
                    ),
                  ),
                  SizedBox(width: actions.isEmpty ? 48 : 48.0 * actions.length, child: Row(mainAxisAlignment: MainAxisAlignment.end, children: actions)),
                ],
              ),
            ),
          ),
          if (showPattern) const SaduStrip(height: 20),
        ],
      ),
    );
  }
}

class MadrajCard extends StatelessWidget {
  const MadrajCard({super.key, required this.child, this.padding = const EdgeInsets.all(14), this.margin});

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(.045), blurRadius: 18, offset: const Offset(0, 8))],
      ),
      child: child,
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.title, this.subtitle, this.icon = Icons.inbox_outlined});

  final String title;
  final String? subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 54, color: AppColors.muted.withOpacity(.55)),
            const SizedBox(height: 12),
            Text(title, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
            if (subtitle != null) ...[
              const SizedBox(height: 6),
              Text(subtitle!, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.muted, height: 1.5)),
            ],
          ],
        ),
      ),
    );
  }
}
