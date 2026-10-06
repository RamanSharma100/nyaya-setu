import 'package:flutter/material.dart';

class AppColors {
  // Primary brand colors - deep judicial navy
  static const Color primaryNavy = Color(0xFF0D1B2A);
  static const Color secondaryNavy = Color(0xFF1B2E45);
  static const Color tertiaryNavy = Color(0xFF243B55);

  // Gold accent - premium & trustworthy
  static const Color accentGold = Color(0xFFD4AF37);
  static const Color accentGoldLight = Color(0xFFF5E27A);
  static const Color accentGoldDim = Color(0xFF8B7520);
  static const Color accentAmber = Color(0xFFF59E0B);

  // Status colors
  static const Color emeraldGreen = Color(0xFF10B981);
  static const Color emeraldLight = Color(0xFF34D399);
  static const Color crimsonRed = Color(0xFF9B111E);
  static const Color crimsonLight = Color(0xFFEF4444);
  static const Color sapphireBlue = Color(0xFF3B82F6);
  static const Color violetPurple = Color(0xFF8B5CF6);

  // Background / Surface
  static const Color backgroundLight = Color(0xFFF1F5F9);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color bgLight = Color(0xFFF0F4F8);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color cardDark = Color(0xFF1B2E45);

  // Glassmorphism
  static const Color glassWhite = Color(0x1AFFFFFF);
  static const Color glassBorder = Color(0x33FFFFFF);
  static const Color glassNavy = Color(0x1A0D1B2A);

  // Text
  static const Color textPrimaryDark = Color(0xFF0F172A);
  static const Color textSecondaryDark = Color(0xFF334155);
  static const Color textMutedDark = Color(0xFF64748B);
  static const Color textDark = Color(0xFF0F172A);
  static const Color textLight = Color(0xFFF8FAFC);
  static const Color textMutedLight = Color(0xFF94A3B8);

  // Diff / Highlight
  static const Color diffAddedBg = Color(0xFFECFDF5);
  static const Color diffAddedText = Color(0xFF065F46);
  static const Color diffRemovedBg = Color(0xFFFEF2F2);
  static const Color diffRemovedText = Color(0xFF991B1B);
  static const Color diffAdditionBg = Color(0xFFECFDF5);
  static const Color diffDeletionBg = Color(0xFFFEF2F2);

  // Gradients
  static const LinearGradient heroGradient = LinearGradient(
    colors: [primaryNavy, Color(0xFF1A3A5C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFD4AF37), Color(0xFFF5E27A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient emeraldGradient = LinearGradient(
    colors: [Color(0xFF059669), Color(0xFF10B981)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient crimsonGradient = LinearGradient(
    colors: [Color(0xFF9B111E), Color(0xFFDC2626)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient purpleGradient = LinearGradient(
    colors: [Color(0xFF7C3AED), Color(0xFF8B5CF6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
