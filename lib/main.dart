import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'app_theme.dart';

// 앱 전체 테마 상태
final themeNotifier = ValueNotifier<ThemeMode>(ThemeMode.system);

void main() {
  runApp(const KiopassApp());
}

class KiopassApp extends StatelessWidget {
  const KiopassApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, mode, __) => MaterialApp(
        title: '키오패스',
        debugShowCheckedModeBanner: false,
        theme: lightTheme,
        darkTheme: darkTheme,
        themeMode: mode,
        home: const LoginScreen(),
      ),
    );
  }
}