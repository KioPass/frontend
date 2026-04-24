import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import 'payment_history_screen.dart';
import 'payment_method_screen.dart';
import 'terms_screen.dart';
import 'support_screen.dart';
import 'settings_screen.dart';

class MyPageScreen extends StatelessWidget {
  final String userName;
  final String userEmail;
  final String userRole;

  const MyPageScreen({
    super.key,
    this.userName = '김태헌',
    this.userEmail = 'hong@example.com',
    this.userRole = 'buyer',
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSeller = userRole == 'seller';

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // 앱바
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
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
                  ),
                  Text('마이페이지', style: tt.titleMedium),
                ],
              ),
            ),

            Divider(height: 1, color: cs.outline),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 프로필
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: cs.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: cs.outline),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 56, height: 56,
                            decoration: BoxDecoration(
                              color: KColors.primary.withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.person_rounded, color: KColors.primary, size: 28),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text('${userName}님', style: tt.titleMedium),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: isSeller
                                            ? KColors.navy.withValues(alpha: isDark ? 0.4 : 0.08)
                                            : KColors.primary.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: isSeller
                                              ? cs.outline
                                              : KColors.primary.withValues(alpha: 0.3),
                                        ),
                                      ),
                                      child: Text(
                                        isSeller ? '판매자' : '구매자',
                                        style: TextStyle(
                                          fontFamily: 'Pretendard',
                                          color: isSeller ? cs.onSurface.withValues(alpha: 0.5) : KColors.primary,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(userEmail, style: tt.bodySmall),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // 나의 쇼핑
                    _buildSection(
                      context,
                      label: '나의 쇼핑',
                      items: [
                        _Item(icon: Icons.history_rounded, label: '결제 내역', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PaymentHistoryScreen()))),
                        _Item(icon: Icons.credit_card_rounded, label: '결제 수단 관리', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PaymentMethodScreen()))),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // 서비스
                    _buildSection(
                      context,
                      label: '서비스',
                      items: [
                        _Item(icon: Icons.description_outlined, label: '이용약관', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TermsScreen()))),
                        _Item(icon: Icons.help_outline_rounded, label: '고객센터', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SupportScreen()))),
                        _Item(icon: Icons.settings_outlined, label: '설정', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()))),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // 로그아웃
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await AuthService.logout();
                    if (!context.mounted) return;
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                    );
                  },
                  icon: Icon(Icons.logout_rounded, size: 18, color: cs.onSurface.withValues(alpha: 0.6)),
                  label: Text('로그아웃', style: TextStyle(fontFamily: 'Pretendard', fontSize: 15, fontWeight: FontWeight.w700, color: cs.onSurface.withValues(alpha: 0.6))),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: cs.outline),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, {required String label, required List<_Item> items}) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text(label, style: tt.bodySmall),
        ),
        Container(
          decoration: BoxDecoration(color: cs.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: cs.outline)),
          child: Column(
            children: items.asMap().entries.map((e) {
              final i = e.key;
              final item = e.value;
              return Column(
                children: [
                  if (i != 0) Divider(height: 1, color: cs.outline, indent: 20, endIndent: 20),
                  InkWell(
                    onTap: item.onTap,
                    borderRadius: BorderRadius.vertical(
                      top: i == 0 ? const Radius.circular(16) : Radius.zero,
                      bottom: i == items.length - 1 ? const Radius.circular(16) : Radius.zero,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      child: Row(
                        children: [
                          Icon(item.icon, color: cs.onSurface.withValues(alpha: 0.5), size: 20),
                          const SizedBox(width: 12),
                          Text(item.label, style: tt.bodyLarge),
                          const Spacer(),
                          Icon(Icons.chevron_right, color: cs.onSurface.withValues(alpha: 0.25), size: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _Item {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _Item({required this.icon, required this.label, required this.onTap});
}