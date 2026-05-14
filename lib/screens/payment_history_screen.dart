import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';

class PaymentHistoryScreen extends StatefulWidget {
  const PaymentHistoryScreen({super.key});

  @override
  State<PaymentHistoryScreen> createState() => _PaymentHistoryScreenState();
}

class _PaymentHistoryScreenState extends State<PaymentHistoryScreen> {
  String _selectedPeriod = '전체';
  final List<String> _periods = ['전체', '이번 달', '3개월', '6개월'];
  List<BuyerPayment> _history = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    setState(() => _isLoading = true);
    final token = await AuthService.getToken();
    if (token != null) {
      final list = await ApiService.getBuyerPayments(token);
      setState(() => _history = list);
    }
    setState(() => _isLoading = false);
  }

  List<BuyerPayment> get _filtered {
    if (_selectedPeriod == '전체') return _history;
    final now = DateTime.now();
    final cutoff = _selectedPeriod == '이번 달'
        ? DateTime(now.year, now.month, 1)
        : _selectedPeriod == '3개월'
            ? now.subtract(const Duration(days: 90))
            : now.subtract(const Duration(days: 180));
    return _history.where((h) {
      final date = DateTime.tryParse(h.date.replaceAll('.', '-'));
      return date != null && date.isAfter(cutoff);
    }).toList();
  }

  String _formatPrice(int price) => price
      .toString()
      .replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');

  Color _methodColor(String method) {
    if (method.contains('카카오')) return const Color(0xFFFEE500);
    if (method.contains('토스')) return const Color(0xFF0064FF);
    return KColors.navy;
  }

  Color _methodTextColor(String method) =>
      method.contains('카카오') ? const Color(0xFF1A1A1A) : Colors.white;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final filtered = _filtered;
    final total = filtered.fold(0, (sum, h) => sum + h.totalAmount);

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
                        decoration: BoxDecoration(
                            color: cs.onSurface.withValues(alpha: 0.06),
                            borderRadius: BorderRadius.circular(12)),
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
                  gradient: const LinearGradient(
                      colors: [KColors.primary, Color(0xFFFF4A22)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                        color: KColors.primary.withValues(alpha: 0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 6))
                  ],
                ),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('총 결제 금액',
                            style: TextStyle(
                                fontFamily: 'Pretendard',
                                color: Colors.white.withValues(alpha: 0.85),
                                fontSize: 13)),
                        const SizedBox(height: 6),
                        Text('${_formatPrice(total)}원',
                            style: const TextStyle(
                                fontFamily: 'Pretendard',
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -1)),
                      ],
                    ),
                    const Spacer(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('총 ${filtered.length}건',
                            style: TextStyle(
                                fontFamily: 'Pretendard',
                                color: Colors.white.withValues(alpha: 0.8),
                                fontSize: 13)),
                        const SizedBox(height: 4),
                        if (filtered.isNotEmpty)
                          Text('평균 ${_formatPrice(total ~/ filtered.length)}원',
                              style: TextStyle(
                                  fontFamily: 'Pretendard',
                                  color: Colors.white.withValues(alpha: 0.8),
                                  fontSize: 13)),
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
                decoration: BoxDecoration(
                    color: cs.onSurface.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(12)),
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
                            child: Text(p,
                                style: TextStyle(
                                    fontFamily: 'Pretendard',
                                    color: selected
                                        ? cs.onSurface
                                        : cs.onSurface.withValues(alpha: 0.4),
                                    fontSize: 12,
                                    fontWeight: selected
                                        ? FontWeight.w700
                                        : FontWeight.w400)),
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
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filtered.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.receipt_long_outlined,
                                  color: cs.onSurface.withValues(alpha: 0.2),
                                  size: 48),
                              const SizedBox(height: 12),
                              Text('결제 내역이 없어요', style: tt.bodyMedium),
                            ],
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (_, i) {
                            final h = filtered[i];
                            return Container(
                              decoration: BoxDecoration(
                                  color: cs.surface,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: cs.outline)),
                              child: Theme(
                                data: Theme.of(context)
                                    .copyWith(dividerColor: Colors.transparent),
                                child: ExpansionTile(
                                  tilePadding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 4),
                                  childrenPadding: EdgeInsets.zero,
                                  title: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(h.storeName, style: tt.titleSmall),
                                            const SizedBox(height: 2),
                                            Text('${h.date} ${h.time}',
                                                style: tt.bodySmall),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text('${_formatPrice(h.totalAmount)}원',
                                          style: const TextStyle(
                                              fontFamily: 'Pretendard',
                                              color: KColors.primary,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w900)),
                                    ],
                                  ),
                                  subtitle: null,
                                  children: [
                                    Divider(height: 1, color: cs.outline),
                                    Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        children: h.items
                                            .map((item) => Padding(
                                                  padding: const EdgeInsets.only(
                                                      bottom: 8),
                                                  child: Row(
                                                    children: [
                                                      Expanded(
                                                          child: Text(
                                                              '${item['name']} × ${item['qty']}',
                                                              style:
                                                                  tt.bodyMedium)),
                                                      Text(
                                                          '${_formatPrice((item['price'] as int) * (item['qty'] as int))}원',
                                                          style: const TextStyle(
                                                              fontFamily:
                                                                  'Pretendard',
                                                              fontWeight:
                                                                  FontWeight.w600)),
                                                    ],
                                                  ),
                                                ))
                                            .toList(),
                                      ),
                                    ),
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
