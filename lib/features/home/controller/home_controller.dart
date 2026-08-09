import 'package:get/get.dart';
import 'package:aurum/data/models/gold_price_model.dart';
import 'package:aurum/data/models/gold_history_model.dart';
import 'package:aurum/data/models/price_movement.dart';
import 'package:aurum/data/models/chart_range.dart';
import 'package:aurum/core/services/gold_api_service.dart';
import 'package:aurum/core/services/storage_service.dart';
import 'package:aurum/core/services/widget_service.dart';
import 'package:aurum/core/utils/app_logger.dart';
import 'package:aurum/core/utils/date_formatter.dart';

class HomeController extends GetxController {
  final Rx<GoldPriceModel?> goldPrice = Rx<GoldPriceModel?>(null);
  final RxBool isLoading = true.obs;
  final RxBool isRefreshing = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString lastUpdated = ''.obs;
  final RxBool isOfflineData = false.obs;
  final Rx<PriceMovement?> priceMovement = Rx<PriceMovement?>(null);

  // Chart reactive state
  final Rx<ChartRange> selectedRange = ChartRange.day24h.obs;
  final RxList<GoldHistoryModel> chartHistory = <GoldHistoryModel>[].obs;
  final Rx<double?> chartHigh = Rx<double?>(null);
  final Rx<double?> chartLow = Rx<double?>(null);

  @override
  void onInit() {
    super.onInit();
    _loadInitialData();
  }

  void _loadInitialData() {
    // 1. Immediately load cached data if present
    final cachedRecord = StorageService().getLatestGoldHistory();
    if (cachedRecord != null) {
      goldPrice.value = cachedRecord.goldPrice;
      lastUpdated.value = DateFormatter.formatDate(cachedRecord.fetchTimestamp);
      isOfflineData.value = true;
      isLoading.value = false;
      priceMovement.value = calculatePriceMovement();
      updateChartData();
      
      // Keep widget up to date with loaded cached data
      WidgetService.updateGoldPriceWidget(cachedRecord.goldPrice);
      
      AppLogger.i('Loaded cached gold price: ${cachedRecord.goldPrice.priceGram24k}');
    } else {
      isLoading.value = true;
      updateChartData();
    }

    // 2. Perform background API request
    fetchGoldPrice();
  }

  PriceMovement? calculatePriceMovement() {
    // History is in ascending chronological order (newest last)
    final history = StorageService().getRecentHistory();
    if (history.length < 2) return null;

    final currentPrice = history.last.goldPrice.priceGram24k;
    
    // Find the most recent distinct previous 24K price
    double? previousPrice;
    for (int i = history.length - 2; i >= 0; i--) {
      final p = history[i].goldPrice.priceGram24k;
      if ((p - currentPrice).abs() > 0.0001) {
        previousPrice = p;
        break;
      }
    }

    // Defensive check: valid positive previous price required
    if (previousPrice == null || previousPrice <= 0) {
      return null;
    }

    final diff = currentPrice - previousPrice;
    final percentage = (diff / previousPrice) * 100;
    return PriceMovement(amountChange: diff, percentageChange: percentage);
  }

  void updateChartData() {
    final allHistory = StorageService().getRecentHistory();
    if (allHistory.isEmpty) {
      chartHistory.clear();
      chartHigh.value = null;
      chartLow.value = null;
      return;
    }

    final now = DateTime.now();
    final cutoff = now.subtract(selectedRange.value.duration);

    // Deduplicate records with identical timestamps (keep latest record per timestamp)
    final Map<String, GoldHistoryModel> uniqueByTimestamp = {};
    for (final record in allHistory) {
      final dt = DateTime.tryParse(record.fetchTimestamp) ?? DateTime.tryParse(record.goldPrice.timestamp);
      if (dt != null) {
        if (dt.isAfter(cutoff) || dt.isAtSameMomentAs(cutoff)) {
          uniqueByTimestamp[dt.toIso8601String()] = record;
        }
      }
    }

    final filtered = uniqueByTimestamp.values.toList();
    // Sort deterministically (oldest first, newest last)
    filtered.sort((a, b) {
      final dtA = DateTime.tryParse(a.fetchTimestamp) ?? DateTime.tryParse(a.goldPrice.timestamp) ?? DateTime(0);
      final dtB = DateTime.tryParse(b.fetchTimestamp) ?? DateTime.tryParse(b.goldPrice.timestamp) ?? DateTime(0);
      return dtA.compareTo(dtB);
    });

    chartHistory.assignAll(filtered);

    if (filtered.length >= 2) {
      double high = filtered.first.goldPrice.priceGram24k;
      double low = filtered.first.goldPrice.priceGram24k;
      for (final r in filtered) {
        final p = r.goldPrice.priceGram24k;
        if (p > high) high = p;
        if (p < low) low = p;
      }
      chartHigh.value = high;
      chartLow.value = low;
    } else {
      chartHigh.value = null;
      chartLow.value = null;
    }
  }

  void setChartRange(ChartRange range) {
    if (selectedRange.value == range) return;
    selectedRange.value = range;
    updateChartData();
  }

  Future<void> fetchGoldPrice({bool isManualRefresh = false}) async {
    // isLoading is strictly for first launch with no cached data
    if (goldPrice.value == null) {
      isLoading.value = true;
    } else {
      isRefreshing.value = true;
    }
    errorMessage.value = '';

    try {
      final freshData = await GoldApiService().fetchLiveGoldPrice();
      
      goldPrice.value = freshData;
      isOfflineData.value = false;
      lastUpdated.value = DateFormatter.formatDate(freshData.timestamp);
      
      // Save to Hive
      final newRecord = GoldHistoryModel(
        goldPrice: freshData,
        fetchTimestamp: freshData.timestamp,
      );
      await StorageService().saveGoldHistory(newRecord);
      
      // Re-calculate price movement and chart with updated history
      priceMovement.value = calculatePriceMovement();
      updateChartData();
      
      // Update home screen widget
      await WidgetService.updateGoldPriceWidget(freshData);
      
      AppLogger.i('Successfully fetched live gold price.');
    } catch (e) {
      AppLogger.e('Failed to fetch live gold price', e);
      
      // If we have no cached data, display the error
      if (goldPrice.value == null) {
        errorMessage.value = 'Unable to load gold price';
      } else {
        isOfflineData.value = true;
      }
    } finally {
      isLoading.value = false;
      isRefreshing.value = false;
    }
  }

  void refreshData() {
    // Prevent duplicate simultaneous refresh requests
    if (isRefreshing.value || isLoading.value) {
      AppLogger.d('Refresh already in progress. Ignoring tap.');
      return;
    }
    fetchGoldPrice(isManualRefresh: true);
  }
}
