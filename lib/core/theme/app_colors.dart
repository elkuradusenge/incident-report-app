import 'package:flutter/material.dart';

/// Colour palette sampled from the assignment reference UI.
abstract final class AppColors {
  // Brand
  static const Color primary = Color(0xFF6C3CF0);
  static const Color gradientStart = Color(0xFF7B4DFF);
  static const Color gradientEnd = Color(0xFFA58BFF);

  /// Hero gradient used by the home header card (top-left -> bottom-right).
  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[gradientStart, gradientEnd],
  );

  // Surfaces
  static const Color page = Color(0xFFFFFFFF);
  static const Color card = Color(0xFFFFFFFF);

  /// Neutral backdrop shown around the app column on wide screens.
  static const Color shell = Color(0xFFF4F2FA);

  // Text
  static const Color textPrimary = Color(0xFF1B1B2F);
  static const Color textSecondary = Color(0xFF6B6B80);
  static const Color textHint = Color(0xFFA0A0B2);

  // Lines
  static const Color border = Color(0xFFE6E4F0);

  static const Color error = Color(0xFFE5484D);

  /// Unselected filter chip fill.
  static const Color filterChip = Color(0xFFF1EEFB);

  // Summary tiles
  static const Color myReportsTile = Color(0xFFEFEAFF);
  static const Color inProgressTile = Color(0xFFE6F0FF);
  static const Color resolvedTile = Color(0xFFE2F6EA);
  static const Color submittedTile = Color(0xFFFDE6EA);

  static const Color myReportsIcon = primary;
  static const Color inProgressIcon = Color(0xFF2F6FED);
  static const Color resolvedIcon = Color(0xFF2FA866);
  static const Color submittedIcon = Color(0xFFE5484D);

  // Status chips
  static const Color submittedChipBackground = Color(0xFFFFE7B3);
  static const Color submittedChipText = Color(0xFFB86E00);
  static const Color inProgressChipBackground = Color(0xFFEDE7FF);
  static const Color inProgressChipText = Color(0xFF5B2EE0);
  static const Color resolvedChipBackground = Color(0xFFDDF5E6);
  static const Color resolvedChipText = Color(0xFF1E8E4E);
}
