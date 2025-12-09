import 'package:flutter/material.dart';

class TColor {
  static Color get background => const Color(0xFFFDFDFD);
  
  static Color get primary => const Color(0xff263238);
  static Color get primaryLight => const Color(0xFF1E3A8A);
  static Color get secondary => const Color(0xFF4CAF50);
  static Color get tertiary => const Color(0xFF9E9E9E);

  static Color get newwhite => const Color(0xffFFFFFF);
  static Color get newgreen => const Color(0xff263238);

  // static Color get primary500 => const Color(0xff7722FF);
  // static Color get primary20 => const Color(0xff924EFF);
  // static Color get primary10 => const Color(0xffAD7BFF);
  // static Color get primary5 => const Color(0xffC9A7FF);
  // static Color get primary0 => const Color(0xffE4D3FF);

  // static Color get secondary => const Color(0xff4E4E61);
  // static Color get secondary50 => const Color(0xffFFA699);
  // static Color get secondary0 => const Color(0xffFFD2CC);

  // static Color get secondaryG => const Color(0xff00FAD9);
  // static Color get secondaryG50 => const Color(0xff7DFFEE);

  static Color get gray => const Color(0xff0E0E12);
  static Color get gray80 => const Color(0xff1C1C23);
  static Color get gray70 => const Color(0xff353542);
  static Color get gray60 => const Color(0xff4E4E61);
  static Color get gray50 => const Color(0xff666680);
  static Color get gray40 => const Color(0xff83839C);
  static Color get gray30 => const Color(0xffA2A2B5);
  static Color get gray20 => const Color(0xffC1C1CD);
  static Color get gray10 => const Color(0xffE0E0E6);
  static Color get gray5 => const Color.fromARGB(255, 236, 236, 244);

  static Color get border => const Color(0xffCFCFFC);
  // static Color get primaryText => Colors.white;
  // static Color get secondaryText => gray60;
  // static Color get white => Colors.white;

  // Text Colors
  static Color get primaryText => const Color(0xFF1A1A1A);
  static Color get secondaryText => const Color(0xFF757575);
  static Color get lightText => const Color(0xFFBDBDBD);
  static Color get white => Colors.white;

  // Status Colors
  static Color get error => const Color(0xFFE53935);
  static Color get success => const Color(0xFF43A047);
  static Color get warning => const Color(0xFFFB8C00);
  static Color get info => const Color(0xFF1E88E5);

  // Background Colors
  // static Color get background => const Color(0xFFFFFFFF);
  static Color get lightGray => const Color(0xFFEDEDED);

  // Waste Category Colors
  static Color get recycling => const Color(0xFF4CAF50);
  static Color get organic => const Color(0xFF8BC34A);
  static Color get hazardous => const Color(0xFFF44336);
  static Color get general => const Color(0xFF9E9E9E);

  static Color get marioBlue       => const Color(0xff0d9bd3);
  static Color get strokeMarioBlue => const Color(0xff0973a0);  // ฟ้าเข้มขึ้น

  static Color get marioYellow       => const Color(0xfff7c900);
  static Color get strokeMarioYellow => const Color(0xffc9a300); // เหลืองทองเข้ม

  static Color get marioRed       => const Color(0xffe5462f);
  static Color get strokeMarioRed => const Color(0xffb63225);   // แดงเข้ม

  static Color get marioGreen       => const Color(0xff4cbe49);
  static Color get strokeMarioGreen => const Color(0xff3b8e3a);  // เขียวเข้ม

  static Color get marioBG => const Color(0xffFFF9F0);

  static Color get placeholder => const Color(0xffB1B1B1);
  static Color get darkGray => const Color(0xff4C4F4D);
}

extension HexColor on Color {
  /// String is in the format "aabbcc" or "ffaabbcc" with an optional leading "#".
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  /// Prefixes a hash sign if [leadingHashSign] is set to `true` (default is `true`).
  String toHex({bool leadingHashSign = true}) {
    final a = (this.a * 255.0).round().clamp(0, 255);
    final r = (this.r * 255.0).round().clamp(0, 255);
    final g = (this.g * 255.0).round().clamp(0, 255);
    final b = (this.b * 255.0).round().clamp(0, 255);

    return '${leadingHashSign ? '#' : ''}'
        '${a.toRadixString(16).padLeft(2, '0')}'
        '${r.toRadixString(16).padLeft(2, '0')}'
        '${g.toRadixString(16).padLeft(2, '0')}'
        '${b.toRadixString(16).padLeft(2, '0')}';
  }
}

