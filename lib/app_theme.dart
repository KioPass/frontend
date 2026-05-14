import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ──────────────────────────────────────────
// 키오패스 색상 토큰
// ──────────────────────────────────────────
class KColors {
  // 브랜드 컬러 (라이트/다크 공통)
  static const primary = Color(0xFFFF6B4A);   // 오렌지
  static const navy = Color(0xFF122A42);       // 네이비

  // 라이트 모드
  static const lightBg = Color(0xFFEEEEEC);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightSurface2 = Color(0xFFF5F5F4);
  static const lightText = Color(0xFF191F28);
  static const lightTextSub = Color(0xFF4E5968);
  static const lightTextHint = Color(0xFF8B95A1);
  static const lightBorder = Color(0xFFE5E8EB);
  static const lightIcon = Color(0xFF6B7684);

  // 다크 모드
  static const darkBg = Color(0xFF122A42);       // 로고 배경색 통일
  static const darkSurface = Color(0xFF1A3A55);  // 카드
  static const darkSurface2 = Color(0xFF22486A); // 입력창/보조 서피스
  static const darkText = Color(0xFFF0F4F8);     // 순백보다 눈 편한 흰색
  static const darkTextSub = Color(0xFFBCC8D8);  // 서브 텍스트 밝게
  static const darkTextHint = Color(0xFF8FA3B8); // 힌트 텍스트 밝게
  static const darkBorder = Color(0xFF2A4060);   // 보더 더 선명하게
  static const darkIcon = Color(0xFF9AAFC4);     // 아이콘
}

// ──────────────────────────────────────────
// 라이트 테마
// ──────────────────────────────────────────
final lightTheme = ThemeData(
  brightness: Brightness.light,
  fontFamily: 'Pretendard',
  scaffoldBackgroundColor: KColors.lightBg,
  colorScheme: ColorScheme.light(
    primary: KColors.primary,
    secondary: KColors.navy,
    surface: KColors.lightSurface,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onSurface: KColors.lightText,
    outline: KColors.lightBorder,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: KColors.lightSurface,
    foregroundColor: KColors.lightText,
    elevation: 0,
    centerTitle: true,
    iconTheme: IconThemeData(color: KColors.lightText),
    systemOverlayStyle: SystemUiOverlayStyle.dark,
    titleTextStyle: TextStyle(
      fontFamily: 'Pretendard',
      color: KColors.lightText,
      fontSize: 17,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.3,
    ),
  ),
  cardTheme: CardThemeData(
    color: KColors.lightSurface,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: const BorderSide(color: KColors.lightBorder, width: 1),
    ),
    margin: EdgeInsets.zero,
  ),
  dividerTheme: const DividerThemeData(
    color: KColors.lightBorder,
    thickness: 1,
    space: 1,
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: KColors.lightSurface2,
    hintStyle: const TextStyle(
      fontFamily: 'Pretendard',
      color: KColors.lightTextHint,
      fontSize: 14,
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: KColors.primary, width: 1.5),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: KColors.navy,
      foregroundColor: Colors.white,
      elevation: 0,
      minimumSize: const Size(double.infinity, 54),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      textStyle: const TextStyle(
        fontFamily: 'Pretendard',
        fontSize: 16,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
      ),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: KColors.navy,
      side: const BorderSide(color: KColors.lightBorder, width: 1),
      minimumSize: const Size(double.infinity, 54),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      textStyle: const TextStyle(
        fontFamily: 'Pretendard',
        fontSize: 16,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
      ),
    ),
  ),
  textTheme: const TextTheme(
    displayLarge: TextStyle(fontFamily: 'Pretendard', color: KColors.lightText, fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -0.8),
    displayMedium: TextStyle(fontFamily: 'Pretendard', color: KColors.lightText, fontSize: 24, fontWeight: FontWeight.w700, letterSpacing: -0.5),
    titleLarge: TextStyle(fontFamily: 'Pretendard', color: KColors.lightText, fontSize: 20, fontWeight: FontWeight.w700, letterSpacing: -0.5),
    titleMedium: TextStyle(fontFamily: 'Pretendard', color: KColors.lightText, fontSize: 17, fontWeight: FontWeight.w700, letterSpacing: -0.3),
    titleSmall: TextStyle(fontFamily: 'Pretendard', color: KColors.lightText, fontSize: 15, fontWeight: FontWeight.w600, letterSpacing: -0.2),
    bodyLarge: TextStyle(fontFamily: 'Pretendard', color: KColors.lightText, fontSize: 16, fontWeight: FontWeight.w400),
    bodyMedium: TextStyle(fontFamily: 'Pretendard', color: KColors.lightTextSub, fontSize: 14, fontWeight: FontWeight.w400),
    bodySmall: TextStyle(fontFamily: 'Pretendard', color: KColors.lightTextHint, fontSize: 12, fontWeight: FontWeight.w400),
    labelLarge: TextStyle(fontFamily: 'Pretendard', color: KColors.lightText, fontSize: 14, fontWeight: FontWeight.w600),
  ),
);

// ──────────────────────────────────────────
// 다크 테마
// ──────────────────────────────────────────
final darkTheme = ThemeData(
  brightness: Brightness.dark,
  fontFamily: 'Pretendard',
  scaffoldBackgroundColor: KColors.darkBg,
  colorScheme: ColorScheme.dark(
    primary: KColors.primary,
    secondary: Color(0xFF2A6496),
    surface: KColors.darkSurface,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onSurface: KColors.darkText,
    outline: KColors.darkBorder,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: KColors.darkBg,
    foregroundColor: KColors.darkText,
    elevation: 0,
    centerTitle: true,
    iconTheme: IconThemeData(color: KColors.darkText),
    systemOverlayStyle: SystemUiOverlayStyle.light,
    titleTextStyle: TextStyle(
      fontFamily: 'Pretendard',
      color: KColors.darkText,
      fontSize: 17,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.3,
    ),
  ),
  cardTheme: CardThemeData(
    color: KColors.darkSurface,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: const BorderSide(color: KColors.darkBorder, width: 1),
    ),
    margin: EdgeInsets.zero,
  ),
  dividerTheme: const DividerThemeData(
    color: KColors.darkBorder,
    thickness: 1,
    space: 1,
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: KColors.darkSurface2,
    hintStyle: const TextStyle(
      fontFamily: 'Pretendard',
      color: KColors.darkTextHint,
      fontSize: 14,
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: KColors.primary, width: 1.5),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: KColors.primary,
      foregroundColor: Colors.white,
      elevation: 0,
      minimumSize: const Size(double.infinity, 54),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      textStyle: const TextStyle(
        fontFamily: 'Pretendard',
        fontSize: 16,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
      ),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: KColors.darkText,
      side: const BorderSide(color: KColors.darkBorder, width: 1),
      minimumSize: const Size(double.infinity, 54),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      textStyle: const TextStyle(
        fontFamily: 'Pretendard',
        fontSize: 16,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
      ),
    ),
  ),
  textTheme: const TextTheme(
    displayLarge: TextStyle(fontFamily: 'Pretendard', color: KColors.darkText, fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -0.8),
    displayMedium: TextStyle(fontFamily: 'Pretendard', color: KColors.darkText, fontSize: 24, fontWeight: FontWeight.w700, letterSpacing: -0.5),
    titleLarge: TextStyle(fontFamily: 'Pretendard', color: KColors.darkText, fontSize: 20, fontWeight: FontWeight.w700, letterSpacing: -0.5),
    titleMedium: TextStyle(fontFamily: 'Pretendard', color: KColors.darkText, fontSize: 17, fontWeight: FontWeight.w700, letterSpacing: -0.3),
    titleSmall: TextStyle(fontFamily: 'Pretendard', color: KColors.darkText, fontSize: 15, fontWeight: FontWeight.w600, letterSpacing: -0.2),
    bodyLarge: TextStyle(fontFamily: 'Pretendard', color: KColors.darkText, fontSize: 16, fontWeight: FontWeight.w400),
    bodyMedium: TextStyle(fontFamily: 'Pretendard', color: KColors.darkTextSub, fontSize: 14, fontWeight: FontWeight.w400),
    bodySmall: TextStyle(fontFamily: 'Pretendard', color: KColors.darkTextHint, fontSize: 12, fontWeight: FontWeight.w400),
    labelLarge: TextStyle(fontFamily: 'Pretendard', color: KColors.darkText, fontSize: 14, fontWeight: FontWeight.w600),
  ),
);