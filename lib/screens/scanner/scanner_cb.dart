import 'dart:convert';

import 'package:another_telephony/telephony.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:scanner/app/constant.dart';
import 'package:scanner/app/settings_mixin.dart';
import 'package:scanner/app/tts_service.dart';
import 'package:scanner/app/user_mode.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ScannerView { scanning, scanned, error }

class ScannerController extends GetxController with SettingsMixin {
  var view = ScannerView.scanning.obs;
  RxBool isReading = true.obs;
  User? user;
  RxString errorText = "".obs;
  RxList<String> timings = ["am_in", "am_out", "pm_in", "pm_out"].obs;
  RxString timing = "am_in".obs;
  final scannerController = MobileScannerController();

  @override
  void onInit() async {
    user = User.fromJson(
      jsonDecode((await SharedPreferences.getInstance()).getString('user')!),
    );
    // Set timing based on current time
    DateTime now = DateTime.now();
    int hour = now.hour;
    int minute = now.minute;
    double currentTime = hour + (minute / 60);

    if (currentTime >= 6 && currentTime <= 10.99) {
      timing("am_in");
    } else if (currentTime >= 11 && currentTime <= 12.5) {
      timing("am_out");
    } else if (currentTime >= 12.51667 && currentTime <= 15) {
      // 12:31 - 2:00
      timing("pm_in");
    } else if (currentTime >= 15.01 && currentTime <= 18) {
      // 4:00 - 6:00
      timing("pm_out");
    }
    print("current time: $currentTime");
    print("timing: $timing");
    await loadSettings();
    view(ScannerView.scanning);
    super.onInit();
  }

  checkInOut(qr, t) async {
    view(ScannerView.scanned);
    try {
      qr = qr.split("?")[1];
      qr = qr.toString().replaceAll("+", " ");
      List<String> qrs = qr.split("&");
      Map<String, String> params = {};
      for (String item in qrs) {
        if (item.contains('=')) {
          List<String> keyValue = item.split('=');
          if (keyValue.length == 2) {
            params[keyValue[0]] = keyValue[1];
          }
        }
      }

      String lrn = params['lrn'] ?? '';
      String name = params['name'] ?? '';
      String grade = params['grade'] ?? '';
      String number = params['number'] ?? '';
      DateTime now = DateTime.now();

      if (lrn.isEmpty || name.isEmpty || grade.isEmpty || number.isEmpty) {
        return;
      }

      var checkDuplicate = await GetConnect().post(
        "${AppStrings.baseUrl}student_checkin/api.php",
        {
          "method": "SELECT",
          "table": "checkins",
          "target": "*",
          "where":
              "lrn='$lrn' AND DATE(scan_date) = CURDATE() AND incharge='${user!.id}'",
          "token": "sdaesi",
        },
        headers: {'Accept': 'application/json'},
      );

      // FIXED LOGIC:
      if (checkDuplicate.statusCode == 200 &&
          checkDuplicate.body['data'].isNotEmpty) {
        if (checkDuplicate.body['data'].first[timing] != null) {
          isReading(true);
          view(ScannerView.scanning);
          return;
        }
        var res = await GetConnect().post(
          "${AppStrings.baseUrl}student_checkin/api.php",
          {
            "method": "UPDATE",
            "table": "checkins",
            "set": "$t=NOW()",
            "where":
                "lrn='$lrn' AND DATE(scan_date)=CURDATE() AND incharge='${user!.id}'",
            "token": "sdaesi",
          },
        );

        print("response: ${res.body}");

        if (res.statusCode == 200) {
          await triggerSMS(name, number);
          view(ScannerView.scanning);
        } else {
          errorText("Update failed");
          view(ScannerView.error);
        }
      } else {
        // Record does not exist → INSERT
        var res = await GetConnect().post(
          "${AppStrings.baseUrl}student_checkin/api.php",
          {
            "method": "INSERT",
            "table": "checkins",
            "columns": [
              "lrn",
              "name",
              "grade",
              "number",
              t,
              "scan_date",
              "incharge",
            ],
            "values": [
              lrn,
              name,
              grade,
              number,
              now.toIso8601String(),
              now.toIso8601String(),
              user!.id,
            ],
            "token": "sdaesi",
          },
        );
        if (res.statusCode == 200) {
          await triggerSMS(name, number);
          view(ScannerView.scanning);
        } else {
          errorText("Insert failed");
          view(ScannerView.error);
        }
      }
    } catch (e, ex) {
      print(ex);
      errorText(e.toString());
      view(ScannerView.error);
    }
  }

  Future<bool> triggerSMS(name, number) async {
    print(timing.value);
    final Telephony telephony = Telephony.instance;
    listener(SendStatus status) async {
      if (status == SendStatus.SENT) {
        isReading(true);
        Get.snackbar(
          'Success!',
          'SMS notification sent successfully',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 3),
          backgroundColor: Colors.green.shade600,
          colorText: Colors.white,
          borderRadius: 8,
          margin: const EdgeInsets.all(10),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          icon: const Icon(Icons.check_circle, color: Colors.white),
          isDismissible: true,
          forwardAnimationCurve: Curves.easeOutBack,
        );
      }
    }

    DateTime now = DateTime.now();
    final greeting =
        timing.value.contains("am") ? "Good Morning" : "Good Afternoon";
    final hour = now.hour > 12 ? now.hour % 12 : now.hour;
    final minute = now.minute < 10 ? "0${now.minute}" : now.minute;
    final period = now.hour > 12 ? "PM" : "AM";
    final action = timing.value.contains("in") ? "entered" : "left";

    String message =
        "$greeting, Ma'am and sir. Your child has $action the school premises at $hour:$minute $period today";

    TextToSpeech().speak(
      "$greeting, Student $name has $action the school premises at $hour:$minute $period. ${timing.value.contains("in") ? "Please ensure safe entry." : "Exit confirmed."}",
    );
    telephony.sendSms(to: number, message: message, statusListener: listener);

    return true;
  }
}

class ScannerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ScannerController>(() => ScannerController());
  }
}
