import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:scanner/app/app_router.dart';
import 'package:scanner/screens/splash/splash.dart';
import 'package:scanner/screens/splash/splash_cb.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812), // Standard design size
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          title: 'Scanner App',
          debugShowCheckedModeBanner: false,
          getPages: appRouter(),
          theme: ThemeData(
            primarySwatch: Colors.blue,
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          home: Splash(),
          initialBinding: SplashBinding(),
        );
      },
    );
  }
}
