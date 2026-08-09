import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aurum/core/constants/app_spacing.dart';
import 'package:aurum/core/constants/app_colors.dart';
import 'package:aurum/core/theme/app_text_styles.dart';
import 'package:aurum/features/home/controller/home_controller.dart';
import 'package:aurum/features/home/views/widgets/main_price_card.dart';
import 'package:aurum/features/home/views/widgets/secondary_price_card.dart';
import 'package:aurum/features/home/views/widgets/price_history_card.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        scrolledUnderElevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: const [
            Text(
              'Aurum',
              style: AppTextStyles.headingMedium,
            ),
            Text(
              'Gold Price Tracker',
              style: AppTextStyles.label,
            ),
          ],
        ),
        actions: [
          Obx(() {
            final isRefreshing = controller.isRefreshing.value;
            return IconButton(
              icon: isRefreshing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary,
                      ),
                    )
                  : const Icon(
                      Icons.refresh_rounded,
                      color: AppColors.primaryText,
                    ),
              tooltip: 'Refresh price',
              onPressed: isRefreshing ? null : controller.refreshData,
            );
          }),
          const SizedBox(width: AppSpacing.xs),
        ],
      ),
      body: SafeArea(
        child: Obx(() {
          // 1. Initial loading state (only when there is NO cached data)
          if (controller.isLoading.value && controller.goldPrice.value == null) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            );
          }

          // 2. Error state (only when there is NO cached data)
          if (controller.errorMessage.value.isNotEmpty && controller.goldPrice.value == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      size: 48,
                      color: AppColors.error,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      controller.errorMessage.value,
                      style: AppTextStyles.body,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    OutlinedButton(
                      onPressed: controller.refreshData,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          // 3. Display Dashboard (cached or live data)
          final priceData = controller.goldPrice.value;
          if (priceData == null) {
            return const SizedBox.shrink();
          }

          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async {
              controller.refreshData();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  MainPriceCard(
                    priceData: priceData,
                    movement: controller.priceMovement.value,
                    lastUpdated: controller.lastUpdated.value,
                    isOffline: controller.isOfflineData.value,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  SecondaryPriceCard(
                    priceData: priceData,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  PriceHistoryCard(
                    history: controller.chartHistory,
                    selectedRange: controller.selectedRange.value,
                    onRangeSelected: controller.setChartRange,
                    highPrice: controller.chartHigh.value,
                    lowPrice: controller.chartLow.value,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
