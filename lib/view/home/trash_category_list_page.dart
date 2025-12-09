import 'package:eco_snap/view/home/trash_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TrashCategoryListPage extends StatelessWidget {
  final String category;

  const TrashCategoryListPage({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final String normalizedCategory = category.trim(); // กันช่องว่างเกิน

    return Scaffold(
      appBar: AppBar(
        title: Text("ขยะประเภท: $normalizedCategory"),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("trash")
            .where("type", isEqualTo: normalizedCategory)
            // ลองเอา orderBy ออกก่อน กันเรื่อง index
            // .orderBy("name")
            .snapshots(),
        builder: (context, snapshot) {
          // 🔴 ถ้ามี error ให้โชว์เลย จะได้เห็นว่า Firestore ฟ้องอะไร
          if (snapshot.hasError) {
            return Center(
              child: Text(
                "เกิดข้อผิดพลาด: ${snapshot.error}",
                textAlign: TextAlign.center,
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData) {
            return const Center(child: Text("ยังไม่มีข้อมูล"));
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return Center(
              child: Text(
                "ไม่มีข้อมูลสำหรับหมวดนี้\n(category: $normalizedCategory)",
                textAlign: TextAlign.center,
              ),
            );
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final item = docs[index].data() as Map<String, dynamic>;

              final imagePath = item["image"] ?? "";
              final bool isNetwork = imagePath.toString().startsWith("http");

              return ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: isNetwork
                      ? Image.network(
                          imagePath,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        )
                      : Image.asset(
                          imagePath,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        ),
                ),
                title: Text(item["name"] ?? ""),
                subtitle: Text("ประเภท: ${item["type"] ?? "-"}"),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TrashDetailPage(
                        name: item['name'] ?? "",
                        type: item['type'] ?? "",
                        image: item['image'] ?? "",
                        description: item['description'] ?? "",
                        binIcon: getBinIcon(item["type"]),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

/// คืน icon ถังขยะตามประเภทจริง
String getBinIcon(String type) {
  switch (type) {
    case "รีไซเคิล":
      return "assets/img/yellow_bin.png";
    case "อินทรีย์":
      return "assets/img/green_bin.png";
    case "อันตราย":
      return "assets/img/red_bin.png";
    case "ทั่วไป":
    default:
      return "assets/img/blue_bin.png";
  }
}
