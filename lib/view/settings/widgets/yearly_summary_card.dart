import 'package:flutter/material.dart';
import 'package:eco_snap/view/settings/settings_service.dart';

class YearlySummaryCard extends StatelessWidget {
  final int year;
  final SettingsService service;
  final String uid;

  const YearlySummaryCard({
    super.key,
    required this.year,
    required this.service,
    required this.uid,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<int>(
      future: service.loadYearlyTotal(uid, year),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        int total = snapshot.data!;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: .08),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // TITLE
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.recycling,
                      color: Colors.green.shade700,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    "Yearly Summary",
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade900,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              Text(
                "ปี $year คุณแยกขยะไปแล้วทั้งหมด",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade700,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 12),

              // BIG NUMBER
              Center(
                child: Text(
                  "$total ครั้ง",
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    color: Colors.green.shade700,
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // ENCOURAGE MESSAGE
              Center(
                child: Text(
                  total == 0
                      ? "เริ่มแยกขยะวันนี้ โลกขอบคุณคุณแน่นอน 🌎💚"
                      : "ดีมากเลย! คุณช่วยโลกไปอีกขั้นแล้ว 🌍✨",
                  style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
