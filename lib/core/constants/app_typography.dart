import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Professional Judicial Typography System for NyayaSetu.
/// Engineered for supreme readability, statutory clarity, and executive polish.
class AppTypography {
  // ---------------------------------------------------------------------------
  // Primary Font Families
  // ---------------------------------------------------------------------------
  
  /// Executive Display & Header Font (Plus Jakarta Sans)
  /// Modern, sharp, authoritative, and perfectly balanced.
  static TextStyle fontHeading({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? letterSpacing,
    double? height,
  }) {
    return GoogleFonts.plusJakartaSans(
      fontSize: fontSize,
      fontWeight: fontWeight ?? FontWeight.w700,
      color: color,
      letterSpacing: letterSpacing ?? -0.2,
      height: height ?? 1.25,
    );
  }

  /// Primary Body & Statute Text Font (Inter)
  /// High legibility, standard for dense legal articles and sections.
  static TextStyle fontBody({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? letterSpacing,
    double? height,
  }) {
    return GoogleFonts.inter(
      fontSize: fontSize,
      fontWeight: fontWeight ?? FontWeight.w400,
      color: color,
      letterSpacing: letterSpacing ?? 0.0,
      height: height ?? 1.5,
    );
  }

  /// Classical Judicial & Landmark Font (Cinzel)
  /// Used for Supreme Court emblems, Latin maxims, and prestigious titles.
  static TextStyle fontJudicial({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? letterSpacing,
    double? height,
  }) {
    return GoogleFonts.cinzel(
      fontSize: fontSize,
      fontWeight: fontWeight ?? FontWeight.w700,
      color: color,
      letterSpacing: letterSpacing ?? 0.6,
      height: height ?? 1.2,
    );
  }

  /// Statutory / Case Law Ratio Font (Lora)
  /// Refined editorial serif for landmark judgment quotes and bare act clauses.
  static TextStyle fontStatute({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? letterSpacing,
    double? height,
    FontStyle? fontStyle,
  }) {
    return GoogleFonts.lora(
      fontSize: fontSize,
      fontWeight: fontWeight ?? FontWeight.w500,
      fontStyle: fontStyle ?? FontStyle.normal,
      color: color,
      letterSpacing: letterSpacing ?? 0.1,
      height: height ?? 1.6,
    );
  }

  // ---------------------------------------------------------------------------
  // Standardized Preset Styles
  // ---------------------------------------------------------------------------

  /// App Hero Title (26-28px, Bold, Navy/White)
  static TextStyle get heroTitle => fontHeading(
        fontSize: 26,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.5,
      );

  /// Section Header (17-18px, Bold, Primary Navy)
  static TextStyle get sectionTitle => fontHeading(
        fontSize: 17,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
        color: AppColors.textPrimaryDark,
      );

  /// Card Headline (15-16px, Semi-Bold)
  static TextStyle get cardTitle => fontHeading(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.1,
      );

  /// Body Standard (14px, Regular, 1.55 line-height)
  static TextStyle get bodyRegular => fontBody(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.55,
      );

  /// Body Muted (13px, Regular, Muted color)
  static TextStyle get bodyMuted => fontBody(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: AppColors.textMutedDark,
        height: 1.5,
      );

  /// Metadata / Overline Tag (10-11px, Bold, Uppercase Tracking)
  static TextStyle get overlineTag => fontHeading(
        fontSize: 10,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.1,
      );

  /// Statutory Quote (14px, Lora serif, 1.65 line-height)
  static TextStyle get legalClause => fontStatute(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.65,
      );
}
