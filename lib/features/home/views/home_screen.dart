import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aurum/core/constants/app_spacing.dart';
import 'package:aurum/core/constants/app_colors.dart';
import 'package:aurum/core/constants/app_radius.dart';
import 'package:aurum/core/theme/app_text_styles.dart';
import 'package:aurum/core/services/theme_service.dart';
import 'package:aurum/features/home/controller/home_controller.dart';
import 'package:aurum/features/home/views/widgets/main_price_card.dart';
import 'package:aurum/features/home/views/widgets/secondary_price_card.dart';
import 'package:aurum/features/home/views/widgets/price_history_card.dart';
import 'package:aurum/core/services/notification_service.dart';
import 'package:aurum/core/services/storage_service.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

  Widget _buildThemeOption({
    required BuildContext context,
    required ThemeMode mode,
    required String label,
    required IconData icon,
    required bool isSelected,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (Get.isRegistered<ThemeService>()) {
            ThemeService.to.switchTheme(mode);
          } else {
            Get.changeThemeMode(mode);
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.surfaceOf(context) : Colors.transparent,
            borderRadius: AppRadius.roundedSmall,
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: isDark ? const Color(0x33000000) : const Color(0x0F000000),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? AppColors.primary : AppColors.secondaryTextOf(context),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected
                      ? AppColors.primaryTextOf(context)
                      : AppColors.secondaryTextOf(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSettingsBottomSheet() {
    Get.bottomSheet(
      Builder(builder: (context) {
        return Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.surfaceOf(context),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(AppSpacing.lg)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Settings',
                style: AppTextStyles.headingMediumOf(context),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Theme',
                style: AppTextStyles.cardTitleOf(context),
              ),
              const SizedBox(height: AppSpacing.sm),
              Builder(builder: (context) {
                if (Get.isRegistered<ThemeService>()) {
                  return Obx(() {
                    final currentMode = ThemeService.to.themeMode;
                    return Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: AppColors.neutralLightOf(context),
                        borderRadius: AppRadius.roundedSmall,
                      ),
                      child: Row(
                        children: [
                          _buildThemeOption(
                            context: context,
                            mode: ThemeMode.system,
                            label: 'System',
                            icon: Icons.brightness_auto,
                            isSelected: currentMode == ThemeMode.system,
                          ),
                          _buildThemeOption(
                            context: context,
                            mode: ThemeMode.light,
                            label: 'Light',
                            icon: Icons.light_mode,
                            isSelected: currentMode == ThemeMode.light,
                          ),
                          _buildThemeOption(
                            context: context,
                            mode: ThemeMode.dark,
                            label: 'Dark',
                            icon: Icons.dark_mode,
                            isSelected: currentMode == ThemeMode.dark,
                          ),
                        ],
                      ),
                    );
                  });
                }
                return Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: AppColors.neutralLightOf(context),
                    borderRadius: AppRadius.roundedSmall,
                  ),
                  child: Row(
                    children: [
                      _buildThemeOption(
                        context: context,
                        mode: ThemeMode.system,
                        label: 'System',
                        icon: Icons.brightness_auto,
                        isSelected: false,
                      ),
                      _buildThemeOption(
                        context: context,
                        mode: ThemeMode.light,
                        label: 'Light',
                        icon: Icons.light_mode,
                        isSelected: Theme.of(context).brightness == Brightness.light,
                      ),
                      _buildThemeOption(
                        context: context,
                        mode: ThemeMode.dark,
                        label: 'Dark',
                        icon: Icons.dark_mode,
                        isSelected: Theme.of(context).brightness == Brightness.dark,
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: AppSpacing.lg),
              Divider(height: 1, color: AppColors.borderOf(context)),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Notifications',
                style: AppTextStyles.cardTitleOf(context),
              ),
              const SizedBox(height: AppSpacing.xs),
              StatefulBuilder(
                builder: (context, setState) {
                  final isEnabled = StorageService().getNotificationsEnabled();
                  return SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text('Daily Gold Updates', style: AppTextStyles.bodyOf(context)),
                    subtitle: Text('09:00 AM · 12:00 PM · 08:00 PM', style: AppTextStyles.labelOf(context)),
                    value: isEnabled,
                    activeTrackColor: AppColors.primary.withValues(alpha: 0.3),
                    activeThumbColor: AppColors.primary,
                    onChanged: (value) async {
                      if (value) {
                        final granted = await NotificationService().requestPermission();
                        if (granted) {
                          await StorageService().setNotificationsEnabled(true);
                          await NotificationService().rescheduleAll();
                          setState(() {});
                        } else {
                          Get.snackbar(
                            'Permission Denied',
                            'Please enable notifications in Android Settings to receive gold updates.',
                            backgroundColor: AppColors.errorLightColor.withValues(alpha: 0.1),
                            colorText: AppColors.errorLightColor,
                          );
                        }
                      } else {
                        await StorageService().setNotificationsEnabled(false);
                        await NotificationService().cancelAll();
                        setState(() {});
                      }
                    },
                  );
                },
              ),
              const SizedBox(height: AppSpacing.md),
              // Dev-only test notification button
              TextButton.icon(
                onPressed: () {
                  NotificationService().showTestGoldPriceNotification();
                },
                icon: Icon(Icons.bug_report, color: AppColors.primaryTextOf(context)),
                label: Text('Send Test Notification', style: TextStyle(color: AppColors.primaryTextOf(context))),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        );
      }),
      isScrollControlled: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        scrolledUnderElevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Aurum',
              style: AppTextStyles.headingMediumOf(context),
            ),
            Text(
              'Gold Price Tracker',
              style: AppTextStyles.labelOf(context),
            ),
          ],
        ),
        actions: [
          Builder(builder: (context) {
            if (!Get.isRegistered<ThemeService>()) {
              final isDark = Theme.of(context).brightness == Brightness.dark;
              return IconButton(
                icon: Icon(
                  isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                  color: AppColors.primaryTextOf(context),
                ),
                tooltip: isDark ? 'Switch to Light theme' : 'Switch to Dark theme',
                onPressed: () {
                  Get.changeThemeMode(isDark ? ThemeMode.light : ThemeMode.dark);
                },
              );
            }
            return Obx(() {
              final isDark = ThemeService.to.isDarkMode;
              return IconButton(
                icon: Icon(
                  isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                  color: AppColors.primaryTextOf(context),
                ),
                tooltip: isDark ? 'Switch to Light theme' : 'Switch to Dark theme',
                onPressed: () {
                  ThemeService.to.switchTheme(isDark ? ThemeMode.light : ThemeMode.dark);
                },
              );
            });
          }),
          IconButton(
            icon: Icon(Icons.settings_outlined, color: AppColors.primaryTextOf(context)),
            tooltip: 'Settings',
            onPressed: _showSettingsBottomSheet,
          ),
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
                  : Icon(
                      Icons.refresh_rounded,
                      color: AppColors.primaryTextOf(context),
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
                      style: AppTextStyles.bodyOf(context),
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
