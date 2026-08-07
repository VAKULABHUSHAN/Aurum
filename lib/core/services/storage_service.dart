import 'package:hive_flutter/hive_flutter.dart';
import 'package:aurum/data/models/gold_price_model.dart';
import 'package:aurum/data/models/gold_history_model.dart';
import 'package:aurum/core/utils/app_logger.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();

  factory StorageService() {
    return _instance;
  }

  StorageService._internal();

  static const String _boxName = 'gold_price_history';
  Box<GoldHistoryModel>? _box;

  Future<void> init() async {
    Hive.registerAdapter(GoldPriceModelAdapter());
    Hive.registerAdapter(GoldHistoryModelAdapter());
    _box = await Hive.openBox<GoldHistoryModel>(_boxName);
  }

  Future<void> saveGoldHistory(GoldHistoryModel newRecord) async {
    if (_box == null) return;
    
    final latestRecord = getLatestGoldHistory();
    
    // Deduplication logic: Only store if fetchTimestamp is different
    if (latestRecord != null && latestRecord.fetchTimestamp == newRecord.fetchTimestamp) {
      AppLogger.i('Skipping save: Record with timestamp ${newRecord.fetchTimestamp} already exists.');
      return;
    }

    await _box!.add(newRecord);
    AppLogger.i('Saved new gold price history record.');
  }

  GoldHistoryModel? getLatestGoldHistory() {
    if (_box == null || _box!.isEmpty) return null;
    
    // Since we append, the latest is the last item
    return _box!.values.last;
  }
}
