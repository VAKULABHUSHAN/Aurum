import 'package:get/get.dart';
import 'package:aurum/features/home/controller/home_controller.dart';
import 'package:aurum/features/home/views/home_screen.dart';
import 'package:aurum/routes/app_routes.dart';

class AppPages {
  AppPages._();

  static const initial = AppRoutes.home;

  static final routes = [
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<HomeController>(() => HomeController());
      }),
    ),
  ];
}
