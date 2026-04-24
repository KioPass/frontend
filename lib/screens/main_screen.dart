import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../app_theme.dart';
import 'barcode_scanner_screen.dart';
export 'barcode_scanner_screen.dart' show ScanType;
import 'buyer_home_screen.dart' as buyer;
import 'seller_home_screen.dart' as seller;
import 'my_page_screen.dart';
import '../services/auth_service.dart';
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  bool _isSeller = false;
  bool _showToggle = false;
  String? _selectedStore;
  String _userName = '';
  String _userEmail = '';
  String _storeName = '';

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    WidgetsBinding.instance.addPostFrameCallback((_) => _showStoreSelectSheet());
  }

  Future<void> _loadUserInfo() async {
    final isSeller = await AuthService.isSeller();
    final name = await AuthService.getUserName();
    final email = await AuthService.getUserEmail();
    final storeName = await AuthService.getStoreName();
    setState(() {
      _showToggle = isSeller;
      _userName = name ?? '사용자';
      _userEmail = email ?? '';
      _storeName = storeName ?? '판매자';
    });
  }

  void _handleToggle(bool toSeller) {
    if (toSeller == _isSeller) return;
    setState(() => _isSeller = toSeller);
  }

  void _showStoreSelectSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _StoreSelectSheet(
        onSelectStore: (name) {
          setState(() => _selectedStore = name);
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context, isDark),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                transitionBuilder: (child, animation) {
                  final isEntering = child.key == ValueKey(_isSeller);
                  final slideOffset = isEntering
                      ? (_isSeller ? const Offset(1, 0) : const Offset(-1, 0))
                      : (_isSeller ? const Offset(-1, 0) : const Offset(1, 0));
                  return SlideTransition(
                    position: Tween<Offset>(begin: slideOffset, end: Offset.zero).animate(animation),
                    child: FadeTransition(opacity: animation, child: child),
                  );
                },
                child: _isSeller
                    ? const seller.SellerTabBody(key: ValueKey(true))
                    : _BuyerBody(
                        key: const ValueKey(false),
                        selectedStore: _selectedStore,
                        onStoreSelect: _showStoreSelectSheet,
                        onStorePicked: (store) => setState(() => _selectedStore = store),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, bool isDark) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      color: isDark ? KColors.darkBg : KColors.lightBg,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // 로고
          Image.asset(
            isDark ? 'assets/images/logo.png' : 'assets/images/logo2.png',
            width: 44, height: 44,
            fit: BoxFit.contain,
          ),

          // 매장 선택 (구매자 + 매장 선택됨)
          if (!_isSeller && _selectedStore != null) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _showStoreSelectSheet,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: cs.onSurface.withValues(alpha: isDark ? 0.12 : 0.06),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: cs.outline),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 60,
                      child: ShaderMask(
                        shaderCallback: (bounds) => LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [cs.onSurface, cs.onSurface, cs.onSurface.withValues(alpha: 0)],
                          stops: const [0.0, 0.65, 1.0],
                        ).createShader(bounds),
                        blendMode: BlendMode.dstIn,
                        child: Text(
                          _selectedStore!,
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            color: cs.onSurface,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.clip,
                        ),
                      ),
                    ),
                    const SizedBox(width: 2),
                    Icon(Icons.keyboard_arrow_down_rounded, color: cs.onSurface.withValues(alpha: 0.5), size: 16),
                  ],
                ),
              ),
            ),
          ],

          // 판매자 이름
          if (_isSeller) ...[
            const SizedBox(width: 8),
            Text(
              '$_storeName 판매자',
              style: TextStyle(
                fontFamily: 'Pretendard',
                color: cs.onSurface.withValues(alpha: 0.7),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],

          const Spacer(),

          // 구매자/판매자 토글
          if (_showToggle) ...[
            _buildToggle(context, isDark),
            const SizedBox(width: 8),
          ],

          // 마이페이지
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => MyPageScreen(
                  userName: _userName,
                  userEmail: _userEmail,
                  userRole: _showToggle ? 'seller' : 'buyer',
                ),
              ),
            ),
            child: Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: cs.onSurface.withValues(alpha: isDark ? 0.12 : 0.06),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.person_outline_rounded, color: cs.onSurface, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggle(BuildContext context, bool isDark) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity == null) return;
        if (details.primaryVelocity! < 0) _handleToggle(true);
        if (details.primaryVelocity! > 0) _handleToggle(false);
      },
      child: Container(
        width: 136,
        height: 34,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: cs.onSurface.withValues(alpha: isDark ? 0.12 : 0.08),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: cs.outline),
        ),
        child: Stack(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              margin: EdgeInsets.only(left: _isSeller ? 64 : 0),
              width: 64,
              height: 28,
              decoration: BoxDecoration(
                color: isDark ? KColors.primary : KColors.navy,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _handleToggle(false),
                    child: Container(
                      height: 28,
                      color: Colors.transparent,
                      child: Center(
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 250),
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: _isSeller
                                ? cs.onSurface.withValues(alpha: 0.4)
                                : Colors.white,
                          ),
                          child: const Text('구매자'),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _handleToggle(true),
                    child: Container(
                      height: 28,
                      color: Colors.transparent,
                      child: Center(
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 250),
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: _isSeller
                                ? Colors.white
                                : cs.onSurface.withValues(alpha: 0.4),
                          ),
                          child: const Text('판매자'),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────
// 구매자 바디
// ──────────────────────────────────────────

class _BuyerBody extends StatelessWidget {
  final String? selectedStore;
  final VoidCallback onStoreSelect;
  final void Function(String) onStorePicked;

  const _BuyerBody({
    super.key,
    required this.selectedStore,
    required this.onStoreSelect,
    required this.onStorePicked,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    if (selectedStore == null) {
      return SizedBox.expand(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(
                    color: cs.onSurface.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Icon(Icons.qr_code_2_rounded, color: cs.onSurface.withValues(alpha: 0.3), size: 44),
                ),
                const SizedBox(height: 20),
                Text('매장을 선택해주세요', style: tt.titleLarge, textAlign: TextAlign.center),
                const SizedBox(height: 8),
                Text(
                  '상단의 매장 이름이나 아래 버튼을 눌러\n쇼핑할 매장을 선택하세요',
                  style: tt.bodyMedium?.copyWith(height: 1.6),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: onStoreSelect,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: KColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                    ),
                    child: const Text(
                      '매장 선택하기',
                      style: TextStyle(fontFamily: 'Pretendard', fontSize: 15, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return const buyer.BuyerProductGrid();
  }
}

// ──────────────────────────────────────────
// 더미 매장 데이터
// ──────────────────────────────────────────

class _StoreData {
  final String name;
  final String address;
  final double lat;
  final double lng;
  double? distanceKm;

  _StoreData({required this.name, required this.address, required this.lat, required this.lng, this.distanceKm});
}

// ──────────────────────────────────────────
// 매장 선택 바텀시트
// ──────────────────────────────────────────

class _StoreSelectSheet extends StatefulWidget {
  final void Function(String name) onSelectStore;
  const _StoreSelectSheet({required this.onSelectStore});

  @override
  State<_StoreSelectSheet> createState() => _StoreSelectSheetState();
}

class _StoreSelectSheetState extends State<_StoreSelectSheet> {
  bool _isLoading = true;
  String? _errorMessage;

  final List<_StoreData> _allStores = [
    _StoreData(name: '키오패스 편의점 강남점', address: '서울시 강남구 테헤란로 123', lat: 37.5010, lng: 127.0396),
    _StoreData(name: '키오패스 마트 선릉점', address: '서울시 강남구 선릉로 45', lat: 37.5040, lng: 127.0490),
    _StoreData(name: '키오패스 편의점 역삼점', address: '서울시 강남구 역삼로 67', lat: 37.4990, lng: 127.0310),
    _StoreData(name: '키오패스 슈퍼 삼성점', address: '서울시 강남구 삼성로 89', lat: 37.5090, lng: 127.0610),
    _StoreData(name: '키오패스 편의점 잠실점', address: '서울시 송파구 올림픽로 300', lat: 37.5140, lng: 127.1000),
    _StoreData(name: '키오패스 마트 홍대점', address: '서울시 마포구 홍익로 20', lat: 37.5570, lng: 126.9240),
  ];

  List<_StoreData> _nearbyStores = [];

  @override
  void initState() {
    super.initState();
    _loadNearbyStores();
  }

  Future<void> _loadNearbyStores() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() { _errorMessage = '위치 권한이 필요합니다'; _isLoading = false; });
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        setState(() { _errorMessage = '설정에서 위치 권한을 허용해주세요'; _isLoading = false; });
        return;
      }
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
      for (final store in _allStores) {
        store.distanceKm = Geolocator.distanceBetween(
          position.latitude, position.longitude, store.lat, store.lng,
        ) / 1000;
      }
      final nearby = _allStores.where((s) => s.distanceKm! <= 5.0).toList()
        ..sort((a, b) => a.distanceKm!.compareTo(b.distanceKm!));
      setState(() { _nearbyStores = nearby; _isLoading = false; });
    } catch (e) {
      setState(() { _errorMessage = '위치를 가져올 수 없습니다'; _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 헤더
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Row(
              children: [
                Icon(Icons.location_on_rounded, color: KColors.primary, size: 22),
                const SizedBox(width: 8),
                Text('주변 매장', style: tt.titleMedium),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Icon(Icons.close, color: cs.onSurface.withValues(alpha: 0.4), size: 22),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 6, 20, 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('현재 위치 기준 5km 이내 매장이에요', style: tt.bodySmall),
            ),
          ),
          Divider(height: 1, color: cs.outline),

          // 컨텐츠
          if (_isLoading)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Column(
                children: [
                  CircularProgressIndicator(color: KColors.primary),
                  const SizedBox(height: 12),
                  Text('주변 매장을 찾는 중...', style: tt.bodySmall),
                ],
              ),
            )
          else if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Column(
                children: [
                  Icon(Icons.location_off_outlined, color: cs.onSurface.withValues(alpha: 0.3), size: 48),
                  const SizedBox(height: 12),
                  Text(_errorMessage!, style: tt.bodyMedium),
                ],
              ),
            )
          else if (_nearbyStores.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Column(
                children: [
                  Icon(Icons.store_outlined, color: cs.onSurface.withValues(alpha: 0.3), size: 48),
                  const SizedBox(height: 12),
                  Text('주변 5km 이내에 매장이 없어요', style: tt.bodyMedium),
                ],
              ),
            )
          else
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.4),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: _nearbyStores.length,
                separatorBuilder: (_, _i) => Divider(height: 1, color: cs.outline, indent: 20, endIndent: 20),
                itemBuilder: (_, i) {
                  final store = _nearbyStores[i];
                  final dist = store.distanceKm! < 1
                      ? '${(store.distanceKm! * 1000).toInt()}m'
                      : '${store.distanceKm!.toStringAsFixed(1)}km';
                  return InkWell(
                    onTap: () => widget.onSelectStore(store.name),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      child: Row(
                        children: [
                          Container(
                            width: 40, height: 40,
                            decoration: BoxDecoration(
                              color: cs.onSurface.withValues(alpha: 0.06),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(Icons.store_rounded, color: cs.onSurface.withValues(alpha: 0.4), size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(store.name, style: tt.titleSmall),
                                const SizedBox(height: 2),
                                Text(store.address, style: tt.bodySmall, overflow: TextOverflow.ellipsis),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: KColors.primary.withValues(alpha: isDark ? 0.2 : 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              dist,
                              style: const TextStyle(
                                fontFamily: 'Pretendard',
                                color: KColors.primary,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

          // QR 찍기 버튼
          Divider(height: 1, color: cs.outline),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final result = await Navigator.push<String>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const BarcodeScannerScreen(
                        scanType: ScanType.qr,
                        title: '매장 QR 스캔',
                      ),
                    ),
                  );
                  if (result != null && mounted) {
                    String storeName = result;
                    if (result.contains('kiopass://store?name=')) {
                      storeName = result.replaceAll('kiopass://store?name=', '');
                    }
                    widget.onSelectStore(storeName);
                  }
                },
                icon: const Icon(Icons.qr_code_scanner_rounded, size: 18),
                label: const Text('매장 QR 찍기', style: TextStyle(fontFamily: 'Pretendard', fontSize: 15, fontWeight: FontWeight.w700)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: KColors.navy,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}