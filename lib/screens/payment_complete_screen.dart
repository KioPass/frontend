import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math' as math;
import '../app_theme.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import 'payment_history_screen.dart';
class PaymentCartItem {
  final String name;
  final int quantity;
  final int totalPrice;

  const PaymentCartItem({
    required this.name,
    required this.quantity,
    required this.totalPrice,
  });
}

class PaymentCompleteScreen extends StatefulWidget {
  final String storeName;
  final String paymentMethod;
  final int cartTotal;
  final int cartCount;
  final List<PaymentCartItem> cartItems;
  final String Function(int) formatPrice;
  final int? storeId;

  const PaymentCompleteScreen({
    super.key,
    required this.storeName,
    required this.paymentMethod,
    required this.cartTotal,
    required this.cartCount,
    required this.cartItems,
    required this.formatPrice,
    this.storeId,
  });

  @override
  State<PaymentCompleteScreen> createState() => _PaymentCompleteScreenState();
}

class _PaymentCompleteScreenState extends State<PaymentCompleteScreen>
    with TickerProviderStateMixin {
  late AnimationController _rippleController;
  late AnimationController _checkController;
  late Animation<double> _checkAnimation;
  bool _isReceiptExpanded = false;
  late final String _orderNumber;
  late final String _orderDate;
  StampCardModel? _stampCard;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _orderDate =
        '${now.year}.${now.month.toString().padLeft(2, '0')}.${now.day.toString().padLeft(2, '0')} '
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    _orderNumber = (math.Random().nextInt(90000000) + 10000000).toString();
    _rippleController = AnimationController(vsync: this, duration: const Duration(milliseconds: 2000))..repeat();
    _checkController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _checkAnimation = CurvedAnimation(parent: _checkController, curve: Curves.elasticOut);
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _checkController.forward();
    });
    _loadStampCard();
  }

  Future<void> _loadStampCard() async {
    if (widget.storeId == null || widget.storeId == 0) return;
    final token = await AuthService.getToken();
    if (token == null || !mounted) return;
    final card = await ApiService.getStampCard(token, widget.storeId!);
    if (mounted) setState(() => _stampCard = card);
  }

  @override
  void dispose() {
    _rippleController.dispose();
    _checkController.dispose();
    super.dispose();
  }

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
                        decoration: BoxDecoration(
                          color: cs.onSurface.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.arrow_back, color: cs.onSurface, size: 20),
                      ),
                    ),
                  ),
                  Text('결제 완료', style: tt.titleMedium),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                child: Column(
                  children: [
                    // 체크 아이콘
                    SizedBox(
                      width: 120, height: 120,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          AnimatedBuilder(
                            animation: _rippleController,
                            builder: (_, _i) => Stack(
                              alignment: Alignment.center,
                              children: List.generate(3, (i) {
                                final delay = i / 3;
                                final progress = (_rippleController.value - delay) % 1.0;
                                if (progress < 0) return const SizedBox.shrink();
                                return Opacity(
                                  opacity: (1 - progress).clamp(0.0, 1.0),
                                  child: Container(
                                    width: 60 + progress * 60,
                                    height: 60 + progress * 60,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(color: KColors.primary.withValues(alpha: 0.4), width: 2),
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ),
                          ScaleTransition(
                            scale: _checkAnimation,
                            child: Container(
                              width: 72, height: 72,
                              decoration: BoxDecoration(
                                color: KColors.primary.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Container(
                                  width: 56, height: 56,
                                  decoration: BoxDecoration(
                                    color: KColors.primary.withValues(alpha: 0.35),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.check_circle_outline_rounded, color: KColors.primary, size: 36),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    Text('결제가 완료됐어요', style: tt.titleLarge?.copyWith(letterSpacing: -0.5))
                        .animate(delay: 400.ms)
                        .fadeIn(duration: 400.ms)
                        .slideY(begin: 0.2, curve: Curves.easeOutCubic),
                    const SizedBox(height: 6),
                    Text('이용해 주셔서 감사합니다', style: tt.bodyMedium)
                        .animate(delay: 550.ms)
                        .fadeIn(duration: 400.ms)
                        .slideY(begin: 0.2, curve: Curves.easeOutCubic),

                    const SizedBox(height: 28),

                    // 영수증 카드
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: cs.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: cs.outline),
                      ),
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          Container(
                            width: 44, height: 44,
                            decoration: BoxDecoration(
                              color: KColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(Icons.receipt_long_outlined, color: KColors.primary, size: 22),
                          ),
                          const SizedBox(height: 10),
                          Text(widget.storeName, style: tt.titleSmall),
                          const SizedBox(height: 2),
                          Text('전자 영수증', style: tt.bodySmall),
                          const SizedBox(height: 16),
                          Divider(height: 1, color: cs.outline),
                          _row(context, '주문번호', _orderNumber),
                          Divider(height: 1, color: cs.outline, indent: 20, endIndent: 20),
                          _row(context, '결제일시', _orderDate),
                          Divider(height: 1, color: cs.outline),

                          // 구매 내역 토글
                          GestureDetector(
                            onTap: () => setState(() => _isReceiptExpanded = !_isReceiptExpanded),
                            behavior: HitTestBehavior.opaque,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                              child: Row(
                                children: [
                                  Text('구매 내역 (${widget.cartCount}개)', style: tt.titleSmall),
                                  const Spacer(),
                                  AnimatedRotation(
                                    turns: _isReceiptExpanded ? 0.5 : 0,
                                    duration: const Duration(milliseconds: 200),
                                    child: Icon(Icons.keyboard_arrow_down_rounded, color: cs.onSurface.withValues(alpha: 0.4), size: 20),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          if (_isReceiptExpanded) ...[
                            Divider(height: 1, color: cs.outline, indent: 20, endIndent: 20),
                            ...widget.cartItems.map((item) => Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(item.name, style: tt.labelLarge),
                                        const SizedBox(height: 2),
                                        Text('수량 ${item.quantity}개', style: tt.bodySmall),
                                      ],
                                    ),
                                  ),
                                  Text(widget.formatPrice(item.totalPrice), style: tt.labelLarge),
                                ],
                              ),
                            )),
                            const SizedBox(height: 4),
                          ],

                          Divider(height: 1, color: cs.outline),

                          // 총 결제금액
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                            child: Row(
                              children: [
                                Text('총 결제금액', style: tt.titleSmall),
                                const Spacer(),
                                TweenAnimationBuilder<int>(
                                  tween: IntTween(begin: 0, end: widget.cartTotal),
                                  duration: const Duration(milliseconds: 900),
                                  curve: Curves.easeOutCubic,
                                  builder: (_, value, __) => Text(
                                    widget.formatPrice(value),
                                    style: const TextStyle(
                                      fontFamily: 'Pretendard',
                                      color: KColors.primary,
                                      fontSize: 22,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: -0.8,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                        .animate(delay: 600.ms)
                        .fadeIn(duration: 500.ms)
                        .slideY(begin: 0.1, curve: Curves.easeOutCubic),

                    const SizedBox(height: 16),

                    // 스탬프 카드
                    if (_stampCard != null && widget.storeId != null && widget.storeId != 0)
                      _StampCardWidget(stampCard: _stampCard!)
                          .animate(delay: 700.ms)
                          .fadeIn(duration: 400.ms)
                          .slideY(begin: 0.1, curve: Curves.easeOutCubic),

                    const SizedBox(height: 24),

                    // 버튼
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const PaymentHistoryScreen()),
                        ),
                        icon: Icon(Icons.receipt_outlined, size: 18, color: cs.onSurface),
                        label: Text('구매 내역 보기', style: TextStyle(fontFamily: 'Pretendard', fontSize: 15, fontWeight: FontWeight.w700, color: cs.onSurface)),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: cs.outline),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    )
                        .animate(delay: 700.ms)
                        .fadeIn(duration: 350.ms)
                        .slideY(begin: 0.15, curve: Curves.easeOutCubic),

                    const SizedBox(height: 12),

                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                        icon: const Icon(Icons.home_outlined, size: 18),
                        label: const Text('홈으로 가기', style: TextStyle(fontFamily: 'Pretendard', fontSize: 15, fontWeight: FontWeight.w700)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: KColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    )
                        .animate(delay: 800.ms)
                        .fadeIn(duration: 350.ms)
                        .slideY(begin: 0.15, curve: Curves.easeOutCubic),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(BuildContext context, String label, String value, {bool bold = false}) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          Text(label, style: tt.bodyMedium),
          const Spacer(),
          Text(value, style: tt.bodyMedium?.copyWith(
            color: cs.onSurface,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
          )),
        ],
      ),
    );
  }
}

class _StampCardWidget extends StatelessWidget {
  final StampCardModel stampCard;
  const _StampCardWidget({required this.stampCard});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final stamps = stampCard.stampCount; // 0~9

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: KColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.local_activity_outlined, color: KColors.primary, size: 18),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('스탬프 카드', style: tt.titleSmall),
                  Text(stampCard.storeName, style: tt.bodySmall),
                ],
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 16),
          // 스탬프 10칸
          Row(
            children: List.generate(10, (i) {
              final filled = i < stamps;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: i < 9 ? 4 : 0),
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 200 + i * 40),
                    height: 8,
                    decoration: BoxDecoration(
                      color: filled ? KColors.primary : cs.onSurface.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text('$stamps / 10 스탬프', style: tt.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
              const Spacer(),
              Text(
                stamps == 0 ? '첫 결제 감사해요!' : '${10 - stamps}번 더 결제하면 쿠폰 발급!',
                style: tt.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }
}