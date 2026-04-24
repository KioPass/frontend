import 'package:flutter/material.dart';
import '../app_theme.dart';

class PaymentHistoryScreen extends StatefulWidget {
  const PaymentHistoryScreen({super.key});

  @override
  State<PaymentHistoryScreen> createState() => _PaymentHistoryScreenState();
}

class _PaymentHistoryScreenState extends State<PaymentHistoryScreen> {
  String _selectedPeriod = '전체';
  final List<String> _periods = ['전체', '이번 달', '3개월', '6개월'];

  final List<Map<String, dynamic>> _history = [
    {'date': '2026.04.19', 'time': '19:23', 'store': '키오패스 편의점 강남점', 'method': 'kakao', 'methodLabel': '카카오페이', 'amount': 4500, 'items': [{'name': '코카콜라 500ml', 'qty': 2, 'price': 1500}, {'name': '새우깡', 'qty': 1, 'price': 1000}, {'name': '삼각김밥 참치', 'qty': 1, 'price': 1200}]},
    {'date': '2026.04.18', 'time': '14:10', 'store': '키오패스 마트 선릉점', 'method': 'toss', 'methodLabel': '토스페이', 'amount': 12300, 'items': [{'name': '11찬 도시락', 'qty': 1, 'price': 5500}, {'name': '바나나우유', 'qty': 2, 'price': 1800}]},
    {'date': '2026.04.17', 'time': '11:45', 'store': '키오패스 편의점 역삼점', 'method': 'card', 'methodLabel': '신용카드', 'amount': 2800, 'items': [{'name': '진라면 매운맛 (컵)', 'qty': 1, 'price': 1300}, {'name': '컵누들 매콤한맛', 'qty': 1, 'price': 1500}]},
    {'date': '2026.04.15', 'time': '20:30', 'store': '키오패스 편의점 강남점', 'method': 'kakao', 'methodLabel': '카카오페이', 'amount': 6300, 'items': [{'name': '초코파이', 'qty': 1, 'price': 4800}, {'name': '칠성사이다 500ml', 'qty': 1, 'price': 1600}]},
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
    final total = _history.fold(0, (sum, h) => sum + (h['amount'] as int));

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
                  Text('결제 내역', style: tt.titleMedium),
                ],
              ),
            ),

            // 요약 카드
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [KColors.primary, Color(0xFFFF4A22)], begin: Alignment.centerLeft, end: Alignment.centerRight),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: KColors.primary.withValues(alpha: 0.3), blurRadius: 16, offset: const Offset(0, 6))],
                ),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('총 결제 금액', style: TextStyle(fontFamily: 'Pretendard', color: Colors.white.withValues(alpha: 0.85), fontSize: 13)),
                        const SizedBox(height: 6),
                        Text('${_formatPrice(total)}원', style: const TextStyle(fontFamily: 'Pretendard', color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900, letterSpacing: -1)),
                      ],
                    ),
                    const Spacer(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('총 ${_history.length}건', style: TextStyle(fontFamily: 'Pretendard', color: Colors.white.withValues(alpha: 0.8), fontSize: 13)),
                        const SizedBox(height: 4),
                        Text('평균 ${_formatPrice(total ~/ _history.length)}원', style: TextStyle(fontFamily: 'Pretendard', color: Colors.white.withValues(alpha: 0.8), fontSize: 13)),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // 기간 필터
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Container(
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
                          child: Center(
                            child: Text(
                              p,
                              style: TextStyle(
                                fontFamily: 'Pretendard',
                                color: selected ? cs.onSurface : cs.onSurface.withValues(alpha: 0.4),
                                fontSize: 12,
                                fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            // 내역 리스트
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                itemCount: _history.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (_, i) {
                  final h = _history[i];
                  final items = h['items'] as List;
                  return Container(
                    decoration: BoxDecoration(color: cs.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: cs.outline)),
                    child: Theme(
                      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        childrenPadding: EdgeInsets.zero,
                        title: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(h['store'], style: tt.titleSmall),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Text('${h['date']} ${h['time']}', style: tt.bodySmall),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(color: _methodColor(h['method']), borderRadius: BorderRadius.circular(6)),
                                        child: Text(h['methodLabel'], style: TextStyle(fontFamily: 'Pretendard', color: _methodTextColor(h['method']), fontSize: 10, fontWeight: FontWeight.w700)),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text('${_formatPrice(h['amount'] as int)}원', style: const TextStyle(fontFamily: 'Pretendard', color: KColors.primary, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
                          ],
                        ),
                        children: [
                          Divider(height: 1, color: cs.outline),
                          ...items.map((item) => Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            child: Row(
                              children: [
                                Container(
                                  width: 32, height: 32,
                                  decoration: BoxDecoration(color: cs.onSurface.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(8)),
                                  child: Icon(Icons.image_outlined, color: cs.onSurface.withValues(alpha: 0.2), size: 16),
                                ),
                                const SizedBox(width: 10),
                                Expanded(child: Text(item['name'], style: tt.labelLarge)),
                                Text('${item['qty']}개', style: tt.bodySmall),
                                const SizedBox(width: 12),
                                Text('${_formatPrice((item['price'] as int) * (item['qty'] as int))}원', style: tt.labelLarge),
                              ],
                            ),
                          )),
                          const SizedBox(height: 4),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}