import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eco_snap/common/color_extension.dart';
import 'package:eco_snap/view/home/trash_detail_page.dart';

class AllTrashView extends StatefulWidget {
  const AllTrashView({super.key});

  @override
  State<AllTrashView> createState() => _AllTrashViewState();
}

class _AllTrashViewState extends State<AllTrashView> {
  final TextEditingController _searchController = TextEditingController();
  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColor.background,
      appBar: AppBar(
        title: const Text('ขยะทั้งหมด'),
        centerTitle: true,
        backgroundColor: TColor.primary,
        elevation: 0,
      ),

      body: Column(
        children: [
          const SizedBox(height: 10),

          // 🔍 SEARCH BAR
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: Material(
              elevation: 2,
              borderRadius: BorderRadius.circular(16),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    searchQuery = value.trim().toLowerCase();
                  });
                },
                decoration: InputDecoration(
                  hintText: 'ค้นหาขยะ...',
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // รายการขยะจาก Firebase Firestore
          Expanded(
            child: FutureBuilder<QuerySnapshot>(
              future: FirebaseFirestore.instance
                  .collection("trash")
                  .orderBy("name")
                  .get(), // โหลดครั้งเดียว

              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;

                // 🔍 SEARCH FILTER
                final filtered = docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final name = data["name"].toString().toLowerCase();
                  return name.contains(searchQuery);
                }).toList();

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final item = filtered[index].data() as Map<String, dynamic>;

                    // auto detect asset vs network
                    final imagePath = item["image"];
                    final bool isNetwork = imagePath.startsWith("http");

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TrashDetailPage(
                              name: item["name"],
                              type: item["type"],
                              image: item["image"],
                              description: item["description"],
                              binIcon: getBinIcon(item["type"]),
                            ),
                          ),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: .05),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: isNetwork
                                  ? Image.network(
                                      imagePath,
                                      width: 52,
                                      height: 52,
                                      fit: BoxFit.cover,
                                    )
                                  : Image.asset(
                                      imagePath,
                                      width: 52,
                                      height: 52,
                                      fit: BoxFit.cover,
                                    ),
                            ),

                            const SizedBox(width: 16),

                            Expanded(
                              child: Text(
                                item["name"],
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),

                            const Icon(Icons.chevron_right, color: Colors.grey),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
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
