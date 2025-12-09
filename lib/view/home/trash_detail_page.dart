import 'package:flutter/material.dart';
import 'package:eco_snap/common/color_extension.dart';

class TrashDetailPage extends StatelessWidget {
  final String name;
  final String type;
  final String image;
  final String description;
  final String binIcon;

  const TrashDetailPage({
    super.key,
    required this.name,
    required this.type,
    required this.image,
    required this.description,
    required this.binIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColor.background,
      appBar: AppBar(title: Text(name), backgroundColor: TColor.primary),

      // ▼▼ เนื้อหาเลื่อนขึ้นลงได้
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: SizedBox(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.asset(
                      image,
                      width: 300,
                      height: 300,
                      fit: BoxFit.contain,
                    ),
                  ],
                ),

                const SizedBox(height: 25),

                Text(
                  name,
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: TColor.gray,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 10),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: _getBinColor(type), // เรียกฟังก์ชันที่กำหนดสี
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "ประเภทขยะ: $type",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                Text(
                  description,
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 50), // กันไม่ให้ตัวหนังสือชน bottom bar
              ],
            ),
          ),
        ),
      ),

      // ▼▼ ส่วนที่ติดล่างหน้าจอ
      bottomNavigationBar: SizedBox(
        width: double.infinity,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 15),
          decoration: BoxDecoration(
            color: Colors.white, // ← มาใส่ตรงนี้แทน
            image: const DecorationImage(
              image: AssetImage("assets/img/bottom_back.png"),
              fit: BoxFit.cover,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "ควรทิ้งลงถังนี้",
                style: TextStyle(fontSize: 20, color: TColor.gray),
              ),
              const SizedBox(height: 10),
              Image.asset(
                binIcon,
                width: 110,
                height: 110,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}

// ฟังก์ชันที่ใช้ในการกำหนดสี
Color _getBinColor(String type) {
  if (type == "รีไซเคิล") {
    return const Color.fromARGB(255, 252, 190, 66);
  } else if (type == "ทั่วไป") {
    return Colors.blue; 
  } else if (type == "อันตราย") {
    return Colors.red;
  } else {
    return Colors.green; 
  }
}
