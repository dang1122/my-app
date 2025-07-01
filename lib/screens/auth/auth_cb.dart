import 'dart:convert';

import 'package:bcrypt/bcrypt.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scanner/app/constant.dart';
import 'package:scanner/app/settings_mixin.dart';
import 'package:scanner/app/user_mode.dart';
import 'package:scanner/screens/splash/splash_cb.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginController extends GetxController with SettingsMixin {
  RxBool isLoaded = true.obs;
  @override
  void onInit() async {
    await loadSettings();
    print(logoPath.value);
    isLoaded.value = true;
    super.onInit();
  }

  // Observable variables
  var isLoginMode = true.obs;
  var isLoginPasswordHidden = true.obs;
  var isSignupPasswordHidden = true.obs;
  var isConfirmPasswordHidden = true.obs;
  var agreeToTerms = false.obs;

  // Text controllers
  final loginEmailController = TextEditingController();
  final loginPasswordController = TextEditingController();
  final signupNameController = TextEditingController();
  final signupEmailController = TextEditingController();
  final signupPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // Form keys
  final loginFormKey = GlobalKey<FormState>();
  final signupFormKey = GlobalKey<FormState>();

  // Switch between login and signup
  void switchToLogin() => isLoginMode.value = true;
  void switchToSignup() => isLoginMode.value = false;

  // Toggle password visibility
  void toggleLoginPassword() =>
      isLoginPasswordHidden.value = !isLoginPasswordHidden.value;
  void toggleSignupPassword() =>
      isSignupPasswordHidden.value = !isSignupPasswordHidden.value;
  void toggleConfirmPassword() =>
      isConfirmPasswordHidden.value = !isConfirmPasswordHidden.value;
  void toggleTermsAgreement() => agreeToTerms.value = !agreeToTerms.value;

  // Login function
  void login() async {
    if (loginFormKey.currentState!.validate()) {
      var res = await GetConnect()
          .post("${AppStrings.baseUrl}student_checkin/api.php", {
            "method": "SELECT",
            "target": "*",
            "table": "users",
            "where": "username = '${loginEmailController.text}'",
            "token": "sdaesi",
          });
      for (var e in res.body['data']) {
        if (BCrypt.checkpw(loginPasswordController.text, e['password'])) {
          final user = User(
            id: e['id'].toString(),
            username: e['username'],
            password: e['password'],
          );
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('user', jsonEncode(user.toJson()));
          Get.snackbar(
            'Success',
            'Login successful!',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
          Get.delete<SplashController>();
          Get.offAllNamed('/splash');
          return;
        }
      }
      Get.snackbar(
        'Error',
        'Login failed. Invalid username or password.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Signup function
  void signup() {
    if (signupFormKey.currentState!.validate()) {
      if (signupPasswordController.text != confirmPasswordController.text) {
        Get.snackbar(
          'Error',
          'Passwords do not match!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      if (!agreeToTerms.value) {
        Get.snackbar(
          'Error',
          'Please agree to the terms and conditions',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      Get.snackbar(
        'Success',
        'Account created for: ${signupNameController.text}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    }
  }

  // Forgot password
  void forgotPassword() {
    Get.snackbar(
      'Forgot Password',
      'Forgot password clicked! (Demo)',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.orange,
      colorText: Colors.white,
    );
  }

  @override
  void onClose() {
    loginEmailController.dispose();
    loginPasswordController.dispose();
    signupNameController.dispose();
    signupEmailController.dispose();
    signupPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => LoginController());
  }
}
