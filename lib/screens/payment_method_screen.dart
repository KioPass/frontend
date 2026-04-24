import 'package:flutter/material.dart';
import '../app_theme.dart';

class PaymentMethodScreen extends StatefulWidget {
  const PaymentMethodScreen({super.key});

  @override
  State<PaymentMethodScreen> createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
  final List<Map<String, dynamic>> _methods = [
    {'type': 'kakao', 'name': '카카오페이', 'isLinked': true, 'isDefault': true},
    {'type': 'toss', 'name': '토스페이', 'isLinked': true, 'isDefault': false},
    {'type': 'card', 'name': '신용카드', 'isLinked': false, 'isDefault': false},
  ];

  void _setDefault(int index) {
    setState(() {
      for (var i = 0; i < _methods.length; i++) _methods[i]['isDefault'] = i == index;
    });
  }

  void _toggleLink(int index) {
    setState(() {
      _methods[index]['isLinked'] = !_methods[index]['isLinked'];
      if (!_methods[index]['isLinked'] && _methods[index]['isDefault']) {
        _methods[index]['isDefault'] = false;
        final linked = _methods.indexWhere((m) => m['isLinked'] == true);
        if (linked != -1) _methods[linked]['isDefault'] = true;
      }
    });
  }

  Color _methodBgColor(String type) {
    switch (type) {
      case 'kakao': return const Color(0xFFFEE500);
      case 'toss': return const Color(0xFF0064FF);
      default: return KColors.navy;
    }
  }

  IconData _methodIcon(String type) {
    switch (type) {
      case 'kakao': return Icons.chat_bubble_rounded;
      case 'toss': return Icons.account_balance_wallet_rounded;
      default: return Icons.credit_card_rounded;
    }
  }

  Color _methodIconColor(String type) => type == 'kakao' ? const Color(0xFF1A1A1A) : Colors.white;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // 앱바
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(color: cs.onSurface.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(12)),
                        child: Icon(Icons.arrow_back, color: cs.onSurface, size: 20),
                      ),
                    ),
                  ),
                  Text('결제 수단 관리', style: tt.titleMedium),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 4, bottom: 10),
                      child: Text('결제 수단', style: tt.bodySmall),
                    ),
                    ...List.generate(_methods.length, (i) => _buildMethodCard(context, i)),
                    const SizedBox(height: 20),
                    // 안내 박스
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cs.onSurface.withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: cs.outline),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.info_outline_rounded, color: cs.onSurface.withValues(alpha: 0.4), size: 16),
                              const SizedBox(width: 6),
                              Text('안내', style: tt.labelLarge?.copyWith(color: cs.onSurface.withValues(alpha: 0.5))),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '• 기본 결제 수단은 결제 시 자동으로 선택돼요\n• 결제 수단 연결/해제는 각 앱에서도 관리할 수 있어요\n• 실제 연동은 백엔드 출시 후 가능해요',
                            style: tt.bodySmall?.copyWith(height: 1.7),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMethodCard(BuildContext context, int index) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final method = _methods[index];
    final isLinked = method['isLinked'] as bool;
    final isDefault = method['isDefault'] as bool;
    final type = method['type'] as String;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDefault ? KColors.primary : cs.outline, width: isDefault ? 1.5 : 1),
      ),
      child: Row(
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: isLinked ? _methodBgColor(type) : cs.onSurface.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(_methodIcon(type), color: isLinked ? _methodIconColor(type) : cs.onSurface.withValues(alpha: 0.25), size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(method['name'], style: tt.titleSmall?.copyWith(color: isLinked ? null : cs.onSurface.withValues(alpha: 0.4))),
                    if (isDefault) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: KColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: KColors.primary.withValues(alpha: 0.3)),
                        ),
                        child: const Text('기본', style: TextStyle(fontFamily: 'Pretendard', color: KColors.primary, fontSize: 10, fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(isLinked ? '연결됨' : '연결 안 됨', style: tt.bodySmall),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: () => _toggleLink(index),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isLinked ? cs.onSurface.withValues(alpha: 0.06) : KColors.primary,
                    borderRadius: BorderRadius.circular(8),
                    border: isLinked ? Border.all(color: cs.outline) : null,
                  ),
                  child: Text(
                    isLinked ? '해제' : '연결',
                    style: TextStyle(fontFamily: 'Pretendard', color: isLinked ? cs.onSurface.withValues(alpha: 0.5) : Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              if (isLinked && !isDefault) ...[
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: () => _setDefault(index),
                  child: Text('기본으로 설정', style: tt.bodySmall?.copyWith(decoration: TextDecoration.underline, decorationColor: cs.onSurface.withValues(alpha: 0.3))),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}