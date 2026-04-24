import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import '../app_theme.dart';
import 'role_select_screen.dart';
import 'terms_screen.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              // ── 뒤로가기 ──
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: cs.onSurface.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.arrow_back, color: cs.onSurface, size: 20),
                ),
              ),

              const SizedBox(height: 32),

              // ── 헤드라인 ──
              Text('회원가입', style: tt.displayLarge),
              const SizedBox(height: 8),
              Text(
                '도난 방지 및 본인인증을 위해\n간편 가입만 지원해요',
                style: tt.bodyMedium?.copyWith(height: 1.6),
              ),

              const SizedBox(height: 24),

              const Spacer(),

              // ── 카카오 버튼 ──
              _SocialButton(
                label: '카카오로 시작하기',
                backgroundColor: const Color(0xFFFEE500),
                textColor: const Color(0xFF191919),
                icon: Icons.chat_bubble_rounded,
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RoleSelectScreen()),
                ),
              ),

              const SizedBox(height: 12),

              // ── 네이버 버튼 ──
              _SocialButton(
                label: '네이버로 시작하기',
                backgroundColor: const Color(0xFF03C75A),
                textColor: Colors.white,
                icon: Icons.person_rounded,
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RoleSelectScreen()),
                ),
              ),

              const SizedBox(height: 20),

              // ── 이용약관 ──
              Center(
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: tt.bodySmall?.copyWith(height: 1.7),
                    children: [
                      const TextSpan(text: '가입 시 키오패스의 '),
                      TextSpan(
                        text: '이용약관',
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          color: cs.onSurface,
                          fontWeight: FontWeight.w700,
                          decoration: TextDecoration.underline,
                          decorationColor: cs.onSurface,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const TermsScreen()),
                              ),
                      ),
                      const TextSpan(text: ' 및 '),
                      TextSpan(
                        text: '개인정보처리방침',
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          color: cs.onSurface,
                          fontWeight: FontWeight.w700,
                          decoration: TextDecoration.underline,
                          decorationColor: cs.onSurface,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () => debugPrint('개인정보'),
                      ),
                      const TextSpan(text: '에 동의해요'),
                    ],
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

class _SocialButton extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color textColor;
  final IconData icon;
  final VoidCallback onPressed;

  const _SocialButton({
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: Row(
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