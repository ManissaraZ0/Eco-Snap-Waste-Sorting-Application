import 'package:flutter/material.dart';
import 'package:eco_snap/common/color_extension.dart';
import 'package:eco_snap/services/auth_services.dart';

import '../../common_widget/round_button.dart';
import '../../common_widget/round_text_field.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _authService = AuthService();

  bool _showPassword = false;
  bool _showConfirmPassword = false;
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

                  Text(
                    "สมัครสมาชิก",
                    style: TextStyle(
                      color: TColor.primaryText,
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 60),

                  // Email
                  RoundTextField(
                    hintText: "อีเมล",
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    leftIcon: Icon(
                      Icons.email_outlined,
                      size: 20,
                      color: TColor.lightText,
                    ),
                    validator: _validateEmail,
                  ),

                  const SizedBox(height: 20),

                  // Password
                  RoundTextField(
                    hintText: "รหัสผ่าน",
                    controller: _passwordController,
                    obscureText: !_showPassword,
                    leftIcon: Icon(
                      Icons.lock_outline,
                      size: 20,
                      color: TColor.lightText,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _showPassword ? Icons.visibility : Icons.visibility_off,
                        color: TColor.lightText,
                        size: 20,
                      ),
                      onPressed:
                          () => setState(() => _showPassword = !_showPassword),
                    ),
                    validator: _validatePassword,
                  ),

                  const SizedBox(height: 20),

                  // Confirm Password
                  RoundTextField(
                    hintText: "ยืนยันรหัสผ่าน",
                    controller: _confirmPasswordController,
                    obscureText: !_showConfirmPassword,
                    leftIcon: Icon(
                      Icons.lock_outline,
                      size: 20,
                      color: TColor.lightText,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _showConfirmPassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: TColor.lightText,
                        size: 20,
                      ),
                      onPressed:
                          () => setState(
                            () => _showConfirmPassword = !_showConfirmPassword,
                          ),
                    ),
                    validator: _validateConfirmPassword,
                  ),

                  const SizedBox(height: 20),

                  Text(
                    "ในการสมัครสมาชิก คุณยอมรับข้อกำหนดในการให้บริการและนโยบายความเป็นส่วนตัวของเรา",
                    style: TextStyle(
                      color: TColor.secondaryText,
                      fontSize: 12,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 30),

                  RoundButton(
                    title: "สมัครสมาชิก",
                    onPressed: _createAccount,
                    backgroundColor: TColor.primary,
                    isLoading: _isLoading,
                  ),

                  const SizedBox(height: 40),

                  // OR
                  Row(
                    children: [
                      Expanded(
                        child: Divider(
                          color: TColor.secondaryText.withValues(alpha: .3),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Text(
                          "หรือสมัครสมาชิกด้วย",
                          style: TextStyle(
                            color: TColor.secondaryText,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          color: TColor.secondaryText.withValues(alpha: .3),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // ปุ่มสมัครสมาชิกด้วย Google แบบเต็มความกว้าง
                  SizedBox(
                    width: double.infinity,
                    child: MaterialButton(
                      onPressed: _signUpWithGoogle,
                      elevation: 0,
                      color: TColor.background,
                      height: 55,
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                          color: TColor.secondaryText.withValues(alpha: .3),
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/img/gg.png',
                            width: 25,
                            height: 25,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.g_mobiledata,
                                size: 30,
                                color: TColor.error,
                              );
                            },
                          ),
                          const SizedBox(width: 10),
                          Text(
                            "บัญชี Google",
                            style: TextStyle(
                              color: TColor.primaryText,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Login
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "มีบัญชีอยู่แล้ว?",
                        style: TextStyle(
                          color: TColor.secondaryText,
                          fontSize: 14,
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          "เข้าสู่ระบบ",
                          style: TextStyle(
                            color: TColor.primary,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
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

  // VALIDATORS
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'กรุณาใส่อีเมลของคุณ';
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) return 'กรุณาใส่อีเมลที่ถูกต้อง';
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'กรุณาใส่รหัสผ่านของคุณ';
    if (value.length < 6) return 'รหัสผ่านต้องมีอย่างน้อย 6 ตัวอักษร';
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) return 'กรุณายืนยันรหัสผ่าน';
    if (value != _passwordController.text) return 'รหัสผ่านไม่ตรงกัน';
    return null;
  }

  // SIGN UP
  Future<void> _createAccount() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final result = await _authService.signUpWithEmail(
      email: _emailController.text,
      password: _passwordController.text,
    );

    setState(() => _isLoading = false);

    if (result['success']) {
      _showSuccessDialog();
    } else {
      _showMessage(result['message'], false);
    }
  }

  // GOOGLE
  Future<void> _signUpWithGoogle() async {
    setState(() => _isLoading = true);

    final result = await _authService.signInWithGoogle();

    setState(() => _isLoading = false);

    if (result['success']) {
      final user = result['user'];

      // เช็คว่า user เคยสมัครแล้วหรือยัง
      final creationTime = user?.metadata.creationTime;
      final lastSignInTime = user?.metadata.lastSignInTime;

      final isNewUser =
          creationTime != null &&
          lastSignInTime != null &&
          creationTime == lastSignInTime;

      if (isNewUser) {
        // ผู้ใช้ใหม่
        _showMessage("สมัครสมาชิกด้วย Google สำเร็จ!", true);
      } else {
        // ผู้ใช้เก่า → เข้าสู่ระบบ
        _showMessage("บัญชีนี้มีการสมัครสมาชิกแล้ว", true);
        Future.delayed(Duration(seconds: 1), () {
          // ignore: use_build_context_synchronously
          Navigator.pushReplacementNamed(context, '/login');
        });
      }
    } else {
      _showMessage(result['message'], false);
    }
  }

  // SUCCESS POPUP
  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            title: Icon(Icons.check_circle, color: TColor.success, size: 60),
            content: const Text(
              'สมัครสมาชิกสำเร็จแล้ว! กรุณาตรวจสอบอีเมลเพื่อยืนยันบัญชี',
              textAlign: TextAlign.center,
            ),
            actions: [
              Center(
                child: SizedBox(
                  width: 120,
                  child: RoundButton(
                    title: "OK",
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
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

  void _showMessage(String msg, bool ok) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: ok ? TColor.success : TColor.error,
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
