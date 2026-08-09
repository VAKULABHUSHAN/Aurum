import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:aurum/core/services/storage_service.dart';
import 'package:aurum/data/models/gold_price_model.dart';
import 'package:aurum/data/models/gold_history_model.dart';
import 'package:aurum/data/models/chart_range.dart';
import 'package:aurum/features/home/controller/home_controller.dart';

void main() {
  late Directory tempDir;

  GoldPriceModel createPrice(double price24k, String timestamp) {
    return GoldPriceModel(
      currency: 'INR',
      timestamp: timestamp,
      priceGram24k: price24k,
      priceGram22k: price24k * 0.916,
      priceGram21k: price24k * 0.875,
      priceGram20k: price24k * 0.833,
      priceGram18k: price24k * 0.750,
      priceGram16k: price24k * 0.666,
      priceGram14k: price24k * 0.583,
      priceGram10k: price24k * 0.416,
    );
  }

  setUp(() async {
    Get.reset();
    tempDir = await Directory.systemTemp.createTemp('hive_chart_test_');
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

  group('HomeController Chart History Tests', () {
    test('Default chart range is 24H and empty when no records exist', () async {
      final controller = HomeController();
      expect(controller.selectedRange.value, ChartRange.day24h);
      expect(controller.chartHistory, isEmpty);
      expect(controller.chartHigh.value, isNull);
      expect(controller.chartLow.value, isNull);
    });

    test('Filters records by range (24H vs 7D vs 30D)', () async {
      final now = DateTime.now();
      final storage = StorageService();

      // Record 1: 2 hours ago (within 24H, 7D, 30D)
      final time2h = now.subtract(const Duration(hours: 2)).toIso8601String();
      await storage.saveGoldHistory(GoldHistoryModel(
        goldPrice: createPrice(8400.0, time2h),
        fetchTimestamp: time2h,
      ));

      // Record 2: 10 hours ago (within 24H, 7D, 30D)
      final time10h = now.subtract(const Duration(hours: 10)).toIso8601String();
      await storage.saveGoldHistory(GoldHistoryModel(
        goldPrice: createPrice(8450.0, time10h),
        fetchTimestamp: time10h,
      ));

      // Record 3: 3 days ago (outside 24H, within 7D, 30D)
      final time3d = now.subtract(const Duration(days: 3)).toIso8601String();
      await storage.saveGoldHistory(GoldHistoryModel(
        goldPrice: createPrice(8300.0, time3d),
        fetchTimestamp: time3d,
      ));

      // Record 4: 15 days ago (outside 24H and 7D, within 30D)
      final time15d = now.subtract(const Duration(days: 15)).toIso8601String();
      await storage.saveGoldHistory(GoldHistoryModel(
        goldPrice: createPrice(8200.0, time15d),
        fetchTimestamp: time15d,
      ));

      final controller = HomeController();
      controller.updateChartData();

      // 24H range
      controller.setChartRange(ChartRange.day24h);
      expect(controller.chartHistory.length, 2);
      expect(controller.chartHigh.value, 8450.0);
      expect(controller.chartLow.value, 8400.0);

      // 7D range
      controller.setChartRange(ChartRange.week7d);
      expect(controller.chartHistory.length, 3);
      expect(controller.chartHigh.value, 8450.0);
      expect(controller.chartLow.value, 8300.0);

      // 30D range
      controller.setChartRange(ChartRange.month30d);
      expect(controller.chartHistory.length, 4);
      expect(controller.chartHigh.value, 8450.0);
      expect(controller.chartLow.value, 8200.0);
    });

    test('Deduplicates records with identical timestamp and keeps latest record deterministically', () async {
      final now = DateTime.now();
      final storage = StorageService();
      final fixedTimestamp = now.subtract(const Duration(hours: 5)).toIso8601String();

      // Same timestamp, different price
      await storage.saveGoldHistory(GoldHistoryModel(
        goldPrice: createPrice(8350.0, fixedTimestamp),
        fetchTimestamp: fixedTimestamp,
      ));

      final time1h = now.subtract(const Duration(hours: 1)).toIso8601String();
      await storage.saveGoldHistory(GoldHistoryModel(
        goldPrice: createPrice(8420.0, time1h),
        fetchTimestamp: time1h,
      ));

      final controller = HomeController();
      controller.updateChartData();
      expect(controller.chartHistory.length, 2);
      expect(controller.chartHigh.value, 8420.0);
      expect(controller.chartLow.value, 8350.0);
    });

    test('High / Low are null when fewer than 2 records in range', () async {
      final now = DateTime.now();
      final storage = StorageService();
      final time1h = now.subtract(const Duration(hours: 1)).toIso8601String();

      await storage.saveGoldHistory(GoldHistoryModel(
        goldPrice: createPrice(8420.0, time1h),
        fetchTimestamp: time1h,
      ));

      final controller = HomeController();
      controller.updateChartData();
      expect(controller.chartHistory.length, 1);
      expect(controller.chartHigh.value, isNull);
      expect(controller.chartLow.value, isNull);
    });

    test('Uses market history for 7D and 30D, and app-observed history for 24H', () async {
      final now = DateTime.now();
      final storage = StorageService();

      // App-observed history (24H)
      final time1h = now.subtract(const Duration(hours: 1)).toIso8601String();
      await storage.saveGoldHistory(GoldHistoryModel(
        goldPrice: createPrice(8400.0, time1h),
        fetchTimestamp: time1h,
      ));
      final time2h = now.subtract(const Duration(hours: 2)).toIso8601String();
      await storage.saveGoldHistory(GoldHistoryModel(
        goldPrice: createPrice(8450.0, time2h),
        fetchTimestamp: time2h,
      ));

      // Market history (7D / 30D)
      final time2d = now.subtract(const Duration(days: 2)).toIso8601String();
      final time5d = now.subtract(const Duration(days: 5)).toIso8601String();
      final time15d = now.subtract(const Duration(days: 15)).toIso8601String();
      
      await storage.saveMarketHistory([
        GoldHistoryModel(goldPrice: createPrice(8000.0, time2d), fetchTimestamp: time2d),
        GoldHistoryModel(goldPrice: createPrice(8100.0, time5d), fetchTimestamp: time5d),
        GoldHistoryModel(goldPrice: createPrice(8200.0, time15d), fetchTimestamp: time15d),
      ]);

      final controller = HomeController();
      controller.updateChartData();

      // 24H should use app-observed history (length 2)
      controller.setChartRange(ChartRange.day24h);
      controller.updateChartData(); // forcefully update since setChartRange might return early
      expect(controller.chartHistory.length, 2);
      expect(controller.chartHigh.value, 8450.0);
      expect(controller.chartLow.value, 8400.0);

      // 7D should use market history (length 2 because 15d is excluded)
      controller.setChartRange(ChartRange.week7d);
      expect(controller.chartHistory.length, 2);
      expect(controller.chartHigh.value, 8100.0);
      expect(controller.chartLow.value, 8000.0);

      // 30D should use market history (length 3)
      controller.setChartRange(ChartRange.month30d);
      expect(controller.chartHistory.length, 3);
      expect(controller.chartHigh.value, 8200.0);
      expect(controller.chartLow.value, 8000.0);
    });
  });
}
