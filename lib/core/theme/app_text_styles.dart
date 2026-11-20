import 'package:flutter/material.dart';
import 'package:aurum/core/constants/app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static const TextStyle headingLarge = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    color: AppColors.primaryTextLight,
    letterSpacing: -0.5,
  );

  static const TextStyle headingMedium = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.primaryTextLight,
    letterSpacing: -0.2,
  );

  static const TextStyle priceLarge = TextStyle(
    fontSize: 48,
    fontWeight: FontWeight.w700,
    color: AppColors.primaryTextLight,
    letterSpacing: -1.0,
  );

  static const TextStyle subtitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.secondaryTextLight,
  );

  static const TextStyle body = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.primaryTextLight,
  );

  static const TextStyle label = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.secondaryTextLight,
  );
  
  static const TextStyle priceMedium = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppColors.primaryTextLight,
    letterSpacing: -0.5,
  );

  static const TextStyle cardTitle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.secondaryTextLight,
    letterSpacing: 0.2,
  );

  static const TextStyle movement = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle badge = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.primary,
  );

  // Context-aware getters
  static TextStyle headingLargeOf(BuildContext context) =>
      headingLarge.copyWith(color: AppColors.primaryTextOf(context));

  static TextStyle headingMediumOf(BuildContext context) =>
      headingMedium.copyWith(color: AppColors.primaryTextOf(context));

  static TextStyle priceLargeOf(BuildContext context) =>
      priceLarge.copyWith(color: AppColors.primaryTextOf(context));

  static TextStyle subtitleOf(BuildContext context) =>
      subtitle.copyWith(color: AppColors.secondaryTextOf(context));

  static TextStyle bodyOf(BuildContext context) =>
      body.copyWith(color: AppColors.primaryTextOf(context));

  static TextStyle labelOf(BuildContext context) =>
      label.copyWith(color: AppColors.secondaryTextOf(context));

  static TextStyle priceMediumOf(BuildContext context) =>
      priceMedium.copyWith(color: AppColors.primaryTextOf(context));

  static TextStyle cardTitleOf(BuildContext context) =>
      cardTitle.copyWith(color: AppColors.secondaryTextOf(context));
}
