import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsController extends GetxController {
  // Observable variables
  final isDarkMode = false.obs;
  final smsEnabled = true.obs;
  final voiceMessageEnabled = true.obs;
  final is24HourFormat = false.obs;
  final licenseKey = ''.obs;
  RxString logoPath = ''.obs;
  var isLoaded = false.obs;

  @override
  void onInit() async {
    super.onInit();
    await loadSettings();
    print(logoPath.value);
    isLoaded.value = true;
  }

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    isDarkMode.value = prefs.getBool('darkMode') ?? false;
    smsEnabled.value = prefs.getBool('smsEnabled') ?? true;
    voiceMessageEnabled.value = prefs.getBool('voiceMessageEnabled') ?? true;
    is24HourFormat.value = prefs.getBool('is24HourFormat') ?? false;
    licenseKey.value = prefs.getString('licenseKey') ?? '';
    logoPath.value = prefs.getString('logoPath') ?? '';
  }

  Future<void> saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', isDarkMode.value);
    await prefs.setBool('smsEnabled', smsEnabled.value);
    await prefs.setBool('voiceMessageEnabled', voiceMessageEnabled.value);
    await prefs.setBool('is24HourFormat', is24HourFormat.value);
    await prefs.setString('licenseKey', licenseKey.value);
    await prefs.setString('logoPath', logoPath.value);
  }
}

class SettingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SettingsController>(() => SettingsController());
  }
}
