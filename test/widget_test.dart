import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:aurum/core/services/storage_service.dart';
import 'package:aurum/data/models/indian_gold_rate_model.dart';
import 'package:aurum/features/home/controller/home_controller.dart';
import 'package:aurum/features/home/views/home_screen.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    Get.reset();
    tempDir = await Directory.systemTemp.createTemp('hive_widget_test_');
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

  testWidgets('HomeScreen renders dashboard with title, 24K and 22K cards', (WidgetTester tester) async {
    final sampleGoldPrice = IndianGoldRateModel(
      price24kPerGram: 8450.50,
      price22kPerGram: 7746.29,
      price18kPerGram: 6337.88,
      timestamp: '2026-08-09T10:00:00Z',
      source: 'IBJA Benchmark',
      unit: 'INR/g',
      session: 'AM',
      rateDate: '2026-08-09',
    );

    await StorageService().cacheLatestLivePrice(sampleGoldPrice);

    final controller = Get.put(HomeController());
    controller.isLoading.value = false;
    controller.isRefreshing.value = false;

    await tester.pumpWidget(
      const GetMaterialApp(
        home: HomeScreen(),
      ),
    );

    await tester.pump();

    // Verify AppBar title and subtitle
    expect(find.text('Aurum'), findsOneWidget);
    expect(find.text('Gold Price Tracker'), findsOneWidget);

    // Verify 24K card
    expect(find.text('24K Gold • India'), findsOneWidget);
    expect(find.text('₹8,450.50'), findsOneWidget);

    // Verify 22K card
    expect(find.text('22K Gold • India'), findsOneWidget);
    expect(find.text('₹7,746.29'), findsOneWidget);

    // Verify units
    expect(find.text('per gram'), findsNWidgets(2));

    // Verify Price History card
    expect(find.text('Price History'), findsOneWidget);
    expect(find.text('7D'), findsOneWidget);
    expect(find.text('30D'), findsOneWidget);
    expect(find.text('24H'), findsNothing);
  });
}
