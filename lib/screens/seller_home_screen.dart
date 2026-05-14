import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:image_picker/image_picker.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import '../app_theme.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import 'sales_detail_screen.dart';
import 'barcode_scanner_screen.dart';

// ──────────────────────────────────────────
// 판매자 홈 (단독 화면)
// ──────────────────────────────────────────

class SellerHomeScreen extends StatefulWidget {
  const SellerHomeScreen({super.key});
  @override
  State<SellerHomeScreen> createState() => _SellerHomeScreenState();
}

class _SellerHomeScreenState extends State<SellerHomeScreen> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(color: cs.onSurface.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(12)),
                      child: Icon(Icons.arrow_back, color: cs.onSurface, size: 20),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Image.asset(isDark ? 'assets/images/logo.png' : 'assets/images/logo2.png', width: 40, height: 40),
                  const SizedBox(width: 8),
                  Text('편의점 A 판매자', style: tt.titleSmall),
                  const Spacer(),
                ],
              ),
            ),
            const SizedBox(height: 4),
            _buildTabs(context),
            const SizedBox(height: 4),
            Expanded(
              child: IndexedStack(
                index: _selectedTab,
                children: [DashboardTab(onInventoryTap: () => setState(() => _selectedTab = 1)), const InventoryTab(), const QrTab()],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabs(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;
    final tabs = [Icons.grid_view_rounded, Icons.inventory_2_outlined, Icons.qr_code_rounded];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: cs.onSurface.withValues(alpha: isDark ? 0.1 : 0.06),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: List.generate(tabs.length, (i) {
            final selected = _selectedTab == i;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedTab = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: selected ? cs.surface : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: selected ? Border.all(color: cs.outline) : null,
                  ),
                  child: Icon(
                    tabs[i],
                    color: selected ? KColors.primary : cs.onSurface.withValues(alpha: 0.4),
                    size: 22,
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────
// 판매자 탭바 (MainScreen에서 재사용)
// ──────────────────────────────────────────

class SellerTabBody extends StatefulWidget {
  final int? storeId;
  const SellerTabBody({super.key, this.storeId});
  @override
  State<SellerTabBody> createState() => _SellerTabBodyState();
}

class _SellerTabBodyState extends State<SellerTabBody> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;
    final tabs = [Icons.grid_view_rounded, Icons.inventory_2_outlined, Icons.qr_code_rounded];

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: cs.onSurface.withValues(alpha: isDark ? 0.1 : 0.06),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: List.generate(tabs.length, (i) {
                final selected = _selectedTab == i;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedTab = i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: selected ? cs.surface : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: selected ? Border.all(color: cs.outline) : null,
                      ),
                      child: Icon(
                        tabs[i],
                        color: selected ? KColors.primary : cs.onSurface.withValues(alpha: 0.4),
                        size: 22,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Expanded(
          child: IndexedStack(
            index: _selectedTab,
            children: [DashboardTab(onInventoryTap: () => setState(() => _selectedTab = 1), storeId: widget.storeId), InventoryTab(storeId: widget.storeId), const QrTab()],
          ),
        ),
      ],
    );
  }
}

// ──────────────────────────────────────────
// 대시보드 탭
// ──────────────────────────────────────────

class DashboardTab extends StatefulWidget {
  final VoidCallback? onInventoryTap;
  final int? storeId;
  const DashboardTab({super.key, this.onInventoryTap, this.storeId});

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  List<ProductItem> _lowStockProducts = [];
  SalesSummary? _salesSummary;
  List<RecentPayment> _recentPayments = [];
  List<TopProduct> _topProducts = [];

  @override
  void initState() {
    super.initState();
    _fetchAll();
  }

  @override
  void didUpdateWidget(DashboardTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.storeId != widget.storeId) _fetchAll();
  }

  Future<void> _fetchAll() async {
    if (widget.storeId == null) return;
    final token = await AuthService.getToken();
    if (token == null) return;
    final results = await Future.wait([
      ApiService.getProducts(token: token, storeId: widget.storeId!),
      ApiService.getSalesSummary(token: token, storeId: widget.storeId!),
      ApiService.getRecentPayments(token: token, storeId: widget.storeId!),
      ApiService.getTopProducts(token: token, storeId: widget.storeId!),
    ]);
    if (mounted) {
      setState(() {
        _lowStockProducts = (results[0] as List<ProductItem>)
            .where((p) => p.lowStock)
            .toList();
        _salesSummary = results[1] as SalesSummary?;
        _recentPayments = results[2] as List<RecentPayment>;
        _topProducts = results[3] as List<TopProduct>;
      });
    }
  }

  Widget _buildChangeBadge(SalesSummary s) {
    final String text;
    final IconData icon;
    if (s.yesterdayAmount == 0 && s.todayAmount > 0) {
      text = '오늘 첫 매출';
      icon = Icons.star_rounded;
    } else if (s.yesterdayAmount == 0 && s.todayAmount == 0) {
      return const SizedBox.shrink();
    } else if (s.changePercent == 0) {
      text = '전일과 동일';
      icon = Icons.trending_flat_rounded;
    } else {
      text = '전일 대비 ${s.changePercent.abs()}% ${s.changePercent > 0 ? '상승' : '하락'}';
      icon = s.changePercent > 0 ? Icons.trending_up_rounded : Icons.trending_down_rounded;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 14),
          const SizedBox(width: 4),
          Text(text, style: TextStyle(fontFamily: 'Pretendard', color: Colors.white.withValues(alpha: 0.9), fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  String _formatAmount(int amount) {
    return amount.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: Column(
        children: [
          // 매출 카드
          Builder(
            builder: (ctx) => GestureDetector(
              onTap: () => Navigator.push(ctx, MaterialPageRoute(builder: (_) => SalesDetailScreen(storeId: widget.storeId))),
              child: Container(
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
                    Text('오늘의 매출', style: TextStyle(fontFamily: 'Pretendard', color: Colors.white.withValues(alpha: 0.85), fontSize: 13, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    Text(
                      _salesSummary == null ? '- 원' : '${_formatAmount(_salesSummary!.todayAmount)}원',
                      style: const TextStyle(fontFamily: 'Pretendard', color: Colors.white, fontSize: 34, fontWeight: FontWeight.w900, letterSpacing: -1.5),
                    ),
                    const SizedBox(height: 12),
                    if (_salesSummary != null) _buildChangeBadge(_salesSummary!),
                    const SizedBox(height: 4),
                    Align(alignment: Alignment.centerRight, child: Icon(Icons.arrow_forward_rounded, color: Colors.white.withValues(alpha: 0.6), size: 16)),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // 최근 결제 내역
          Container(
            width: double.infinity,
            decoration: BoxDecoration(color: cs.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: cs.outline)),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
                  child: Row(
                    children: [
                      Text('최근 결제 내역', style: tt.titleSmall),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SalesDetailScreen(storeId: widget.storeId))),
                        child: Icon(Icons.chevron_right, color: cs.onSurface.withValues(alpha: 0.3), size: 20),
                      ),
                    ],
                  ),
                ),
                Divider(height: 1, color: cs.outline),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Row(
                    children: [
                      Expanded(flex: 2, child: TableHeader('시간')),
                      Expanded(flex: 3, child: TableHeader('결제자')),
                      Expanded(flex: 3, child: TableHeader('수단')),
                      Expanded(flex: 3, child: TableHeader('내역')),
                    ],
                  ),
                ),
                if (_recentPayments.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Center(child: Text('결제 내역이 없어요', style: tt.bodySmall)),
                  )
                else
                  ..._recentPayments.map((p) => Column(
                    children: [
                      Divider(height: 1, color: cs.outline, indent: 20, endIndent: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        child: Row(
                          children: [
                            Expanded(flex: 2, child: Text(p.time, style: tt.bodySmall)),
                            Expanded(flex: 3, child: Text(p.buyerName, style: tt.labelLarge)),
                            Expanded(flex: 4, child: Text(p.itemSummary, style: tt.bodySmall, overflow: TextOverflow.ellipsis)),
                          ],
                        ),
                      ),
                    ],
                  )),
                const SizedBox(height: 4),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // TOP 5
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: cs.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: cs.outline)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.trending_up_rounded, color: KColors.primary, size: 18),
                    const SizedBox(width: 6),
                    Text('판매량 TOP 5', style: tt.titleSmall),
                  ],
                ),
                const SizedBox(height: 16),
                if (_topProducts.isEmpty)
                  Center(child: Text('판매 데이터가 없어요', style: tt.bodySmall))
                else
                  ..._topProducts.map((p) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Container(
                          width: 28, height: 28,
                          decoration: BoxDecoration(
                            color: p.rank <= 3 ? KColors.primary : cs.onSurface.withValues(alpha: 0.08),
                            shape: BoxShape.circle,
                          ),
                          child: Center(child: Text('${p.rank}', style: TextStyle(fontFamily: 'Pretendard', color: p.rank <= 3 ? Colors.white : cs.onSurface.withValues(alpha: 0.5), fontSize: 12, fontWeight: FontWeight.w700))),
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: Text(p.productName, style: tt.labelLarge)),
                        Text('${p.totalCount}개', style: const TextStyle(fontFamily: 'Pretendard', color: KColors.primary, fontSize: 13, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  )),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 재고 부족
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: Color(0xFFEF4444), size: 18),
                    const SizedBox(width: 6),
                    Text('재고 부족 알림', style: tt.titleSmall),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: const Color(0xFFEF4444).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                      child: Text('${_lowStockProducts.length}개', style: const TextStyle(fontFamily: 'Pretendard', color: Color(0xFFEF4444), fontSize: 11, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                if (_lowStockProducts.isEmpty)
                  Center(child: Text('재고 부족 상품이 없어요', style: tt.bodySmall))
                else
                  ..._lowStockProducts.map((p) => GestureDetector(
                    onTap: widget.onInventoryTap,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444).withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(p.name, style: tt.labelLarge),
                                const SizedBox(height: 2),
                                Text('바코드: ${p.barcode}', style: tt.bodySmall),
                              ],
                            ),
                          ),
                          PulseBadge(label: '${p.stock}개 남음', small: true),
                        ],
                      ),
                    ),
                  )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────
// 재고 관리 탭
// ──────────────────────────────────────────

class InventoryTab extends StatefulWidget {
  final int? storeId;
  const InventoryTab({super.key, this.storeId});
  @override
  State<InventoryTab> createState() => _InventoryTabState();
}

class _InventoryTabState extends State<InventoryTab> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<ProductItem> _products = [];
  bool _isLoading = false;

  final List<String> _categories = ['음료', '식품', '간식', '기타'];

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  @override
  void didUpdateWidget(InventoryTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.storeId != widget.storeId) _fetchProducts();
  }

  Future<void> _saveProduct(ProductItem? existing, Map<String, dynamic> data,
      {String? imagePath}) async {
    if (widget.storeId == null) return;
    final token = await AuthService.getToken();
    if (token == null) return;
    ProductItem? saved;
    if (existing != null) {
      saved = await ApiService.updateProduct(
          token: token, storeId: widget.storeId!, productId: existing.id, data: data);
    } else {
      saved = await ApiService.createProduct(
          token: token, storeId: widget.storeId!, data: data);
    }
    if (imagePath != null && saved != null) {
      await ApiService.uploadProductImage(
          token: token,
          storeId: widget.storeId!,
          productId: saved.id,
          imagePath: imagePath);
    }
    _fetchProducts();
  }

  Future<void> _deleteProductById(int productId) async {
    if (widget.storeId == null) return;
    final token = await AuthService.getToken();
    if (token == null) return;
    await ApiService.deleteProduct(token: token, storeId: widget.storeId!, productId: productId);
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    if (widget.storeId == null) return;
    setState(() => _isLoading = true);
    final token = await AuthService.getToken();
    if (token != null) {
      final items = await ApiService.getProducts(
          token: token, storeId: widget.storeId!);
      setState(() => _products = items);
    }
    setState(() => _isLoading = false);
  }

  List<ProductItem> get _filtered {
    if (_searchQuery.isEmpty) return _products;
    return _products.where((p) =>
      p.name.contains(_searchQuery) ||
      p.barcode.contains(_searchQuery)
    ).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showProductDialog({ProductItem? product, String? scannedBarcode}) {
    final isEdit = product != null;
    final nameCtrl = TextEditingController(text: isEdit ? product.name : '');
    final barcodeCtrl = TextEditingController(text: isEdit ? product.barcode : (scannedBarcode ?? ''));
    final priceCtrl = TextEditingController(text: isEdit ? product.price.toString() : '');
    final stockCtrl = TextEditingController(text: isEdit ? product.stock.toString() : '');
    String selectedCategory = isEdit ? product.category : '음료';
    XFile? selectedImage;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          final cs = Theme.of(ctx).colorScheme;
          final tt = Theme.of(ctx).textTheme;
          return Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
            child: Container(
              decoration: BoxDecoration(color: cs.surface, borderRadius: BorderRadius.circular(20)),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Text(isEdit ? '제품 수정' : '제품 추가', style: tt.titleMedium),
                        const Spacer(),
                        GestureDetector(
                          onTap: () => Navigator.pop(ctx),
                          child: Icon(Icons.close, color: cs.onSurface.withValues(alpha: 0.4), size: 22),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // 상품 이미지
                    Center(
                      child: GestureDetector(
                        onTap: () async {
                          final source = await showModalBottomSheet<ImageSource>(
                            context: ctx,
                            backgroundColor: Colors.transparent,
                            builder: (_) => _ImageSourceSheet(),
                          );
                          if (source == null) return;
                          final picker = ImagePicker();
                          final img = await picker.pickImage(
                              source: source, imageQuality: 80);
                          if (img != null) {
                            setDialogState(() => selectedImage = img);
                          }
                        },
                        child: Container(
                          width: 100, height: 100,
                          decoration: BoxDecoration(
                            color: cs.onSurface.withValues(alpha: 0.06),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: selectedImage != null
                                ? KColors.primary : cs.outline),
                            image: selectedImage != null
                                ? DecorationImage(
                                    image: FileImage(File(selectedImage!.path)),
                                    fit: BoxFit.cover)
                                : (isEdit && product.imageUrl != null
                                    ? DecorationImage(
                                        image: NetworkImage(product.imageUrl!),
                                        fit: BoxFit.cover)
                                    : null),
                          ),
                          child: selectedImage == null && !(isEdit && product.imageUrl != null)
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add_photo_alternate_outlined,
                                        color: cs.onSurface.withValues(alpha: 0.3), size: 28),
                                    const SizedBox(height: 4),
                                    Text('사진 추가', style: TextStyle(
                                        fontFamily: 'Pretendard',
                                        color: cs.onSurface.withValues(alpha: 0.4),
                                        fontSize: 11)),
                                  ],
                                )
                              : null,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _field(ctx, '제품명', nameCtrl, '제품명 입력'),
                    const SizedBox(height: 14),
                    Text('바코드', style: tt.labelLarge),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: barcodeCtrl,
                            keyboardType: TextInputType.number,
                            style: tt.bodyLarge,
                            decoration: InputDecoration(hintText: '바코드 번호 입력'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () async {
                            final result = await Navigator.push<String>(
                              ctx,
                              MaterialPageRoute(builder: (_) => const BarcodeScannerScreen(title: '재고 바코드 스캔')),
                            );
                            if (result != null) {
                              barcodeCtrl.text = result;
                              setDialogState(() {});
                            }
                          },
                          child: Container(
                            width: 48, height: 48,
                            decoration: BoxDecoration(color: KColors.navy, borderRadius: BorderRadius.circular(12)),
                            child: const Icon(Icons.camera_alt_outlined, color: Colors.white, size: 22),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _field(ctx, '가격 (원)', priceCtrl, '판매 가격 입력', keyboardType: TextInputType.number),
                    const SizedBox(height: 14),
                    _field(ctx, '재고 수량', stockCtrl, '재고 수량 입력', keyboardType: TextInputType.number),
                    const SizedBox(height: 14),
                    Text('카테고리', style: tt.labelLarge),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _categories.map((cat) {
                        final selected = selectedCategory == cat;
                        return GestureDetector(
                          onTap: () => setDialogState(() => selectedCategory = cat),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: selected ? KColors.primary : cs.onSurface.withValues(alpha: 0.06),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: selected ? KColors.primary : cs.outline),
                            ),
                            child: Text(cat, style: TextStyle(fontFamily: 'Pretendard', color: selected ? Colors.white : cs.onSurface.withValues(alpha: 0.6), fontSize: 13, fontWeight: FontWeight.w600)),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          if (nameCtrl.text.isEmpty || barcodeCtrl.text.isEmpty || priceCtrl.text.isEmpty || stockCtrl.text.isEmpty) return;
                          final data = {
                            'name': nameCtrl.text,
                            'barcode': barcodeCtrl.text,
                            'category': selectedCategory,
                            'price': int.tryParse(priceCtrl.text) ?? 0,
                            'stock': int.tryParse(stockCtrl.text) ?? 0,
                          };
                          Navigator.pop(ctx);
                          _saveProduct(isEdit ? product : null, data,
                              imagePath: selectedImage?.path);
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: KColors.primary, foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                        child: Text(isEdit ? '수정 완료' : '제품 추가', style: const TextStyle(fontFamily: 'Pretendard', fontSize: 15, fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _field(BuildContext context, String label, TextEditingController ctrl, String hint, {TextInputType keyboardType = TextInputType.text}) {
    final tt = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: tt.labelLarge),
        const SizedBox(height: 6),
        TextField(controller: ctrl, keyboardType: keyboardType, style: tt.bodyLarge, decoration: InputDecoration(hintText: hint)),
      ],
    );
  }

  void _showDeleteDialog(ProductItem product) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 40),
        child: Builder(
          builder: (ctx) {
            final cs = Theme.of(ctx).colorScheme;
            final tt = Theme.of(ctx).textTheme;
            return Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: cs.surface, borderRadius: BorderRadius.circular(20)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 52, height: 52,
                    decoration: BoxDecoration(color: const Color(0xFFEF4444).withValues(alpha: 0.1), shape: BoxShape.circle),
                    child: const Icon(Icons.delete_outline, color: Color(0xFFEF4444), size: 26),
                  ),
                  const SizedBox(height: 16),
                  Text('제품 삭제', style: tt.titleMedium),
                  const SizedBox(height: 8),
                  Text('${product.name}을(를)\n정말 삭제하시겠어요?', style: tt.bodyMedium?.copyWith(height: 1.5), textAlign: TextAlign.center),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 46,
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(ctx),
                            style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                            child: const Text('취소', style: TextStyle(fontFamily: 'Pretendard', fontSize: 14, fontWeight: FontWeight.w700)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: SizedBox(
                          height: 46,
                          child: ElevatedButton(
                            onPressed: () { Navigator.pop(ctx); _deleteProductById(product.id); },
                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444), foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                            child: const Text('삭제', style: TextStyle(fontFamily: 'Pretendard', fontSize: 14, fontWeight: FontWeight.w700)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Column(
            children: [
              // 검색바 (구매자와 동일한 애니메이션)
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 46,
                decoration: BoxDecoration(
                  color: isDark
                      ? cs.onSurface.withValues(alpha: _searchQuery.isNotEmpty ? 0.12 : 0.07)
                      : _searchQuery.isNotEmpty ? Colors.white : const Color(0xFFF5F5F3),
                  borderRadius: BorderRadius.circular(_searchQuery.isNotEmpty ? 12 : 18),
                  border: Border.all(
                    color: _searchQuery.isNotEmpty
                        ? KColors.primary
                        : isDark ? cs.onSurface.withValues(alpha: 0.12) : const Color(0xFFDDDEDB),
                    width: _searchQuery.isNotEmpty ? 1.5 : 1,
                  ),
                  boxShadow: _searchQuery.isNotEmpty && !isDark
                      ? [BoxShadow(color: KColors.primary.withValues(alpha: 0.12), blurRadius: 12, offset: const Offset(0, 3))]
                      : null,
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (v) => setState(() => _searchQuery = v),
                  style: tt.bodyLarge,
                  decoration: InputDecoration(
                    hintText: '제품명 또는 바코드 검색',
                    hintStyle: TextStyle(fontFamily: 'Pretendard', color: cs.onSurface.withValues(alpha: 0.3), fontSize: 14),
                    prefixIcon: Icon(
                      Icons.search,
                      color: _searchQuery.isNotEmpty ? KColors.primary : cs.onSurface.withValues(alpha: 0.35),
                      size: 20,
                    ),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? GestureDetector(
                            onTap: () => setState(() {
                              _searchQuery = '';
                              _searchController.clear();
                            }),
                            child: Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: Icon(Icons.cancel_rounded, color: cs.onSurface.withValues(alpha: 0.3), size: 18),
                            ),
                          )
                        : null,
                    suffixIconConstraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(_searchQuery.isNotEmpty ? 12 : 18), borderSide: BorderSide.none),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(_searchQuery.isNotEmpty ? 12 : 18), borderSide: BorderSide.none),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(_searchQuery.isNotEmpty ? 12 : 18), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // 액션 버튼
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 46,
                      child: ElevatedButton.icon(
                        onPressed: () => _showProductDialog(),
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('추가', style: TextStyle(fontFamily: 'Pretendard', fontSize: 14, fontWeight: FontWeight.w700)),
                        style: ElevatedButton.styleFrom(backgroundColor: KColors.primary, foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SizedBox(
                      height: 46,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final result = await Navigator.push<String>(context, MaterialPageRoute(builder: (_) => const BarcodeScannerScreen(title: '재고 바코드 스캔')));
                          if (result != null) {
                            final exists = _products.any((p) => p.barcode == result);
                            if (exists) {
                              setState(() => _searchQuery = result);
                              _searchController.text = result;
                            } else {
                              setState(() { _searchQuery = ''; _searchController.clear(); });
                              _showProductDialog(scannedBarcode: result);
                            }
                          }
                        },
                        icon: const Icon(Icons.camera_alt_outlined, size: 18),
                        label: const Text('스캔', style: TextStyle(fontFamily: 'Pretendard', fontSize: 14, fontWeight: FontWeight.w700)),
                        style: ElevatedButton.styleFrom(backgroundColor: KColors.navy, foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
            itemCount: _filtered.length,
            separatorBuilder: (_, _i) => const SizedBox(height: 10),
            itemBuilder: (_, i) {
              final product = _filtered[i];
              final bool lowStock = product.lowStock;
              return Container(
                decoration: BoxDecoration(
                  color: cs.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: lowStock ? const Color(0xFFEF4444).withValues(alpha: 0.5) : cs.outline),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 72, height: 72,
                        decoration: BoxDecoration(
                          color: cs.onSurface.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(12),
                          image: product.imageUrl != null
                              ? DecorationImage(
                                  image: NetworkImage(product.imageUrl!),
                                  fit: BoxFit.cover)
                              : null,
                        ),
                        child: product.imageUrl == null
                            ? Icon(Icons.image_outlined, color: cs.onSurface.withValues(alpha: 0.2), size: 28)
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                              decoration: BoxDecoration(color: cs.onSurface.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(6)),
                              child: Text(product.category, style: TextStyle(fontFamily: 'Pretendard', color: cs.onSurface.withValues(alpha: 0.5), fontSize: 11, fontWeight: FontWeight.w500)),
                            ),
                            const SizedBox(height: 5),
                            Text(product.name, style: tt.titleSmall),
                            const SizedBox(height: 2),
                            Text(product.barcode, style: tt.bodySmall),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Text('${product.price}원', style: const TextStyle(fontFamily: 'Pretendard', color: KColors.primary, fontSize: 15, fontWeight: FontWeight.w700)),
                                const SizedBox(width: 8),
                                Text(
                                  '재고 ${product.stock}개',
                                  style: TextStyle(fontFamily: 'Pretendard', color: lowStock ? const Color(0xFFEF4444) : cs.onSurface.withValues(alpha: 0.5), fontSize: 12, fontWeight: lowStock ? FontWeight.w700 : FontWeight.w400),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          GestureDetector(
                            onTap: () => _showProductDialog(product: product),
                            child: Container(
                              width: 32, height: 32,
                              decoration: BoxDecoration(color: cs.onSurface.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(8)),
                              child: Icon(Icons.edit_outlined, color: cs.onSurface.withValues(alpha: 0.5), size: 16),
                            ),
                          ),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: () => _showDeleteDialog(product),
                            child: Container(
                              width: 32, height: 32,
                              decoration: BoxDecoration(color: const Color(0xFFEF4444).withValues(alpha: 0.08), borderRadius: BorderRadius.circular(8)),
                              child: const Icon(Icons.delete_outline, color: Color(0xFFEF4444), size: 16),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ──────────────────────────────────────────
// QR 탭
// ──────────────────────────────────────────

class QrTab extends StatefulWidget {
  const QrTab({super.key});

  @override
  State<QrTab> createState() => _QrTabState();
}

class _QrTabState extends State<QrTab> {
  String _storeName = '내 매장';
  int? _storeId;
  final GlobalKey _qrKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _loadStoreInfo();
  }

  Future<void> _loadStoreInfo() async {
    final name = await AuthService.getStoreName();
    final id = await AuthService.getStoreId();
    if (mounted) setState(() {
      _storeName = name ?? '내 매장';
      _storeId = id;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        Expanded(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 타이틀
                  Text('입장 QR 코드', style: tt.titleLarge),
                  const SizedBox(height: 6),
                  Text('구매자가 이 코드를 스캔하면 매장에 입장해요', style: tt.bodySmall, textAlign: TextAlign.center),

                  const SizedBox(height: 32),

                  // QR 카드
                  RepaintBoundary(
                    key: _qrKey,
                    child: Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(color: KColors.navy.withValues(alpha: isDark ? 0.4 : 0.12), blurRadius: 32, offset: const Offset(0, 12)),
                        BoxShadow(color: KColors.primary.withValues(alpha: 0.06), blurRadius: 16, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: Column(
                      children: [
                        // 매장명
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8, height: 8,
                              decoration: const BoxDecoration(color: KColors.primary, shape: BoxShape.circle),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _storeName,
                              style: const TextStyle(fontFamily: 'Pretendard', color: KColors.navy, fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: -0.3),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // QR 이미지
                        QrImageView(
                          data: 'kiopass://store?name=$_storeName&id=$_storeId',
                          version: QrVersions.auto,
                          size: 220,
                          backgroundColor: Colors.white,
                          eyeStyle: const QrEyeStyle(
                            eyeShape: QrEyeShape.square,
                            color: KColors.navy,
                          ),
                          dataModuleStyle: const QrDataModuleStyle(
                            dataModuleShape: QrDataModuleShape.square,
                            color: KColors.navy,
                          ),
                        ),

                        const SizedBox(height: 20),

                        // 하단 URL 표시
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F5F3),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            'kiopass://store?name=$_storeName&id=$_storeId',
                            style: const TextStyle(fontFamily: 'Pretendard', color: Color(0xFF8B95A1), fontSize: 11, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  ),
                  ), // RepaintBoundary

                  const SizedBox(height: 32),

                  // 버튼들
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 52,
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              try {
                                final boundary = _qrKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
                                if (boundary == null) return;
                                final image = await boundary.toImage(pixelRatio: 3.0);
                                final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
                                if (byteData == null) return;
                                final result = await ImageGallerySaverPlus.saveImage(byteData.buffer.asUint8List(), name: 'kiopass_qr_$_storeName');
                                if (!mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Row(children: [const Icon(Icons.check_circle_rounded, color: Colors.white, size: 16), const SizedBox(width: 8), const Text('갤러리에 저장됐어요', style: TextStyle(fontFamily: 'Pretendard'))]),
                                    backgroundColor: KColors.navy,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                );
                              } catch (e) {
                                if (!mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('저장에 실패했어요', style: TextStyle(fontFamily: 'Pretendard')), behavior: SnackBarBehavior.floating),
                                );
                              }
                            },
                            icon: Icon(Icons.download_rounded, size: 18, color: cs.onSurface),
                            label: Text('저장', style: TextStyle(fontFamily: 'Pretendard', fontSize: 14, fontWeight: FontWeight.w700, color: cs.onSurface)),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: cs.onSurface.withValues(alpha: 0.2), width: 1),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: SizedBox(
                          height: 52,
                          child: ElevatedButton.icon(
                            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('인쇄 요청이 완료됐어요', style: TextStyle(fontFamily: 'Pretendard')), backgroundColor: KColors.primary, behavior: SnackBarBehavior.floating),
                            ),
                            icon: const Icon(Icons.print_rounded, size: 18),
                            label: const Text('탁상용 스티커 인쇄', style: TextStyle(fontFamily: 'Pretendard', fontSize: 14, fontWeight: FontWeight.w700)),
                            style: ElevatedButton.styleFrom(backgroundColor: KColors.primary, foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

}



class _ImageSourceSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      decoration: BoxDecoration(color: cs.surface, borderRadius: BorderRadius.circular(20)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 36, height: 4,
            decoration: BoxDecoration(color: cs.onSurface.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(999)),
          ),
          const SizedBox(height: 8),
          ListTile(
            leading: Container(
              width: 40, height: 40,
              decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.camera_alt_rounded, color: Color(0xFF3182F6), size: 20),
            ),
            title: Text('카메라로 촬영', style: tt.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
            onTap: () => Navigator.pop(context, ImageSource.camera),
          ),
          ListTile(
            leading: Container(
              width: 40, height: 40,
              decoration: BoxDecoration(color: const Color(0xFFF0FDF4), borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.photo_library_rounded, color: Color(0xFF03B26C), size: 20),
            ),
            title: Text('갤러리에서 선택', style: tt.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
            onTap: () => Navigator.pop(context, ImageSource.gallery),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: SizedBox(
              width: double.infinity, height: 48,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  backgroundColor: cs.onSurface.withValues(alpha: 0.05),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text('취소', style: TextStyle(color: cs.onSurface.withValues(alpha: 0.5), fontFamily: 'Pretendard', fontWeight: FontWeight.w600)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TableHeader extends StatelessWidget {
  final String text;
  const TableHeader(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text, style: Theme.of(context).textTheme.bodySmall);
  }
}

class PulseBadge extends StatefulWidget {
  final String label;
  final bool small;
  const PulseBadge({super.key, required this.label, this.small = false});

  @override
  State<PulseBadge> createState() => _PulseBadgeState();
}

class _PulseBadgeState extends State<PulseBadge> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..repeat(reverse: true);
    _opacity = Tween(begin: 0.5, end: 1.0).animate(_controller);
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
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: widget.small ? 4 : 6),
        decoration: BoxDecoration(
          color: const Color(0xFFEF4444).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.4)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!widget.small) ...[const Icon(Icons.warning_amber_rounded, color: Color(0xFFEF4444), size: 13), const SizedBox(width: 4)],
            Text(widget.label, style: TextStyle(fontFamily: 'Pretendard', color: const Color(0xFFEF4444), fontSize: widget.small ? 11 : 12, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}