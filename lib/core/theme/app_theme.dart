import 'package:flutter/material.dart';
import 'app_colors.dart';

/// App theme configuration following Apple design standards
/// Following Clean Architecture principles - core utilities
class AppTheme {
  static const String _fontFamily = 'SF Pro Display'; // Apple's system font

  /// Light theme configuration
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: _fontFamily,

      // Color scheme
      colorScheme: const ColorScheme.light(
        primary: AppColors.neonGreen,
        onPrimary: AppColors.textPrimaryDark,
        secondary: AppColors.solarOrange,
        onSecondary: AppColors.textPrimaryDark,
        tertiary: AppColors.cosmicBlue,
        onTertiary: AppColors.textPrimaryDark,
        surface: AppColors.backgroundPrimaryLight,
        onSurface: AppColors.textPrimaryLight,
        error: AppColors.error,
        onError: AppColors.textPrimaryDark,
        outline: AppColors.borderLight,
        shadow: AppColors.shadowLight,
      ),

      // App bar theme
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.navBackgroundLight,
        foregroundColor: AppColors.navTitleLight,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: AppColors.navTitleLight,
          fontSize: 17,
          fontWeight: FontWeight.w600,
          fontFamily: _fontFamily,
        ),
        iconTheme: IconThemeData(color: AppColors.textPrimaryLight, size: 24),
      ),

      // Drawer theme
      drawerTheme: const DrawerThemeData(
        backgroundColor: AppColors.backgroundSecondaryLight,
        elevation: 16,
        width: null, // Will be set to 80% programmatically
      ),

      // Card theme
      cardTheme: const CardThemeData(
        color: AppColors.cardLight,
        elevation: 2,
        shadowColor: AppColors.shadowLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
      ),

      // Elevated button theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.buttonPrimary,
          foregroundColor: AppColors.textPrimaryDark,
          elevation: 2,
          shadowColor: AppColors.shadowLight,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, fontFamily: _fontFamily),
        ),
      ),

      // Text button theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.linkDefault,
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, fontFamily: _fontFamily),
        ),
      ),

      // Chip theme
      chipTheme: const ChipThemeData(
        backgroundColor: AppColors.backgroundTertiaryLight,
        selectedColor: AppColors.neonGreen,
        labelStyle: TextStyle(
          color: AppColors.textPrimaryLight,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          fontFamily: _fontFamily,
        ),
        side: BorderSide(color: AppColors.borderLight),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
      ),

      // List tile theme
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        titleTextStyle: TextStyle(
          color: AppColors.textPrimaryLight,
          fontSize: 16,
          fontWeight: FontWeight.w500,
          fontFamily: _fontFamily,
        ),
        subtitleTextStyle: TextStyle(
          color: AppColors.textSecondaryLight,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          fontFamily: _fontFamily,
        ),
      ),

      // Divider theme
      dividerTheme: const DividerThemeData(color: AppColors.dividerLight, thickness: 0.5, space: 1),
    );
  }

  /// Dark theme configuration
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: _fontFamily,

      // Color scheme
      colorScheme: const ColorScheme.dark(
        primary: AppColors.neonGreen,
        onPrimary: AppColors.textPrimaryDark,
        secondary: AppColors.solarOrange,
        onSecondary: AppColors.textPrimaryDark,
        tertiary: AppColors.cosmicBlue,
        onTertiary: AppColors.textPrimaryDark,
        surface: AppColors.backgroundPrimaryDark,
        onSurface: AppColors.textPrimaryDark,
        error: AppColors.error,
        onError: AppColors.textPrimaryDark,
        outline: AppColors.borderDark,
        shadow: AppColors.shadowDark,
      ),

      // App bar theme
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.navBackgroundDark,
        foregroundColor: AppColors.navTitleDark,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: AppColors.navTitleDark,
          fontSize: 17,
          fontWeight: FontWeight.w600,
          fontFamily: _fontFamily,
        ),
        iconTheme: IconThemeData(color: AppColors.textPrimaryDark, size: 24),
      ),

      // Drawer theme
      drawerTheme: const DrawerThemeData(
        backgroundColor: AppColors.backgroundSecondaryDark,
        elevation: 16,
        width: null, // Will be set to 80% programmatically
      ),

      // Card theme
      cardTheme: const CardThemeData(
        color: AppColors.cardDark,
        elevation: 2,
        shadowColor: AppColors.shadowDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
      ),

      // Elevated button theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.buttonPrimary,
          foregroundColor: AppColors.textPrimaryDark,
          elevation: 2,
          shadowColor: AppColors.shadowDark,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, fontFamily: _fontFamily),
        ),
      ),

      // Text button theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.linkDefault,
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, fontFamily: _fontFamily),
        ),
      ),

      // Chip theme
      chipTheme: const ChipThemeData(
        backgroundColor: AppColors.backgroundTertiaryDark,
        selectedColor: AppColors.neonGreen,
        labelStyle: TextStyle(
          color: AppColors.textPrimaryDark,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          fontFamily: _fontFamily,
        ),
        side: BorderSide(color: AppColors.borderDark),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
      ),

      // List tile theme
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        titleTextStyle: TextStyle(
          color: AppColors.textPrimaryDark,
          fontSize: 16,
          fontWeight: FontWeight.w500,
          fontFamily: _fontFamily,
        ),
        subtitleTextStyle: TextStyle(
          color: AppColors.textSecondaryDark,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          fontFamily: _fontFamily,
        ),
      ),

      // Divider theme
      dividerTheme: const DividerThemeData(color: AppColors.dividerDark, thickness: 0.5, space: 1),
    );
  }
}
