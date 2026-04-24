import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../app_theme.dart';
import 'dart:ui';
import 'payment_complete_screen.dart';
import 'my_page_screen.dart';
import 'barcode_scanner_screen.dart';

class Product {
  final String name;
  final String price;
  final String category;
  final int priceValue;
  final String barcode;

  const Product({
    required this.name,
    required this.price,
    required this.category,
    required this.priceValue,
    this.barcode = '',
  });
}

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  int get totalPrice => product.priceValue * quantity;
}

class BuyerHomeScreen extends StatefulWidget {
  const BuyerHomeScreen({super.key});

  @override
  State<BuyerHomeScreen> createState() => _BuyerHomeScreenState();
}

class _BuyerHomeScreenState extends State<BuyerHomeScreen> {
  String? _selectedStore;
  String _searchQuery = '';
  String _selectedCategory = '전체';
  final List<CartItem> _cartItems = [];

  int get _cartCount => _cartItems.fold(0, (sum, item) => sum + item.quantity);
  int get _cartTotal => _cartItems.fold(0, (sum, item) => sum + item.totalPrice);

  final List<Map<String, String>> _stores = [
    {'name': '편의점 A', 'address': '서울시 강남구'},
    {'name': '편의점 B', 'address': '서울시 강남구'},
    {'name': '슈퍼마켓 C', 'address': '서울시 강남구'},
  ];

  final List<String> _categories = ['전체', '음료', '식품', '간식'];

  final List<Product> _products = const [
    Product(name: '코카콜라 500ml', price: '1,500원', category: '음료', priceValue: 1500, barcode: '8801234567890'),
    Product(name: '삼각김밥 참치', price: '1,200원', category: '식품', priceValue: 1200, barcode: '8801234567891'),
    Product(name: '바나나우유', price: '1,800원', category: '음료', priceValue: 1800, barcode: '8801234567892'),
    Product(name: '새우깡', price: '1,000원', category: '간식', priceValue: 1000, barcode: '8801234567893'),
    Product(name: '컵누들 매콤한맛', price: '1,500원', category: '식품', priceValue: 1500, barcode: '8801234567894'),
    Product(name: '포카칩 오리지널', price: '1,700원', category: '간식', priceValue: 1700, barcode: '8801234567895'),
    Product(name: '초코파이', price: '4,800원', category: '간식', priceValue: 4800, barcode: '8801234567896'),
    Product(name: '진라면 매운맛 (컵)', price: '1,300원', category: '식품', priceValue: 1300, barcode: '8801234567897'),
    Product(name: '펩시콜라 355ml', price: '1,400원', category: '음료', priceValue: 1400, barcode: '8801234567898'),
    Product(name: '칠성사이다 500ml', price: '1,600원', category: '음료', priceValue: 1600, barcode: '8801234567899'),
    Product(name: '제주 삼다수 500ml', price: '950원', category: '음료', priceValue: 950, barcode: '8801234567900'),
    Product(name: '11찬 도시락', price: '5,500원', category: '식품', priceValue: 5500, barcode: '8801234567901'),
  ];

  List<Product> get _filteredProducts {
    return _products.where((p) {
      final matchCategory = _selectedCategory == '전체' || p.category == _selectedCategory;
      final matchSearch = _searchQuery.isEmpty || p.name.contains(_searchQuery);
      return matchCategory && matchSearch;
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showStoreSelectSheet();
    });
  }

  void _addToCart(Product product) {
    setState(() {
      final existing = _cartItems.where((i) => i.product.name == product.name);
      if (existing.isNotEmpty) {
        existing.first.quantity++;
      } else {
        _cartItems.add(CartItem(product: product));
      }
    });
  }

  void _removeFromCart(CartItem item) {
    setState(() => _cartItems.remove(item));
  }

  void _incrementQty(CartItem item) {
    setState(() => item.quantity++);
  }

  void _decrementQty(CartItem item) {
    setState(() {
      if (item.quantity > 1) {
        item.quantity--;
      } else {
        _cartItems.remove(item);
      }
    });
  }

  void _clearCart() {
    setState(() => _cartItems.clear());
  }

  String _formatPrice(int price) {
    return '${price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}원';
  }

  void _showStoreSelectSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _StoreSelectSheet(
        stores: _stores,
        onSelectStore: (name) {
          setState(() => _selectedStore = name);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showCartDialog() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (_) => StatefulBuilder(
        builder: (context, setDialogState) {
          return _CartDialog(
            cartItems: _cartItems,
            cartTotal: _cartTotal,
            cartCount: _cartCount,
            formatPrice: _formatPrice,
            onIncrement: (item) { _incrementQty(item); setDialogState(() {}); },
            onDecrement: (item) { _decrementQty(item); setDialogState(() {}); },
            onRemove: (item) { _removeFromCart(item); setDialogState(() {}); },
            onClear: () { _clearCart(); setDialogState(() {}); },
            onCheckout: () {
              Navigator.pop(context);
              _showPaymentDialog();
            },
          );
        },
      ),
    );
  }

  void _showPaymentDialog() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (_) => StatefulBuilder(
        builder: (context, setDialogState) {
          return _PaymentDialog(
            cartCount: _cartCount,
            cartTotal: _cartTotal,
            cartItems: _cartItems.map((item) => PaymentCartItem(
              name: item.product.name,
              quantity: item.quantity,
              totalPrice: item.totalPrice,
            )).toList(),
            formatPrice: _formatPrice,
            storeName: _selectedStore ?? '',
            onClose: () => Navigator.pop(context),
            onBack: () {
              Navigator.pop(context);
              _showCartDialog();
            },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: _selectedStore == null
                  ? _buildEmptyState()
                  : _buildProductList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Image.asset('assets/images/logo.png', width: 48, height: 48, fit: BoxFit.contain),
          if (_selectedStore != null) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _showStoreSelectSheet,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.15), width: 1),
                ),
                child: Row(
                  children: [
                    Text(_selectedStore!, style: const TextStyle(fontFamily: 'Pretendard', color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                    const SizedBox(width: 4),
                    const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white, size: 16),
                  ],
                ),
              ),
            ),
          ],
          const Spacer(),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const MyPageScreen(
                  userName: '김태헌',
                  userEmail: 'hong@example.com',
                  userRole: 'buyer',
                ),
              ),
            ),
            icon: const Icon(Icons.person_outline, color: Colors.white, size: 24),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.qr_code_2_rounded, color: Colors.white.withValues(alpha: 0.3), size: 80),
          const SizedBox(height: 20),
          const Text('매장을 선택해주세요', style: TextStyle(fontFamily: 'Pretendard', color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700, letterSpacing: -0.3)),
          const SizedBox(height: 8),
          Text(
            '상단의 매장 이름이나 아래 버튼을 눌러\n쇼핑할 매장을 선택하세요',
            style: TextStyle(fontFamily: 'Pretendard', color: Colors.white.withValues(alpha: 0.5), fontSize: 13, height: 1.6, letterSpacing: -0.1),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: _showStoreSelectSheet,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B4A),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                padding: const EdgeInsets.symmetric(horizontal: 32),
              ),
              child: const Text('매장 선택하기', style: TextStyle(fontFamily: 'Pretendard', fontSize: 15, fontWeight: FontWeight.w700, letterSpacing: -0.2)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductList() {
    return Stack(
      children: [
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Column(
                children: [
                  _buildSearchBar(),
                  const SizedBox(height: 12),
                  _buildCategoryFilter(),
                  const SizedBox(height: 12),
                ],
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 110),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.9,
                ),
                itemCount: _filteredProducts.length,
                itemBuilder: (_, i) => _buildProductCard(_filteredProducts[i]),
              ),
            ),
          ],
        ),
        Positioned(
          bottom: 24, left: 16, right: 16,
          child: Row(
            children: [
              _buildCameraButton(),
              const Spacer(),
              _buildCartButton(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;
    final hasQuery = _searchQuery.isNotEmpty;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 50,
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: hasQuery ? 0.12 : 0.07)
            : hasQuery ? Colors.white : const Color(0xFFF5F5F3),
        borderRadius: BorderRadius.circular(hasQuery ? 14 : 20),
        border: Border.all(
          color: hasQuery
              ? const Color(0xFFFF6B4A)
              : isDark
                  ? Colors.white.withValues(alpha: 0.12)
                  : const Color(0xFFDDDEDB),
          width: hasQuery ? 1.5 : 1,
        ),
        boxShadow: hasQuery && !isDark
            ? [BoxShadow(color: const Color(0xFFFF6B4A).withValues(alpha: 0.12), blurRadius: 12, offset: const Offset(0, 3))]
            : isDark ? null : [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: TextField(
        onChanged: (v) => setState(() => _searchQuery = v),
        style: TextStyle(
          fontFamily: 'Pretendard',
          color: cs.onSurface,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: '제품명으로 검색해보세요',
          hintStyle: TextStyle(
            fontFamily: 'Pretendard',
            color: cs.onSurface.withValues(alpha: 0.3),
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 16, right: 8),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                hasQuery ? Icons.search_rounded : Icons.search_rounded,
                key: ValueKey(hasQuery),
                color: hasQuery
                    ? const Color(0xFFFF6B4A)
                    : cs.onSurface.withValues(alpha: isDark ? 0.4 : 0.35),
                size: 20,
              ),
            ),
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 44, minHeight: 44),
          suffixIcon: hasQuery
              ? GestureDetector(
                  onTap: () => setState(() => _searchQuery = ''),
                  child: Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Icon(Icons.cancel_rounded, color: cs.onSurface.withValues(alpha: 0.3), size: 18),
                  ),
                )
              : null,
          suffixIconConstraints: const BoxConstraints(minWidth: 40, minHeight: 40),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(hasQuery ? 14 : 20),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(hasQuery ? 14 : 20),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(hasQuery ? 14 : 20),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;
    return SizedBox(
      height: 34,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final selected = _selectedCategory == _categories[i];
          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = _categories[i]),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              decoration: BoxDecoration(
                color: selected
                    ? const Color(0xFFFF6B4A)
                    : isDark
                        ? Colors.white.withValues(alpha: 0.1)
                        : Colors.white,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: selected
                      ? const Color(0xFFFF6B4A)
                      : isDark
                          ? Colors.white.withValues(alpha: 0.15)
                          : const Color(0xFFD1D5DB),
                  width: 1,
                ),
              ),
              child: Center(
                child: Text(
                  _categories[i],
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    color: selected
                        ? Colors.white
                        : isDark
                            ? Colors.white.withValues(alpha: 0.6)
                            : const Color(0xFF4E5968),
                    fontSize: 13,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 4,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Container(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.06),
                        child: const Center(child: Icon(Icons.image_outlined, color: Color(0xFFD1D5DB), size: 40)),
                      ),
                      Positioned(
                        bottom: 0, left: 0, right: 0,
                        child: Container(
                          height: 60,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [Color(0x55000000), Colors.transparent],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 10, left: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: KColors.navy.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(product.category, style: const TextStyle(fontFamily: 'Pretendard', color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(product.name, style: const TextStyle(fontFamily: 'Pretendard', color: KColors.navy, fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: -0.2), maxLines: 2, overflow: TextOverflow.ellipsis),
                        Text(product.price, style: const TextStyle(fontFamily: 'Pretendard', color: Color(0xFFFF6B4A), fontSize: 15, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              bottom: 10, right: 10,
              child: GestureDetector(
                onTap: () => _addToCart(product),
                child: Container(
                  width: 34, height: 34,
                  decoration: const BoxDecoration(color: KColors.navy, shape: BoxShape.circle),
                  child: const Icon(Icons.add, color: Colors.white, size: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraButton() {
    return Container(
      width: 56, height: 56,
      decoration: BoxDecoration(
        color: KColors.darkSurface,
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: IconButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BarcodeScannerScreen(
                title: '상품 바코드 스캔',
                getCartCount: () => _cartCount,
                onContinuousScan: (barcode) {
                  final found = _products.where((p) => p.barcode == barcode);
                  if (found.isNotEmpty) {
                    _addToCart(found.first);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '${found.first.name} 담김 ✓',
                          style: const TextStyle(fontFamily: 'Pretendard', fontWeight: FontWeight.w600),
                        ),
                        backgroundColor: KColors.navy,
                        behavior: SnackBarBehavior.floating,
                        duration: const Duration(seconds: 1),
                        margin: const EdgeInsets.fromLTRB(16, 0, 16, 140),
                      ),
                    );
                    return true; // 카메라 유지
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          '등록되지 않은 상품이에요',
                          style: TextStyle(fontFamily: 'Pretendard'),
                        ),
                        backgroundColor: Color(0xFFEF4444),
                        behavior: SnackBarBehavior.floating,
                        duration: Duration(seconds: 2),
                      ),
                    );
                    return false; // 카메라 닫기
                  }
                },
              ),
            ),
          );
        },
        icon: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 24),
        padding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildCartButton() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: GestureDetector(
          onTap: _showCartDialog,
          child: Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              color: const Color(0xFFFF6B4A).withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1),
              boxShadow: [BoxShadow(color: const Color(0xFFFF6B4A).withValues(alpha: 0.45), blurRadius: 16, offset: const Offset(0, 6))],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.shopping_cart_rounded, color: Colors.white, size: 22),
                const SizedBox(width: 8),
                const Text('장바구니', style: TextStyle(fontFamily: 'Pretendard', color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700, letterSpacing: -0.2)),
                if (_cartCount > 0) ...[
                  const SizedBox(width: 8),
                  Container(
                    width: 24, height: 24,
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    child: Center(
                      child: Text('$_cartCount', style: const TextStyle(fontFamily: 'Pretendard', color: Color(0xFFFF6B4A), fontSize: 11, fontWeight: FontWeight.w900)),
                    ),
                  )
                      .animate(key: ValueKey(_cartCount))
                      .scale(begin: const Offset(0.5, 0.5), end: const Offset(1, 1), duration: 300.ms, curve: Curves.elasticOut),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────
// 장바구니 다이얼로그
// ──────────────────────────────────────────

class _CartDialog extends StatelessWidget {
  final List<CartItem> cartItems;
  final int cartTotal;
  final int cartCount;
  final String Function(int) formatPrice;
  final void Function(CartItem) onIncrement;
  final void Function(CartItem) onDecrement;
  final void Function(CartItem) onRemove;
  final VoidCallback onClear;
  final VoidCallback onCheckout;

  const _CartDialog({
    required this.cartItems,
    required this.cartTotal,
    required this.cartCount,
    required this.formatPrice,
    required this.onIncrement,
    required this.onDecrement,
    required this.onRemove,
    required this.onClear,
    required this.onCheckout,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: Container(
        decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(20)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(context),
            SizedBox(
              height: 280,
              child: cartItems.isEmpty ? _buildEmptyCart() : _buildCartList(),
            ),
            _buildCheckoutButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Row(
        children: [
          const Icon(Icons.shopping_cart_rounded, color: KColors.navy, size: 20),
          const SizedBox(width: 6),
          const Text('장바구니', style: TextStyle(fontFamily: 'Pretendard', color: KColors.navy, fontSize: 17, fontWeight: FontWeight.w700)),
          const SizedBox(width: 6),
          TweenAnimationBuilder<int>(
            key: ValueKey(cartCount),
            tween: IntTween(begin: 0, end: cartCount),
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutCubic,
            builder: (_, value, __) => Text(
              '$value',
              style: const TextStyle(fontFamily: 'Pretendard', color: Color(0xFFFF6B4A), fontSize: 17, fontWeight: FontWeight.w700),
            ),
          ),
          if (cartItems.isNotEmpty) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onClear,
              child: Text('모두 비우기', style: const TextStyle(fontFamily: 'Pretendard', color: Color(0xFF8B95A1), fontSize: 12, fontWeight: FontWeight.w500)),
            ),
          ],
          const Spacer(),
          TweenAnimationBuilder<int>(
            key: ValueKey(cartTotal),
            tween: IntTween(begin: 0, end: cartTotal),
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutCubic,
            builder: (_, value, __) => Text(
              formatPrice(value),
              style: const TextStyle(fontFamily: 'Pretendard', color: Color(0xFFFF6B4A), fontSize: 17, fontWeight: FontWeight.w900, letterSpacing: -0.5),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.close, color: Color(0xFF8B95A1), size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.shopping_cart_outlined, color: KColors.navy.withValues(alpha: 0.15), size: 56),
        const SizedBox(height: 12),
        const Text('장바구니가 비어있습니다', style: TextStyle(fontFamily: 'Pretendard', color: KColors.navy, fontSize: 15, fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text('바코드를 스캔하여 상품을 담아보세요', style: const TextStyle(fontFamily: 'Pretendard', color: Color(0xFF8B95A1), fontSize: 12)),
      ],
    );
  }

  Widget _buildCartList() {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: cartItems.length,
      separatorBuilder: (_, _) => const Divider(height: 1, color: Color(0xFFF3F4F6)),
      itemBuilder: (_, i) {
        final item = cartItems[i];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.image_outlined, color: Color(0xFFD1D5DB), size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.product.name, style: const TextStyle(fontFamily: 'Pretendard', color: KColors.navy, fontSize: 13, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Text(formatPrice(item.totalPrice), style: const TextStyle(fontFamily: 'Pretendard', color: Color(0xFFFF6B4A), fontSize: 12, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => onRemove(item),
                icon: const Icon(Icons.delete_outline, color: Color(0xFFD1D5DB), size: 18),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 8),
              Row(
                children: [
                  _QtyButton(icon: Icons.remove, onTap: () => onDecrement(item)),
                  const SizedBox(width: 10),
                  Text('${item.quantity}', style: const TextStyle(fontFamily: 'Pretendard', color: KColors.navy, fontSize: 14, fontWeight: FontWeight.w700)),
                  const SizedBox(width: 10),
                  _QtyButton(icon: Icons.add, onTap: () => onIncrement(item)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCheckoutButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: cartItems.isNotEmpty ? onCheckout : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: KColors.navy,
            disabledBackgroundColor: const Color(0xFFD1D5DB),
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text('결제하기', style: TextStyle(fontFamily: 'Pretendard', fontSize: 15, fontWeight: FontWeight.w700, letterSpacing: -0.2)),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────
// 결제 수단 선택 다이얼로그
// ──────────────────────────────────────────

class _PaymentDialog extends StatefulWidget {
  final int cartCount;
  final int cartTotal;
  final List<PaymentCartItem> cartItems;
  final String Function(int) formatPrice;
  final VoidCallback onClose;
  final VoidCallback onBack;
  final String storeName;

  const _PaymentDialog({
    required this.cartCount,
    required this.cartTotal,
    required this.cartItems,
    required this.formatPrice,
    required this.onClose,
    required this.onBack,
    required this.storeName,
  });

  @override
  State<_PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentDialogState extends State<_PaymentDialog> {
  String _selectedMethod = '카카오페이';

  final List<Map<String, dynamic>> _methods = [
    {'name': '카카오페이', 'color': Color(0xFFFEE500), 'textColor': Color(0xFF1A1A1A)},
    {'name': '토스페이', 'color': Color(0xFF0064FF), 'textColor': Colors.white},
    {'name': '신용카드', 'color': KColors.navy, 'textColor': Colors.white},
  ];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: Container(
        decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(20)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            const SizedBox(height: 4),
            _buildSummaryCard(),
            const SizedBox(height: 16),
            _buildPaymentMethods(),
            const SizedBox(height: 16),
            _buildConfirmButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: widget.onBack,
            child: Icon(Icons.arrow_back, color: const Color(0xFF8B95A1), size: 22),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.credit_card_rounded, color: KColors.navy, size: 22),
          const SizedBox(width: 8),
          const Text('결제 수단 선택', style: TextStyle(fontFamily: 'Pretendard', color: KColors.navy, fontSize: 18, fontWeight: FontWeight.w700, letterSpacing: -0.3)),
          const Spacer(),
          GestureDetector(
            onTap: widget.onClose,
            child: Icon(Icons.close, color: const Color(0xFF8B95A1), size: 22),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('선택한 상품 ${widget.cartCount}개', style: const TextStyle(fontFamily: 'Pretendard', color: Color(0xFF8B95A1), fontSize: 12, fontWeight: FontWeight.w400)),
                const SizedBox(height: 4),
                const Text('총 결제 금액', style: TextStyle(fontFamily: 'Pretendard', color: KColors.navy, fontSize: 15, fontWeight: FontWeight.w700)),
              ],
            ),
            const Spacer(),
            Text(
              widget.formatPrice(widget.cartTotal),
              style: const TextStyle(fontFamily: 'Pretendard', color: Color(0xFFFF6B4A), fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: -0.8),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethods() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: _methods.map((method) {
          final selected = _selectedMethod == method['name'];
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: GestureDetector(
              onTap: () => setState(() => _selectedMethod = method['name']),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: double.infinity,
                height: 52,
                decoration: BoxDecoration(
                  color: selected ? method['color'] as Color : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: selected ? (method['color'] as Color) : const Color(0xFFE5E7EB),
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Text(
                    method['name'] as String,
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      color: selected ? method['textColor'] as Color : KColors.navy,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildConfirmButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PaymentCompleteScreen(
                  storeName: widget.storeName,
                  paymentMethod: _selectedMethod,
                  cartTotal: widget.cartTotal,
                  cartCount: widget.cartCount,
                  cartItems: widget.cartItems,
                  formatPrice: widget.formatPrice,
                ),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF6B4A),
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: Colors.white, width: 2),
            ),
          ),
          child: Text(
            '$_selectedMethod로 결제 진행하기',
            style: const TextStyle(fontFamily: 'Pretendard', fontSize: 15, fontWeight: FontWeight.w700, letterSpacing: -0.2),
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────
// 수량 버튼
// ──────────────────────────────────────────

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _QtyButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 26, height: 26,
        decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, size: 14, color: KColors.navy),
      ),
    );
  }
}

// ──────────────────────────────────────────
// 매장 선택 바텀시트
// ──────────────────────────────────────────

class _StoreSelectSheet extends StatelessWidget {
  final List<Map<String, String>> stores;
  final void Function(String name) onSelectStore;

  const _StoreSelectSheet({required this.stores, required this.onSelectStore});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(20)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Row(
              children: [
                const Icon(Icons.qr_code_rounded, color: KColors.navy, size: 22),
                const SizedBox(width: 8),
                const Text('매장 QR 스캔', style: TextStyle(fontFamily: 'Pretendard', color: KColors.navy, fontSize: 18, fontWeight: FontWeight.w700, letterSpacing: -0.3)),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Icon(Icons.close, color: const Color(0xFF8B95A1), size: 22),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: const Text('매장의 QR코드를 스캔하거나 매장을 선택하세요', style: TextStyle(fontFamily: 'Pretendard', color: Color(0xFF8B95A1), fontSize: 13)),
          ),
          ...stores.map((store) => Column(
            children: [
              const Divider(height: 1, color: Color(0xFFF3F4F6)),
              InkWell(
                onTap: () => onSelectStore(store['name']!),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(store['name']!, style: const TextStyle(fontFamily: 'Pretendard', color: KColors.navy, fontSize: 15, fontWeight: FontWeight.w700)),
                            const SizedBox(height: 2),
                            Text(store['address']!, style: const TextStyle(fontFamily: 'Pretendard', color: Color(0xFF8B95A1), fontSize: 13)),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: Color(0xFFD1D5DB), size: 20),
                    ],
                  ),
                ),
              ),
            ],
          )),
          const Divider(height: 1, color: Color(0xFFF3F4F6)),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: const Text('원하는 매장이 없으신가요?', style: TextStyle(fontFamily: 'Pretendard', color: Color(0xFF8B95A1), fontSize: 12)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () => debugPrint('매장 QR 찍기'),
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

// ──────────────────────────────────────────
// 역할 토글 위젯
// ──────────────────────────────────────────

class _RoleToggle extends StatefulWidget {
  final VoidCallback onSellerTap;
  const _RoleToggle({required this.onSellerTap});

  @override
  State<_RoleToggle> createState() => _RoleToggleState();
}

class _RoleToggleState extends State<_RoleToggle>
    with SingleTickerProviderStateMixin {
  bool _isSeller = false;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap(bool toSeller) {
    if (toSeller == _isSeller) return;
    setState(() => _isSeller = toSeller);
    if (toSeller) {
      _controller.forward();
      Future.delayed(const Duration(milliseconds: 200), () {
        widget.onSellerTap();
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) {
            setState(() => _isSeller = false);
            _controller.reverse();
          }
        });
      });
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 34,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15), width: 1),
      ),
      child: Stack(
        children: [
          AnimatedAlign(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            alignment: _isSeller ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              width: 64,
              height: 28,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () => _handleTap(false),
                child: Container(
                  width: 64,
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
                            ? Colors.white.withValues(alpha: 0.5)
                            : KColors.navy,
                      ),
                      child: const Text('구매자'),
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => _handleTap(true),
                child: Container(
                  width: 64,
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
                            ? KColors.navy
                            : Colors.white.withValues(alpha: 0.5),
                      ),
                      child: const Text('판매자'),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────
// 구매자 상품 그리드 (MainScreen에서 재사용)
// ──────────────────────────────────────────

class BuyerProductGrid extends StatefulWidget {
  final List<String>? categories;

  const BuyerProductGrid({
    super.key,
    this.categories,
  });

  @override
  State<BuyerProductGrid> createState() => _BuyerProductGridState();
}

class _BuyerProductGridState extends State<BuyerProductGrid> {
  String _searchQuery = '';
  String _selectedCategory = '전체';
  final List<CartItem> _cartItems = [];

  int get _cartCount => _cartItems.fold(0, (sum, item) => sum + item.quantity);
  int get _cartTotal => _cartItems.fold(0, (sum, item) => sum + item.totalPrice);

  // 매장별 카테고리 → 백엔드 연동 시 API로 교체
  List<String> get _categories => widget.categories ?? ['전체', '음료', '식품', '간식'];

  final List<Product> _products = const [
    Product(name: '코카콜라 500ml', price: '1,500원', category: '음료', priceValue: 1500, barcode: '8801234567890'),
    Product(name: '삼각김밥 참치', price: '1,200원', category: '식품', priceValue: 1200, barcode: '8801234567891'),
    Product(name: '바나나우유', price: '1,800원', category: '음료', priceValue: 1800, barcode: '8801234567892'),
    Product(name: '새우깡', price: '1,000원', category: '간식', priceValue: 1000, barcode: '8801234567893'),
    Product(name: '컵누들 매콤한맛', price: '1,500원', category: '식품', priceValue: 1500, barcode: '8801234567894'),
    Product(name: '포카칩 오리지널', price: '1,700원', category: '간식', priceValue: 1700, barcode: '8801234567895'),
    Product(name: '초코파이', price: '4,800원', category: '간식', priceValue: 4800, barcode: '8801234567896'),
    Product(name: '진라면 매운맛 (컵)', price: '1,300원', category: '식품', priceValue: 1300, barcode: '8801234567897'),
    Product(name: '펩시콜라 355ml', price: '1,400원', category: '음료', priceValue: 1400, barcode: '8801234567898'),
    Product(name: '칠성사이다 500ml', price: '1,600원', category: '음료', priceValue: 1600, barcode: '8801234567899'),
    Product(name: '제주 삼다수 500ml', price: '950원', category: '음료', priceValue: 950, barcode: '8801234567900'),
    Product(name: '11찬 도시락', price: '5,500원', category: '식품', priceValue: 5500, barcode: '8801234567901'),
  ];

  List<Product> get _filteredProducts {
    return _products.where((p) {
      final matchCategory = _selectedCategory == '전체' || p.category == _selectedCategory;
      final matchSearch = _searchQuery.isEmpty || p.name.contains(_searchQuery);
      return matchCategory && matchSearch;
    }).toList();
  }

  void _addToCart(Product product) {
    setState(() {
      final existing = _cartItems.where((i) => i.product.name == product.name);
      if (existing.isNotEmpty) {
        existing.first.quantity++;
      } else {
        _cartItems.add(CartItem(product: product));
      }
    });
  }

  void _removeFromCart(CartItem item) => setState(() => _cartItems.remove(item));
  void _incrementQty(CartItem item) => setState(() => item.quantity++);
  void _decrementQty(CartItem item) => setState(() {
    if (item.quantity > 1) { item.quantity--; } else { _cartItems.remove(item); }
  });
  void _clearCart() => setState(() => _cartItems.clear());

  String _formatPrice(int price) {
    return '${price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}원';
  }

  void _showCartDialog() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (_) => StatefulBuilder(
        builder: (context, setDialogState) {
          return _CartDialog(
            cartItems: _cartItems,
            cartTotal: _cartTotal,
            cartCount: _cartCount,
            formatPrice: _formatPrice,
            onIncrement: (item) { _incrementQty(item); setDialogState(() {}); },
            onDecrement: (item) { _decrementQty(item); setDialogState(() {}); },
            onRemove: (item) { _removeFromCart(item); setDialogState(() {}); },
            onClear: () { _clearCart(); setDialogState(() {}); },
            onCheckout: () {
              Navigator.pop(context);
              _showPaymentDialog();
            },
          );
        },
      ),
    );
  }

  void _showPaymentDialog() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (_) => StatefulBuilder(
        builder: (context, setDialogState) {
          return _PaymentDialog(
            cartCount: _cartCount,
            cartTotal: _cartTotal,
            cartItems: _cartItems.map((item) => PaymentCartItem(
              name: item.product.name,
              quantity: item.quantity,
              totalPrice: item.totalPrice,
            )).toList(),
            formatPrice: _formatPrice,
            storeName: '편의점 A',
            onClose: () => Navigator.pop(context),
            onBack: () {
              Navigator.pop(context);
              _showCartDialog();
            },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Column(
                children: [
                  _buildSearchBar(),
                  const SizedBox(height: 12),
                  _buildCategoryFilter(),
                  const SizedBox(height: 12),
                ],
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 110),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.9,
                ),
                itemCount: _filteredProducts.length,
                itemBuilder: (_, i) => _buildProductCard(_filteredProducts[i]),
              ),
            ),
          ],
        ),
        Positioned(
          bottom: 24, left: 16, right: 16,
          child: Row(
            children: [
              _buildCameraButton(),
              const Spacer(),
              _buildCartButton(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;
    final hasQuery = _searchQuery.isNotEmpty;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 50,
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: hasQuery ? 0.12 : 0.07)
            : hasQuery ? Colors.white : const Color(0xFFF5F5F3),
        borderRadius: BorderRadius.circular(hasQuery ? 14 : 20),
        border: Border.all(
          color: hasQuery
              ? const Color(0xFFFF6B4A)
              : isDark
                  ? Colors.white.withValues(alpha: 0.12)
                  : const Color(0xFFDDDEDB),
          width: hasQuery ? 1.5 : 1,
        ),
        boxShadow: hasQuery && !isDark
            ? [BoxShadow(color: const Color(0xFFFF6B4A).withValues(alpha: 0.12), blurRadius: 12, offset: const Offset(0, 3))]
            : isDark ? null : [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: TextField(
        onChanged: (v) => setState(() => _searchQuery = v),
        style: TextStyle(
          fontFamily: 'Pretendard',
          color: cs.onSurface,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: '제품명으로 검색해보세요',
          hintStyle: TextStyle(
            fontFamily: 'Pretendard',
            color: cs.onSurface.withValues(alpha: 0.3),
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 16, right: 8),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                hasQuery ? Icons.search_rounded : Icons.search_rounded,
                key: ValueKey(hasQuery),
                color: hasQuery
                    ? const Color(0xFFFF6B4A)
                    : cs.onSurface.withValues(alpha: isDark ? 0.4 : 0.35),
                size: 20,
              ),
            ),
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 44, minHeight: 44),
          suffixIcon: hasQuery
              ? GestureDetector(
                  onTap: () => setState(() => _searchQuery = ''),
                  child: Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Icon(Icons.cancel_rounded, color: cs.onSurface.withValues(alpha: 0.3), size: 18),
                  ),
                )
              : null,
          suffixIconConstraints: const BoxConstraints(minWidth: 40, minHeight: 40),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(hasQuery ? 14 : 20),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(hasQuery ? 14 : 20),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(hasQuery ? 14 : 20),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;
    return SizedBox(
      height: 34,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final selected = _selectedCategory == _categories[i];
          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = _categories[i]),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              decoration: BoxDecoration(
                color: selected
                    ? const Color(0xFFFF6B4A)
                    : isDark
                        ? Colors.white.withValues(alpha: 0.1)
                        : Colors.white,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: selected
                      ? const Color(0xFFFF6B4A)
                      : isDark
                          ? Colors.white.withValues(alpha: 0.15)
                          : const Color(0xFFD1D5DB),
                  width: 1,
                ),
              ),
              child: Center(
                child: Text(
                  _categories[i],
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    color: selected
                        ? Colors.white
                        : isDark
                            ? Colors.white.withValues(alpha: 0.6)
                            : const Color(0xFF4E5968),
                    fontSize: 13,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 4,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Container(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.06),
                        child: const Center(child: Icon(Icons.image_outlined, color: Color(0xFFD1D5DB), size: 40)),
                      ),
                      Positioned(
                        bottom: 0, left: 0, right: 0,
                        child: Container(
                          height: 60,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [Color(0x55000000), Colors.transparent],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 10, left: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: KColors.navy.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(product.category, style: const TextStyle(fontFamily: 'Pretendard', color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(product.name, style: const TextStyle(fontFamily: 'Pretendard', color: KColors.navy, fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: -0.2), maxLines: 2, overflow: TextOverflow.ellipsis),
                        Text(product.price, style: const TextStyle(fontFamily: 'Pretendard', color: Color(0xFFFF6B4A), fontSize: 15, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              bottom: 10, right: 10,
              child: GestureDetector(
                onTap: () => _addToCart(product),
                child: Container(
                  width: 34, height: 34,
                  decoration: const BoxDecoration(color: KColors.navy, shape: BoxShape.circle),
                  child: const Icon(Icons.add, color: Colors.white, size: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraButton() {
    return Container(
      width: 56, height: 56,
      decoration: BoxDecoration(
        color: KColors.darkSurface,
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: IconButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BarcodeScannerScreen(
                title: '상품 바코드 스캔',
                getCartCount: () => _cartCount,
                onContinuousScan: (barcode) {
                  final found = _products.where((p) => p.barcode == barcode);
                  if (found.isNotEmpty) {
                    _addToCart(found.first);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '${found.first.name} 담김 ✓',
                          style: const TextStyle(fontFamily: 'Pretendard', fontWeight: FontWeight.w600),
                        ),
                        backgroundColor: KColors.navy,
                        behavior: SnackBarBehavior.floating,
                        duration: const Duration(seconds: 1),
                        margin: const EdgeInsets.fromLTRB(16, 0, 16, 140),
                      ),
                    );
                    return true; // 카메라 유지
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          '등록되지 않은 상품이에요',
                          style: TextStyle(fontFamily: 'Pretendard'),
                        ),
                        backgroundColor: Color(0xFFEF4444),
                        behavior: SnackBarBehavior.floating,
                        duration: Duration(seconds: 2),
                      ),
                    );
                    return false; // 카메라 닫기
                  }
                },
              ),
            ),
          );
        },
        icon: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 24),
        padding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildCartButton() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: GestureDetector(
          onTap: _showCartDialog,
          child: Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              color: const Color(0xFFFF6B4A).withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1),
              boxShadow: [BoxShadow(color: const Color(0xFFFF6B4A).withValues(alpha: 0.45), blurRadius: 16, offset: const Offset(0, 6))],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.shopping_cart_rounded, color: Colors.white, size: 22),
                const SizedBox(width: 8),
                const Text('장바구니', style: TextStyle(fontFamily: 'Pretendard', color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700, letterSpacing: -0.2)),
                if (_cartCount > 0) ...[
                  const SizedBox(width: 8),
                  Container(
                    width: 24, height: 24,
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    child: Center(
                      child: Text('$_cartCount', style: const TextStyle(fontFamily: 'Pretendard', color: Color(0xFFFF6B4A), fontSize: 11, fontWeight: FontWeight.w900)),
                    ),
                  )
                      .animate(key: ValueKey(_cartCount))
                      .scale(begin: const Offset(0.5, 0.5), end: const Offset(1, 1), duration: 300.ms, curve: Curves.elasticOut),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}