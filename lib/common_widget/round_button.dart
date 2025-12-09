import 'package:flutter/material.dart';

class RoundButton extends StatelessWidget {
  final String title;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final double? fontSize;
  final double? height;
  final double? borderRadius;
  final bool isLoading;

  const RoundButton({
    Key? key,
    required this.title,
    required this.onPressed,
    this.backgroundColor,
    this.textColor = Colors.white,
    this.fontSize = 16,
    this.height = 55,
    this.borderRadius = 15,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? const Color(0xFF081331),
          disabledBackgroundColor: Colors.grey,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius!),
          ),
          elevation: 0,
        ),
        child:
            isLoading
                ? SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      textColor ?? Colors.white,
                    ),
                  ),
                )
                : Text(
                  title,
                  style: TextStyle(
                    color: textColor,
                    fontSize: fontSize,
                    fontWeight: FontWeight.w700,
                  ),
                ),
      ),
    );
  }
}
