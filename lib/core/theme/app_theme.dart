import 'package:flutter/material.dart';

/// ──────────────────────────────────────────
/// 키오패스 디자인 시스템 토큰
/// ──────────────────────────────────────────

// ── 1. 색상 ──────────────────────────────
class AppColors {
  AppColors._();

  // 메인 배경 / 기본 텍스트 (Navy)
  static const Color navy = Color(0xFF122A42);

  // 포인트 컬러 (Orange)
  static const Color orange = Color(0xFFFF6B4A);
  static const Color orangeDark = Color(0xFFFF4A22);

  // 그라데이션 (Orange)
  static const LinearGradient orangeGradient = LinearGradient(
    colors: [orange, orangeDark],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  // 경고 / 알림 (Red)
  static const Color red = Color(0xFFEF4444);
  static const Color redLight = Color(0xFFFFE4E4); // red-100

  // 무채색 (Grayscale)
  static const Color gray50  = Color(0xFFF9FAFB);
  static const Color gray100 = Color(0xFFF3F4F6);
  static const Color gray200 = Color(0xFFE5E7EB);
  static const Color gray300 = Color(0xFFD1D5DB);
  static const Color gray400 = Color(0xFF9CA3AF);
  static const Color gray500 = Color(0xFF6B7280);
  static const Color gray600 = Color(0xFF4B5563);

  // 투명도 (White/Opacity) — 오렌지 배경 위 사용
  static const Color white10 = Color(0x1AFFFFFF);
  static const Color white20 = Color(0x33FFFFFF);
  static const Color white80 = Color(0xCCFFFFFF);

  static const Color white = Colors.white;
}

// ── 2. 타이포그래피 ───────────────────────
class AppTextStyles {
  AppTextStyles._();

  // 가장 강조 (금액, 영수증 타이틀) — font-black (900)
  static const TextStyle displayBlack = TextStyle(
    fontFamily: 'Pretendard',
    fontWeight: FontWeight.w900,
    letterSpacing: -0.05 * 32, // tracking-tighter
    color: AppColors.navy,
  );

  // 카드 타이틀, 상품명, 버튼 — font-bold (700)
  static const TextStyle titleBold = TextStyle(
    fontFamily: 'Pretendard',
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
    color: AppColors.navy,
  );

  // 테이블 헤더 — font-semibold (600)
  static const TextStyle semiBold = TextStyle(
    fontFamily: 'Pretendard',
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    color: AppColors.navy,
  );

  // 서브 텍스트, 뱃지 — font-medium (500)
  static const TextStyle medium = TextStyle(
    fontFamily: 'Pretendard',
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
    color: AppColors.gray500,
  );

  // 금액 전용 (자간 좁게) — tracking-tighter
  static TextStyle amountStyle({
    double fontSize = 32,
    Color color = AppColors.navy,
  }) {
    return TextStyle(
      fontFamily: 'Pretendard',
      fontWeight: FontWeight.w900,
      fontSize: fontSize,
      letterSpacing: fontSize * -0.05,
      color: color,
    );
  }
}

// ── 3. Border Radius ─────────────────────
class AppRadius {
  AppRadius._();

  static const double sm   = 8;   // rounded-lg  — 뱃지, 서브 버튼
  static const double md   = 12;  // rounded-xl  — 카드, 인풋, 주요 버튼
  static const double lg   = 16;  // rounded-2xl — 모달, 탭 컨테이너
  static const double full = 9999; // rounded-full — 아이콘 버튼, 원형 뱃지

  static const BorderRadius smAll   = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius mdAll   = BorderRadius.all(Radius.circular(md));
  static const BorderRadius lgAll   = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius fullAll = BorderRadius.all(Radius.circular(full));
}

// ── 4. 그림자 ─────────────────────────────
class AppShadows {
  AppShadows._();

  // shadow-sm — 일반 카드
  static const List<BoxShadow> sm = [
    BoxShadow(
      color: Color(0x0D000000),
      blurRadius: 4,
      offset: Offset(0, 1),
    ),
  ];

  // shadow-lg — 강조 카드 (오늘의 매출 등)
  static const List<BoxShadow> lg = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
  ];
}

// ── 5. 테두리 스타일 ─────────────────────
class AppBorders {
  AppBorders._();

  // 기본 카드 — 테두리 없음 (그림자로 대체)
  static const Border none = Border.fromBorderSide(BorderSide.none);

  // 오렌지 버튼 — 흰색 2px
  static const Border orangeButton = Border.fromBorderSide(
    BorderSide(color: AppColors.white, width: 2),
  );

  // 재고 부족 컨테이너
  static const Border stockWarning = Border.fromBorderSide(
    BorderSide(color: AppColors.red, width: 1),
  );

  // 재고 부족 연한 테두리
  static const Border stockWarningLight = Border.fromBorderSide(
    BorderSide(color: AppColors.redLight, width: 1),
  );

  // 테이블 헤더 상하 구분선
  static const Border tableHeader = Border.symmetric(
    horizontal: BorderSide(color: AppColors.gray200, width: 1),
  );
}

// ── 6. 공통 위젯 헬퍼 ────────────────────

/// 오렌지 그라데이션 배경 카드
class GradientCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;

  const GradientCard({super.key, required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.orangeGradient,
        borderRadius: AppRadius.mdAll,
        boxShadow: AppShadows.lg,
      ),
      child: child,
    );
  }
}

/// 일반 흰색 카드 (shadow-sm)
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final BorderRadius? borderRadius;

  const AppCard({super.key, required this.child, this.padding, this.borderRadius});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: borderRadius ?? AppRadius.mdAll,
        boxShadow: AppShadows.sm,
      ),
      child: child,
    );
  }
}

/// 재고 부족 경고 뱃지 (animate-pulse 효과)
class StockWarningBadge extends StatefulWidget {
  final String label;
  const StockWarningBadge({super.key, required this.label});

  @override
  State<StockWarningBadge> createState() => _StockWarningBadgeState();
}

class _StockWarningBadgeState extends State<StockWarningBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _opacity = Tween(begin: 0.4, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.redLight,
          borderRadius: AppRadius.smAll,
          border: AppBorders.stockWarning,
        ),
        child: Text(
          widget.label,
          style: AppTextStyles.medium.copyWith(
            color: AppColors.red,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}