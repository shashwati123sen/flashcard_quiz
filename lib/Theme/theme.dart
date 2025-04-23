import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF6C6EFF);
  static const Color secondaryColor = Color(0xFF66CCFF);
  static const Color backgroundColor = Color(0xFFFFC107);
  static const Color cardColor = Colors.white;
  static const Color textPrimaryColor = Color(0xff203748);
  static const Color textSecondaryColor = Color(0xff67526f);

  static ThemeData get theme {
    return ThemeData(
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      textTheme: GoogleFonts.poppinsTextTheme(),
      appBarTheme: AppBarTheme(
        backgroundColor: cardColor,
        foregroundColor: textPrimaryColor,
        elevation: 0,
        iconTheme: IconThemeData(
          color: textPrimaryColor,
        ),
      ),
      cardTheme: CardTheme(
        color: cardColor,
        elevation: 2,
      ),

    );

  }
}
