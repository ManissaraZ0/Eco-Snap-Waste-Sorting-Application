import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eco_snap/common/color_extension.dart';
import 'package:eco_snap/common_widget/banner_carousel.dart';
import 'package:eco_snap/view/home/all_trash_view.dart';
import 'package:eco_snap/view/home/trash_category_list_page.dart';
import 'package:eco_snap/view/home/trash_detail_page.dart';
import 'package:eco_snap/view/settings/settings_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> allTrash = [];
  List<Map<String, dynamic>> filteredTrash = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadTrashFromFirebase();
  }

  /// โหลดขยะทั้งหมดจาก Firestore
  Future<void> loadTrashFromFirebase() async {
    final snapshot = await FirebaseFirestore.instance
        .collection("trash")
        .orderBy("name")
        .get();

    final data = snapshot.docs.map((doc) {
      return doc.data();
    }).toList();

    setState(() {
      allTrash = data;
      filteredTrash = data;
      isLoading = false;
    });
  }

  /// 🔍 ฟิลเตอร์ค้นหา
  void _search(String text) {
    setState(() {
      filteredTrash = allTrash
          .where(
            (item) => item['name'].toString().toLowerCase().contains(
              text.toLowerCase(),
            ),
          )
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
          backgroundColor: TColor.background,
          elevation: 0,
          centerTitle: true,
          title: const Text(
            'Waste Management',
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w600,
              fontSize: 20,
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("users")
                    .doc(FirebaseAuth.instance.currentUser!.uid) // ← ใช้ uid จริงของ user
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.grey,
                    );
                  }

                  final data = snapshot.data!.data() as Map<String, dynamic>;
                  String profilePic =
                      data["profile_picture"] ?? "assets/img/u1.png";

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SettingsView()),
                      );
                    },
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle, // วงกลม
                        color: Colors.white,
                        image: DecorationImage(
                          image: AssetImage(profilePic),
                          fit: BoxFit.contain, // ไม่ crop ทั้งหมด
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

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: EdgeInsets.zero,
              children: [
                // SEARCH BAR
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8,
                  ),
                  child: Material(
                    elevation: 1,
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.white,
                    child: TextField(
                      controller: _searchController,
                      onChanged: _search,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        hintText: 'ค้นหาขยะ...',
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Colors.grey,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 0,
                          horizontal: 20,
                        ),
                      ),
                    ),
                  ),
                ),

                // BANNER
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8,
                  ),
                  child: BannerCarousel(),
                ),

                const SizedBox(height: 20),

                // TRASH BINS
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TrashBin(
                        imagePath: 'assets/img/green_bin.png',
                        label: 'อินทรีย์',
                      ),
                      TrashBin(
                        imagePath: 'assets/img/blue_bin.png',
                        label: 'ทั่วไป',
                      ),
                      TrashBin(
                        imagePath: 'assets/img/red_bin.png',
                        label: 'อันตราย',
                      ),
                      TrashBin(
                        imagePath: 'assets/img/yellow_bin.png',
                        label: 'รีไซเคิล',
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // HEADER
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'รายการขยะ',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AllTrashView(),
                            ),
                          );
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.green, // สีตัวอักษร
                          overlayColor: Colors.green.withValues(
                            alpha: 0.1,
                          ), // สีตอนกด
                        ),
                        child: const Text(
                          'See All',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600, // ทำให้เด่นขึ้น
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // GRID VIEW (โหลดจาก Firebase)
                GridView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 1,
                  ),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredTrash.length < 6
                      ? filteredTrash.length
                      : 6,
                  itemBuilder: (context, index) {
                    final item = filteredTrash[index];

                    return InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TrashDetailPage(
                              name: item['name'],
                              type: item['type'],
                              image: item['image'],
                              description: item['description'],
                              binIcon: getBinIcon(item['type']),
                            ),
                          ),
                        );
                      },
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(item['image'], width: 60, height: 60),
                            const SizedBox(height: 10),
                            Text(
                              item['name'],
                              textAlign: TextAlign
                                  .center, // ← บังคับให้จัดกลางทุกบรรทัด
                              maxLines: 2, // ← ถ้าข้อความยาวจะขึ้นบรรทัดใหม่
                              overflow: TextOverflow
                                  .ellipsis, // ← ถ้ายาวเกิน 2 บรรทัดจะขึ้น …
                              style: TextStyle(
                                fontSize: item['name'].length > 12 ? 12 : 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
    );
  }
}

class TrashBin extends StatelessWidget {
  final String imagePath;
  final String label;

  const TrashBin({super.key, required this.imagePath, required this.label});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TrashCategoryListPage(category: label),
          ),
        );
      },
      child: Column(
        children: [
          Image.asset(imagePath, width: 80, height: 80),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}

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
