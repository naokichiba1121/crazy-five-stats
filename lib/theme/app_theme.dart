import 'package:flutter/material.dart';

class AppTheme {
  // ベースカラー：野球スタジアム夜間の電光掲示板イメージ
  static const Color bgDark = Color(0xFF0A0E1A);       // 深夜スタジアム
  static const Color bgCard = Color(0xFF111827);        // カード背景
  static const Color bgCardLight = Color(0xFF1A2436);   // カード背景ライト
  static const Color neonGreen = Color(0xFF00FF7F);     // 電光掲示板グリーン
  static const Color neonGreenDim = Color(0xFF00C853);  // 暗めグリーン
  static const Color goldAccent = Color(0xFFFFD700);    // ゴールド
  static const Color goldDim = Color(0xFFC8A400);       // 暗めゴールド
  static const Color redAlert = Color(0xFFFF3B30);      // エラー赤
  static const Color blueLight = Color(0xFF4FC3F7);     // 青白ライト
  static const Color textPrimary = Color(0xFFF0F4FF);   // 主テキスト
  static const Color textSecondary = Color(0xFF8899BB); // 副テキスト
  static const Color divider = Color(0xFF1E2D45);       // 区切り線
  static const Color fieldGreen = Color(0xFF0D3321);    // 芝生グリーン

  static ThemeData get dark => ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: bgDark,
        primaryColor: neonGreen,
        colorScheme: const ColorScheme.dark(
          primary: neonGreen,
          secondary: goldAccent,
          surface: bgCard,
          error: redAlert,
        ),
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          backgroundColor: bgDark,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: neonGreen,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
          iconTheme: IconThemeData(color: neonGreen),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF080C16),
          selectedItemColor: neonGreen,
          unselectedItemColor: Color(0xFF4A5568),
          showSelectedLabels: true,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
          unselectedLabelStyle: TextStyle(fontSize: 11),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: neonGreen,
            foregroundColor: bgDark,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
            ),
          ),
        ),
        cardTheme: const CardThemeData(
          color: bgCard,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
        dividerTheme: const DividerThemeData(
          color: divider,
          thickness: 1,
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: textPrimary, fontSize: 16),
          bodyMedium: TextStyle(color: textPrimary, fontSize: 14),
          bodySmall: TextStyle(color: textSecondary, fontSize: 12),
          titleLarge: TextStyle(color: textPrimary, fontSize: 20, fontWeight: FontWeight.w700),
          titleMedium: TextStyle(color: textPrimary, fontSize: 16, fontWeight: FontWeight.w600),
          titleSmall: TextStyle(color: textSecondary, fontSize: 14, fontWeight: FontWeight.w500),
        ),
      );
}
