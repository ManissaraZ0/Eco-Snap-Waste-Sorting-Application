import 'dart:async';
import 'package:flutter/material.dart';
import '../models/question.dart';
import '../models/leaderboard_entry.dart';

// Firebase
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GameProvider extends ChangeNotifier {
  final List<Question> allQuestions;

  GameProvider(this.allQuestions);

  late List<Question> currentRound;
  int currentIndex = 0;
  int score = 0;

  int combo = 0;
  int comboBonus = 50;

  int timeLeft = 7;
  Timer? _timer;
  bool _disposed = false;
  Color? answerColor;

  List<LeaderboardEntry> leaderboard = [];
  List<LeaderboardEntry> history = [];

  Future<void> fetchHistory() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('game_history')
        .orderBy('score', descending: true)
        .get();

    history = snapshot.docs.map((doc) {
      final data = doc.data();
      return LeaderboardEntry(
        name: "Player", // ถ้าไม่มีชื่อใน Firebase
        score: data['score'] ?? 0,
        timestamp: (data['time_stamp'] as Timestamp).toDate(),
      );
    }).toList();

    notifyListeners();
  }

  /// ---- บันทึกคะแนนลง Firebase ----
  Future<void> saveScore(int score) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final uid = user.uid;
    final userDoc = FirebaseFirestore.instance.collection('users').doc(uid);

    // 1) บันทึก history
    await userDoc.collection('game_history').add({
      'score': score,
      'time_stamp': Timestamp.now(),
    });

    // 2) อัปเดต high score ถ้าจำเป็น
    final snap = await userDoc.get();
    final currentHighScore = snap.data()?['high_score'] ?? 0;

    if (score > currentHighScore) {
      await userDoc.update({'high_score': score});
    }
  }

  /// ---- บันทึกคะแนนใน Provider ----
  void addResult(String name, int score) {
    final entry = LeaderboardEntry(
      name: name,
      score: score,
      timestamp: DateTime.now(),
    );

    history.add(entry);
    history.sort((a, b) => b.score.compareTo(a.score));

    leaderboard.add(entry);
    leaderboard.sort((a, b) => b.score.compareTo(a.score));

    safeNotify();
  }

  bool get isFinished => currentIndex >= currentRound.length;

  void startNewRound() {
    resetGame();

    currentRound = List<Question>.from(allQuestions)..shuffle();
    currentRound = currentRound.take(5).toList();

    startTimer();
    safeNotify();
  }

  void startTimer() {
    timeLeft = 7;
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_disposed) return;

      timeLeft--;

      if (timeLeft <= 0) {
        _timer?.cancel();
        answerColor = Colors.red;
        combo = 0;
        safeNotify(); // เรียกตรง ๆ ปลอดภัยเพราะอยู่ใน timer callback

        Future.delayed(const Duration(milliseconds: 300), () {
          if (!isFinished) safeGoNext();
        });
        return;
      }

      safeNotify(); // เรียกตรง ๆ ปลอดภัย
    });
  }

  void answer(String chosenBin) {
    if (isFinished) return;

    _timer?.cancel();

    bool isCorrect = chosenBin == currentRound[currentIndex].correctBin;

    if (isCorrect) {
      combo++;
      int baseScore = timeLeft * 10;
      int bonus = combo * comboBonus;
      score += baseScore + bonus;
      answerColor = Colors.green;
    } else {
      combo = 0;
      answerColor = Colors.red;
    }

    safeNotify();

    Future.delayed(const Duration(milliseconds: 300), () {
      if (!isFinished) safeGoNext();
    });
  }

  void safeGoNext() {
    if (_disposed) return;
    if (isFinished) return;

    currentIndex++;
    answerColor = null;

    if (!isFinished) startTimer();

    safeNotify();
  }

  void safeNotify() {
    if (_disposed) return;
    notifyListeners();
  }

  void resetGame() {
    currentRound = [];
    currentIndex = 0;
    score = 0;
    combo = 0;
    answerColor = null;
    timeLeft = 7;
    _timer?.cancel();
    safeNotify();
  }

  bool isLeaderboardLoaded = false;

  Future<void> loadLeaderboard() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final query = await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .collection("game_history")
        .orderBy("score", descending: true)
        .limit(1)
        .get();

    leaderboard = query.docs.map((doc) {
      final data = doc.data();

      return LeaderboardEntry(
        name: "Player", // เพราะ Firestore ไม่มีฟิลด์ name
        score: data["score"] ?? 0,
        timestamp: data["time_stamp"] != null
            ? (data["time_stamp"] as Timestamp).toDate()
            : DateTime.now(),
      );
    }).toList();

    isLeaderboardLoaded = true;
    notifyListeners();
  }

  Future<void> clearHistory() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userDoc = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('game_history');

    final snapshot = await userDoc.get();

    // ลบทุก document
    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }

    // เคลียร์ใน provider ด้วย
    history.clear();
    safeNotify();
  }

  @override
  void dispose() {
    _disposed = true;
    _timer?.cancel();
    super.dispose();
  }
}
