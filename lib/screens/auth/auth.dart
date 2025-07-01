import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scanner/screens/auth/auth_cb.dart';

class LoginScreen extends GetView<LoginController> {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(
        () =>
            controller.isLoaded.value
                ? Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors:
                          controller.isDarkMode.value
                              ? [
                                const Color(0xFF1a202c),
                                const Color(0xFF2d3748),
                              ]
                              : [
                                const Color(0xFF667eea),
                                const Color(0xFF764ba2),
                              ],
                    ),
                  ),
                  child: SafeArea(
                    child: Center(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        child: Container(
                          width: double.infinity,
                          constraints: BoxConstraints(maxWidth: 400.w),
                          decoration: BoxDecoration(
                            color:
                                controller.isDarkMode.value
                                    ? const Color(0xFF2d3748).withOpacity(0.95)
                                    : Colors.white.withOpacity(0.95),
                            borderRadius: BorderRadius.circular(24.r),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    controller.isDarkMode.value
                                        ? Colors.black.withOpacity(0.3)
                                        : Colors.black.withOpacity(0.1),
                                blurRadius: 20.r,
                                offset: Offset(0, 10.h),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              // Top gradient bar
                              Padding(
                                padding: EdgeInsets.all(30.w),
                                child: Column(
                                  children: [
                                    _buildHeader(),
                                    SizedBox(height: 30.h),
                                    Obx(
                                      () =>
                                          controller.isLoginMode.value
                                              ? _buildLoginForm()
                                              : _buildSignupForm(),
                                    ),
                                    SizedBox(height: 20.h),
                                    _buildTermsText(),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                )
                : Container(),
      ),
      // Dark mode toggle button
      floatingActionButton: Obx(
        () => FloatingActionButton(
          mini: true,
          onPressed: () async {
            controller.isDarkMode.value = !controller.isDarkMode.value;
            await controller.saveSettings();
          },
          backgroundColor:
              controller.isDarkMode.value
                  ? const Color(0xFF4299e1)
                  : const Color(0xFF667eea),
          child: Icon(
            controller.isDarkMode.value ? Icons.light_mode : Icons.dark_mode,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Obx(
      () => Column(
        children: [
          // Logo with dark mode support
          controller.logoPath.value == ""
              ? Container(
                height: 100.h,
                width: 100.h,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors:
                        controller.isDarkMode.value
                            ? [const Color(0xFF4299e1), const Color(0xFF3182ce)]
                            : [
                              const Color(0xFF667eea),
                              const Color(0xFF764ba2),
                            ],
                  ),
                  borderRadius: BorderRadius.circular(20.r),
                  boxShadow: [
                    BoxShadow(
                      color:
                          controller.isDarkMode.value
                              ? const Color(0xFF4299e1).withOpacity(0.3)
                              : const Color(0xFF667eea).withOpacity(0.3),
                      blurRadius: 15.r,
                      offset: Offset(0, 5.h),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.security_rounded,
                  size: 50.sp,
                  color: Colors.white,
                ),
              )
              : SizedBox(
                height: 100.h,
                width: 100.w,
                child: Image.file(
                  File(controller.logoPath.value),
                  fit: BoxFit.cover,
                ),
              ),
          SizedBox(height: 20.h),
          // Title
          Text(
            'Welcome SDAESI',
            style: GoogleFonts.poppins(
              fontSize: 23.sp,
              fontWeight: FontWeight.w600,
              color:
                  controller.isDarkMode.value
                      ? const Color(0xFFf7fafc)
                      : const Color(0xFF2d3748),
            ),
          ),
          SizedBox(height: 8.h),
          // Subtitle
          Text(
            'Sign in to your account or create a new one',
            style: GoogleFonts.poppins(
              fontSize: 14.sp,
              color:
                  controller.isDarkMode.value
                      ? const Color(0xFFa0aec0)
                      : const Color(0xFF718096),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLoginForm() {
    return Form(
      key: controller.loginFormKey,
      child: Column(
        children: [
          _buildInputField(
            label: 'Email',
            controller: controller.loginEmailController,
            keyboardType: TextInputType.emailAddress,
          ),
          SizedBox(height: 10.h),
          Obx(
            () => _buildInputField(
              label: 'Password',
              controller: controller.loginPasswordController,
              isPassword: true,
              obscureText: controller.isLoginPasswordHidden.value,
              onTogglePassword: controller.toggleLoginPassword,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your password';
                }
                return null;
              },
            ),
          ),
          SizedBox(height: 10),
          // Align(
          //   alignment: Alignment.centerRight,
          //   child: TextButton(
          //     onPressed: controller.forgotPassword,
          //     child: Obx(
          //       () => Text(
          //         'Forgot Password?',
          //         style: GoogleFonts.poppins(
          //           fontSize: 14.sp,
          //           fontWeight: FontWeight.w500,
          //           color:
          //               controller.isDarkMode.value
          //                   ? const Color(0xFF4299e1)
          //                   : const Color(0xFF667eea),
          //         ),
          //       ),
          //     ),
          //   ),
          // ),
          SizedBox(height: 10.h),
          _buildGradientButton(text: 'Sign In', onPressed: controller.login),
        ],
      ),
    );
  }

  Widget _buildSignupForm() {
    return Form(
      key: controller.signupFormKey,
      child: Column(
        children: [
          _buildInputField(
            label: 'Full Name',
            controller: controller.signupNameController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your full name';
              }
              return null;
            },
          ),
          SizedBox(height: 20.h),
          _buildInputField(
            label: 'Email',
            controller: controller.signupEmailController,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              if (!GetUtils.isEmail(value)) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
          SizedBox(height: 20.h),
          Obx(
            () => _buildInputField(
              label: 'Password',
              controller: controller.signupPasswordController,
              isPassword: true,
              obscureText: controller.isSignupPasswordHidden.value,
              onTogglePassword: controller.toggleSignupPassword,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please create a password';
                }
                if (value.length < 6) {
                  return 'Password must be at least 6 characters';
                }
                return null;
              },
            ),
          ),
          SizedBox(height: 20.h),
          Obx(
            () => _buildInputField(
              label: 'Confirm Password',
              controller: controller.confirmPasswordController,
              isPassword: true,
              obscureText: controller.isConfirmPasswordHidden.value,
              onTogglePassword: controller.toggleConfirmPassword,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please confirm your password';
                }
                return null;
              },
            ),
          ),
          SizedBox(height: 20.h),
          Obx(
            () => Row(
              children: [
                Checkbox(
                  value: controller.agreeToTerms.value,
                  onChanged: (value) => controller.toggleTermsAgreement(),
                  activeColor:
                      controller.isDarkMode.value
                          ? const Color(0xFF4299e1)
                          : const Color(0xFF667eea),
                ),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: GoogleFonts.poppins(
                        fontSize: 14.sp,
                        color:
                            controller.isDarkMode.value
                                ? const Color(0xFFa0aec0)
                                : const Color(0xFF718096),
                      ),
                      children: [
                        const TextSpan(text: 'I agree to the '),
                        TextSpan(
                          text: 'Terms of Service',
                          style: GoogleFonts.poppins(
                            color:
                                controller.isDarkMode.value
                                    ? const Color(0xFF4299e1)
                                    : const Color(0xFF667eea),
                          ),
                        ),
                        const TextSpan(text: ' and '),
                        TextSpan(
                          text: 'Privacy Policy',
                          style: GoogleFonts.poppins(
                            color:
                                controller.isDarkMode.value
                                    ? const Color(0xFF4299e1)
                                    : const Color(0xFF667eea),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20.h),
          _buildGradientButton(
            text: 'Create Account',
            onPressed: controller.signup,
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    TextInputType? keyboardType,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onTogglePassword,
    String? Function(String?)? validator,
  }) {
    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color:
                  this.controller.isDarkMode.value
                      ? const Color(0xFFf7fafc)
                      : const Color(0xFF2d3748),
            ),
          ),
          SizedBox(height: 8.h),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            obscureText: obscureText,
            validator: validator,
            style: GoogleFonts.poppins(
              fontSize: 16.sp,
              color:
                  this.controller.isDarkMode.value
                      ? const Color(0xFFf7fafc)
                      : const Color(0xFF2d3748),
            ),
            decoration: InputDecoration(
              hintText: 'Enter your ${label.toLowerCase()}',
              hintStyle: GoogleFonts.poppins(
                color:
                    this.controller.isDarkMode.value
                        ? const Color(0xFF718096)
                        : const Color(0xFFa0aec0),
              ),
              filled: true,
              fillColor:
                  this.controller.isDarkMode.value
                      ? const Color(0xFF4a5568)
                      : Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(
                  color:
                      this.controller.isDarkMode.value
                          ? const Color(0xFF718096)
                          : const Color(0xFFe2e8f0),
                  width: 2,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(
                  color:
                      this.controller.isDarkMode.value
                          ? const Color(0xFF718096)
                          : const Color(0xFFe2e8f0),
                  width: 2,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(
                  color:
                      this.controller.isDarkMode.value
                          ? const Color(0xFF4299e1)
                          : const Color(0xFF667eea),
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: const BorderSide(color: Colors.red, width: 2),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 20.w,
                vertical: 16.h,
              ),
              suffixIcon:
                  isPassword
                      ? IconButton(
                        onPressed: onTogglePassword,
                        icon: Icon(
                          obscureText ? Icons.visibility : Icons.visibility_off,
                          color:
                              this.controller.isDarkMode.value
                                  ? const Color(0xFF718096)
                                  : const Color(0xFFa0aec0),
                        ),
                      )
                      : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGradientButton({
    required String text,
    required VoidCallback onPressed,
  }) {
    return Obx(
      () => Container(
        width: double.infinity,
        height: 48.h,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors:
                controller.isDarkMode.value
                    ? [const Color(0xFF4299e1), const Color(0xFF3182ce)]
                    : [const Color(0xFF667eea), const Color(0xFF764ba2)],
          ),
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color:
                  controller.isDarkMode.value
                      ? const Color(0xFF4299e1).withOpacity(0.3)
                      : const Color(0xFF667eea).withOpacity(0.3),
              blurRadius: 8.r,
              offset: Offset(0, 4.h),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
          child: Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTermsText() {
    return Obx(
      () => Text(
        'By continuing, you agree to our Terms of Service and Privacy Policy',
        style: GoogleFonts.poppins(
          fontSize: 12.sp,
          color:
              controller.isDarkMode.value
                  ? const Color(0xFFa0aec0)
                  : const Color(0xFF718096),
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
