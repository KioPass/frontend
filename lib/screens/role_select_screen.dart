import 'package:flutter/material.dart';
import '../app_theme.dart';
import 'main_screen.dart';
import 'seller_verify_screen.dart';
import '../services/auth_service.dart';

class RoleSelectScreen extends StatefulWidget {
  const RoleSelectScreen({super.key});

  @override
  State<RoleSelectScreen> createState() => _RoleSelectScreenState();
}

class _RoleSelectScreenState extends State<RoleSelectScreen> {
  String? _selectedRole;
  bool _isLoading = false;

  Future<void> _handleNext() async {
    if (_selectedRole == null) return;
    setState(() => _isLoading = true);
    await AuthService.saveUser(role: _selectedRole!, name: '', email: '');
    if (!mounted) return;
    setState(() => _isLoading = false);
    if (_selectedRole == 'seller') {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const SellerVerifyScreen()));
    } else {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
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
              Text('어떤 서비스가\n필요하신가요?', style: tt.displayLarge?.copyWith(height: 1.25)),
              const SizedBox(height: 8),
              Text('가입하실 회원 유형을 선택해주세요', style: tt.bodyMedium),

              const SizedBox(height: 32),

              // ── 구매자 카드 ──
              _RoleCard(
                role: 'buyer',
                selectedRole: _selectedRole,
                icon: Icons.shopping_bag_rounded,
                title: '구매자',
                description: '바코드를 스캔하고 편리하게 쇼핑해요',
                onTap: () => setState(() => _selectedRole = 'buyer'),
              ),

              const SizedBox(height: 12),

              // ── 판매자 카드 ──
              _RoleCard(
                role: 'seller',
                selectedRole: _selectedRole,
                icon: Icons.storefront_rounded,
                title: '판매자',
                description: '제품을 등록하고 매장을 운영해요',
                onTap: () => setState(() => _selectedRole = 'seller'),
              ),

              const Spacer(),

              // ── 다음 버튼 ──
              AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: _selectedRole != null ? 1.0 : 0.4,
                child: SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _selectedRole != null && !_isLoading ? _handleNext : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: KColors.primary,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: KColors.primary.withValues(alpha: 0.4),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20, height: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Text(
                            '다음으로',
                            style: TextStyle(
                              fontFamily: 'Pretendard',
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.3,
                            ),
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

class _RoleCard extends StatelessWidget {
  final String role;
  final String? selectedRole;
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  const _RoleCard({
    required this.role,
    required this.selectedRole,
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  bool get isSelected => selectedRole == role;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected
              ? KColors.primary.withValues(alpha: isDark ? 0.15 : 0.07)
              : cs.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? KColors.primary : cs.outline,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 52, height: 52,
              decoration: BoxDecoration(
                color: isSelected
                    ? KColors.primary.withValues(alpha: 0.15)
                    : cs.onSurface.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                color: isSelected ? KColors.primary : cs.onSurface.withValues(alpha: 0.4),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: tt.titleSmall?.copyWith(
                      color: isSelected ? KColors.primary : cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(description, style: tt.bodySmall),
                ],
              ),
            ),
            AnimatedOpacity(
              duration: const Duration(milliseconds: 180),
              opacity: isSelected ? 1 : 0,
              child: const Icon(Icons.check_circle_rounded, color: KColors.primary, size: 22),
            ),
          ],
        ),
      ),
    );
  }
}