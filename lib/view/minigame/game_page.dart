import 'package:eco_snap/view/main_tab/main_tab_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eco_snap/common/color_extension.dart';
import 'package:eco_snap/provider/game_provider.dart';

import '../../common_widget/waste_option_button.dart';
import 'result_page.dart';

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  bool _navigated = false; // ป้องกัน navigate ซ้ำ

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final gp = context.read<GameProvider>();
      await gp.loadLeaderboard();
      gp.startNewRound(); // reset และสุ่มคำถามใหม่
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, game, child) {
        if (game.isFinished && !_navigated) {
          _navigated = true;

          WidgetsBinding.instance.addPostFrameCallback((_) async {
            final gp = context.read<GameProvider>();

            int topScore = 0;

            if (gp.isLeaderboardLoaded && gp.leaderboard.isNotEmpty) {
              topScore = gp.leaderboard.first.score;
            }

            bool isHighScore = game.score > topScore;

            // ⭐ บันทึกคะแนนใน Provider
            gp.addResult("Player", game.score);

            // ⭐ บันทึกคะแนนใน Firebase
            await gp.saveScore(game.score);

            // ⭐ Navigate ไป Result
            if (mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      ResultPage(score: game.score, isHighScore: isHighScore),
                ),
              );
            }
          });
        }

        if (game.isFinished) {
          return const Scaffold(backgroundColor: Colors.black);
        }

        final question = game.currentRound[game.currentIndex];

        return Scaffold(
          backgroundColor: game.answerColor ?? TColor.newgreen,
          appBar: AppBar(
            title: const Text(
              'please sort your waste',
              style: TextStyle(color: Colors.white),
            ),
            centerTitle: true,
            backgroundColor: game.answerColor ?? TColor.newgreen,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                // รีเซ็ตเกมทันที
                context.read<GameProvider>().startNewRound();

                // Navigate ไปหน้า MainTabView
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const MainTabView()),
                );
              },
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "number ${game.currentIndex + 1} / 5",
                  style: const TextStyle(fontSize: 22, color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  "time: ${game.timeLeft}",
                  style: const TextStyle(fontSize: 20, color: Colors.white),
                ),
                const SizedBox(height: 12),
                Center(
                  child: SizedBox(
                    height: 220,
                    child: Image.asset(question.imagePath, fit: BoxFit.contain),
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                  ), // เว้นซ้าย–ขวา
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: 1,
                    children: [
                      WasteOptionButton(
                        size: 120,
                        color: "yellow",
                        onTap: () => game.answer("yellow"),
                      ),
                      WasteOptionButton(
                        size: 120,
                        color: "green",
                        onTap: () => game.answer("green"),
                      ),
                      WasteOptionButton(
                        size: 120,
                        color: "blue",
                        onTap: () => game.answer("blue"),
                      ),
                      WasteOptionButton(
                        size: 120,
                        color: "red",
                        onTap: () => game.answer("red"),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
