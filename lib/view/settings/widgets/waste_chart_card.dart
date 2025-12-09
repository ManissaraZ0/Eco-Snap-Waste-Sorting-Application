import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:eco_snap/view/settings/settings_service.dart';

class WasteChartCard extends StatelessWidget {
  final int selectedYear;
  final SettingsService service;
  final String uid;

  WasteChartCard({
    super.key,
    required this.selectedYear,
    required this.service,
    required this.uid,
  });

  final ScrollController _chartScrollController = ScrollController();

  double findMaxY(List<BarChartGroupData> barGroups) {
    double maxValue = 0;

    for (var g in barGroups) {
      for (var rod in g.barRods) {
        if (rod.toY > maxValue) maxValue = rod.toY;
      }
    }

    if (maxValue < 10) return 10;
    return maxValue + 5; // padding เพิ่มเล็กน้อยเพื่อความสวยงาม
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 4),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white, // 👈 พื้นหลังสีขาว
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // TITLE
            Text(
              "Monthly Waste Statistics",
              style: TextStyle(
                color: Colors.grey.shade900,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              height: 230,
              child: FutureBuilder(
                future: service.loadMonthlyChart(uid, selectedYear),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final barGroups = snapshot.data!;

                  // Auto Scroll to Current Month
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    int currentMonth = DateTime.now().month;
                    double targetX = (currentMonth - 1) * 70;

                    _chartScrollController.animateTo(
                      targetX,
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeOut,
                    );
                  });

                  return SingleChildScrollView(
                    controller: _chartScrollController,
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: barGroups.length * 70,
                      child: BarChart(
                        BarChartData(
                          maxY: findMaxY(barGroups),

                          barGroups: barGroups,

                          barTouchData: BarTouchData(
                            enabled: true,
                            touchTooltipData: BarTouchTooltipData(
                              getTooltipItem:
                                  (group, groupIndex, rod, rodIndex) {
                                    return BarTooltipItem(
                                      rod.toY.toInt().toString(),
                                      const TextStyle(
                                        color: Colors.white,
                                        backgroundColor: Colors.transparent,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    );
                                  },
                            ),
                          ),

                          borderData: FlBorderData(show: false),

                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 32,
                                getTitlesWidget: (value, meta) {
                                  return Text(
                                    value.toInt().toString(),
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  );
                                },
                              ),
                            ),

                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  const months = [
                                    "",
                                    "Jan",
                                    "Feb",
                                    "Mar",
                                    "Apr",
                                    "May",
                                    "Jun",
                                    "Jul",
                                    "Aug",
                                    "Sep",
                                    "Oct",
                                    "Nov",
                                    "Dec",
                                  ];
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 6),
                                    child: Text(
                                      months[value.toInt()],
                                      style: TextStyle(
                                        color: Colors.grey.shade800,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
