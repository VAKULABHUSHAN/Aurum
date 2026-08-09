import 'package:intl/intl.dart';

class CurrencyFormatter {
  CurrencyFormatter._();

  static String formatPrice(double value) {
    final format = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 2,
    );
    return format.format(value);
  }

  static String formatChange(double value) {
    final formatted = formatPrice(value.abs());
    if (value > 0.0001) {
      return '↑ $formatted';
    } else if (value < -0.0001) {
      return '↓ $formatted';
    } else {
      return '— $formatted';
    }
  }

  static String formatPercentage(double value) {
    final prefix = value > 0.0001 ? '+' : '';
    return '$prefix${value.toStringAsFixed(2)}%';
  }
}
