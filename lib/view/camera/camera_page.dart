import 'dart:async';
import 'dart:convert';
// import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eco_snap/common/color_extension.dart';
import 'package:eco_snap/view/settings/settings_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  // File? _imageFile;
  XFile? _imageFile;
  bool _isLoading = false;
  Map<String, dynamic>? _result;
  String? _error;

  final ImagePicker _picker = ImagePicker();

  // final String ollamaUrl = 'http://192.168.1.8:11434/api/generate';

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final Map<String, Color> colorMap = {
    'เหลือง': Colors.yellow.shade700,
    'เขียว': Colors.green.shade600,
    'แดง': Colors.red.shade600,
    'น้ำเงิน': Colors.blue.shade600,
  };

  final Map<String, IconData> iconMap = {
    'รีไซเคิล': Icons.recycling,
    'อินทรีย์': Icons.compost,
    'อันตราย': Icons.warning,
    'ทั่วไป': Icons.delete,
  };

  String fixEncoding(String input) {
    return utf8.decode(input.runes.toList());
  }

  @override
  void initState() {
    super.initState();
    _requestPermissions();
    _checkCurrentUser();
  }

  void _checkCurrentUser() {
    User? user = _auth.currentUser;
    if (user != null) {
      debugPrint('User login อยู่:');
      debugPrint('UID: ${user.uid}');
      debugPrint('Email: ${user.email}');
    } else {
      debugPrint('ยังไม่มี User login');
    }
  }

  Future<void> _requestPermissions() async {
    await Permission.camera.request();
    await Permission.photos.request();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _imageFile = image;
          _result = null;
          _error = null;
        });
        await _classifyImage();
      }
    } catch (e) {
      setState(() {
        _error = 'ไม่สามารถเลือกรูปภาพได้: $e';
      });
    }
  }

  Future<void> _classifyImage() async {
    if (_imageFile == null) return;

    setState(() {
      _isLoading = true;
      _error = null;
      _result = null;
    });

    try {
      // อ่านรูปเป็น bytes แล้วแปลง base64
      List<int> imageBytes = await _imageFile!.readAsBytes();
      String base64Image = base64Encode(imageBytes);

      // URL backend Vercel
      final String apiUrl = 'https://trash-ai-backend.vercel.app/api/classify';

      final response = await http
          .post(
            Uri.parse(apiUrl),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({"image": "data:image/jpeg;base64,$base64Image"}),
          )
          .timeout(
            const Duration(seconds: 60),
            onTimeout: () {
              throw TimeoutException("ประมวลผลช้าเกินไป");
            },
          );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint("RAW RESPONSE: ${response.body}");

        if (data == null) {
          throw Exception("ไม่มี response จาก server");
        }

        // เช็ค error จาก server
        if (data["error"] != null) {
          throw Exception(data["error"]);
        }

        // ดึง text จาก Vercel AI Gateway
        final text = data["text"];

        if (text == null || text.isEmpty) {
          throw Exception("ไม่มีผลลัพธ์จาก AI");
        }

        // ดึง JSON จากข้อความตอบกลับ
        final jsonString = RegExp(r'\{[\s\S]*\}').firstMatch(text)?.group(0);

        if (jsonString == null) {
          throw FormatException("ไม่พบ JSON ในผลลัพธ์\n$text");
        }

        final result = jsonDecode(jsonString);

        String type = result["type"] ?? "";
        String reason = result["reason"] ?? "";
        String color = "";

        if (type == "อันตราย") {
          color = "แดง";
        } else if (type == "อินทรีย์") {
          color = "เขียว";
        } else if (type == "รีไซเคิล") {
          color = "เหลือง";
        } else if (type == "ทั่วไป") {
          color = "น้ำเงิน";
        } else {
          color = "เทา";
        }

        result["type"] = type;
        result["reason"] = reason;
        result["color"] = color;

        setState(() {
          _result = result;
          _isLoading = false;
        });
      } else {
        throw Exception(
          "Server error ${response.statusCode}\n${response.body}",
        );
      }
    } on TimeoutException {
      setState(() {
        _error = "ใช้เวลาประมวลผลนานเกินไป";
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = "เกิดข้อผิดพลาด: $e";
        _isLoading = false;
      });
    }
  }

  Future<void> _saveToFirestore(String trashType) async {
    try {
      User? currentUser = _auth.currentUser;

      if (currentUser == null) {
        debugPrint('ยังไม่ได้ login');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('กรุณา login ก่อนใช้งาน'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      String userId = currentUser.uid;

      await _firestore.collection('waste_sorting').add({
        'user_id': userId,
        'type': trashType,
        'date': Timestamp.now(),
      });

      debugPrint('บันทึกสำเร็จ');
      debugPrint('User: $userId');
      debugPrint('Type: $trashType');
      debugPrint('Time: ${DateTime.now()}');
    } catch (e) {
      debugPrint('Error: $e');
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('เกิดข้อผิดพลาด: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _collectPoints() {
    final trashType = _result?['type'] ?? '';

    _saveToFirestore(trashType);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 150,
                height: 150,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    ...List.generate(6, (index) {
                      final angle = (index * 60) * pi / 180;
                      final radius = 60.0;
                      return Positioned(
                        left: 75 + radius * cos(angle) - 6,
                        top: 75 + radius * sin(angle) - 6,
                        child: Container(
                          width: index % 2 == 0 ? 12 : 8,
                          height: index % 2 == 0 ? 12 : 8,
                          decoration: BoxDecoration(
                            color: index % 2 == 0
                                ? Colors.grey.shade400
                                : Colors.grey.shade300,
                            shape: BoxShape.circle,
                          ),
                        ),
                      );
                    }),
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: .15),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: CustomPaint(
                        painter: BadgePainter(),
                        child: const Center(
                          child: Icon(
                            Icons.check,
                            size: 50,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                "You've collected! :D",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D3748),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _goToStatisticsPage();
                      },
                      icon: const Icon(Icons.bar_chart, size: 20),
                      label: const Text('ดูสถิติ'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5B21B6),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _resetApp();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF5B21B6),
                        side: const BorderSide(
                          color: Color(0xFF5B21B6),
                          width: 2,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('ตกลง'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _goToStatisticsPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SettingsView()),
    );
  }

  void _ignoreResult() {
    _resetApp();
  }

  void _resetApp() {
    setState(() {
      _imageFile = null;
      _result = null;
      _error = null;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColor.background,
      appBar: AppBar(
        title: const Text(
          'Waste Management',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: TColor.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black), // Icon ปุ่ม Back
          onPressed: () {
            Navigator.pop(context); // กลับไปยังหน้าก่อนหน้า (MainTabView)
          },
        ),
      ),

      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 5,
              child: Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: _imageFile != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.network(
                          _imageFile!.path,
                          fit: BoxFit.contain,
                        ),
                      )
                    : Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.image, size: 60, color: Colors.grey),
                            const SizedBox(height: 12),
                            Text(
                              'กดปุ่มด้านล่างเพื่อถ่ายรูป\nหรือเลือกรูปจากแกลเลอรี่',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ),
            Expanded(
              flex: 5,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.only(
                  top: 8,
                  bottom: 16,
                  left: 16,
                  right: 16,
                ),
                child: _isLoading
                    ? _buildLoadingWidget()
                    : _error != null
                    ? _buildErrorWidget()
                    : _result != null
                    ? _buildResultCard()
                    : _buildButtonsWidget(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButtonsWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _pickImage(ImageSource.camera),
                icon: const Icon(Icons.camera_alt, color: Colors.black),
                label: const Text(
                  'ถ่ายรูป',
                  style: TextStyle(color: Colors.black),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  side: const BorderSide(color: Colors.black, width: 2),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _pickImage(ImageSource.gallery),
                icon: const Icon(Icons.photo_library, color: Colors.black),
                label: const Text(
                  'เลือกรูป',
                  style: TextStyle(color: Colors.black),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  side: const BorderSide(color: Colors.black, width: 2),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLoadingWidget() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Color.fromARGB(255, 0, 0, 0)),
          SizedBox(height: 16),
          Text(
            'กำลังวิเคราะห์...',
            style: TextStyle(color: Color.fromARGB(255, 0, 0, 0), fontSize: 16),
          ),
          SizedBox(height: 8),
          Text(
            'อาจใช้เวลา 30-90 วินาที',
            style: TextStyle(fontSize: 12, color: Color.fromARGB(255, 0, 0, 0)),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Card(
        color: Colors.red.shade50,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(Icons.error, color: Colors.red),
              const SizedBox(width: 12),
              Expanded(
                child: Text(_error!, style: const TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultCard() {
    final type = _result!['type'] ?? '';
    final color = _result!['color'] ?? '';
    final reason = _result!['reason'] ?? '';
    final binColor = colorMap[color] ?? Colors.grey;
    final icon = iconMap[type] ?? Icons.delete;

    return SingleChildScrollView(
      child: Card(
        elevation: 4,
        color: const Color.fromARGB(255, 234, 234, 234),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.only(
            top: 16,
            bottom: 5,
            left: 16,
            right: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: binColor.withValues(alpha: .2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 35, color: binColor),
              ),
              const SizedBox(height: 12),
              Text(
                type,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: binColor,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: binColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  color == "เทา" ? 'ถังสี -' : 'ถังสี $color',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                reason,
                style: const TextStyle(fontSize: 13),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),
              if (color != "เทา") // 👈 เงื่อนไขเช็กสี
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _collectPoints,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      'collect count',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),

              if (color != "เทา") const SizedBox(height: 8),
              TextButton(
                onPressed: _ignoreResult,
                child: const Text(
                  'ignore',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BadgePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF3D4A5C)
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final path = Path();
    const teeth = 12;
    const outerRadius = 50.0;
    const innerRadius = 42.0;

    for (int i = 0; i < teeth * 2; i++) {
      final angle = (i * 180 / teeth) * pi / 180;
      final r = i % 2 == 0 ? outerRadius : innerRadius;
      final x = center.dx + r * cos(angle);
      final y = center.dy + r * sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
