import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  static String formatDate(String iso8601String) {
    try {
      final date = DateTime.parse(iso8601String).toLocal();
      return DateFormat('hh:mm a').format(date);
    } catch (e) {
      return '--:--';
    }
  }
}
