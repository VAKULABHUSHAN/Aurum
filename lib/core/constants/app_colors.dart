import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary brand color - Gold
  static const Color primary = Color(0xFFD4AF37); // Gold
  static const Color primaryDark = Color(0xFFE5C158); // Slightly brighter gold for dark mode contrast

  // Light Palette
  static const Color backgroundLight = Color(0xFFFAFAFA);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color primaryTextLight = Color(0xFF1E1E1E);
  static const Color secondaryTextLight = Color(0xFF757575);
  static const Color borderLight = Color(0xFFE8E8E8);
  static const Color neutralLightBg = Color(0xFFF5F5F5);

  static const Color successLight = Color(0xFF2E7D32);
  static const Color successBgLight = Color(0xFFE8F5E9);
  static const Color errorLightColor = Color(0xFFD32F2F);
  static const Color errorBgLight = Color(0xFFFFEBEE);
  static const Color neutralTextLight = Color(0xFF757575);

  // Dark Palette
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color primaryTextDark = Color(0xFFF5F5F5);
  static const Color secondaryTextDark = Color(0xFF9E9E9E);
  static const Color borderDark = Color(0xFF2C2C2C);
  static const Color neutralDarkBg = Color(0xFF2A2A2A);

  static const Color successDark = Color(0xFF81C784);
  static const Color successBgDark = Color(0xFF1B3320);
  static const Color errorDarkColor = Color(0xFFE57373);
  static const Color errorBgDark = Color(0xFF381B1E);
  static const Color neutralTextDark = Color(0xFF9E9E9E);

  // Legacy / Default constants (maintained for backward compatibility)
  static const Color background = backgroundLight;
  static const Color surface = surfaceLight;
  static const Color primaryText = primaryTextLight;
  static const Color secondaryText = secondaryTextLight;
  static const Color border = borderLight;
  static const Color error = errorLightColor;
  static const Color errorLight = errorBgLight;
  static const Color success = successLight;
  static const Color neutral = neutralTextLight;
  static const Color neutralLight = neutralLightBg;

  // Context-aware color helpers
  static Color surfaceOf(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? surfaceDark : surfaceLight;

  static Color backgroundOf(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? backgroundDark : backgroundLight;

  static Color primaryTextOf(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? primaryTextDark : primaryTextLight;

  static Color secondaryTextOf(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? secondaryTextDark : secondaryTextLight;

  static Color borderOf(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? borderDark : borderLight;

  static Color neutralLightOf(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? neutralDarkBg : neutralLightBg;

  static Color cardShadowOf(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0x33000000)
          : const Color(0x08000000);
}
