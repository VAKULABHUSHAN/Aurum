import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:aurum/core/constants/app_colors.dart';
import 'package:aurum/core/services/storage_service.dart';
import 'package:aurum/core/services/theme_service.dart';
import 'package:aurum/core/theme/app_theme.dart';
import 'package:aurum/data/models/chart_range.dart';
import 'package:aurum/data/models/indian_gold_rate_model.dart';
import 'package:aurum/data/models/price_movement.dart';
import 'package:aurum/features/home/views/widgets/chart_range_selector.dart';
import 'package:aurum/features/home/views/widgets/main_price_card.dart';
import 'package:aurum/features/home/views/widgets/secondary_price_card.dart';
import 'package:aurum/features/home/views/widgets/price_movement_badge.dart';
import 'package:aurum/features/home/views/widgets/price_history_card.dart';

void main() {
  late Directory tempDir;

  final samplePrice = IndianGoldRateModel(
    price24kPerGram: 8450.50,
    price22kPerGram: 7746.29,
    price18kPerGram: 6337.88,
    timestamp: '2026-08-09T10:30:00Z',
    source: 'IBJA Benchmark',
    unit: 'INR/g',
    session: 'AM',
    rateDate: '2026-08-09',
  );

  setUp(() async {
    Get.reset();
    tempDir = await Directory.systemTemp.createTemp('hive_theme_test_');
    Hive.init(tempDir.path);
    await StorageService().init();
  });

  tearDown(() async {
    await Hive.deleteFromDisk();
    try {
      if (tempDir.existsSync()) {
        await tempDir.delete(recursive: true);
      }
    } catch (_) {}
  });

  group('StorageService Theme Mode Persistence Tests', () {
    test('Default theme mode is ThemeMode.system', () {
      expect(StorageService().getThemeMode(), ThemeMode.system);
    });

    test('Persists and retrieves Light theme mode', () async {
      await StorageService().setThemeMode(ThemeMode.light);
      expect(StorageService().getThemeMode(), ThemeMode.light);
    });

    test('Persists and retrieves Dark theme mode', () async {
      await StorageService().setThemeMode(ThemeMode.dark);
      expect(StorageService().getThemeMode(), ThemeMode.dark);
    });

    test('Persists and retrieves System theme mode', () async {
      await StorageService().setThemeMode(ThemeMode.dark);
      expect(StorageService().getThemeMode(), ThemeMode.dark);
      await StorageService().setThemeMode(ThemeMode.system);
      expect(StorageService().getThemeMode(), ThemeMode.system);
    });
  });

  group('ThemeService Tests', () {
    test('Initializes with default stored theme and switches theme', () async {
      final service = Get.put(ThemeService());
      expect(service.themeMode, ThemeMode.system);

      await service.switchTheme(ThemeMode.dark);
      expect(service.themeMode, ThemeMode.dark);
      expect(service.isDarkMode, isTrue);
      expect(StorageService().getThemeMode(), ThemeMode.dark);

      await service.switchTheme(ThemeMode.light);
      expect(service.themeMode, ThemeMode.light);
      expect(service.isDarkMode, isFalse);
      expect(StorageService().getThemeMode(), ThemeMode.light);
    });
  });

  group('AppTheme Configuration Tests', () {
    test('Light theme has correct Brightness, colors and Material 3 enabled', () {
      final light = AppTheme.lightTheme;
      expect(light.useMaterial3, isTrue);
      expect(light.brightness, Brightness.light);
      expect(light.scaffoldBackgroundColor, AppColors.backgroundLight);
      expect(light.colorScheme.surface, AppColors.surfaceLight);
      expect(light.colorScheme.onSurface, AppColors.primaryTextLight);
      expect(light.colorScheme.primary, AppColors.primary);
    });

    test('Dark theme has correct Brightness, colors and Material 3 enabled', () {
      final dark = AppTheme.darkTheme;
      expect(dark.useMaterial3, isTrue);
      expect(dark.brightness, Brightness.dark);
      expect(dark.scaffoldBackgroundColor, AppColors.backgroundDark);
      expect(dark.colorScheme.surface, AppColors.surfaceDark);
      expect(dark.colorScheme.onSurface, AppColors.primaryTextDark);
      expect(dark.colorScheme.primary, AppColors.primary);
    });
  });

  group('AppColors Context Helpers Tests', () {
    testWidgets('Returns light colors when Theme is light', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Builder(
            builder: (context) {
              expect(AppColors.surfaceOf(context), AppColors.surfaceLight);
              expect(AppColors.backgroundOf(context), AppColors.backgroundLight);
              expect(AppColors.primaryTextOf(context), AppColors.primaryTextLight);
              expect(AppColors.secondaryTextOf(context), AppColors.secondaryTextLight);
              expect(AppColors.borderOf(context), AppColors.borderLight);
              expect(AppColors.neutralLightOf(context), AppColors.neutralLightBg);
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('Returns dark colors when Theme is dark', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Builder(
            builder: (context) {
              expect(AppColors.surfaceOf(context), AppColors.surfaceDark);
              expect(AppColors.backgroundOf(context), AppColors.backgroundDark);
              expect(AppColors.primaryTextOf(context), AppColors.primaryTextDark);
              expect(AppColors.secondaryTextOf(context), AppColors.secondaryTextDark);
              expect(AppColors.borderOf(context), AppColors.borderDark);
              expect(AppColors.neutralLightOf(context), AppColors.neutralDarkBg);
              return const SizedBox();
            },
          ),
        ),
      );
    });
  });

  group('Widget Theme Adaptation Tests', () {
    testWidgets('MainPriceCard renders properly in Dark Theme', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: MainPriceCard(
              priceData: samplePrice,
              movement: const PriceMovement(amountChange: 25.0, percentageChange: 0.3),
              lastUpdated: '02:30 PM',
              isOffline: false,
            ),
          ),
        ),
      );

      expect(find.text('24K Gold • India'), findsOneWidget);
      expect(find.text('₹8,450.50'), findsOneWidget);
      expect(find.text('per gram'), findsOneWidget);
      expect(find.text('Updated at 02:30 PM'), findsOneWidget);
      expect(find.text('IBJA Benchmark · Indicative'), findsOneWidget);
      expect(find.text('↑ ₹25.00 (+0.30%)'), findsOneWidget);
    });

    testWidgets('SecondaryPriceCard renders properly in Dark Theme', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: SecondaryPriceCard(priceData: samplePrice),
          ),
        ),
      );

      expect(find.text('22K Gold • India'), findsOneWidget);
      expect(find.text('₹7,746.29'), findsOneWidget);
      expect(find.text('per gram'), findsOneWidget);
    });

    testWidgets('PriceMovementBadge adapts colors in Light and Dark themes', (WidgetTester tester) async {
      // Light Mode test
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: PriceMovementBadge(
              movement: PriceMovement(amountChange: 10.0, percentageChange: 0.12),
            ),
          ),
        ),
      );
      expect(find.text('↑ ₹10.00 (+0.12%)'), findsOneWidget);

      // Dark Mode test
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: const Scaffold(
            body: PriceMovementBadge(
              movement: PriceMovement(amountChange: -10.0, percentageChange: -0.12),
            ),
          ),
        ),
      );
      expect(find.text('↓ ₹10.00 (-0.12%)'), findsOneWidget);
    });

    testWidgets('ChartRangeSelector renders and triggers range selection in Dark Theme', (WidgetTester tester) async {
      ChartRange selected = ChartRange.week7d;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return ChartRangeSelector(
                  selectedRange: selected,
                  onRangeSelected: (range) {
                    setState(() {
                      selected = range;
                    });
                  },
                );
              },
            ),
          ),
        ),
      );

      expect(find.text('7D'), findsOneWidget);
      expect(find.text('30D'), findsOneWidget);

      await tester.tap(find.text('30D'));
      await tester.pumpAndSettle();
      expect(selected, ChartRange.month30d);
    });

    testWidgets('PriceHistoryCard renders in Dark Theme', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: PriceHistoryCard(
              history: [samplePrice],
              selectedRange: ChartRange.week7d,
              onRangeSelected: (_) {},
              highPrice: null,
              lowPrice: null,
            ),
          ),
        ),
      );

      expect(find.text('Price History'), findsOneWidget);
      expect(find.text('Building price history...'), findsOneWidget);
    });
  });
}
