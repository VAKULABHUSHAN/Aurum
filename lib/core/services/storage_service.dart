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

  static const String _marketBoxName = 'gold_market_history';
  Box<GoldHistoryModel>? _marketBox;

  Future<void> init() async {
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(GoldPriceModelAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(GoldHistoryModelAdapter());
    }
    _box = await Hive.openBox<GoldHistoryModel>(_boxName);
    _marketBox = await Hive.openBox<GoldHistoryModel>(_marketBoxName);
  }

  Future<void> cacheLatestLivePrice(GoldHistoryModel newRecord) async {
    if (_box == null) return;
    
    // Clear and keep only the latest live price record
    await _box!.clear();
    await _box!.add(newRecord);
  }

  Future<void> saveMarketHistory(List<GoldHistoryModel> newRecords) async {
    if (_marketBox == null) return;
    
    final existingRecords = _marketBox!.values.toList();
    final Map<String, GoldHistoryModel> uniqueRecords = {};
    
    // Populate with existing records
    for (final record in existingRecords) {
      uniqueRecords[record.fetchTimestamp] = record;
    }
    
    // Update/insert new records (overwriting if exact timestamp exists)
    for (final record in newRecords) {
      uniqueRecords[record.fetchTimestamp] = record;
    }
    
    final mergedRecords = uniqueRecords.values.toList();
    
    // Sort chronologically (oldest to newest)
    mergedRecords.sort((a, b) {
      final dtA = DateTime.tryParse(a.fetchTimestamp) ?? DateTime(0);
      final dtB = DateTime.tryParse(b.fetchTimestamp) ?? DateTime(0);
      return dtA.compareTo(dtB);
    });

    await _marketBox!.clear();
    await _marketBox!.addAll(mergedRecords);
    AppLogger.i('Saved ${mergedRecords.length} market history records.');
  }

  GoldHistoryModel? getLatestLivePrice() {
    if (_box == null || _box!.isEmpty) return null;
    return _box!.values.last;
  }

  List<GoldHistoryModel> getMarketHistory() {
    if (_marketBox == null || _marketBox!.isEmpty) return [];
    return _marketBox!.values.toList();
  }
}
