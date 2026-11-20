import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aurum/core/services/storage_service.dart';

class ThemeService extends GetxService {
  static ThemeService get to => Get.find<ThemeService>();

  final Rx<ThemeMode> _themeMode = ThemeMode.system.obs;
  ThemeMode get themeMode => _themeMode.value;

  @override
  void onInit() {
    super.onInit();
    _themeMode.value = StorageService().getThemeMode();
  }

  bool get isDarkMode {
    if (_themeMode.value == ThemeMode.system) {
      return Get.isPlatformDarkMode;
    }
    return _themeMode.value == ThemeMode.dark;
  }

  Future<void> switchTheme(ThemeMode mode) async {
    _themeMode.value = mode;
    Get.changeThemeMode(mode);
    await StorageService().setThemeMode(mode);
  }
}
