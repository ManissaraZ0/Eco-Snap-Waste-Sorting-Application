import 'package:flutter/material.dart';

class WasteOptionButton extends StatelessWidget {
  final String color;
  final double size;
  final VoidCallback onTap;

  const WasteOptionButton({
    super.key,
    required this.color,
    required this.onTap,
    required this.size,
  });

  Color get binColor {
    switch (color) {
      case "yellow":
        return Colors.yellow;
      case "green":
        return Colors.green;
      case "blue":
        return Colors.blue;
      case "red":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: ColorFiltered(
          colorFilter: ColorFilter.mode(binColor, BlendMode.srcIn),
          child: Image.asset(
            "assets/img/recycle-bin-2.png",
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
