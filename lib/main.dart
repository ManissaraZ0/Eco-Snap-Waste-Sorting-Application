import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:eco_snap/common/color_extension.dart';
import 'package:eco_snap/models/question.dart';
import 'package:eco_snap/provider/game_provider.dart';
import 'package:eco_snap/view/login/login_screen.dart';
import 'package:eco_snap/view/login/signup_screen.dart';
import 'package:eco_snap/view/login/splash_screen.dart';
import 'package:eco_snap/view/main_tab/main_tab_view.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // ใช้ Question Bank ที่มีอยู่เดิม
  List<Question> get questionBank => [
    Question(imagePath: "assets/img/banana.jpg", correctBin: "green"),
    Question(imagePath: "assets/img/battery.jpg", correctBin: "red"),
    Question(imagePath: "assets/img/bottle_cap.jpg", correctBin: "yellow"),
    Question(imagePath: "assets/img/can.jpg", correctBin: "yellow"),
    Question(imagePath: "assets/img/cardboard.jpg", correctBin: "yellow"),
    Question(imagePath: "assets/img/eggshell.png", correctBin: "green"),
    Question(imagePath: "assets/img/food_scrap.jpg", correctBin: "green"),
    Question(imagePath: "assets/img/glass_bottle.jpg", correctBin: "yellow"),
    Question(imagePath: "assets/img/light_bulb.jpg", correctBin: "red"),
    Question(imagePath: "assets/img/medicine.jpeg", correctBin: "red"),
    Question(imagePath: "assets/img/milk_carton.jpg", correctBin: "yellow"),
    Question(imagePath: "assets/img/napkin.jpg", correctBin: "blue"),
    Question(imagePath: "assets/img/newspaper.jpg", correctBin: "yellow"),
    Question(imagePath: "assets/img/oil_carton.png", correctBin: "yellow"),
    Question(imagePath: "assets/img/old_clothes.jpg", correctBin: "blue"),
    Question(imagePath: "assets/img/plastic_bag.jpg", correctBin: "blue"),
    Question(imagePath: "assets/img/plastic_cup.jpg", correctBin: "yellow"),
    Question(imagePath: "assets/img/spray_bottle.jpg", correctBin: "red"),
    Question(imagePath: "assets/img/Styrofoam.jpg", correctBin: "blue"),
    Question(imagePath: "assets/img/water_bottle.png", correctBin: "yellow"),
    Question(imagePath: "assets/img/leaf.jpg", correctBin: "green"),
  ];

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GameProvider(questionBank)..startNewRound(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Waste Management Platform',
        theme: ThemeData(
          fontFamily: GoogleFonts.kanit().fontFamily,
          scaffoldBackgroundColor: TColor.background,
          colorScheme: ColorScheme.fromSeed(
            seedColor: TColor.primary,
            surface: TColor.gray80,
            primary: TColor.primary,
            primaryContainer: TColor.gray60,
            secondary: TColor.secondary,
          ),
          useMaterial3: false,
        ),
        // เส้นทางระบบล็อกอิน
        routes: {
          '/login': (context) => LoginScreen(),
          '/signup': (context) => SignUpScreen(),
          '/main': (context) => MainTabView(), // เพิ่มไว้สำหรับหลังล็อกอิน
        },

        // หน้าแรก = SplashScreen
        home: const SplashScreen(),
      ),
    );
  }
}
