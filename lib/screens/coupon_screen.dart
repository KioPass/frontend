import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../app_theme.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart'; // _loadCoupons에서 사용
import 'buyer_home_screen.dart' as buyer;

class CouponScreen extends StatefulWidget {
  const CouponScreen({super.key});

  @override
  State<CouponScreen> createState() => _CouponScreenState();
}

class _CouponScreenState extends State<CouponScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  List<StampCardModel> _cards = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadCoupons();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadCoupons() async {
    final token = await AuthService.getToken();
    if (token == null || !mounted) return;
    final list = await ApiService.getMyCoupons(token);
    if (mounted) setState(() { _cards = list; _loading = false; });
  }

  void _goToStore(StampCardModel card) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          body: buyer.BuyerProductGrid(
            storeId: card.storeId,
            storeName: card.storeName,
          ),
        ),
      ),
    );
  }

  List<StampCardModel> get _withCoupon => _cards.where((c) => c.availableCoupons > 0).toList();
  List<StampCardModel> get _allCards => _cards;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final totalCoupons = _cards.fold(0, (s, c) => s + c.availableCoupons);

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
                  Text('쿠폰함', style: tt.titleMedium),
                ],
              ),
            ),

            // 쿠폰 총 보유 배너
            if (!_loading && totalCoupons > 0)
              Container(
                margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [KColors.primary, KColors.primary.withValues(alpha: 0.75)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.local_activity_rounded, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('사용 가능한 쿠폰', style: tt.bodySmall?.copyWith(color: Colors.white.withValues(alpha: 0.8))),
                          const SizedBox(height: 2),
                          Text('$totalCoupons장', style: const TextStyle(fontFamily: 'Pretendard', color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: Colors.white, size: 20),
                  ],
                ),
              ).animate().fadeIn(duration: 350.ms).slideY(begin: 0.1),

            // 탭바
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: cs.onSurface.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                controller: _tabController,
                dividerColor: Colors.transparent,
                indicator: BoxDecoration(
                  color: cs.surface,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [BoxShadow(color: cs.onSurface.withValues(alpha: 0.06), blurRadius: 4, offset: const Offset(0, 1))],
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                indicatorPadding: const EdgeInsets.all(3),
                labelStyle: const TextStyle(fontFamily: 'Pretendard', fontSize: 13, fontWeight: FontWeight.w700),
                unselectedLabelStyle: const TextStyle(fontFamily: 'Pretendard', fontSize: 13, fontWeight: FontWeight.w500),
                labelColor: cs.onSurface,
                unselectedLabelColor: cs.onSurface.withValues(alpha: 0.4),
                tabs: [
                  Tab(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('사용 가능'),
                        if (totalCoupons > 0) ...[
                          const SizedBox(width: 4),
                          Container(
                            width: 16, height: 16,
                            decoration: const BoxDecoration(color: KColors.primary, shape: BoxShape.circle),
                            child: Center(child: Text('$totalCoupons', style: const TextStyle(fontFamily: 'Pretendard', color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900))),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const Tab(text: '스탬프 현황'),
                ],
              ),
            ),

            const SizedBox(height: 16),

            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        _CouponTab(cards: _withCoupon, onUse: _goToStore),
                        _StampTab(cards: _allCards),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── 사용 가능 쿠폰 탭 ────────────────────────────────────────────────────
class _CouponTab extends StatelessWidget {
  final List<StampCardModel> cards;
  final void Function(StampCardModel) onUse;

  const _CouponTab({required this.cards, required this.onUse});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    if (cards.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.local_activity_outlined, size: 48, color: cs.onSurface.withValues(alpha: 0.2)),
            const SizedBox(height: 12),
            Text('사용 가능한 쿠폰이 없어요', style: tt.titleSmall?.copyWith(color: cs.onSurface.withValues(alpha: 0.4))),
            const SizedBox(height: 4),
            Text('10번 결제하면 1,000원 쿠폰이 발급돼요', style: tt.bodySmall),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
      itemCount: cards.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) => _CouponCard(card: cards[i], onUse: () => onUse(cards[i]))
          .animate(delay: Duration(milliseconds: i * 60))
          .fadeIn(duration: 300.ms)
          .slideY(begin: 0.1, curve: Curves.easeOutCubic),
    );
  }
}

class _CouponCard extends StatelessWidget {
  final StampCardModel card;
  final VoidCallback onUse;

  const _CouponCard({required this.card, required this.onUse});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: KColors.primary.withValues(alpha: 0.25)),
        boxShadow: [BoxShadow(color: KColors.primary.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          // 상단 쿠폰 정보
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
            child: Row(
              children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    color: KColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.storefront_outlined, color: KColors.primary, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(card.storeName, style: tt.titleSmall),
                      const SizedBox(height: 2),
                      Text('${card.availableCoupons}장 보유', style: tt.bodySmall?.copyWith(color: KColors.primary, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 점선 구분선 (쿠폰 스타일)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Row(
              children: List.generate(30, (i) => Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  height: 1,
                  color: i.isEven ? KColors.primary.withValues(alpha: 0.2) : Colors.transparent,
                ),
              )),
            ),
          ),

          // 하단 쿠폰 금액 + 사용 버튼
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('할인 금액', style: tt.bodySmall),
                    const SizedBox(height: 2),
                    const Text(
                      '1,000원',
                      style: TextStyle(fontFamily: 'Pretendard', color: KColors.primary, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: -0.5),
                    ),
                  ],
                ),
                const Spacer(),
                GestureDetector(
                  onTap: onUse,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: KColors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      '매장 가기',
                      style: TextStyle(fontFamily: 'Pretendard', color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── 스탬프 현황 탭 ────────────────────────────────────────────────────────
class _StampTab extends StatelessWidget {
  final List<StampCardModel> cards;

  const _StampTab({required this.cards});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    if (cards.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.receipt_long_outlined, size: 48, color: cs.onSurface.withValues(alpha: 0.2)),
            const SizedBox(height: 12),
            Text('아직 결제 내역이 없어요', style: tt.titleSmall?.copyWith(color: cs.onSurface.withValues(alpha: 0.4))),
            const SizedBox(height: 4),
            Text('매장에서 결제하면 스탬프가 쌓여요', style: tt.bodySmall),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
      itemCount: cards.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) => _StampCard(card: cards[i])
          .animate(delay: Duration(milliseconds: i * 60))
          .fadeIn(duration: 300.ms)
          .slideY(begin: 0.1, curve: Curves.easeOutCubic),
    );
  }
}

class _StampCard extends StatelessWidget {
  final StampCardModel card;

  const _StampCard({required this.card});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final stamps = card.stampCount;
    final hasCoupon = card.availableCoupons > 0;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: hasCoupon ? KColors.primary.withValues(alpha: 0.3) : cs.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: hasCoupon ? KColors.primary.withValues(alpha: 0.1) : cs.onSurface.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.storefront_outlined, color: hasCoupon ? KColors.primary : cs.onSurface.withValues(alpha: 0.4), size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(card.storeName, style: tt.labelLarge),
              ),
              if (hasCoupon)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: KColors.primary, borderRadius: BorderRadius.circular(999)),
                  child: Text('쿠폰 ${card.availableCoupons}장', style: const TextStyle(fontFamily: 'Pretendard', color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                ),
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
                  child: Column(
                    children: [
                      AnimatedContainer(
                        duration: Duration(milliseconds: 200 + i * 30),
                        width: double.infinity,
                        height: 10,
                        decoration: BoxDecoration(
                          color: filled ? KColors.primary : cs.onSurface.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),

          const SizedBox(height: 10),
          Row(
            children: [
              Text('$stamps / 10', style: tt.bodySmall?.copyWith(fontWeight: FontWeight.w700, color: KColors.primary)),
              const SizedBox(width: 4),
              Text('스탬프', style: tt.bodySmall),
              const Spacer(),
              Text(
                stamps >= 10
                    ? '쿠폰 발급 완료!'
                    : '${10 - stamps}번 더 결제 시 쿠폰 발급',
                style: tt.bodySmall,
              ),
            ],
          ),

          if (card.totalEarned > 0) ...[
            const SizedBox(height: 8),
            Text('총 ${card.totalEarned}장 발급됨', style: tt.bodySmall?.copyWith(color: cs.onSurface.withValues(alpha: 0.35))),
          ],
        ],
      ),
    );
  }
}
