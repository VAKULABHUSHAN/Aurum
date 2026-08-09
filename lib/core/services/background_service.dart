import 'package:workmanager/workmanager.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:aurum/core/services/gold_api_service.dart';
import 'package:aurum/core/services/storage_service.dart';
import 'package:aurum/core/services/widget_service.dart';
import 'package:aurum/data/models/gold_history_model.dart';
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

      // Deduplication check: handled internally by StorageService.saveGoldHistory if timestamp is exact same.
      // But we also want to avoid saving if the price is identical? The requirement said:
      // "If the newly fetched 24K and 22K prices are identical to the most recent stored snapshot, do not create meaningless duplicate history records. If the existing storage implementation already handles this, reuse it."
      // StorageService.saveGoldHistory handles exact timestamp duplicates. Let's add price checking here or in StorageService.
      // Wait, let's just use what we have, or add a quick check:
      final latestRecord = StorageService().getLatestGoldHistory();
      bool shouldSave = true;
      if (latestRecord != null) {
        if (latestRecord.goldPrice.priceGram24k == freshData.priceGram24k &&
            latestRecord.goldPrice.priceGram22k == freshData.priceGram22k) {
          // It's technically possible prices didn't change.
          AppLogger.i('Background: Prices are identical. Still updating widget, but we might skip saving depending on storage policy.');
          // Actually, we should just let StorageService handle timestamp deduplication.
          // Wait, the prompt explicitly says: "If the newly fetched 24K and 22K prices are identical to the most recent stored snapshot, do not create meaningless duplicate history records."
          shouldSave = false;
        }
      }

      if (shouldSave) {
        final newRecord = GoldHistoryModel(
          goldPrice: freshData,
          fetchTimestamp: freshData.timestamp,
        );
        await StorageService().saveGoldHistory(newRecord);
      }

      // Update Widget Data
      await WidgetService.updateGoldPriceWidget(freshData);

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
