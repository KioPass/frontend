import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

enum ScanType { barcode, qr }

class BarcodeScannerScreen extends StatefulWidget {
  final ScanType scanType;
  final String? title;
  final bool Function(String barcode)? onContinuousScan;
  final int Function()? getCartCount;

  const BarcodeScannerScreen({
    super.key,
    this.scanType = ScanType.barcode,
    this.title,
    this.onContinuousScan,
    this.getCartCount,
  });

  @override
  State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
  final MobileScannerController _controller = MobileScannerController();
  bool _scanned = false;
  bool _flashOn = false;
  String? _lastScannedBarcode;
  String? _lastScannedName;
  DateTime? _lastScannedTime;
  final List<Map<String, dynamic>> _scannedItems = [];

  static const _cooldown = Duration(seconds: 2);

  bool get _isContinuous => widget.onContinuousScan != null;
  int get _totalCount => _scannedItems.fold(0, (sum, item) => sum + (item['count'] as int));

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Rect _getScanWindow(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isQr = widget.scanType == ScanType.qr;
    final w = isQr ? 260.0 : 280.0;
    final h = isQr ? 260.0 : 160.0;
    final cx = size.width / 2;
    final cy = size.height / 2;
    return Rect.fromLTRB(cx - w / 2, cy - h / 2, cx + w / 2, cy + h / 2);
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_scanned) return;
    final barcode = capture.barcodes.firstOrNull?.rawValue;
    if (barcode == null) return;

    // 쿨다운 체크
    final now = DateTime.now();
    if (_lastScannedBarcode == barcode &&
        _lastScannedTime != null &&
        now.difference(_lastScannedTime!) < _cooldown) {
      return;
    }

    // scanType에 따라 필터링
    if (widget.scanType == ScanType.qr) {
      if (!barcode.startsWith('kiopass://')) return;
    } else {
      if (!RegExp(r'^\d+$').hasMatch(barcode)) return;
    }

    setState(() => _scanned = true);
    _lastScannedBarcode = barcode;
    _lastScannedTime = DateTime.now();
    HapticFeedback.mediumImpact();
    SystemSound.play(SystemSoundType.click);
    _controller.stop();

    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;

    if (_isContinuous) {
      final shouldContinue = widget.onContinuousScan!(barcode);
      if (!mounted) return;

      if (shouldContinue) {
        final existing = _scannedItems.where((i) => i['barcode'] == barcode);
        setState(() {
          if (existing.isNotEmpty) {
            existing.first['count'] = (existing.first['count'] as int) + 1;
          } else {
            _scannedItems.add({'barcode': barcode, 'count': 1});
          }
          _scanned = false;
        });
        _controller.start();
      } else {
        Navigator.pop(context);
      }
    } else {
      Navigator.pop(context, barcode);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scanWindow = _getScanWindow(context);
    final isQr = widget.scanType == ScanType.qr;
    final frameW = isQr ? 260.0 : 280.0;
    final frameH = isQr ? 260.0 : 160.0;
    final frameColor = _scanned ? Colors.green : const Color(0xFFFF6B4A);
    final cartCount = widget.getCartCount?.call() ?? _totalCount;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // 카메라
            MobileScanner(
              controller: _controller,
              onDetect: _onDetect,
              scanWindow: scanWindow,
            ),
            // 어두운 오버레이
            Container(
              decoration: ShapeDecoration(
                shape: _ScannerOverlayShape(
                  borderColor: frameColor,
                  borderWidth: 3,
                  overlayColor: Colors.black.withValues(alpha: 0.6),
                  cutOutWidth: frameW,
                  cutOutHeight: frameH,
                  borderRadius: 12,
                ),
              ),
            ),
            // 스캔 프레임
            Center(
              child: SizedBox(
                width: frameW,
                height: frameH,
                child: Stack(
                  children: [
                    _buildCorner(top: true, left: true, color: frameColor),
                    _buildCorner(top: true, left: false, color: frameColor),
                    _buildCorner(top: false, left: true, color: frameColor),
                    _buildCorner(top: false, left: false, color: frameColor),
                    if (!isQr) const _ScanLine(),
                  ],
                ),
              ),
            ),
            // 상단 앱바
            Positioned(
              top: 0, left: 0, right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.black.withValues(alpha: 0.7), Colors.transparent],
                  ),
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      widget.title ?? (isQr ? '매장 QR 스캔' : '바코드 스캔'),
                      style: const TextStyle(
                        fontFamily: 'Pretendard',
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                        _controller.toggleTorch();
                        setState(() => _flashOn = !_flashOn);
                      },
                      child: Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(
                          color: _flashOn
                              ? const Color(0xFFFF6B4A)
                              : Colors.black.withValues(alpha: 0.5),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _flashOn ? Icons.flashlight_on : Icons.flashlight_off_outlined,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // 하단 안내 텍스트
            Positioned(
              bottom: _isContinuous ? 120 : 60,
              left: 0, right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _isContinuous ? Icons.info_outline_rounded : Icons.crop_free_rounded,
                        color: Colors.white.withValues(alpha: 0.7),
                        size: 14,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _isContinuous
                            ? '스캔하면 자동으로 장바구니에 담겨요'
                            : '${isQr ? 'QR코드' : '바코드'}를 네모 안에 맞춰주세요',
                        style: const TextStyle(
                          fontFamily: 'Pretendard',
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // 연속 스캔 모드 하단
            if (_isContinuous)
              Positioned(
                bottom: 0, left: 0, right: 0,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [Colors.black.withValues(alpha: 0.85), Colors.transparent],
                    ),
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF6B4A),
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFF6B4A).withValues(alpha: 0.45),
                              blurRadius: 20,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.shopping_cart_rounded, color: Colors.white, size: 20),
                            const SizedBox(width: 10),
                            const Text(
                              '장바구니 확인',
                              style: TextStyle(
                                fontFamily: 'Pretendard',
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.3,
                              ),
                            ),
                            if (cartCount > 0) ...[
                              const SizedBox(width: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.25),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  '$cartCount개',
                                  style: const TextStyle(
                                    fontFamily: 'Pretendard',
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            // 스캔 성공 토스트
            if (_isContinuous && _lastScannedName != null)
              Positioned(
                bottom: 120, left: 24, right: 24,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, anim) => SlideTransition(
                    position: Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
                      CurvedAnimation(parent: anim, curve: Curves.easeOutCubic),
                    ),
                    child: FadeTransition(opacity: anim, child: child),
                  ),
                  child: Container(
                    key: ValueKey(_lastScannedBarcode),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1C1C1E).withValues(alpha: 0.92),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36, height: 36,
                          decoration: BoxDecoration(
                            color: const Color(0xFF34C759).withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.check_rounded, color: Color(0xFF34C759), size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _lastScannedName!,
                                style: const TextStyle(
                                  fontFamily: 'Pretendard',
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                '장바구니에 담겼어요',
                                style: TextStyle(
                                  fontFamily: 'Pretendard',
                                  color: Color(0xFF8E8E93),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF6B4A).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '×${_scannedItems.isEmpty ? 1 : _scannedItems.firstWhere((i) => i['barcode'] == _lastScannedBarcode, orElse: () => {'count': 1})['count']}',
                            style: const TextStyle(
                              fontFamily: 'Pretendard',
                              color: Color(0xFFFF6B4A),
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCorner({required bool top, required bool left, required Color color}) {
    return Positioned(
      top: top ? 0 : null,
      bottom: top ? null : 0,
      left: left ? 0 : null,
      right: left ? null : 0,
      child: Container(
        width: 24, height: 24,
        decoration: BoxDecoration(
          border: Border(
            top: top ? BorderSide(color: color, width: 3) : BorderSide.none,
            bottom: top ? BorderSide.none : BorderSide(color: color, width: 3),
            left: left ? BorderSide(color: color, width: 3) : BorderSide.none,
            right: left ? BorderSide.none : BorderSide(color: color, width: 3),
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────
// 스캔 라인 애니메이션
// ──────────────────────────────────────────

class _ScanLine extends StatefulWidget {
  const _ScanLine();

  @override
  State<_ScanLine> createState() => _ScanLineState();
}

class _ScanLineState extends State<_ScanLine> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (_, __) => Positioned(
        top: _animation.value * 150,
        left: 0, right: 0,
        child: Container(
          height: 2,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                const Color(0xFFFF6B4A).withValues(alpha: 0.8),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────
// 오버레이 쉐이프
// ──────────────────────────────────────────

class _ScannerOverlayShape extends ShapeBorder {
  final Color borderColor;
  final double borderWidth;
  final Color overlayColor;
  final double cutOutWidth;
  final double cutOutHeight;
  final double borderRadius;

  const _ScannerOverlayShape({
    required this.borderColor,
    required this.borderWidth,
    required this.overlayColor,
    required this.cutOutWidth,
    required this.cutOutHeight,
    required this.borderRadius,
  });

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) => Path();

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    final cutOut = Rect.fromCenter(
      center: rect.center,
      width: cutOutWidth,
      height: cutOutHeight,
    );
    return Path()
      ..addRect(rect)
      ..addRRect(RRect.fromRectAndRadius(cutOut, Radius.circular(borderRadius)))
      ..fillType = PathFillType.evenOdd;
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    final paint = Paint()..color = overlayColor;
    final cutOut = Rect.fromCenter(
      center: rect.center,
      width: cutOutWidth,
      height: cutOutHeight,
    );
    final path = Path()
      ..addRect(rect)
      ..addRRect(RRect.fromRectAndRadius(cutOut, Radius.circular(borderRadius)))
      ..fillType = PathFillType.evenOdd;
    canvas.drawPath(path, paint);
  }

  @override
  ShapeBorder scale(double t) => this;
}