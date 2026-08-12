import 'package:hive_flutter/hive_flutter.dart';
import 'package:aurum/data/models/gold_price_model.dart';
import 'package:aurum/data/models/gold_history_model.dart';
import 'package:aurum/data/models/indian_gold_rate_model.dart';
import 'package:aurum/core/utils/app_logger.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();

  factory StorageService() {
    return _instance;
  }

  StorageService._internal();

  static const String _boxName = 'indian_gold_latest_live_price';
  Box<IndianGoldRateModel>? _box;

  static const String _marketBoxName = 'indian_gold_market_history';
  Box<IndianGoldRateModel>? _marketBox;

  Box<dynamic>? _settingsBox;

  Future<void> init() async {
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(GoldPriceModelAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(GoldHistoryModelAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(IndianGoldRateModelAdapter());
    }
    _box = await Hive.openBox<IndianGoldRateModel>(_boxName);
    _marketBox = await Hive.openBox<IndianGoldRateModel>(_marketBoxName);
    _settingsBox = await Hive.openBox('aurum_settings');
  }

  Future<void> cacheLatestLivePrice(IndianGoldRateModel newRecord) async {
    if (_box == null) return;
    
    // Clear and keep only the latest live price record
    await _box!.clear();
    await _box!.add(newRecord);
  }

  Future<void> saveMarketHistory(List<IndianGoldRateModel> newRecords) async {
    if (_marketBox == null) return;
    
    final existingRecords = _marketBox!.values.toList();
    final Map<String, IndianGoldRateModel> uniqueRecords = {};
    
    // Populate with existing records
    for (final record in existingRecords) {
      final key = '${record.rateDate}_${record.session}';
      uniqueRecords[key] = record;
    }
    
    // Update/insert new records (overwriting if exact timestamp exists)
    for (final record in newRecords) {
      final key = '${record.rateDate}_${record.session}';
      uniqueRecords[key] = record;
    }
    
    final mergedRecords = uniqueRecords.values.toList();
    
    // Sort chronologically (oldest to newest) by timestamp string
    mergedRecords.sort((a, b) {
      final dtA = DateTime.tryParse(a.timestamp) ?? DateTime(0);
      final dtB = DateTime.tryParse(b.timestamp) ?? DateTime(0);
      return dtA.compareTo(dtB);
    });

    await _marketBox!.clear();
    await _marketBox!.addAll(mergedRecords);
    AppLogger.i('Saved ${mergedRecords.length} Indian market history records.');
  }

  IndianGoldRateModel? getLatestLivePrice() {
    if (_box == null || _box!.isEmpty) return null;
    return _box!.values.last;
  }

  List<IndianGoldRateModel> getMarketHistory() {
    if (_marketBox == null || _marketBox!.isEmpty) return [];
    return _marketBox!.values.toList();
  }

  bool getNotificationsEnabled() {
    return _settingsBox?.get('notificationsEnabled', defaultValue: false) ?? false;
  }

  Future<void> setNotificationsEnabled(bool value) async {
    await _settingsBox?.put('notificationsEnabled', value);
  }
}
