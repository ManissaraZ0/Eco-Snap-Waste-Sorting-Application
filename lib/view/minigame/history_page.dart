import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eco_snap/provider/game_provider.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final gameProvider = context.read<GameProvider>();

    return FutureBuilder(
      future: gameProvider.fetchHistory(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final history = context.watch<GameProvider>().history;

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            title: const Text("History", style: TextStyle(color: Colors.black)),
            iconTheme: const IconThemeData(color: Colors.black),
          ),

          /// 🟢 ปุ่มลอยสำหรับ "ล้างประวัติทั้งหมด"
          floatingActionButton: FloatingActionButton(
            backgroundColor: Colors.redAccent,
            child: const Icon(Icons.delete, color: Colors.white),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text("คุณต้องการที่จะลบประวัติการเล่นทั้งหมดหรือไม่ ?"),
                    content: const Text(
                      "คุณแน่ใจใช่มั้ยที่จะลบประวัติการเล่นทั้งหมด คุณจะไม่สามารถกู้คืนประวัติที่ถูกลบนี้ได้",
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text("ยกเลิก"),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                        ),
                        child: const Text("ลบ"),
                      ),
                    ],
                  );
                },
              );

              if (confirm == true) {
                await context.read<GameProvider>().clearHistory();
              }
            },
          ),

          body: history.isEmpty
              ? const Center(
                  child: Text(
                    "ไม่พบประวัติการเล่น",
                    style: TextStyle(fontSize: 18, color: Colors.black54),
                  ),
                )
              : ListView.builder(
                  itemCount: history.length,
                  itemBuilder: (context, index) {
                    final entry = history[index];
                    final rank = index + 1;

                    IconData trophyIcon = Icons.emoji_events;
                    Color trophyColor;
                    if (rank == 1) {
                      trophyColor = Colors.amber;
                    } else if (rank == 2) {
                      trophyColor = Colors.grey;
                    } else if (rank == 3) {
                      trophyColor = const Color(0xFFCD7F32);
                    } else {
                      trophyColor = const Color(0xFFE0B2B2);
                    }

                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      leading: Stack(
                        alignment: const Alignment(0, -0.45),
                        children: [
                          Icon(trophyIcon, color: trophyColor, size: 40),
                          Text(
                            "$rank",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  color: Colors.black45,
                                  offset: Offset(1, 1),
                                  blurRadius: 2,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      title: Text(
                        "${entry.timestamp}",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      trailing: Text(
                        entry.score.toString(),
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  },
                ),
        );
      },
    );
  }
}
