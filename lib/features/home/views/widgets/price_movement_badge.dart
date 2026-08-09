import 'package:flutter/material.dart';
import 'package:aurum/core/constants/app_colors.dart';
import 'package:aurum/core/constants/app_radius.dart';
import 'package:aurum/core/theme/app_text_styles.dart';
import 'package:aurum/core/utils/currency_formatter.dart';
import 'package:aurum/data/models/price_movement.dart';

class PriceMovementBadge extends StatelessWidget {
  final PriceMovement movement;

  const PriceMovementBadge({
    super.key,
    required this.movement,
  });

  @override
  Widget build(BuildContext context) {
    final Color textColor;
    final Color backgroundColor;

    if (movement.isPositive) {
      textColor = AppColors.success;
      backgroundColor = AppColors.successLight;
    } else if (movement.isNegative) {
      textColor = AppColors.error;
      backgroundColor = AppColors.errorLight;
    } else {
      textColor = AppColors.neutral;
      backgroundColor = AppColors.neutralLight;
    }

    final changeText = CurrencyFormatter.formatChange(movement.amountChange);
    final percentageText = CurrencyFormatter.formatPercentage(movement.percentageChange);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: AppRadius.roundedSmall,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$changeText ($percentageText)',
            style: AppTextStyles.movement.copyWith(color: textColor),
          ),
        ],
      ),
    );
  }
}
