import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:aurum/core/utils/app_logger.dart';
import 'package:aurum/data/models/indian_gold_rate_model.dart';
import 'package:aurum/data/models/price_movement.dart';
import 'package:aurum/core/services/storage_service.dart';
import 'package:get/get.dart';
import 'package:aurum/routes/app_routes.dart';
import 'package:intl/intl.dart';

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  // Ignored in background
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    try {
      tz.initializeTimeZones();
      final timeZoneInfo = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneInfo.identifier));

      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
      );

      await flutterLocalNotificationsPlugin.initialize(
        settings: initializationSettings,
        onDidReceiveNotificationResponse: _onNotificationTap,
        onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
      );

      AppLogger.i('NOTIFICATION SERVICE INITIALIZED');
      
      // Attempt to reschedule on boot/init just in case
      rescheduleAll();
    } catch (e) {
      AppLogger.e('NotificationService init failed', e);
    }
  }

  void _onNotificationTap(NotificationResponse response) {
    AppLogger.i('NOTIFICATION TAP -> DASHBOARD');
    Get.offAllNamed(AppRoutes.home);
  }

  Future<bool> requestPermission() async {
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      final bool? granted = await androidImplementation.requestNotificationsPermission();
      if (granted == true) {
        AppLogger.i('NOTIFICATION PERMISSION GRANTED');
        return true;
      } else {
        AppLogger.i('NOTIFICATION PERMISSION DENIED');
        return false;
      }
    }
    return false;
  }

  Future<void> rescheduleAll() async {
    if (!StorageService().getNotificationsEnabled()) {
      return;
    }
    
    final latestModel = StorageService().getLatestLivePrice();
    if (latestModel == null) return;
    
    if (!_isValid(latestModel)) return;
    
    // Calculate movement
    final movement = _calculatePriceMovement();

    await cancelAll();
    await _scheduleNotification(9001, 9, 0, latestModel, movement);
    await _scheduleNotification(9002, 12, 0, latestModel, movement);
    await _scheduleNotification(9003, 20, 0, latestModel, movement);
  }

  Future<void> cancelAll() async {
    await flutterLocalNotificationsPlugin.cancel(id: 9001);
    AppLogger.i('NOTIFICATION CANCELLED -> 9001');
    await flutterLocalNotificationsPlugin.cancel(id: 9002);
    AppLogger.i('NOTIFICATION CANCELLED -> 9002');
    await flutterLocalNotificationsPlugin.cancel(id: 9003);
    AppLogger.i('NOTIFICATION CANCELLED -> 9003');
  }

  Future<void> _scheduleNotification(int id, int hour, int minute, IndianGoldRateModel model, PriceMovement? movement) async {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    final body = _buildNotificationBody(model, movement);

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id: id,
      title: '🪙 Aurum — Gold Price Update',
      body: body,
      scheduledDate: scheduledDate,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'gold_price_updates',
          'Gold Price Updates',
          channelDescription: 'Daily Indian gold price updates from Aurum',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          styleInformation: BigTextStyleInformation(''),
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexact,
      matchDateTimeComponents: DateTimeComponents.time,
    );
    
    String timeStr = '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
    if (id == 9001) AppLogger.i('MORNING NOTIFICATION SCHEDULED -> $timeStr');
    if (id == 9002) AppLogger.i('AFTERNOON NOTIFICATION SCHEDULED -> $timeStr');
    if (id == 9003) AppLogger.i('EVENING NOTIFICATION SCHEDULED -> $timeStr');
  }

  Future<void> showTestGoldPriceNotification() async {
    final latestModel = StorageService().getLatestLivePrice();
    if (latestModel == null || !_isValid(latestModel)) return;
    
    final movement = _calculatePriceMovement();
    final body = _buildNotificationBody(latestModel, movement);

    await flutterLocalNotificationsPlugin.show(
      id: 9999,
      title: '🪙 Aurum — Gold Price Update',
      body: body,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'gold_price_updates',
          'Gold Price Updates',
          channelDescription: 'Daily Indian gold price updates from Aurum',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          styleInformation: BigTextStyleInformation(''),
        ),
      ),
    );
  }

  String _buildNotificationBody(IndianGoldRateModel model, PriceMovement? movement) {
    final p24 = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0).format(model.price24kPerGram);
    final p22 = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0).format(model.price22kPerGram);
    
    String movementStr = '';
    if (movement != null) {
      final sign = movement.amountChange > 0 ? '+' : '';
      final amt = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 2).format(movement.amountChange.abs());
      final pct = movement.percentageChange.abs().toStringAsFixed(2);
      movementStr = '\nToday: $sign$amt ($sign$pct%)';
    }

    String timestampStr = '';
    final dt = DateTime.tryParse(model.timestamp)?.toLocal();
    if (dt != null) {
      final now = DateTime.now();
      if (dt.year == now.year && dt.month == now.month && dt.day == now.day) {
        timestampStr = 'Updated: ${DateFormat('hh:mm a').format(dt)}';
      } else {
        timestampStr = 'Latest available: ${DateFormat('MMM dd, yyyy · hh:mm a').format(dt)}';
      }
    }

    return '24K Gold: $p24/g\n22K Gold: $p22/g$movementStr\n\nIBJA Benchmark · Indicative\n$timestampStr';
  }

  bool _isValid(IndianGoldRateModel model) {
    if (model.price24kPerGram <= 0 || model.price22kPerGram <= 0) return false;
    if (model.price22kPerGram > model.price24kPerGram) return false;
    return true;
  }

  PriceMovement? _calculatePriceMovement() {
    final history = StorageService().getMarketHistory();
    if (history.length < 2) return null;

    final currentPrice = history.last.price24kPerGram;
    
    double? previousPrice;
    for (int i = history.length - 2; i >= 0; i--) {
      final p = history[i].price24kPerGram;
      if ((p - currentPrice).abs() > 0.0001) {
        previousPrice = p;
        break;
      }
    }

    if (previousPrice == null || previousPrice <= 0) {
      return null;
    }

    final diff = currentPrice - previousPrice;
    final percentage = (diff / previousPrice) * 100;
    return PriceMovement(amountChange: diff, percentageChange: percentage);
  }
}
