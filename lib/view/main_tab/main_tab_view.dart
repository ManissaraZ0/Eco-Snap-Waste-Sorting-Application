import 'package:eco_snap/view/camera/camera_page.dart';
import 'package:eco_snap/view/minigame/landing_page.dart';
import 'package:flutter/material.dart';
import 'package:eco_snap/common/color_extension.dart';
import 'package:eco_snap/view/home/home_view.dart';

class MainTabView extends StatefulWidget {
  const MainTabView({super.key});

  @override
  State<MainTabView> createState() => _MainTabViewState();
}

class _MainTabViewState extends State<MainTabView> {
  int selectTab = 0;
  final PageStorageBucket bucket = PageStorageBucket();

  final List<Widget> tabPages = const [HomeView(), LandingPage()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      resizeToAvoidBottomInset: false,
      body: PageStorage(bucket: bucket, child: tabPages[selectTab]),

      // ปุ่มตรงกลาง
      floatingActionButton: SizedBox(
        width: 60, // กำหนดความกว้างของปุ่ม
        height: 60, // กำหนดความสูงของปุ่ม
        child: FloatingActionButton(
          backgroundColor: Colors.green,
          child: const Icon(Icons.camera_alt, color: Colors.white),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CameraPage()),
            );
          },
        ),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // Bottom bar แบบเว้า (notched)
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(), // การเว้า
        notchMargin: 15, // เว้นที่ให้ปุ่มกลาง
        color: TColor.primary, // สีพื้นหลังที่เหลือ
        elevation: 2, // ใช้เงาบริเวณขอบ
        child: SizedBox(
          height: 65,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navButton(icon: Icons.home, index: 0),

              const SizedBox(width: 40), // เว้นที่ให้ปุ่มกลาง

              _navButton(icon: Icons.gamepad, index: 1),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navButton({required IconData icon, required int index}) {
    bool active = selectTab == index;

    return IconButton(
      iconSize: active ? 32 : 26,
      color: active ? Colors.white : Colors.white54,
      icon: Icon(icon),
      onPressed: () {
        setState(() {
          selectTab = index;
        });
      },
    );
  }
}
