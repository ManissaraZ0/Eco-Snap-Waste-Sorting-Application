import 'package:flutter/material.dart';
import 'package:eco_snap/common/color_extension.dart';
import 'package:eco_snap/services/auth_services.dart';

import '../../common_widget/round_button.dart';
import '../../common_widget/round_text_field.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColor.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),

                  // Back button
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(
                      Icons.arrow_back,
                      color: TColor.primaryText,
                      size: 28,
                    ),
                    padding: EdgeInsets.zero,
                    alignment: Alignment.centerLeft,
                  ),

                  const SizedBox(height: 20),

                  // Forgot password?
                  Text(
                    "ลืมรหัสผ่าน?",
                    style: TextStyle(
                      color: TColor.primaryText,
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 60),

                  // ช่องใส่อีเมล
                  RoundTextField(
                    hintText: "ใส่อีเมลของคุณ",
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    leftIcon: Icon(
                      Icons.email_outlined,
                      size: 20,
                      color: TColor.lightText,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'กรุณาใส่อีเมลของคุณ';
                      }
                      if (!value.contains('@')) {
                        return 'กรุณาใส่อีเมลที่ถูกต้อง';
                      }
                      // เพิ่ม email format validation
                      final emailRegex = RegExp(
                        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                      );
                      if (!emailRegex.hasMatch(value)) {
                        return 'กรุณาใส่อีเมลที่ถูกต้อง';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 15),

                  // ข้อความแจ้งเตือน
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '*',
                          style: TextStyle(
                            color: TColor.error,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(
                            'เราจะส่งลิงก์สำหรับตั้งรหัสผ่านใหม่ไปยังอีเมลของคุณ',
                            style: TextStyle(
                              color: TColor.secondaryText,
                              fontSize: 13,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // ปุ่ม Submit
                  RoundButton(
                    title: "ยืนยัน",
                    onPressed: _submitResetPassword,
                    backgroundColor: TColor.primary,
                    isLoading: _isLoading,
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  // Submit Reset Password (เชื่อม Firebase)
  Future<void> _submitResetPassword() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      setState(() {
        _isLoading = true;
      });

      // เรียกใช้ Firebase Reset Password
      final result = await _authService.resetPassword(
        email: _emailController.text,
      );

      setState(() {
        _isLoading = false;
      });

      if (result['success']) {
        // ส่ง email สำเร็จ
        if (mounted) {
          _showSuccessDialog();
        }
      } else {
        // ส่งไม่สำเร็จ
        if (mounted) {
          _showMessage(result['message'], false);
        }
      }
    }
  }

  // Show Success Dialog
  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            title: Icon(Icons.mark_email_read, color: TColor.success, size: 60),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'ส่งอีเมลแล้ว!',
                  style: TextStyle(
                    color: TColor.primaryText,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'เราได้ส่งลิงก์สำหรับตั้งรหัสผ่านใหม่ไปยังอีเมลของคุณแล้ว',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: TColor.secondaryText,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  _emailController.text,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: TColor.primary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            actions: [
              Center(
                child: SizedBox(
                  width: 120,
                  child: RoundButton(
                    title: "รับทราบ",
                    onPressed: () {
                      Navigator.pop(context); // ปิด dialog
                      Navigator.pop(context); // กลับไปหน้า login
                    },
                    backgroundColor: TColor.primary,
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
    );
  }

  // Show Message
  void _showMessage(String message, bool isSuccess) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess ? TColor.success : TColor.error,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ),
    );
  }
}
