import 'package:get/get.dart';
import 'package:scanner/screens/auth/auth.dart';
import 'package:scanner/screens/auth/auth_cb.dart';
import 'package:scanner/screens/logs/logs.dart';
import 'package:scanner/screens/logs/logs_cb.dart';
import 'package:scanner/screens/settings/settings.dart';
import 'package:scanner/screens/settings/settings_cb.dart';
import 'package:scanner/screens/splash/splash.dart';
import 'package:scanner/screens/splash/splash_cb.dart';

import '../screens/scanner/scanner.dart';
import '../screens/scanner/scanner_cb.dart';

appRouter() => [
  GetPage(name: '/scanner', page: () => Scanner(), binding: ScannerBinding()),
  GetPage(name: '/login', page: () => LoginScreen(), binding: LoginBinding()),
  GetPage(
    name: '/attendance',
    page: () => Attendance(),
    binding: AttendanceBindings(),
  ),
  GetPage(
    name: '/settings',
    page: () => SettingsScreen(),
    binding: SettingsBinding(),
  ),
  GetPage(name: '/splash', page: () => Splash(), binding: SplashBinding()),
];
