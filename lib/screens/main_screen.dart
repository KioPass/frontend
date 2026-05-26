import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../app_theme.dart';
import 'barcode_scanner_screen.dart';
export 'barcode_scanner_screen.dart' show ScanType;
import 'buyer_home_screen.dart' as buyer;
import 'seller_home_screen.dart' as seller;
import 'my_page_screen.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  bool _isSeller = false;
  bool _showToggle = false;
  String? _selectedStore;
  int? _selectedStoreId;
  String _userName = '';
  String _userEmail = '';
  String _userRole = 'BUYER';
  String _storeName = '';
  int? _myStoreId;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    // 구매자만 매장 선택 시트 표시 (판매자는 자기 매장이 있으므로 불필요)
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final isSeller = await AuthService.isSeller();
      if (!isSeller && mounted) _showStoreSelectSheet();
    });
  }

  Future<void> _loadUserInfo() async {
    final isSeller = await AuthService.isSeller();
    final name = await AuthService.getUserName();
    final email = await AuthService.getUserEmail();
    final role = await AuthService.getUserRole();
    final storeName = await AuthService.getStoreName();
    final storeId = await AuthService.getStoreId();
    setState(() {
      _showToggle = isSeller;
      _isSeller = isSeller;
      _userName = name ?? '사용자';
      _userEmail = email ?? '';
      _userRole = role ?? 'BUYER';
      _storeName = storeName ?? '판매자';
      _myStoreId = storeId;
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
        onSelectStore: (name, id) {
          setState(() {
            _selectedStore = name;
            _selectedStoreId = id;
          });
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
            Divider(height: 1, thickness: 1, color: Theme.of(context).colorScheme.outline),
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
                    ? seller.SellerTabBody(key: const ValueKey(true), storeId: _myStoreId)
                    : _BuyerBody(
                        key: const ValueKey(false),
                        selectedStore: _selectedStore,
                        selectedStoreId: _selectedStoreId,
                        onStoreSelect: _showStoreSelectSheet,
                        onStorePicked: (name, id) => setState(() {
                          _selectedStore = name;
                          _selectedStoreId = id;
                        }),
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
      color: Theme.of(context).scaffoldBackgroundColor,
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
                  userRole: _userRole,
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
  final int? selectedStoreId;
  final VoidCallback onStoreSelect;
  final void Function(String name, int? id) onStorePicked;

  const _BuyerBody({
    super.key,
    required this.selectedStore,
    this.selectedStoreId,
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
    return buyer.BuyerProductGrid(storeId: selectedStoreId, storeName: selectedStore);
  }
}

// ──────────────────────────────────────────
// 매장 선택 바텀시트
// ──────────────────────────────────────────

class _StoreSelectSheet extends StatefulWidget {
  final void Function(String name, int? id) onSelectStore;
  const _StoreSelectSheet({required this.onSelectStore});

  @override
  State<_StoreSelectSheet> createState() => _StoreSelectSheetState();
}

class _StoreSelectSheetState extends State<_StoreSelectSheet> {
  bool _isLoading = true;
  String? _errorMessage;
  List<NearbyStore> _stores = [];

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
      final token = await AuthService.getToken();
      if (token == null) {
        setState(() { _errorMessage = '로그인이 필요합니다'; _isLoading = false; });
        return;
      }
      final stores = await ApiService.getNearbyStores(
        token: token,
        latitude: position.latitude,
        longitude: position.longitude,
      );
      setState(() { _stores = stores; _isLoading = false; });
    } catch (e) {
      setState(() { _errorMessage = '위치를 가져올 수 없습니다'; _isLoading = false; });
    }
  }

  Future<void> _openQrScanner() async {
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
      int? storeId;
      if (result.contains('kiopass://store?')) {
        final uri = Uri.parse(result);
        storeName = uri.queryParameters['name'] ?? result;
        final idStr = uri.queryParameters['id'];
        storeId = idStr != null ? int.tryParse(idStr) : null;
      }
      if (storeId != null) {
        final token = await AuthService.getToken();
        if (token != null && mounted) {
          final allowed = await ApiService.verifyDoorEntry(token, storeId, storeName);
          if (mounted) {
            if (allowed) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('🔓 입장이 허가됐습니다', style: TextStyle(fontFamily: 'Pretendard', fontWeight: FontWeight.w600)),
                  backgroundColor: const Color(0xFF22C55E),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  duration: const Duration(seconds: 2),
                ),
              );
            } else {
              final cs = Theme.of(context).colorScheme;
              showDialog(
                context: context,
                builder: (dialogCtx) => AlertDialog(
                  backgroundColor: cs.surface,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 8),
                      Container(
                        width: 56, height: 56,
                        decoration: BoxDecoration(color: const Color(0xFFEF4444).withValues(alpha: 0.1), shape: BoxShape.circle),
                        child: const Icon(Icons.lock_rounded, color: Color(0xFFEF4444), size: 26),
                      ),
                      const SizedBox(height: 16),
                      const Text('입장이 거절되었습니다', style: TextStyle(fontFamily: 'Pretendard', fontSize: 17, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      const Text('관리자에게 문의해주세요', style: TextStyle(fontFamily: 'Pretendard', fontSize: 14, color: Color(0xFF8B95A1))),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 46,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(dialogCtx),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFEF4444),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('확인', style: TextStyle(fontFamily: 'Pretendard', fontSize: 15, fontWeight: FontWeight.w700)),
                        ),
                      ),
                    ],
                  ),
                ),
              );
              return;
            }
          }
        }
      }
      widget.onSelectStore(storeName, storeId);
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
          else if (_stores.isEmpty)
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
                itemCount: _stores.length,
                separatorBuilder: (_, _i) => Divider(height: 1, color: cs.outline, indent: 20, endIndent: 20),
                itemBuilder: (_, i) {
                  final store = _stores[i];
                  return InkWell(
                    onTap: () => _openQrScanner(),
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
                                Text(store.storename, style: tt.titleSmall),
                                const SizedBox(height: 2),
                                Text(store.address, style: tt.bodySmall, overflow: TextOverflow.ellipsis),
                              ],
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
                onPressed: _openQrScanner,
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