import 'package:workmanager/workmanager.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:aurum/core/services/gold_api_service.dart';
import 'package:aurum/core/services/storage_service.dart';
import 'package:aurum/core/services/widget_service.dart';
import 'package:aurum/data/models/gold_history_model.dart';
import 'package:aurum/data/models/gold_price_model.dart';
import 'package:aurum/core/utils/app_logger.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      AppLogger.i('BACKGROUND SYNC STARTED: $task');

      // Initialize Hive for background isolate
      await Hive.initFlutter();
      
      // Initialize StorageService (this registers adapters and opens the box)
      await StorageService().init();

      // Fetch Live Data
      final freshData = await GoldApiService().fetchLiveGoldPrice();

      final newRecord = GoldHistoryModel(
        goldPrice: freshData,
        fetchTimestamp: freshData.timestamp,
      );
      await StorageService().cacheLatestLivePrice(newRecord);

      // Update Widget Data
      await WidgetService.updateGoldPriceWidget(freshData);

      // Fetch Market History
      try {
        final to = DateTime.now();
        final from = to.subtract(const Duration(days: 30));
        final bars = await GoldApiService().fetchHistoricalBars(from: from, to: to);
        
        if (bars.isNotEmpty) {
          final latestUsdPerGram = bars.last.close / 31.1034768;
          final conversionMultiplier = freshData.priceGram24k / latestUsdPerGram;
          
          final marketHistory = bars.map((bar) {
            final barUsdPerGram = bar.close / 31.1034768;
            final price24k = barUsdPerGram * conversionMultiplier;
            final price22k = price24k * (22.0 / 24.0);
            
            return GoldHistoryModel(
              goldPrice: GoldPriceModel(
                currency: 'INR',
                timestamp: bar.barStart.toIso8601String(),
                priceGram24k: price24k,
                priceGram22k: price22k,
                priceGram21k: 0.0,
                priceGram20k: 0.0,
                priceGram18k: 0.0,
                priceGram16k: 0.0,
                priceGram14k: 0.0,
                priceGram10k: 0.0,
              ),
              fetchTimestamp: bar.barStart.toIso8601String(),
            );
          }).toList();
          
          await StorageService().saveMarketHistory(marketHistory);
        }
      } catch (e) {
        AppLogger.e('Background: Failed to fetch market history', e);
      }

      AppLogger.i('BACKGROUND SYNC SUCCESS');
      return Future.value(true);
    } catch (e) {
      AppLogger.e('BACKGROUND SYNC FAILED', e);
      return Future.value(false); // Return false on failure so WorkManager can retry if configured
    }
  });
}

class BackgroundService {
  static const String syncTaskName = 'aurum_gold_price_sync';

  static final BackgroundService _instance = BackgroundService._internal();

  factory BackgroundService() {
    return _instance;
  }

  BackgroundService._internal();

  Future<void> init() async {
    await Workmanager().initialize(
      callbackDispatcher,
    );

    await Workmanager().registerPeriodicTask(
      '1', // unique name
      syncTaskName,
      frequency: const Duration(minutes: 30),
      constraints: Constraints(
        networkType: NetworkType.connected, // Only run if connected to network
      ),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.keep, // Do not duplicate tasks
    );
    
    AppLogger.i('BackgroundService initialized');
  }
}
