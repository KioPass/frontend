import 'package:flutter/material.dart';
import '../app_theme.dart';

class SalesDetailScreen extends StatefulWidget {
  const SalesDetailScreen({super.key});

  @override
  State<SalesDetailScreen> createState() => _SalesDetailScreenState();
}

class _SalesDetailScreenState extends State<SalesDetailScreen> {
  String _selectedPeriod = '오늘';
  final List<String> _periods = ['오늘', '이번 주', '이번 달', '3개월'];

  final List<Map<String, dynamic>> _transactions = [
    {'time': '14:23', 'name': '김*민', 'method': 'card', 'label': '신용카드', 'amount': 4500},
    {'time': '13:45', 'name': '비회원', 'method': 'kakao', 'label': '카카오페이', 'amount': 12300},
    {'time': '12:10', 'name': '이*영', 'method': 'card', 'label': '신용카드', 'amount': 2800},
    {'time': '11:30', 'name': '박*수', 'method': 'toss', 'label': '토스페이', 'amount': 6300},
    {'time': '10:15', 'name': '최*진', 'method': 'kakao', 'label': '카카오페이', 'amount': 9100},
  ];

  String _formatPrice(int price) => price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');

  Color _methodColor(String method) {
    switch (method) {
      case 'kakao': return const Color(0xFFFEE500);
      case 'toss': return const Color(0xFF0064FF);
      default: return KColors.navy;
    }
  }

  Color _methodTextColor(String method) => method == 'kakao' ? const Color(0xFF1A1A1A) : Colors.white;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final total = _transactions.fold(0, (sum, t) => sum + (t['amount'] as int));

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
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
                  Text('매출 상세', style: tt.titleMedium),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                child: Column(
                  children: [
                    // 기간 선택
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(color: cs.onSurface.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(12)),
                      child: Row(
                        children: _periods.map((p) {
                          final selected = _selectedPeriod == p;
                          return Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _selectedPeriod = p),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(
                                  color: selected ? cs.surface : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                  border: selected ? Border.all(color: cs.outline) : null,
                                ),
                                child: Center(child: Text(p, style: TextStyle(fontFamily: 'Pretendard', color: selected ? cs.onSurface : cs.onSurface.withValues(alpha: 0.4), fontSize: 12, fontWeight: selected ? FontWeight.w700 : FontWeight.w400))),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // 매출 카드
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [KColors.primary, Color(0xFFFF4A22)], begin: Alignment.centerLeft, end: Alignment.centerRight),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [BoxShadow(color: KColors.primary.withValues(alpha: 0.3), blurRadius: 16, offset: const Offset(0, 6))],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_selectedPeriod == '오늘' ? '오늘의 매출' : '$_selectedPeriod 매출', style: TextStyle(fontFamily: 'Pretendard', color: Colors.white.withValues(alpha: 0.85), fontSize: 13)),
                          const SizedBox(height: 8),
                          Text('${_formatPrice(total)}원', style: const TextStyle(fontFamily: 'Pretendard', color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: -1.2)),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              _statChip('${_transactions.length}건'),
                              const SizedBox(width: 8),
                              _statChip('평균 ${_formatPrice(total ~/ _transactions.length)}원'),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // 결제 수단별 비율
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(color: cs.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: cs.outline)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('결제 수단별', style: tt.titleSmall),
                          const SizedBox(height: 16),
                          _methodBar(context, '신용카드', 2, _transactions.length, KColors.navy),
                          const SizedBox(height: 10),
                          _methodBar(context, '카카오페이', 2, _transactions.length, const Color(0xFFFEE500), textColor: const Color(0xFF1A1A1A)),
                          const SizedBox(height: 10),
                          _methodBar(context, '토스페이', 1, _transactions.length, const Color(0xFF0064FF)),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // 거래 내역
                    Container(
                      decoration: BoxDecoration(color: cs.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: cs.outline)),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
                            child: Row(children: [Text('거래 내역', style: tt.titleSmall), const Spacer(), Text('${_transactions.length}건', style: tt.bodySmall)]),
                          ),
                          Divider(height: 1, color: cs.outline),
                          ..._transactions.map((t) => Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                                child: Row(
                                  children: [
                                    Text(t['time'], style: tt.bodySmall),
                                    const SizedBox(width: 12),
                                    Expanded(child: Text(t['name'], style: tt.labelLarge)),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(color: _methodColor(t['method']), borderRadius: BorderRadius.circular(6)),
                                      child: Text(t['label'], style: TextStyle(fontFamily: 'Pretendard', color: _methodTextColor(t['method']), fontSize: 10, fontWeight: FontWeight.w700)),
                                    ),
                                    const SizedBox(width: 10),
                                    Text('${_formatPrice(t['amount'] as int)}원', style: tt.labelLarge?.copyWith(color: KColors.primary)),
                                  ],
                                ),
                              ),
                              Divider(height: 1, color: cs.outline, indent: 20, endIndent: 20),
                            ],
                          )),
                          const SizedBox(height: 4),
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

  Widget _statChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
      child: Text(label, style: TextStyle(fontFamily: 'Pretendard', color: Colors.white.withValues(alpha: 0.9), fontSize: 12, fontWeight: FontWeight.w500)),
    );
  }

  Widget _methodBar(BuildContext context, String label, int count, int total, Color color, {Color? textColor}) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final ratio = count / total;
    return Row(
      children: [
        SizedBox(width: 72, child: Text(label, style: tt.bodySmall)),
        const SizedBox(width: 8),
        Expanded(
          child: Stack(
            children: [
              Container(height: 8, decoration: BoxDecoration(color: cs.onSurface.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(999))),
              FractionallySizedBox(
                widthFactor: ratio,
                child: Container(height: 8, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(999))),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text('${(ratio * 100).toInt()}%', style: tt.bodySmall),
      ],
    );
  }
}