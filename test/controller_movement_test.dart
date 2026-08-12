import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:aurum/core/services/storage_service.dart';
import 'package:aurum/data/models/indian_gold_rate_model.dart';
import 'package:aurum/features/home/controller/home_controller.dart';
import 'package:get/get.dart';

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
    tempDir = await Directory.systemTemp.createTemp('hive_test_');
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

  group('HomeController & StorageService Movement Calculation Tests', () {
    test('calculatePriceMovement returns null when fewer than 2 records exist', () async {
      final storage = StorageService();
      await storage.saveMarketHistory([
        createPrice(8000.0, '2026-08-09T10:00:00Z', 'AM'),
      ]);

      final controller = HomeController();
      expect(controller.calculatePriceMovement(), isNull);
    });

    test('calculatePriceMovement calculates positive movement correctly', () async {
      final storage = StorageService();
      await storage.saveMarketHistory([
        createPrice(8000.0, '2026-08-09T10:00:00Z', 'AM'),
        createPrice(8080.0, '2026-08-10T10:00:00Z', 'AM'),
      ]);

      final controller = HomeController();
      final movement = controller.calculatePriceMovement();

      expect(movement, isNotNull);
      expect(movement!.amountChange, closeTo(80.0, 0.001));
      expect(movement.percentageChange, closeTo(1.0, 0.001));
      expect(movement.isPositive, isTrue);
    });

    test('calculatePriceMovement calculates negative movement correctly', () async {
      final storage = StorageService();
      await storage.saveMarketHistory([
        createPrice(8000.0, '2026-08-09T10:00:00Z', 'AM'),
        createPrice(7920.0, '2026-08-10T10:00:00Z', 'AM'),
      ]);

      final controller = HomeController();
      final movement = controller.calculatePriceMovement();

      expect(movement, isNotNull);
      expect(movement!.amountChange, closeTo(-80.0, 0.001));
      expect(movement.percentageChange, closeTo(-1.0, 0.001));
      expect(movement.isNegative, isTrue);
    });

    test('calculatePriceMovement ignores consecutive duplicate price records and finds prior distinct price', () async {
      final storage = StorageService();
      await storage.saveMarketHistory([
        createPrice(8000.0, '2026-08-08T09:00:00Z', 'AM'),
        createPrice(8100.0, '2026-08-09T10:00:00Z', 'AM'),
        createPrice(8100.0, '2026-08-10T11:00:00Z', 'AM'),
      ]);

      final controller = HomeController();
      final movement = controller.calculatePriceMovement();

      expect(movement, isNotNull);
      // Compares latest 8100 with distinct previous 8000 (diff = +100)
      expect(movement!.amountChange, closeTo(100.0, 0.001));
      expect(movement.percentageChange, closeTo(1.25, 0.001));
    });

    test('calculatePriceMovement returns null if all previous prices are duplicates of current', () async {
      final storage = StorageService();
      await storage.saveMarketHistory([
        createPrice(8000.0, '2026-08-09T09:00:00Z', 'AM'),
        createPrice(8000.0, '2026-08-10T10:00:00Z', 'AM'),
      ]);

      final controller = HomeController();
      final movement = controller.calculatePriceMovement();

      expect(movement, isNull);
    });
  });
}
