import 'package:get/get.dart';
import 'package:aurum/data/models/gold_price_model.dart';
import 'package:aurum/data/models/gold_history_model.dart';
import 'package:aurum/data/models/price_movement.dart';
import 'package:aurum/core/services/gold_api_service.dart';
import 'package:aurum/core/services/storage_service.dart';
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
      AppLogger.i('Loaded cached gold price: ${cachedRecord.goldPrice.priceGram24k}');
    } else {
      isLoading.value = true;
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
      
      // Re-calculate price movement with updated history
      priceMovement.value = calculatePriceMovement();
      
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
