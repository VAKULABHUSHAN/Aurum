import 'package:flutter/material.dart';
import 'package:aurum/core/constants/app_colors.dart';
import 'package:aurum/core/constants/app_radius.dart';
import 'package:aurum/core/constants/app_spacing.dart';
import 'package:aurum/core/theme/app_text_styles.dart';
import 'package:aurum/core/utils/currency_formatter.dart';
import 'package:aurum/core/utils/date_formatter.dart';
import 'package:aurum/data/models/indian_gold_rate_model.dart';
import 'package:aurum/data/models/price_movement.dart';
import 'package:aurum/features/home/views/widgets/price_movement_badge.dart';

class MainPriceCard extends StatelessWidget {
  final IndianGoldRateModel priceData;
  final PriceMovement? movement;
  final String lastUpdated;
  final bool isOffline;

  const MainPriceCard({
    super.key,
    required this.priceData,
    required this.movement,
    required this.lastUpdated,
    required this.isOffline,
  });

  @override
  Widget build(BuildContext context) {
    final formattedTime = lastUpdated.isNotEmpty
        ? lastUpdated
        : DateFormatter.formatDate(priceData.timestamp);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceOf(context),
        borderRadius: AppRadius.roundedMedium,
        border: Border.all(color: AppColors.borderOf(context), width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadowOf(context),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    '24K Gold • India',
                    style: AppTextStyles.cardTitleOf(context),
                  ),
                ],
              ),
              if (isOffline)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.neutralLightOf(context),
                    borderRadius: AppRadius.roundedSmall,
                    border: Border.all(color: AppColors.borderOf(context)),
                  ),
                  child: Text(
                    'Offline Data',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppColors.secondaryTextOf(context),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            CurrencyFormatter.formatPrice(priceData.price24kPerGram),
            style: AppTextStyles.priceLargeOf(context),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'per gram',
            style: AppTextStyles.subtitleOf(context),
          ),
          if (movement != null) ...[
            const SizedBox(height: AppSpacing.md),
            PriceMovementBadge(movement: movement!),
          ],
          const SizedBox(height: AppSpacing.lg),
          Divider(height: 1, color: AppColors.borderOf(context)),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Updated at $formattedTime',
                style: AppTextStyles.labelOf(context),
              ),
              Text(
                'IBJA Benchmark · Indicative',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppColors.secondaryTextOf(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
