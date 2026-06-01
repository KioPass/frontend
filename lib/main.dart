import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'screens/login_screen.dart';
import 'screens/main_screen.dart';
import 'screens/seller_pending_screen.dart';
import 'app_theme.dart';
import 'services/auth_service.dart';
import 'services/api_service.dart';
import 'services/fcm_service.dart';

final themeNotifier = ValueNotifier<ThemeMode>(ThemeMode.system);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
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
        home: const _AuthGate(),
      ),
    );
  }
}

class _AuthGate extends StatefulWidget {
  const _AuthGate();

  @override
  State<_AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<_AuthGate> with SingleTickerProviderStateMixin {
  late Future<Widget> _routeFuture;
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();
    _routeFuture = _determineRoute();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  Future<Widget> _determineRoute() async {
    final results = await Future.wait([_resolveRoute(), Future.delayed(const Duration(milliseconds: 1500))]);
    return results[0] as Widget;
  }

  Future<Widget> _resolveRoute() async {
    final isLoggedIn = await AuthService.isLoggedIn();
    if (!isLoggedIn) return const LoginScreen();

    FcmService.initialize();

    final token = await AuthService.getToken();
    if (token != null) {
      final info = await ApiService.getMyStore(token);
      if (info != null && info.status == 'PENDING') {
        return SellerPendingScreen(storeName: info.storeName);
      }
    }

    return const MainScreen();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: _routeFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          final isDark = WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark;
          return Scaffold(
            backgroundColor: isDark ? const Color(0xFF122A42) : const Color(0xFFEEEEEC),
            body: FadeTransition(
              opacity: _fadeAnim,
              child: Center(
                child: Image.asset(
                  isDark ? 'assets/images/logo.png' : 'assets/images/logo2.png',
                  width: 120, height: 120,
                ),
              ),
            ),
          );
        }
        return snapshot.data ?? const LoginScreen();
      },
    );
  }
}
