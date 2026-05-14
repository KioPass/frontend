import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';

class SalesDetailScreen extends StatefulWidget {
  final int? storeId;
  const SalesDetailScreen({super.key, this.storeId});

  @override
  State<SalesDetailScreen> createState() => _SalesDetailScreenState();
}

class _SalesDetailScreenState extends State<SalesDetailScreen> {
  String _selectedPeriod = '오늘';
  final List<String> _periods = ['오늘', '이번 주', '이번 달', '3개월'];

  List<RecentPayment> _transactions = [];
  bool _isLoading = false;

  final Map<String, String> _periodMap = {
    '오늘': 'today',
    '이번 주': 'week',
    '이번 달': 'month',
    '3개월': '3month',
  };

  @override
  void initState() {
    super.initState();
    _fetchTransactions();
  }

  Future<void> _fetchTransactions() async {
    if (widget.storeId == null) return;
    setState(() => _isLoading = true);
    final token = await AuthService.getToken();
    if (token != null) {
      final list = await ApiService.getRecentPayments(
        token: token,
        storeId: widget.storeId!,
        period: _periodMap[_selectedPeriod],
      );
      setState(() => _transactions = list);
    }
    setState(() => _isLoading = false);
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
    final total = _transactions.fold(0, (sum, t) => sum + t.totalAmount);

    // 결제 수단별 집계
    final methodCounts = <String, int>{};
    for (final t in _transactions) {
      methodCounts[t.paymentMethod] = (methodCounts[t.paymentMethod] ?? 0) + 1;
    }

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
                        decoration: BoxDecoration(
                            color: cs.onSurface.withValues(alpha: 0.06),
                            borderRadius: BorderRadius.circular(12)),
                        child: Icon(Icons.arrow_back, color: cs.onSurface, size: 20),
                      ),
                    ),
                  ),
                  Text('매출 상세', style: tt.titleMedium),
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  // 기간 선택
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
                              onTap: () {
                                setState(() => _selectedPeriod = p);
                                _fetchTransactions();
                              },
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

                  Expanded(
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : SingleChildScrollView(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                            child: Column(
                              children: [
                                // 매출 카드
                                Container(
                                  width: double.infinity,
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
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                          _selectedPeriod == '오늘'
                                              ? '오늘의 매출'
                                              : '$_selectedPeriod 매출',
                                          style: TextStyle(
                                              fontFamily: 'Pretendard',
                                              color: Colors.white.withValues(alpha: 0.85),
                                              fontSize: 13)),
                                      const SizedBox(height: 8),
                                      Text('${_formatPrice(total)}원',
                                          style: const TextStyle(
                                              fontFamily: 'Pretendard',
                                              color: Colors.white,
                                              fontSize: 32,
                                              fontWeight: FontWeight.w900,
                                              letterSpacing: -1.2)),
                                      const SizedBox(height: 12),
                                      Row(
                                        children: [
                                          _statChip('${_transactions.length}건'),
                                          if (_transactions.isNotEmpty) ...[
                                            const SizedBox(width: 8),
                                            _statChip(
                                                '평균 ${_formatPrice(total ~/ _transactions.length)}원'),
                                          ],
                                        ],
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 16),

                                const SizedBox(height: 0),

                                // 거래 내역
                                Container(
                                  decoration: BoxDecoration(
                                      color: cs.surface,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(color: cs.outline)),
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
                                        child: Row(children: [
                                          Text('거래 내역', style: tt.titleSmall),
                                          const Spacer(),
                                          Text('${_transactions.length}건',
                                              style: tt.bodySmall)
                                        ]),
                                      ),
                                      Divider(height: 1, color: cs.outline),
                                      if (_transactions.isEmpty)
                                        Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 24),
                                          child: Center(
                                              child: Text('거래 내역이 없어요', style: tt.bodySmall)),
                                        )
                                      else
                                        ..._transactions.map((t) => Column(
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets.symmetric(
                                                      horizontal: 20, vertical: 14),
                                                  child: Row(
                                                    children: [
                                                      Text(t.time, style: tt.bodySmall),
                                                      const SizedBox(width: 12),
                                                      Expanded(
                                                          child: Text(t.buyerName,
                                                              style: tt.labelLarge)),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                          '${_formatPrice(t.totalAmount)}원',
                                                          style: tt.labelLarge
                                                              ?.copyWith(color: KColors.primary)),
                                                    ],
                                                  ),
                                                ),
                                                Divider(
                                                    height: 1,
                                                    color: cs.outline,
                                                    indent: 20,
                                                    endIndent: 20),
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
          ],
        ),
      ),
    );
  }

  Widget _statChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
      child: Text(label,
          style: TextStyle(
              fontFamily: 'Pretendard',
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 12,
              fontWeight: FontWeight.w500)),
    );
  }

  Widget _methodBar(BuildContext context, String label, int count, int total,
      Color color, {Color? textColor}) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final ratio = total == 0 ? 0.0 : count / total;
    return Row(
      children: [
        SizedBox(width: 72, child: Text(label, style: tt.bodySmall)),
        const SizedBox(width: 8),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 8,
              backgroundColor: cs.onSurface.withValues(alpha: 0.08),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(6)),
          child: Text('$count건',
              style: TextStyle(
                  fontFamily: 'Pretendard',
                  color: textColor ?? Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w700)),
        ),
      ],
    );
  }
}
