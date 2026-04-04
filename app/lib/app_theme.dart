import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const primary = Color(0xFF3D6B4F);
  static const dark = Color(0xFF2E5239);
  static const background = Color(0xFFF5F0E8);
  static const gold = Color(0xFFC8933A);
  static const muted = Color(0xFF8A9E90);
  static const white = Colors.white;
  static const locked = Color(0xFFCCCCCC);
}

class AppTextStyles {
  static TextStyle heading(double size) => GoogleFonts.playfairDisplay(
        fontSize: size,
        fontWeight: FontWeight.w700,
        color: AppColors.white,
      );

  static TextStyle headingDark(double size) => GoogleFonts.playfairDisplay(
        fontSize: size,
        fontWeight: FontWeight.w700,
        color: AppColors.dark,
      );

  static TextStyle body(double size, {Color? color}) => GoogleFonts.inter(
        fontSize: size,
        color: color ?? AppColors.dark,
      );

  static TextStyle label(double size, {Color? color}) => GoogleFonts.inter(
        fontSize: size,
        fontWeight: FontWeight.w600,
        color: color ?? AppColors.dark,
      );
}
