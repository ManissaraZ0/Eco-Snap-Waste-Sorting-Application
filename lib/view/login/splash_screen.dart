import 'dart:async';
import 'package:flutter/material.dart';
import 'package:eco_snap/common/color_extension.dart';

import 'login_screen.dart';

// Splash Screen
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColor.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(flex: 2),

            // ข้อความ Platform of Waste Management
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                children: [
                  Text(
                    'Eco Snap',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w700,
                      color: TColor.primaryText,
                      letterSpacing: 0.5,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 60),

            // รูป recycling-bin.png พร้อม Container
            Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: TColor.lightGray.withValues(alpha: .5),
                shape: BoxShape.circle,
              ),
              child: Image.asset(
                'assets/img/recycling-bin.png',
                width: 180,
                height: 180,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.recycling,
                    size: 180,
                    color: TColor.primary,
                  );
                },
              ),
            ),

            const Spacer(flex: 2),

            // Loading indicator
            SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                color: TColor.primary,
                strokeWidth: 3,
              ),
            ),

            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}
