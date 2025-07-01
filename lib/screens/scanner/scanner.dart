import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:scanner/screens/scanner/scanner_cb.dart';

class Scanner extends GetView<ScannerController> {
  const Scanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isDark = controller.isDarkMode.value;

      return Scaffold(
        backgroundColor: isDark ? Colors.grey[900] : Colors.white,
        appBar: AppBar(
          backgroundColor: isDark ? Colors.grey[850] : Colors.white,
          automaticallyImplyLeading: false,
          leading: GestureDetector(
            onTap: () {
              controller.isReading(true);
            },
            child: Icon(
              Icons.refresh,
              size: 20.sp,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          title: Text(
            'QR Scanner',
            style: GoogleFonts.poppins(
              fontSize: 17.sp,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          centerTitle: true,
          actions: [
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    Get.offAndToNamed('/attendance');
                  },
                  child: Icon(
                    Icons.list_alt,
                    size: 20.sp,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                // SizedBox(width: 15.w),
                // GestureDetector(
                //   onTap: () async {
                //     // var pref = await SharedPreferences.getInstance();
                //     // await pref.clear();
                //     //Get.toNamed('/login');
                //   },
                //   child: Icon(
                //     Icons.logout,
                //     size: 20.sp,
                //     color: isDark ? Colors.white : Colors.black,
                //   ),
                // ),
                SizedBox(width: 15.w),
                GestureDetector(
                  onTap: () {
                    Get.offAndToNamed('/settings');
                  },
                  child: Icon(
                    Icons.settings,
                    size: 20.sp,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                SizedBox(width: 15.w),
              ],
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  MobileScanner(
                    controller: controller.scannerController,
                    onDetect: (capture) async {
                      if (controller.isReading.value) {
                        controller.isReading(false);
                        await controller.checkInOut(
                          capture.barcodes.first.rawValue,
                          controller.timing.value,
                        );
                      }
                    },
                  ),
                  CustomPaint(
                    painter: ScannerOverlay(isDarkMode: isDark),
                    child: const SizedBox(width: 300, height: 300),
                  ),
                ],
              ),
            ),
            Obx(
              () => switch (controller.view.value) {
                ScannerView.scanning => _scanning(),
                ScannerView.error => _errorScan(isDark),
                ScannerView.scanned => _scanned(isDark),
              },
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
              color: isDark ? Colors.grey[900] : Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Scan QR in the frame.',
                    style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      color: isDark ? Colors.grey[400] : Colors.grey,
                    ),
                  ),
                  SizedBox(
                    width: Get.width / 3,
                    child: DropdownButtonFormField<String>(
                      value: controller.timing.value,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 15.w,
                          vertical: 10.h,
                        ),
                        filled: true,
                        fillColor: isDark ? Colors.grey[800] : Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color:
                                isDark ? Colors.grey[600]! : Colors.grey[300]!,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color:
                                isDark ? Colors.grey[600]! : Colors.grey[300]!,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color:
                                isDark ? Colors.blue[400]! : Colors.blue[300]!,
                          ),
                        ),
                      ),
                      icon: Icon(
                        Icons.arrow_drop_down,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                      dropdownColor: isDark ? Colors.grey[800] : Colors.white,
                      items:
                          controller.timings.map((String timing) {
                            return DropdownMenuItem<String>(
                              value: timing,
                              child: Text(
                                timing,
                                style: GoogleFonts.poppins(
                                  fontSize: 14.sp,
                                  color:
                                      isDark ? Colors.white : Colors.grey[800],
                                ),
                              ),
                            );
                          }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          controller.timing.value = newValue;
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _scanning() {
    return Container();
  }

  Widget _errorScan(bool isDark) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 10.h),
      color: isDark ? Colors.red[900]?.withOpacity(0.3) : Colors.red[100],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Error scanning QR code. Error ${controller.errorText.value}.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 14.sp,
              color: isDark ? Colors.red[300] : Colors.red[900],
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8.h),
          GestureDetector(
            onTap: () {
              controller.view.value = ScannerView.scanning;
            },
            child: Text(
              'Okay',
              style: GoogleFonts.poppins(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _scanned(bool isDark) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 10.h),
      color: isDark ? Colors.green[900]?.withOpacity(0.3) : Colors.green[100],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Processing QR code...',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 14.sp,
              color: isDark ? Colors.green[300] : Colors.green[900],
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8.h),
          GestureDetector(
            onTap: () {
              controller.isReading.value = true;
              controller.view.value = ScannerView.scanning;
            },
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(
                decoration: TextDecoration.underline,
                fontSize: 14.sp,
                color: isDark ? Colors.red[300] : Colors.red,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ScannerOverlay extends CustomPainter {
  final bool isDarkMode;

  ScannerOverlay({this.isDarkMode = false});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.white.withOpacity(0.5)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0;

    // Draw outer rectangle
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    // Draw corner lines
    final cornerLength = size.width * 0.1;
    final paint2 =
        Paint()
          ..color = isDarkMode ? Colors.blue[300]! : Colors.blue
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4.0;

    // Top left corner
    canvas.drawLine(Offset(0, 0), Offset(cornerLength, 0), paint2);
    canvas.drawLine(Offset(0, 0), Offset(0, cornerLength), paint2);

    // Top right corner
    canvas.drawLine(
      Offset(size.width, 0),
      Offset(size.width - cornerLength, 0),
      paint2,
    );
    canvas.drawLine(
      Offset(size.width, 0),
      Offset(size.width, cornerLength),
      paint2,
    );

    // Bottom left corner
    canvas.drawLine(
      Offset(0, size.height),
      Offset(cornerLength, size.height),
      paint2,
    );
    canvas.drawLine(
      Offset(0, size.height),
      Offset(0, size.height - cornerLength),
      paint2,
    );

    // Bottom right corner
    canvas.drawLine(
      Offset(size.width, size.height),
      Offset(size.width - cornerLength, size.height),
      paint2,
    );
    canvas.drawLine(
      Offset(size.width, size.height),
      Offset(size.width, size.height - cornerLength),
      paint2,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is ScannerOverlay &&
        oldDelegate.isDarkMode != isDarkMode;
  }
}
