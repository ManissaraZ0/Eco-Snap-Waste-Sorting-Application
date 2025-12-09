import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eco_snap/view/main_tab/main_tab_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:eco_snap/view/settings/settings_service.dart';
import 'package:eco_snap/view/settings/widgets/profile_picker_dialog.dart';
import 'package:eco_snap/view/settings/widgets/waste_chart_card.dart';
import 'package:eco_snap/view/settings/widgets/yearly_summary_card.dart';
import '../../common/color_extension.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  bool isActive = false;
  int selectedProfile = 1;
  int selectedYear = DateTime.now().year;
  final SettingsService _service = SettingsService();
  Map<String, dynamic>? userData;

  final String uid = FirebaseAuth.instance.currentUser!.uid;

  Future<void> loadUserData() async {
    final doc = await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .get();

    if (doc.exists) {
      setState(() {
        userData = doc.data();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  // --------------------------- UI ---------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColor.background,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 10),

              // header
              Stack(
                alignment: Alignment.center,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MainTabView(),
                            ), // กำหนดให้กลับไปที่ MainTabView
                            (route) => false, // ทำให้ไม่สามารถกลับไปหน้าเดิมได้
                          );
                        },
                        icon: Image.asset(
                          "assets/img/back.png",
                          width: 25,
                          height: 25,
                          color: TColor.gray30,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              // profile pic + name + email
              userData == null
                  ? const Center(child: CircularProgressIndicator())
                  : Column(
                      children: [
                        // profile picture
                        Image.asset(
                          userData!["profile_picture"] ?? "assets/img/u1.png",
                          width: 90,
                          height: 90,
                        ),

                        const SizedBox(height: 15),

                        // name
                        Text(
                          userData!["display_name"] ?? "Unknown User",
                          style: TextStyle(
                            color: TColor.gray80,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),

                        const SizedBox(height: 4),

                        // email
                        Text(
                          userData!["email"] ?? "",
                          style: TextStyle(
                            color: TColor.gray80,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),

              const SizedBox(height: 15),

              InkWell(
                borderRadius: BorderRadius.circular(15),
                onTap: () {
                  if (userData == null) return;

                  String pic =
                      userData!["profile_picture"] ?? "assets/img/u1.png";

                  // ดึงตัวเลขท้ายไฟล์ เช่น u3.png → 3
                  int currentProfile = int.parse(
                    pic.replaceAll(RegExp(r'[^0-9]'), ''),
                  );
                  showProfilePickerDialog(
                    context: context,
                    selectedProfile: currentProfile,
                    onSelected: (result) {
                      setState(() {
                        selectedProfile = result;
                      });

                      loadUserData(); // refresh
                    },
                  );
                },

                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    border: Border.all(color: TColor.strokeMarioYellow),
                    color: TColor.marioYellow,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    "Edit profile",
                    style: TextStyle(
                      color: TColor.marioBG,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // -------------------- YEAR SELECTOR WITH ARROWS --------------------
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // ปุ่มย้อนปี
                  IconButton(
                    icon: Icon(
                      Icons.chevron_left,
                      size: 28,
                      color: TColor.gray30,
                    ),
                    onPressed: () {
                      setState(() {
                        selectedYear--;
                      });
                    },
                  ),

                  // แสดงปี
                  Text(
                    "$selectedYear",
                    style: TextStyle(
                      color: TColor.gray80,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  // ปุ่มเพิ่มปี (ห้ามเกินปีปัจจุบัน)
                  IconButton(
                    icon: Icon(
                      Icons.chevron_right,
                      size: 28,
                      color: TColor.gray30,
                    ),
                    onPressed: selectedYear < DateTime.now().year
                        ? () {
                            setState(() {
                              selectedYear++;
                            });
                          }
                        : null,
                  ),
                ],
              ),

              WasteChartCard(
                selectedYear: selectedYear,
                service: _service,
                uid: uid,
              ),

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 10,
                ),
                child: YearlySummaryCard(
                  year: selectedYear,
                  service: _service,
                  uid: uid,
                ),
              ),

              // -------------------- END OF CONTENT --------------------
            ],
          ),
        ),
      ),
    );
  }
}
