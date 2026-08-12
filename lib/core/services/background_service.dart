import 'package:workmanager/workmanager.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:aurum/core/services/gold_api_service.dart';
import 'package:aurum/core/services/storage_service.dart';
import 'package:aurum/core/services/widget_service.dart';
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
      final freshData = await GoldApiService().fetchIndianGoldRates();

      await StorageService().cacheLatestLivePrice(freshData);

      // Update Widget Data
      // (WidgetService will be updated separately to accept IndianGoldRateModel)
      await WidgetService.updateGoldPriceWidget(freshData);

      // Add to Market History locally (Since API historical data is unavailable)
      try {
        final currentHistory = StorageService().getMarketHistory();
        currentHistory.add(freshData);
        await StorageService().saveMarketHistory(currentHistory);
      } catch (e) {
        AppLogger.e('Background: Failed to update market history', e);
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
