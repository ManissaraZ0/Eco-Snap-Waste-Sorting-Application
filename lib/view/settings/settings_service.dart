import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class SettingsService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final Map<String, Color> wasteColors = {
      "อันตราย": Colors.red,
      "ทั่วไป": Colors.blue,
      "อินทรีย์": Colors.green,
      "รีไซเคิล": Colors.yellow,
    };

  Future<int> loadYearlyTotal(String uid, int year) async {
    final start = DateTime(year, 1, 1);
    final end = DateTime(year + 1, 1, 1);

    final query = await _db
        .collection("waste_sorting")
        .where("user_id", isEqualTo: uid)
        .where("date", isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where("date", isLessThan: Timestamp.fromDate(end))
        .get();

    return query.size;
  }

  Future<List<BarChartGroupData>> loadMonthlyChart(String uid, int year) async {
    final start = DateTime(year, 1, 1);
    final end = DateTime(year + 1, 1, 1);

    final query = await FirebaseFirestore.instance
        .collection("waste_sorting")
        .where("user_id", isEqualTo: uid)
        .orderBy("date")
        .get();

    // filter ด้วย Dart แทน Firestore
    final filteredDocs = query.docs.where((doc) {
      final d = (doc["date"] as Timestamp).toDate();
      return d.isAfter(start) && d.isBefore(end);
    }).toList();

    // เตรียมข้อมูล 12 เดือน x 4 ประเภท
    final Map<int, Map<String, int>> monthlyCount = {};

    for (int m = 1; m <= 12; m++) {
      monthlyCount[m] = {
        "อันตราย": 0,
        "ทั่วไป": 0,
        "อินทรีย์": 0,
        "รีไซเคิล": 0,
      };
    }

    for (var doc in filteredDocs) {
      final data = doc.data();
      DateTime d = (data["date"] as Timestamp).toDate();
      int month = d.month;

      String type = data["type"] ?? "ทั่วไป";
      if (monthlyCount[month]!.containsKey(type)) {
        monthlyCount[month]![type] = monthlyCount[month]![type]! + 1;
      }
    }

    // สร้างกราฟ stacked bar
    List<BarChartGroupData> bars = [];

    monthlyCount.forEach((month, typeCount) {
      List<BarChartRodStackItem> stacks = [];
      double sum = 0;
      double startY = 0;

      // ignore: avoid_types_as_parameter_names
      typeCount.forEach((type, count) {
        double endY = startY + count.toDouble();
        stacks.add(BarChartRodStackItem(startY, endY, wasteColors[type]!));
        startY = endY;
        sum += count;
      });

      bars.add(
        BarChartGroupData(
          x: month,
          barRods: [
            BarChartRodData(
              toY: sum,
              rodStackItems: stacks,
              width: 22,
              borderRadius: BorderRadius.circular(0),
            ),
          ],
        ),
      );
    });

    return bars;
  }
}
