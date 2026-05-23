import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color red = Color(0xFFC4000B);
  static const Color darkRed = Color(0xFF930007);
  static const Color black = Color(0xFF111111);
  static const Color ink = Color(0xFF242424);
  static const Color muted = Color(0xFF7B7B7B);
  static const Color softMuted = Color(0xFFB8B8B8);
  static const Color border = Color(0xFFE8E8E8);
  static const Color background = Color(0xFFF7F7F7);
  static const Color card = Colors.white;
  static const Color success = Color(0xFF0A7E3F);
  static const Color warning = Color(0xFFFFA000);

  static const LinearGradient redGradient = LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
    colors: [red, darkRed],
  );
}
