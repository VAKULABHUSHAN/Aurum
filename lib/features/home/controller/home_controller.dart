import 'package:get/get.dart';
import 'package:aurum/data/models/gold_price_model.dart';
import 'package:aurum/data/models/gold_history_model.dart';
import 'package:aurum/core/services/gold_api_service.dart';
import 'package:aurum/core/services/storage_service.dart';
import 'package:aurum/core/utils/app_logger.dart';
import 'package:aurum/core/utils/date_formatter.dart';

class HomeController extends GetxController {
  final Rx<GoldPriceModel?> goldPrice = Rx<GoldPriceModel?>(null);
  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;
  final RxString lastUpdated = ''.obs;
  final RxBool isOfflineData = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadInitialData();
  }

  void _loadInitialData() {
    // 1. Immediately load cached data
    final cachedRecord = StorageService().getLatestGoldHistory();
    if (cachedRecord != null) {
      goldPrice.value = cachedRecord.goldPrice;
      lastUpdated.value = DateFormatter.formatDate(cachedRecord.fetchTimestamp);
      isOfflineData.value = true;
      isLoading.value = false;
      AppLogger.i('Loaded cached gold price: ${cachedRecord.goldPrice.priceGram24k}');
    }

    // 2. Perform background API request
    fetchGoldPrice();
  }

  Future<void> fetchGoldPrice() async {
    // Only show loading if we don't have cached data
    if (goldPrice.value == null) {
      isLoading.value = true;
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
      
      AppLogger.i('Successfully fetched live gold price.');
    } catch (e) {
      AppLogger.e('Failed to fetch live gold price', e);
      
      // If we have no cached data, display the error
      if (goldPrice.value == null) {
        errorMessage.value = e.toString().replaceAll('Exception: ', '');
      }
    } finally {
      isLoading.value = false;
    }
  }

  void refreshData() {
    fetchGoldPrice();
  }
}
