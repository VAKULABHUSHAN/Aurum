import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  static String formatDate(String iso8601String) {
    return formatTime(iso8601String);
  }

  static String formatTime(String iso8601String) {
    try {
      final date = DateTime.parse(iso8601String).toLocal();
      return DateFormat('hh:mm a').format(date);
    } catch (e) {
      return '--:--';
    }
  }

  static String formatShortDate(String iso8601String) {
    try {
      final date = DateTime.parse(iso8601String).toLocal();
      return DateFormat('dd MMM').format(date);
    } catch (e) {
      return '--';
    }
  }

  static String formatFullDateTime(String iso8601String) {
    try {
      final date = DateTime.parse(iso8601String).toLocal();
      return DateFormat('dd MMM, hh:mm a').format(date);
    } catch (e) {
      return '--:--';
    }
  }
}
