import 'package:home_widget/home_widget.dart';
import 'package:aurum/data/models/gold_price_model.dart';
import 'package:aurum/core/utils/currency_formatter.dart';
import 'package:aurum/core/utils/date_formatter.dart';
import 'package:aurum/core/utils/app_logger.dart';

class WidgetService {
  static const String _androidWidgetName = 'AurumWidgetProvider';

  static Future<void> updateGoldPriceWidget(GoldPriceModel data) async {
    try {
      final formatted24k = CurrencyFormatter.formatPrice(data.priceGram24k);
      final formatted22k = CurrencyFormatter.formatPrice(data.priceGram22k);
      
      // The widget wants "Updated 03:27 PM"
      final timeStr = DateFormatter.formatTime(data.timestamp);
      final formattedTime = 'Updated $timeStr';

      await HomeWidget.saveWidgetData<String>('gold_24k_price', formatted24k);
      await HomeWidget.saveWidgetData<String>('gold_22k_price', '22K: $formatted22k');
      await HomeWidget.saveWidgetData<String>('gold_currency', data.currency);
      await HomeWidget.saveWidgetData<String>('gold_updated_at', formattedTime);

      await HomeWidget.updateWidget(
        name: _androidWidgetName,
        androidName: _androidWidgetName,
      );
      
      AppLogger.i('WidgetService: Widget updated successfully');
    } catch (e) {
      AppLogger.e('WidgetService: Failed to update widget', e);
    }
  }
}
