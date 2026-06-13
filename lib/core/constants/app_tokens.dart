import 'package:flutter/material.dart';

abstract final class AppColors {
  static const primary = Color(0xFF071B4D);
  static const primaryPressed = Color(0xFF041236);
  static const background = Color(0xFFF7F8FA);
  static const backgroundSubtle = Color(0xFFF2F4F7);
  static const cardBackground = Color(0xFFFFFFFF);
  static const textPrimary = Color(0xFF0B1020);
  static const textSecondary = Color(0xFF667085);
  static const textTertiary = Color(0xFF98A2B3);
  static const border = Color(0xFFE4E7EC);
  static const borderStrong = Color(0xFFD0D5DD);
  static const success = Color(0xFF12B76A);
  static const successBackground = Color(0xFFECFDF3);
  static const error = Color(0xFFF04438);
  static const errorBackground = Color(0xFFFEF3F2);
  static const link = Color(0xFF2563EB);
  static const warning = Color(0xFFF79009);
  static const warningBackground = Color(0xFFFFFAEB);
  static const shadow = Color(0x1A101828);
}

abstract final class AppSpacing {
  static const screenPadding = 24.0;
  static const cardPadding = 18.0;
  static const itemGap = 12.0;
  static const sectionGap = 28.0;
  static const bottomSafePadding = 20.0;
}

abstract final class AppRadius {
  static const card = 18.0;
  static const input = 14.0;
  static const button = 14.0;
  static const badge = 999.0;
}

abstract final class AppSizes {
  static const buttonHeight = 54.0;
}
