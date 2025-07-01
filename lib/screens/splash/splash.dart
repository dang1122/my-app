import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scanner/screens/splash/splash_cb.dart';

class Splash extends GetView<SplashController> {
  const Splash({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Or your app's primary color
      body: Obx(() {
        switch (controller.view.value) {
          case SplashView.showLogo:
            return _buildLogoView();
          case SplashView.loading:
            return _buildLoadingView();
          case SplashView.loaded:
            return _buildLoadedView();
          case SplashView.error:
            return _buildErrorView();
        }
      }),
    );
  }

  Widget _buildLogoView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Enhanced logo display with animation
          AnimatedContainer(
            duration: const Duration(milliseconds: 800),
            curve: Curves.elasticOut,
            child: _buildLogo(size: 120),
          ),
          const SizedBox(height: 32),
          // Animated loading indicator
          const SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
          ),
          const SizedBox(height: 24),
          // Animated text
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 1000),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: const Text(
                  'Loading...',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildLogo(size: 100),
          const SizedBox(height: 32),
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          const Text(
            'Initializing...',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadedView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildLogo(size: 100),
          const SizedBox(height: 32),
          // Success animation
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 600),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    size: 48,
                    color: Colors.green,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          const Text(
            'Ready to go!',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildLogo(size: 100),
          const SizedBox(height: 32),
          // Error animation
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 600),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Colors.red,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          const Text(
            'Something went wrong',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 8),
          TextButton(onPressed: () {}, child: const Text('Tap to retry')),
        ],
      ),
    );
  }

  Widget _buildLogo({required double size}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child:
            controller.logoPath.value.isNotEmpty
                ? Image.file(
                  File(controller.logoPath.value),
                  width: size,
                  height: size,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return _buildFallbackLogo(size);
                  },
                )
                : _buildFallbackLogo(size),
      ),
    );
  }

  Widget _buildFallbackLogo(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blue.shade400, Colors.blue.shade600],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Icon(
        Icons.qr_code_scanner, // Replace with your app's icon
        color: Colors.white,
        size: 48,
      ),
    );
  }
}
