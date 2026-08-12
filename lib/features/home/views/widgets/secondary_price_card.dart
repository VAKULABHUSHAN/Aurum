import 'package:flutter/material.dart';
import 'package:aurum/core/constants/app_colors.dart';
import 'package:aurum/core/constants/app_radius.dart';
import 'package:aurum/core/constants/app_spacing.dart';
import 'package:aurum/core/theme/app_text_styles.dart';
import 'package:aurum/core/utils/currency_formatter.dart';
import 'package:aurum/data/models/indian_gold_rate_model.dart';

class SecondaryPriceCard extends StatelessWidget {
  final IndianGoldRateModel priceData;

  const SecondaryPriceCard({
    super.key,
    required this.priceData,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.roundedMedium,
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.6),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              const Text(
                '22K Gold • India',
                style: AppTextStyles.cardTitle,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            CurrencyFormatter.formatPrice(priceData.price22kPerGram),
            style: AppTextStyles.priceMedium,
          ),
          const SizedBox(height: AppSpacing.xs),
          const Text(
            'per gram',
            style: AppTextStyles.subtitle,
          ),
        ],
      ),
    );
  }
}
