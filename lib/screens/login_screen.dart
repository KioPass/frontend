import 'package:flutter/material.dart';
import 'main_screen.dart';
import 'signup_screen.dart';
import '../app_theme.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import '../services/fcm_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;

  Future<void> _handleOAuth(Future<OAuthResult> Function() oauthCall) async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    try {
      final result = await oauthCall();
      if (!mounted) return;

      if (result.isLoginSuccess && result.token != null) {
        final profile = await ApiService.getUserProfile(result.token!);
        if (!mounted) return;
        if (profile != null) {
          await AuthService.saveUser(
            role: profile.role,
            name: profile.username,
            email: profile.email,
            token: result.token,
          );
          // 판매자/관리자인 경우 storeId + storeName 저장
          if (profile.role == 'SELLER' || profile.role == 'ADMIN') {
            final storeInfo = await ApiService.getMyStore(result.token!);
            if (storeInfo != null) {
              await AuthService.saveStoreId(storeInfo.storeId);
              await AuthService.saveStoreName(storeInfo.storeName);
            }
          }
          FcmService.initialize();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const MainScreen()),
          );
        } else {
          _showError('사용자 정보를 가져올 수 없어요. 다시 시도해주세요.');
        }
      } else if (result.isError) {
        if (result.errorCode == 'no_server') {
          _showError('서버 주소가 설정되지 않았어요. 개발자에게 문의해주세요.');
        } else if (result.errorCode == '401') {
          _showError('가입되지 않은 계정이에요. 먼저 회원가입을 해주세요.');
        } else {
          _showError('로그인에 실패했어요. 다시 시도해주세요.');
        }
      }
      // cancelled: 아무것도 하지 않음
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontFamily: 'Pretendard')),
        backgroundColor: const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 60),

              Image.asset(
                isDark ? 'assets/images/logo.png' : 'assets/images/logo2.png',
                width: 140,
                height: 140,
                fit: BoxFit.contain,
              ),

              const SizedBox(height: 24),

              Text(
                '키오패스에 오신 것을 환영합니다',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                '바코드 스캔 쇼핑 시스템',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),

              const Spacer(),

              _SocialButton(
                label: '카카오로 시작하기',
                backgroundColor: const Color(0xFFFEE500),
                textColor: const Color(0xFF191919),
                icon: Icons.chat_bubble_rounded,
                isLoading: _isLoading,
                onPressed: () => _handleOAuth(ApiService.loginWithKakao),
              ),

              const SizedBox(height: 12),

              _SocialButton(
                label: '네이버로 시작하기',
                backgroundColor: const Color(0xFF03C75A),
                textColor: Colors.white,
                icon: Icons.person_rounded,
                isLoading: _isLoading,
                onPressed: () => _handleOAuth(ApiService.loginWithNaver),
              ),

              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(child: Divider(color: cs.outline)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      '아직 계정이 없으신가요?',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                  Expanded(child: Divider(color: cs.outline)),
                ],
              ),

              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                height: 54,
                child: OutlinedButton(
                  onPressed: _isLoading
                      ? null
                      : () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const SignupScreen()),
                          ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                        color: cs.onSurface.withValues(alpha: 0.2), width: 1),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('회원가입'),
                ),
              ),

              const SizedBox(height: 20),

              Text(
                '로그인 시 이용약관 및 개인정보처리방침에 동의해요',
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color textColor;
  final IconData icon;
  final bool isLoading;
  final VoidCallback onPressed;

  const _SocialButton({
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    required this.icon,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          disabledBackgroundColor: backgroundColor.withValues(alpha: 0.6),
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: textColor,
                  strokeWidth: 2,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: textColor, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      color: textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
