import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      scaffoldBackgroundColor: AppColors.background,

      primaryColor: AppColors.primary,

      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.textPrimary,
        elevation: 0,
      ),

      textTheme: TextTheme(
        bodyMedium: TextStyle(color: AppColors.textPrimary),
      ),

      cardTheme: CardThemeData(
        color: Colors.white,
        shadowColor: Colors.black12,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius:
          BorderRadius.circular(AppSpacing.radiusLarge),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(
              horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(AppSpacing.radiusMedium),
          ),
        ),
      ),
    );
  }
}