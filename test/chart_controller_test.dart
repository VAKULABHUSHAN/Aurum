import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:aurum/core/services/storage_service.dart';
import 'package:aurum/data/models/indian_gold_rate_model.dart';
import 'package:aurum/data/models/chart_range.dart';
import 'package:aurum/features/home/controller/home_controller.dart';

void main() {
  late Directory tempDir;

  IndianGoldRateModel createPrice(double price24k, String timestamp, String session) {
    return IndianGoldRateModel(
      price24kPerGram: price24k,
      price22kPerGram: price24k * 0.916,
      price18kPerGram: price24k * 0.750,
      timestamp: timestamp,
      source: 'IBJA Benchmark',
      unit: 'INR/g',
      session: session,
      rateDate: timestamp.split('T')[0],
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
    test('Default chart range is 7D and empty when no records exist', () async {
      final controller = HomeController();
      expect(controller.selectedRange.value, ChartRange.week7d);
      expect(controller.chartHistory, isEmpty);
      expect(controller.chartHigh.value, isNull);
      expect(controller.chartLow.value, isNull);
    });

    test('Filters records by range (7D vs 30D)', () async {
      final now = DateTime.now();
      final storage = StorageService();

      // Record 1: 2 hours ago (within 7D, 30D)
      final time2h = now.subtract(const Duration(hours: 2)).toIso8601String();
      // Record 2: 3 days ago (within 7D, 30D)
      final time3d = now.subtract(const Duration(days: 3)).toIso8601String();
      // Record 3: 15 days ago (outside 7D, within 30D)
      final time15d = now.subtract(const Duration(days: 15)).toIso8601String();
      // Record 4: 40 days ago (outside 30D)
      final time40d = now.subtract(const Duration(days: 40)).toIso8601String();

      await storage.saveMarketHistory([
        createPrice(8400.0, time2h, 'PM'),
        createPrice(8300.0, time3d, 'PM'),
        createPrice(8200.0, time15d, 'PM'),
        createPrice(8100.0, time40d, 'PM'),
      ]);

      final controller = HomeController();
      controller.updateChartData();

      // 7D range
      controller.setChartRange(ChartRange.week7d);
      expect(controller.chartHistory.length, 2);
      expect(controller.chartHigh.value, 8400.0);
      expect(controller.chartLow.value, 8300.0);

      // 30D range
      controller.setChartRange(ChartRange.month30d);
      expect(controller.chartHistory.length, 3);
      expect(controller.chartHigh.value, 8400.0);
      expect(controller.chartLow.value, 8200.0);
    });

    test('Deduplicates records with identical timestamp and keeps latest record deterministically', () async {
      final now = DateTime.now();
      final storage = StorageService();
      final fixedTimestamp = now.subtract(const Duration(hours: 5)).toIso8601String();

      // Same timestamp, different price. saveMarketHistory will handle it.
      await storage.saveMarketHistory([
        createPrice(8350.0, fixedTimestamp, 'AM')
      ]);
      await storage.saveMarketHistory([
        createPrice(8420.0, fixedTimestamp, 'PM')
      ]);

      final controller = HomeController();
      controller.updateChartData();
      
      // Because rateDate + session are used for uniqueness in uniqueByTimestamp... wait!
      // In HomeController updateChartData we used: `uniqueByTimestamp[dateKey] = record;` (PM overwrites AM)
      expect(controller.chartHistory.length, 1);
      expect(controller.chartHigh.value, isNull); // only 1 record, so high/low are null
      expect(controller.chartHistory.first.price24kPerGram, 8420.0);
    });

    test('High / Low are null when fewer than 2 records in range', () async {
      final now = DateTime.now();
      final storage = StorageService();
      final time1h = now.subtract(const Duration(hours: 1)).toIso8601String();

      await storage.saveMarketHistory([
        createPrice(8420.0, time1h, 'PM')
      ]);

      final controller = HomeController();
      controller.updateChartData();
      expect(controller.chartHistory.length, 1);
      expect(controller.chartHigh.value, isNull);
      expect(controller.chartLow.value, isNull);
    });

    test('Uses exclusively market history for all ranges', () async {
      final now = DateTime.now();
      final storage = StorageService();

      // Market history
      final time2d = now.subtract(const Duration(days: 2)).toIso8601String();
      final time5d = now.subtract(const Duration(days: 5)).toIso8601String();
      final time15d = now.subtract(const Duration(days: 15)).toIso8601String();
      
      await storage.saveMarketHistory([
        createPrice(8000.0, time2d, 'PM'),
        createPrice(8100.0, time5d, 'PM'),
        createPrice(8200.0, time15d, 'PM'),
      ]);

      final controller = HomeController();
      controller.updateChartData();

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
