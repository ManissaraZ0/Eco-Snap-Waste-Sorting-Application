import 'package:eco_snap/provider/game_provider.dart';
import 'package:flutter/material.dart';
import 'package:eco_snap/common/color_extension.dart';
import 'package:eco_snap/view/minigame/game_page.dart';
import 'package:provider/provider.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          /// พื้นหลังรูปภาพ
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/img/sorting_bg.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),

          /// กล่องขาว + ปุ่ม Start
          Center(
            child: Container(
              padding: const EdgeInsets.all(24),
              margin: const EdgeInsets.symmetric(horizontal: 32),
              decoration: BoxDecoration(
                color: TColor.newwhite.withValues(alpha: .9),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: .15),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Waste Sorting Game!",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),

                  const Text(
                    "Tap the Start button to begin the waste sorting game.\nAnswer as quickly and accurately as you can!!",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, color: Colors.black54),
                  ),

                  const SizedBox(height: 32),

                  /// ปุ่ม Start
                  SizedBox(
                    width: 160,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: TColor.newgreen,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () {
                        final gp = context.read<GameProvider>();
                        gp.startNewRound(); // <-- Reset + เริ่มเกมใหม่ที่นี่

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const GamePage(),
                          ),
                        );
                      },

                      child: const Text(
                        "START",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
