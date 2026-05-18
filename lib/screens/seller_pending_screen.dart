import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import 'login_screen.dart';
import 'main_screen.dart';

class SellerPendingScreen extends StatefulWidget {
  final String storeName;
  const SellerPendingScreen({super.key, required this.storeName});

  @override
  State<SellerPendingScreen> createState() => _SellerPendingScreenState();
}

class _SellerPendingScreenState extends State<SellerPendingScreen>
    with SingleTickerProviderStateMixin {
  bool _isChecking = false;
  late AnimationController _pulseController;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _pulse = CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _checkApproval() async {
    setState(() => _isChecking = true);
    try {
      final token = await AuthService.getToken();
      if (token == null) return;
      final info = await ApiService.getMyStore(token);
      if (!mounted) return;
      if (info != null && info.status == 'APPROVED') {
        await AuthService.saveUser(
          role: 'SELLER',
          name: await AuthService.getUserName() ?? '',
          email: await AuthService.getUserEmail() ?? '',
          token: token,
        );
        await AuthService.saveStoreName(info.storeName);
        await AuthService.saveStoreId(info.storeId);
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              '아직 승인 대기 중이에요',
              style: TextStyle(fontFamily: 'Pretendard', fontWeight: FontWeight.w600),
            ),
            backgroundColor: KColors.navy,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isChecking = false);
    }
  }

  Future<void> _logout() async {
    await AuthService.logout();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              const Spacer(flex: 2),

              // 아이콘
              AnimatedBuilder(
                animation: _pulse,
                builder: (_, __) => Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: KColors.primary.withValues(alpha: 0.06 + _pulse.value * 0.06),
                  ),
                  child: Center(
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: KColors.primary.withValues(alpha: 0.12 + _pulse.value * 0.08),
                      ),
                      child: const Icon(
                        Icons.hourglass_top_rounded,
                        color: KColors.primary,
                        size: 34,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 28),

              Text('승인 대기 중', style: tt.displayLarge),
              const SizedBox(height: 10),
              Text(
                '관리자가 서류를 검토하고 있어요\n영업일 기준 1~2일 내에 승인됩니다',
                style: tt.bodyMedium?.copyWith(height: 1.7),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 20),

              // 매장명 뱃지
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: cs.onSurface.withValues(alpha: isDark ? 0.08 : 0.05),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: cs.outline),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.storefront_rounded, color: cs.onSurface.withValues(alpha: 0.4), size: 18),
                    const SizedBox(width: 8),
                    Text(
                      widget.storeName,
                      style: tt.titleSmall,
                    ),
                  ],
                ),
              ),


              const Spacer(flex: 3),

              // 승인 확인 버튼
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _isChecking ? null : _checkApproval,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: KColors.primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: KColors.primary.withValues(alpha: 0.4),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _isChecking
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text(
                          '승인 상태 확인하기',
                          style: TextStyle(fontFamily: 'Pretendard', fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: -0.3),
                        ),
                ),
              ),

              const SizedBox(height: 12),

              // 로그아웃
              SizedBox(
                width: double.infinity,
                height: 50,
                child: TextButton(
                  onPressed: _logout,
                  style: TextButton.styleFrom(
                    backgroundColor: cs.onSurface.withValues(alpha: 0.05),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text(
                    '로그아웃',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: cs.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
