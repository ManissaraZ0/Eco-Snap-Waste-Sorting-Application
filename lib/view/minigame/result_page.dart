import 'package:eco_snap/view/main_tab/main_tab_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eco_snap/common/color_extension.dart';
import 'package:eco_snap/provider/game_provider.dart';
import 'package:eco_snap/view/minigame/game_page.dart';
import 'package:eco_snap/view/minigame/history_page.dart';


class ResultPage extends StatelessWidget {
  final int score;
  final bool isHighScore;

  /// <-- เพิ่มตัวนี้

  const ResultPage({super.key, required this.score, required this.isHighScore});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              "assets/img/sorting_bg.jpg",
              fit: BoxFit.cover,
            ),
          ),

          // ปุ่มย้อนกลับมุมซ้ายบน
          Positioned(
            top: 40, // ปรับตาม status bar
            left: 16,
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white, size: 30),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => MainTabView()),
                );
              },
            ),
          ),

          Center(
            child: Container(
              padding: EdgeInsets.all(30),
              margin: EdgeInsets.symmetric(horizontal: 40),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .92),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),

              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  /// ถ้าเป็น high score ให้แสดงข้อความพิเศษ
                  if (isHighScore)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          "NEW HIGH SCORE!",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: const Color.fromARGB(255, 57, 128, 79),
                          ),
                        ),
                      ),
                    ),

                  Text(
                    "score",
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: TColor.newgreen,
                    ),
                  ),

                  Text(
                    "$score",
                    style: TextStyle(
                      fontSize: 52,
                      fontWeight: FontWeight.bold,
                      color: TColor.newgreen,
                    ),
                  ),

                  SizedBox(height: 20),

                  IconButton(
                    icon: Icon(Icons.history, size: 40, color: TColor.newgreen),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => HistoryPage()),
                      );
                    },
                  ),

                  SizedBox(height: 18),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: TColor.newgreen,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 28,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      context.read<GameProvider>().startNewRound();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => GamePage()),
                      );
                    },
                    child: Text("play again", style: TextStyle(fontSize: 20)),
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
