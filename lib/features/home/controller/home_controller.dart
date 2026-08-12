import 'package:get/get.dart';
import 'package:aurum/data/models/indian_gold_rate_model.dart';
import 'package:aurum/data/models/price_movement.dart';
import 'package:aurum/data/models/chart_range.dart';
import 'package:aurum/core/services/gold_api_service.dart';
import 'package:aurum/core/services/storage_service.dart';
import 'package:aurum/core/services/widget_service.dart';
import 'package:aurum/core/utils/app_logger.dart';
import 'package:aurum/core/utils/date_formatter.dart';

class HomeController extends GetxController {
  final Rx<IndianGoldRateModel?> goldPrice = Rx<IndianGoldRateModel?>(null);
  final RxBool isLoading = true.obs;
  final RxBool isRefreshing = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString lastUpdated = ''.obs;
  final RxBool isOfflineData = false.obs;
  final Rx<PriceMovement?> priceMovement = Rx<PriceMovement?>(null);

  // Chart reactive state
  final Rx<ChartRange> selectedRange = ChartRange.week7d.obs;
  final RxList<IndianGoldRateModel> chartHistory = <IndianGoldRateModel>[].obs;
  final Rx<double?> chartHigh = Rx<double?>(null);
  final Rx<double?> chartLow = Rx<double?>(null);

  @override
  void onInit() {
    super.onInit();
    _loadInitialData();
  }

  void _loadInitialData() {
    // 1. Immediately load cached data if present
    final cachedRecord = StorageService().getLatestLivePrice();
    if (cachedRecord != null) {
      goldPrice.value = cachedRecord;
      lastUpdated.value = DateFormatter.formatDate(cachedRecord.timestamp);
      isOfflineData.value = true;
      isLoading.value = false;
      priceMovement.value = calculatePriceMovement();
      updateChartData();
      
      // Keep widget up to date with loaded cached data
      WidgetService.updateGoldPriceWidget(cachedRecord);
      
      AppLogger.i('Loaded cached indian gold price: ${cachedRecord.price24kPerGram}');
    } else {
      isLoading.value = true;
      updateChartData();
    }

    // 2. Perform background API request
    fetchGoldPrice();
  }

  PriceMovement? calculatePriceMovement() {
    // History is in ascending chronological order (newest last)
    final history = StorageService().getMarketHistory();
    if (history.length < 2) return null;

    final currentPrice = history.last.price24kPerGram;
    
    // Find the most recent distinct previous 24K price
    double? previousPrice;
    for (int i = history.length - 2; i >= 0; i--) {
      final p = history[i].price24kPerGram;
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
    final sourceHistory = StorageService().getMarketHistory();

    if (sourceHistory.isEmpty) {
      chartHistory.clear();
      chartHigh.value = null;
      chartLow.value = null;
      return;
    }

    final now = DateTime.now();
    final cutoff = now.subtract(selectedRange.value.duration);

    // Deduplicate records with identical timestamps (keep latest record per timestamp)
    final Map<String, IndianGoldRateModel> uniqueByTimestamp = {};
    for (final record in sourceHistory) {
      final dt = DateTime.tryParse(record.timestamp);
      if (dt != null) {
        if (dt.isAfter(cutoff) || dt.isAtSameMomentAs(cutoff)) {
          // If we have an AM and PM for the same date, PM overwrites because it comes later (sorted chronologically)
          final dateKey = record.rateDate;
          uniqueByTimestamp[dateKey] = record;
        }
      }
    }

    final filtered = uniqueByTimestamp.values.toList();
    // Sort deterministically (oldest first, newest last)
    filtered.sort((a, b) {
      final dtA = DateTime.tryParse(a.timestamp) ?? DateTime(0);
      final dtB = DateTime.tryParse(b.timestamp) ?? DateTime(0);
      return dtA.compareTo(dtB);
    });

    chartHistory.assignAll(filtered);

    if (filtered.length >= 2) {
      double high = filtered.first.price24kPerGram;
      double low = filtered.first.price24kPerGram;
      for (final r in filtered) {
        final p = r.price24kPerGram;
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
      final freshData = await GoldApiService().fetchIndianGoldRates();
      
      goldPrice.value = freshData;
      isOfflineData.value = false;
      lastUpdated.value = DateFormatter.formatDate(freshData.timestamp);
      
      // Save to Hive
      await StorageService().cacheLatestLivePrice(freshData);
      
      // Append to local Market History
      try {
        final currentHistory = StorageService().getMarketHistory();
        currentHistory.add(freshData);
        await StorageService().saveMarketHistory(currentHistory);
      } catch (e) {
        AppLogger.e('Failed to save market history', e);
      }

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
        if (e.toString().contains('NETWORK_UNAVAILABLE')) {
          errorMessage.value = 'No internet connection.';
        } else {
          errorMessage.value = 'Unable to load gold price';
        }
      } else {
        isOfflineData.value = true;
        AppLogger.i('OFFLINE — USING CACHED INDIAN GOLD RATE');
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
