import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:scanner/screens/settings/settings_cb.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app/constant.dart';

class SettingsScreen extends GetView<SettingsController> {
  final _licenseKeyController = TextEditingController();
  final _smsTextController = TextEditingController();
  final _voiceTextController = TextEditingController();

  SettingsScreen({super.key});

  // Custom color scheme based on dark mode toggle
  ColorScheme _getColorScheme(bool isDark) {
    if (isDark) {
      return const ColorScheme.dark(
        primary: Color(0xFF6B73FF),
        primaryContainer: Color(0xFF1A1B3A),
        secondary: Color(0xFF03DAC6),
        secondaryContainer: Color(0xFF1A2E2A),
        tertiary: Color(0xFFFF6B6B),
        tertiaryContainer: Color(0xFF3A1A1A),
        surface: Color(0xFF121212),
        surfaceVariant: Color(0xFF2C2C2C),
        background: Color(0xFF0A0A0A),
        onPrimary: Colors.white,
        onPrimaryContainer: Color(0xFFE0E3FF),
        onSecondary: Colors.black,
        onSecondaryContainer: Color(0xFFB2DFDB),
        onTertiary: Colors.white,
        onTertiaryContainer: Color(0xFFFFDADA),
        onSurface: Color(0xFFE3E3E3),
        onSurfaceVariant: Color(0xFFB3B3B3),
        onBackground: Color(0xFFE3E3E3),
        outline: Color(0xFF404040),
        shadow: Colors.black54,
      );
    } else {
      return const ColorScheme.light(
        primary: Color(0xFF1976D2),
        primaryContainer: Color(0xFFE3F2FD),
        secondary: Color(0xFF00796B),
        secondaryContainer: Color(0xFFE0F2F1),
        tertiary: Color(0xFFD32F2F),
        tertiaryContainer: Color(0xFFFFEBEE),
        surface: Colors.white,
        surfaceVariant: Color(0xFFF5F5F5),
        background: Color(0xFFFAFAFA),
        onPrimary: Colors.white,
        onPrimaryContainer: Color(0xFF0D47A1),
        onSecondary: Colors.white,
        onSecondaryContainer: Color(0xFF004D40),
        onTertiary: Colors.white,
        onTertiaryContainer: Color(0xFFB71C1C),
        onSurface: Color(0xFF1C1B1F),
        onSurfaceVariant: Color(0xFF49454F),
        onBackground: Color(0xFF1C1B1F),
        outline: Color(0xFF79747E),
        shadow: Colors.black26,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isDark = controller.isDarkMode.value;
      final colorScheme = _getColorScheme(isDark);

      return Scaffold(
        backgroundColor: colorScheme.background,
        appBar: AppBar(
          title: Text(
            'Settings',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          elevation: 0,
          backgroundColor: colorScheme.surface,
          foregroundColor: colorScheme.onSurface,
          centerTitle: true,
          iconTheme: IconThemeData(color: colorScheme.onSurface),
          leading: Obx(
            () =>
                controller.licenseKey.value != ""
                    ? IconButton(
                      icon: Icon(
                        Icons.arrow_back,
                        color: colorScheme.onSurface,
                      ),
                      onPressed: () {
                        Get.deleteAll();
                        Get.offAndToNamed('/scanner');
                      },
                    )
                    : Container(),
          ),
          automaticallyImplyLeading: false,
          actions: [
            GestureDetector(
              onTap: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove('user');
                Get.deleteAll();
                Get.toNamed('/login');
              },
              child: Container(
                margin: EdgeInsets.only(right: 20.w),
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.red,
                ),
                child: Text(
                  "Logout",
                  style: GoogleFonts.poppins(color: Colors.white),
                ),
              ),
            ),
          ],
        ),

        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Obx(
            () =>
                controller.isLoaded.value
                    ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header Section
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                            'Preferences',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: colorScheme.primary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Dark Mode Card
                        _buildSettingsCard(
                          colorScheme: colorScheme,
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 8,
                            ),
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                isDark ? Icons.dark_mode : Icons.light_mode,
                                color: colorScheme.onPrimaryContainer,
                                size: 24,
                              ),
                            ),
                            title: Text(
                              'Dark Mode',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            subtitle: Text(
                              isDark
                                  ? 'Dark theme enabled'
                                  : 'Light theme enabled',
                              style: TextStyle(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            trailing: Switch.adaptive(
                              value: controller.isDarkMode.value,
                              onChanged: (value) {
                                controller.isDarkMode.value = value;
                                controller.saveSettings();
                              },
                              activeColor: colorScheme.primary,
                              inactiveThumbColor: colorScheme.outline,
                              inactiveTrackColor: colorScheme.surfaceVariant,
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Notifications Header
                        Text(
                          'Notifications',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // SMS Notifications Card
                        _buildSettingsCard(
                          colorScheme: colorScheme,
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: colorScheme.secondaryContainer,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        Icons.sms_outlined,
                                        color: colorScheme.onSecondaryContainer,
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'SMS Notifications',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: colorScheme.onSurface,
                                            ),
                                          ),
                                          Text(
                                            'Configure SMS alert settings',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color:
                                                  colorScheme.onSurfaceVariant,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Obx(
                                  () => Row(
                                    children: [
                                      Expanded(
                                        child: _buildRadioOption(
                                          colorScheme: colorScheme,
                                          title: 'Enable',
                                          value: true,
                                          groupValue:
                                              controller.smsEnabled.value,
                                          onChanged: (value) {
                                            controller.smsEnabled.value =
                                                value!;
                                            controller.saveSettings();
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: _buildRadioOption(
                                          colorScheme: colorScheme,
                                          title: 'Disable',
                                          value: false,
                                          groupValue:
                                              controller.smsEnabled.value,
                                          onChanged: (value) {
                                            controller.smsEnabled.value =
                                                value!;
                                            controller.saveSettings();
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Obx(() {
                                  if (controller.smsEnabled.value) {
                                    return Column(
                                      children: [
                                        const SizedBox(height: 16),
                                        TextField(
                                          controller: _smsTextController,
                                          maxLines: 3,
                                          style: TextStyle(
                                            color: colorScheme.onSurface,
                                          ),
                                          decoration: InputDecoration(
                                            labelText: 'SMS Template',
                                            labelStyle: TextStyle(
                                              color:
                                                  colorScheme.onSurfaceVariant,
                                            ),
                                            hintText:
                                                'Enter your SMS message template... Use \$name for name and \$time for time',
                                            hintStyle: TextStyle(
                                              color: colorScheme
                                                  .onSurfaceVariant
                                                  .withOpacity(0.6),
                                            ),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              borderSide: BorderSide(
                                                color: colorScheme.outline,
                                              ),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              borderSide: BorderSide(
                                                color: colorScheme.outline
                                                    .withOpacity(0.5),
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              borderSide: BorderSide(
                                                color: colorScheme.primary,
                                                width: 2,
                                              ),
                                            ),
                                            filled: true,
                                            fillColor: colorScheme
                                                .surfaceVariant
                                                .withOpacity(0.3),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            'Available variables: \$name (for name), \$time (for time)',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: colorScheme
                                                  .onSurfaceVariant
                                                  .withOpacity(0.8),
                                              fontStyle: FontStyle.italic,
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  }
                                  return const SizedBox.shrink();
                                }),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Voice Messages Card
                        _buildSettingsCard(
                          colorScheme: colorScheme,
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: colorScheme.tertiaryContainer,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        Icons.record_voice_over_outlined,
                                        color: colorScheme.onTertiaryContainer,
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Voice Messages',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: colorScheme.onSurface,
                                            ),
                                          ),
                                          Text(
                                            'Configure voice alert settings',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color:
                                                  colorScheme.onSurfaceVariant,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Obx(
                                  () => Row(
                                    children: [
                                      Expanded(
                                        child: _buildRadioOption(
                                          colorScheme: colorScheme,
                                          title: 'Enable',
                                          value: true,
                                          groupValue:
                                              controller
                                                  .voiceMessageEnabled
                                                  .value,
                                          onChanged: (value) {
                                            controller
                                                .voiceMessageEnabled
                                                .value = value!;
                                            controller.saveSettings();
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: _buildRadioOption(
                                          colorScheme: colorScheme,
                                          title: 'Disable',
                                          value: false,
                                          groupValue:
                                              controller
                                                  .voiceMessageEnabled
                                                  .value,
                                          onChanged: (value) {
                                            controller
                                                .voiceMessageEnabled
                                                .value = value!;
                                            controller.saveSettings();
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Obx(() {
                                  if (controller.voiceMessageEnabled.value) {
                                    return Column(
                                      children: [
                                        const SizedBox(height: 16),
                                        TextField(
                                          controller: _voiceTextController,
                                          maxLines: 3,
                                          style: TextStyle(
                                            color: colorScheme.onSurface,
                                          ),
                                          decoration: InputDecoration(
                                            labelText: 'Voice Message Template',
                                            labelStyle: TextStyle(
                                              color:
                                                  colorScheme.onSurfaceVariant,
                                            ),
                                            hintText:
                                                'Enter your voice message template... Use \$name for name and \$time for time',
                                            hintStyle: TextStyle(
                                              color: colorScheme
                                                  .onSurfaceVariant
                                                  .withOpacity(0.6),
                                            ),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              borderSide: BorderSide(
                                                color: colorScheme.outline,
                                              ),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              borderSide: BorderSide(
                                                color: colorScheme.outline
                                                    .withOpacity(0.5),
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              borderSide: BorderSide(
                                                color: colorScheme.primary,
                                                width: 2,
                                              ),
                                            ),
                                            filled: true,
                                            fillColor: colorScheme
                                                .surfaceVariant
                                                .withOpacity(0.3),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            'Available variables: \$name (for name), \$time (for time)',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: colorScheme
                                                  .onSurfaceVariant
                                                  .withOpacity(0.8),
                                              fontStyle: FontStyle.italic,
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  }
                                  return const SizedBox.shrink();
                                }),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Branding Header
                        Text(
                          'Branding',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Company Logo Card
                        _buildSettingsCard(
                          colorScheme: colorScheme,
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: colorScheme.primaryContainer,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        Icons.business_outlined,
                                        color: colorScheme.onPrimaryContainer,
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Company Logo',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: colorScheme.onSurface,
                                            ),
                                          ),
                                          Text(
                                            'Upload your company logo',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color:
                                                  colorScheme.onSurfaceVariant,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                Center(
                                  child: Obx(
                                    () => GestureDetector(
                                      onTap: _pickImage,
                                      child: Container(
                                        width: Get.width,
                                        height: 140,
                                        decoration: BoxDecoration(
                                          color:
                                              controller.logoPath.value.isEmpty
                                                  ? colorScheme.surfaceVariant
                                                  : null,
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          border: Border.all(
                                            color: colorScheme.outline
                                                .withOpacity(0.5),
                                            width: 2,
                                          ),
                                        ),
                                        child:
                                            controller.logoPath.value.isEmpty
                                                ? Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Icon(
                                                      Icons
                                                          .add_photo_alternate_outlined,
                                                      size: 48,
                                                      color:
                                                          colorScheme
                                                              .onSurfaceVariant,
                                                    ),
                                                    const SizedBox(height: 8),
                                                    Text(
                                                      'Tap to upload',
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color:
                                                            colorScheme
                                                                .onSurfaceVariant,
                                                      ),
                                                    ),
                                                  ],
                                                )
                                                : ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(14),
                                                  child: Image.file(
                                                    File(
                                                      controller.logoPath.value,
                                                    ),
                                                    width: 140,
                                                    height: 140,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                SizedBox(
                                  width: Get.width,
                                  child: ElevatedButton.icon(
                                    icon: Icon(
                                      Icons.upload_outlined,
                                      color: colorScheme.onPrimary,
                                    ),
                                    label: Text(
                                      'Upload Logo',
                                      style: TextStyle(
                                        color: colorScheme.onPrimary,
                                      ),
                                    ),
                                    onPressed: _pickImage,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: colorScheme.primary,
                                      foregroundColor: colorScheme.onPrimary,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 24,
                                        vertical: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // License Header
                        Text(
                          'License',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // License Key Card
                        _buildSettingsCard(
                          colorScheme: colorScheme,
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: colorScheme.secondaryContainer,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        Icons.key_outlined,
                                        color: colorScheme.onSecondaryContainer,
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'License Key',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: colorScheme.onSurface,
                                            ),
                                          ),
                                          Text(
                                            'Enter your software license key',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color:
                                                  colorScheme.onSurfaceVariant,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Obx(() {
                                  _licenseKeyController.text =
                                      controller.licenseKey.value;
                                  return TextField(
                                    controller: _licenseKeyController,
                                    style: TextStyle(
                                      color: colorScheme.onSurface,
                                    ),
                                    decoration: InputDecoration(
                                      labelText: 'License Key',
                                      labelStyle: TextStyle(
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                      hintText: 'Enter your license key...',
                                      hintStyle: TextStyle(
                                        color: colorScheme.onSurfaceVariant
                                            .withOpacity(0.6),
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: colorScheme.outline,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: colorScheme.outline
                                              .withOpacity(0.5),
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: colorScheme.primary,
                                          width: 2,
                                        ),
                                      ),
                                      filled: true,
                                      fillColor: colorScheme.surfaceVariant
                                          .withOpacity(0.3),
                                      prefixIcon: Icon(
                                        Icons.vpn_key_outlined,
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                    onChanged: (value) {
                                      controller.licenseKey.value = value;
                                      //controller.saveSettings();
                                    },
                                  );
                                }),
                                const SizedBox(height: 10),
                                SizedBox(
                                  width: Get.width,
                                  child: ElevatedButton.icon(
                                    icon: Icon(
                                      Icons.key,
                                      color: colorScheme.onPrimary,
                                    ),
                                    label: Text(
                                      'Change License Key',
                                      style: TextStyle(
                                        color: colorScheme.onPrimary,
                                      ),
                                    ),
                                    onPressed: _changeLicenseKey,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: colorScheme.primary,
                                      foregroundColor: colorScheme.onPrimary,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 24,
                                        vertical: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),
                      ],
                    )
                    : Container(
                      height: Get.height - 200.h,
                      child: Center(child: CircularProgressIndicator()),
                    ),
          ),
        ),
      );
    });
  }

  Widget _buildSettingsCard({
    required ColorScheme colorScheme,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildRadioOption({
    required ColorScheme colorScheme,
    required String title,
    required bool value,
    required bool groupValue,
    required ValueChanged<bool?> onChanged,
  }) {
    final isSelected = value == groupValue;

    return GestureDetector(
      onTap: () => onChanged(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? colorScheme.primaryContainer.withOpacity(0.5)
                  : colorScheme.surfaceVariant.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                isSelected
                    ? colorScheme.primary
                    : colorScheme.outline.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Radio<bool>(
              value: value,
              groupValue: groupValue,
              onChanged: onChanged,
              activeColor: colorScheme.primary,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? colorScheme.primary : colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 100,
    );
    if (image != null) {
      // Get the app's local storage directory
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String fileName =
          'logo${DateTime.now().millisecondsSinceEpoch}.jpg';
      final String storagePath = '${appDir.path}/$fileName';

      // Copy the picked image to permanent storage
      var file = await File(image.path).copy(storagePath);

      // Update the controller with the new permanent path
      print("path ${file.path}");
      controller.logoPath.value = file.path;
      controller.saveSettings();
      print(controller.logoPath.value);
    }
  }

  Future<void> _changeLicenseKey() async {
    var res = await GetConnect().post(
      "${AppStrings.baseUrl}student_checkin/api.php",
      {
        "method": "SELECT",
        "table": "license_keys",
        "set": "*",
        "where": "license_key='${_licenseKeyController.text}' && is_active = 1",
        "token": "sdaesi",
      },
    );
    if (res.body['data'].isNotEmpty) {
      print(res.body['data']);
      controller.licenseKey.value = _licenseKeyController.text;
      controller.saveSettings();
      _showSuccessDialog();
    } else {
      controller.licenseKey.value = "";
      controller.saveSettings();
      Get.snackbar(
        'Error',
        'Invalid license key',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade700,
        colorText: Colors.white,
        borderRadius: 8,
        margin: EdgeInsets.all(8.w),
        duration: const Duration(seconds: 3),
        isDismissible: true,
        dismissDirection: DismissDirection.horizontal,
        forwardAnimationCurve: Curves.easeOutBack,
        reverseAnimationCurve: Curves.easeInBack,
        icon: const Icon(Icons.error_outline, color: Colors.white),
      );
    }
  }

  void _showSuccessDialog() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle_outline,
                color: Colors.green,
                size: 64,
              ),
              const SizedBox(height: 16),
              Text(
                'Success!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Get.theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Settings have been updated successfully.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Get.theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Get.back();
                  Get.offNamed('/scanner');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Get.theme.colorScheme.primary,
                  foregroundColor: Get.theme.colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('OK'),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }
}
