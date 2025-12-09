import 'package:flutter/material.dart';
import 'package:eco_snap/common/color_extension.dart';
import 'package:eco_snap/services/auth_services.dart';
import 'package:eco_snap/view/main_tab/main_tab_view.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../common_widget/round_button.dart';
import '../../common_widget/round_text_field.dart';
import 'signup_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;
  bool _isPasswordVisible = false;

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
                    "ยินดีต้อนรับสู่ Eco Snap",
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
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'กรุณาใส่อีเมล';
                      }
                      if (!value.contains('@')) {
                        return 'กรุณาใส่อีเมลที่ถูกต้อง';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 20),

                  // Password
                  RoundTextField(
                    hintText: "รหัสผ่าน",
                    controller: _passwordController,
                    obscureText: !_isPasswordVisible,
                    leftIcon: Icon(
                      Icons.lock_outline,
                      color: TColor.lightText,
                      size: 20,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: TColor.lightText,
                        size: 20,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                  ),

                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ForgotPasswordScreen(),
                          ),
                        );
                      },
                      child: Text(
                        "ลืมรหัสผ่าน?",
                        style: TextStyle(
                          color: TColor.secondaryText,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  RoundButton(
                    title: "เข้าสู่ระบบ",
                    onPressed: _logInUser,
                    backgroundColor: TColor.primary,
                    isLoading: _isLoading,
                  ),

                  const SizedBox(height: 40),

                  Row(
                    children: [
                      Expanded(
                        child: Divider(
                          color: TColor.secondaryText.withValues(alpha: .3),
                          thickness: 1,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Text(
                          "หรือเข้าสู่ระบบด้วย",
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
                          thickness: 1,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    child: MaterialButton(
                      onPressed: _signInWithGoogle,
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

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "ยังไม่มีบัญชีผู้ใช้? ",
                        style: TextStyle(
                          color: TColor.secondaryText,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SignUpScreen(),
                            ),
                          );
                        },
                        child: Text(
                          "สมัครสมาชิก",
                          style: TextStyle(
                            color: TColor.primary,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            decoration: TextDecoration.underline,
                            decorationColor: TColor.primary,
                            decorationThickness: 2,
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

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Email Login
  Future<void> _logInUser() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final result = await _authService.signInWithEmail(
        email: _emailController.text,
        password: _passwordController.text,
      );

      setState(() => _isLoading = false);

      if (result['success']) {
        _showMessage('ยินดีต้อนรับ!', true);

        Navigator.pushReplacement(
          // ignore: use_build_context_synchronously
          context,
          MaterialPageRoute(builder: (context) => const MainTabView()),
        );
      } else {
        _showMessage(result['message'], false);
      }
    }
  }

  // Google Login
  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);

    final result = await _authService.signInWithGoogle();

    setState(() => _isLoading = false);

    if (result['success']) {
      _showMessage('ยินดีต้อนรับ!', true);
      Navigator.pushReplacement(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(builder: (context) => const MainTabView()),
      );
    } else {
      _showMessage(result['message'], false);
    }
  }

  // Show message
  void _showMessage(String message, bool isSuccess) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.kanit(),),
        backgroundColor: isSuccess ? TColor.success : TColor.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
