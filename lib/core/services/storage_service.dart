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

  Future<void> saveMarketHistory(List<GoldHistoryModel> records) async {
    if (_marketBox == null) return;
    await _marketBox!.clear();
    await _marketBox!.addAll(records);
    AppLogger.i('Saved ${records.length} market history records.');
  }

  GoldHistoryModel? getLatestGoldHistory() {
    if (_box == null || _box!.isEmpty) return null;
    return _box!.values.last;
  }

  List<GoldHistoryModel> getRecentHistory({int? limit}) {
    if (_box == null || _box!.isEmpty) return [];
    final all = _box!.values.toList();
    if (limit != null && all.length > limit) {
      return all.sublist(all.length - limit);
    }
    return all;
  }

  List<GoldHistoryModel> getMarketHistory() {
    if (_marketBox == null || _marketBox!.isEmpty) return [];
    return _marketBox!.values.toList();
  }
}
