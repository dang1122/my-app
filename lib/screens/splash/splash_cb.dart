import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:scanner/app/settings_mixin.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum SplashView { loading, loaded, error, showLogo }

class SplashController extends GetxController with SettingsMixin {
  final view = SplashView.loading.obs;
  final String errorMessage = '';

  @override
  void onInit() async {
    _initAsync();
    super.onInit();
  }

  Future<void> _initAsync() async {
    await loadSettings();
    view(SplashView.showLogo);
    await Permission.sms.request().isGranted;
    await Permission.camera.request().isGranted;
    await Future.delayed(Duration(seconds: 3));
    final prefs = await SharedPreferences.getInstance();
    final String? userString = prefs.getString('user');

    if (userString != null && licenseKey.value != "") {
      Get.toNamed('/scanner');
    } else if (userString != null && licenseKey.value == "") {
      // show toast
      Get.snackbar(
        'License Key Required',
        'Please provide a license key to continue.',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
      );
      Get.toNamed('/settings');
    } else {
      Get.toNamed('/login');
    }

    view(SplashView.loaded);
  }
}

class SplashBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SplashController>(() => SplashController());
  }
}
