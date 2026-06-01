import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/web_auth_helper.dart';
import '../app_theme.dart';
import 'dart:ui';
import 'payment_complete_screen.dart';
import 'my_page_screen.dart';
import 'barcode_scanner_screen.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';

class Product {
  final String name;
  final String price;
  final String category;
  final int priceValue;
  final String barcode;
  final String? imageUrl;

  const Product({
    required this.name,
    required this.price,
    required this.category,
    required this.priceValue,
    this.barcode = '',
    this.imageUrl,
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
    if (_cartCount == 0) {
      showDialog(
        context: context,
        barrierColor: Colors.black.withValues(alpha: 0.5),
        builder: (_) => Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 헤더 (기존 장바구니 다이얼로그와 동일)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                  child: Row(
                    children: [
                      Icon(Icons.shopping_cart_rounded, color: Theme.of(context).colorScheme.onSurface, size: 20),
                      const SizedBox(width: 6),
                      Text('장바구니', style: TextStyle(fontFamily: 'Pretendard', color: Theme.of(context).colorScheme.onSurface, fontSize: 17, fontWeight: FontWeight.w700)),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(Icons.close, color: Color(0xFF8B95A1), size: 20),
                      ),
                    ],
                  ),
                ),
                // 빈 장바구니 내용 (기존 _buildEmptyCart와 동일)
                SizedBox(
                  height: 280,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shopping_cart_outlined, color: KColors.navy.withValues(alpha: 0.15), size: 56),
                      const SizedBox(height: 12),
                      Text('장바구니가 비어있습니다', style: TextStyle(fontFamily: 'Pretendard', color: Theme.of(context).colorScheme.onSurface, fontSize: 15, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      const Text('바코드를 스캔하여 상품을 담아보세요', style: TextStyle(fontFamily: 'Pretendard', color: Color(0xFF8B95A1), fontSize: 12)),
                    ],
                  ),
                ),
                // 결제하기 버튼 (비활성화 상태)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF6B4A),
                        disabledBackgroundColor: const Color(0xFFFF6B4A).withOpacity(0.35),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('결제하기', style: TextStyle(fontFamily: 'Pretendard', fontSize: 15, fontWeight: FontWeight.w700, letterSpacing: -0.2)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      return;
    }
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
            storeId: 0,
            onIncrement: (item) { _incrementQty(item); setDialogState(() {}); },
            onDecrement: (item) { _decrementQty(item); setDialogState(() {}); },
            onRemove: (item) { _removeFromCart(item); setDialogState(() {}); },
            onClear: () { _clearCart(); setDialogState(() {}); },
            onCheckout: (finalAmount, couponUsed) {
              Navigator.pop(context);
              _processTossPayment(finalAmount, couponUsed);
            },
          );
        },
      ),
    );
  }

  Future<void> _processTossPayment(int finalAmount, bool couponUsed) async {
    final token = await AuthService.getToken();
    if (token == null) return;

    final orderName = _cartItems.length == 1
        ? _cartItems.first.product.name
        : '${_cartItems.first.product.name} 외 ${_cartItems.length - 1}건';

    final checkoutInfo = await ApiService.requestTossPayment(
      amount: finalAmount,
      orderName: orderName,
      tossMethod: '간편결제',
    );
    if (checkoutInfo == null || !mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _PaymentProgressOverlay(),
    );

    try {
      final result = await WebAuthHelper.authenticate(
        url: checkoutInfo.checkoutUrl,
        callbackUrlScheme: 'myapp',
      );
      final uri = Uri.parse(result);
      if (!mounted) return;
      if (uri.queryParameters['status'] != 'success') {
        Navigator.pop(context);
        return;
      }

      final paymentKey = uri.queryParameters['paymentKey']!;
      final orderId = uri.queryParameters['orderId']!;
      final amount = int.parse(uri.queryParameters['amount']!);
      final cartSnapshot = List<CartItem>.from(_cartItems);
      final total = finalAmount;
      final count = _cartCount;

      await ApiService.confirmTossPayment(
        token: token,
        paymentKey: paymentKey,
        orderId: orderId,
        amount: amount,
        storeId: 0,
        storeName: _selectedStore ?? '',
        couponUsed: couponUsed,
        items: cartSnapshot.map((i) => {
          'productName': i.product.name,
          'barcode': i.product.barcode,
          'quantity': i.quantity,
          'price': i.totalPrice ~/ i.quantity,
        }).toList(),
      );

      if (!mounted) return;
      Navigator.pop(context);
      _clearCart();
      Navigator.push(context, MaterialPageRoute(
        builder: (_) => PaymentCompleteScreen(
          storeName: _selectedStore ?? '',
          paymentMethod: '토스페이',
          cartTotal: total,
          cartCount: count,
          storeId: 0,
          cartItems: cartSnapshot.map((i) => PaymentCartItem(
            name: i.product.name,
            quantity: i.quantity,
            totalPrice: i.totalPrice,
          )).toList(),
          formatPrice: _formatPrice,
        ),
      ));
    } catch (_) {
      if (mounted) Navigator.pop(context);
    }
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
                      product.imageUrl != null
                          ? Image.network(
                              product.imageUrl!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                              errorBuilder: (_, __, ___) => Container(
                                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.06),
                                child: const Center(child: Icon(Icons.image_outlined, color: Color(0xFFD1D5DB), size: 40)),
                              ),
                              loadingBuilder: (_, child, progress) => progress == null
                                  ? child
                                  : Container(
                                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.06),
                                      child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                                    ),
                            )
                          : Container(
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
                        Text(product.name, style: TextStyle(fontFamily: 'Pretendard', color: Theme.of(context).colorScheme.onSurface, fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: -0.2), maxLines: 2, overflow: TextOverflow.ellipsis),
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
                  decoration: BoxDecoration(color: KColors.primary, shape: BoxShape.circle),
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

class _CartDialog extends StatefulWidget {
  final List<CartItem> cartItems;
  final int cartTotal;
  final int cartCount;
  final String Function(int) formatPrice;
  final void Function(CartItem) onIncrement;
  final void Function(CartItem) onDecrement;
  final void Function(CartItem) onRemove;
  final VoidCallback onClear;
  final void Function(int finalAmount, bool couponUsed) onCheckout;
  final int? storeId;
  final String? token;

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
    this.storeId,
    this.token,
  });

  @override
  State<_CartDialog> createState() => _CartDialogState();
}

class _CartDialogState extends State<_CartDialog> {
  StampCardModel? _stampCard;
  bool _couponApplied = false;

  @override
  void initState() {
    super.initState();
    _loadStampCard();
  }

  Future<void> _loadStampCard() async {
    final sid = widget.storeId;
    if (sid == null || sid == 0) return;
    final tok = widget.token ?? await AuthService.getToken();
    if (tok == null) return;
    final card = await ApiService.getStampCard(tok, sid);
    // 쿠폰이 있을 때만 표시
    if (mounted && card != null && card.availableCoupons > 0) {
      setState(() => _stampCard = card);
    }
  }

  int get _effectiveTotal =>
      _couponApplied ? (widget.cartTotal - 1000).clamp(0, widget.cartTotal) : widget.cartTotal;

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
              child: widget.cartItems.isEmpty ? _buildEmptyCart() : _buildCartList(),
            ),
            if (_stampCard != null) _buildCouponRow(context),
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
          Builder(builder: (ctx) => Icon(Icons.shopping_cart_rounded, color: Theme.of(ctx).colorScheme.onSurface, size: 20)),
          const SizedBox(width: 6),
          Builder(builder: (ctx) => Text('장바구니', style: TextStyle(fontFamily: 'Pretendard', color: Theme.of(ctx).colorScheme.onSurface, fontSize: 17, fontWeight: FontWeight.w700))),
          const SizedBox(width: 6),
          TweenAnimationBuilder<int>(
            key: ValueKey('count-${widget.cartCount}'),
            tween: IntTween(begin: 0, end: widget.cartCount),
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutCubic,
            builder: (_, value, __) => Text(
              '$value',
              style: const TextStyle(fontFamily: 'Pretendard', color: Color(0xFFFF6B4A), fontSize: 17, fontWeight: FontWeight.w700),
            ),
          ),
          if (widget.cartItems.isNotEmpty) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: widget.onClear,
              child: Text('모두 비우기', style: const TextStyle(fontFamily: 'Pretendard', color: Color(0xFF8B95A1), fontSize: 12, fontWeight: FontWeight.w500)),
            ),
          ],
          const Spacer(),
          TweenAnimationBuilder<int>(
            key: ValueKey('total-$_effectiveTotal'),
            tween: IntTween(begin: 0, end: _effectiveTotal),
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutCubic,
            builder: (_, value, __) => Text(
              widget.formatPrice(value),
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
        Builder(builder: (ctx) => Icon(Icons.shopping_cart_outlined, color: Theme.of(ctx).colorScheme.onSurface.withValues(alpha: 0.2), size: 56)),
        const SizedBox(height: 12),
        Builder(builder: (ctx) => Text('장바구니가 비어있습니다', style: TextStyle(fontFamily: 'Pretendard', color: Theme.of(ctx).colorScheme.onSurface, fontSize: 15, fontWeight: FontWeight.w700))),
        const SizedBox(height: 4),
        Text('바코드를 스캔하여 상품을 담아보세요', style: const TextStyle(fontFamily: 'Pretendard', color: Color(0xFF8B95A1), fontSize: 12)),
      ],
    );
  }

  Widget _buildCouponRow(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final card = _stampCard!;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
      child: GestureDetector(
        onTap: () => setState(() => _couponApplied = !_couponApplied),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: _couponApplied ? KColors.primary.withValues(alpha: 0.08) : cs.onSurface.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _couponApplied ? KColors.primary.withValues(alpha: 0.4) : cs.outline),
          ),
          child: Row(
            children: [
              Icon(Icons.confirmation_num_outlined, size: 18, color: _couponApplied ? KColors.primary : cs.onSurface.withValues(alpha: 0.4)),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '1,000원 할인 쿠폰',
                      style: TextStyle(fontFamily: 'Pretendard', fontSize: 13, fontWeight: FontWeight.w700, color: _couponApplied ? KColors.primary : cs.onSurface.withValues(alpha: 0.7)),
                    ),
                    Text(
                      '${card.availableCoupons}장 보유',
                      style: TextStyle(fontFamily: 'Pretendard', fontSize: 11, color: cs.onSurface.withValues(alpha: 0.4)),
                    ),
                  ],
                ),
              ),
              if (_couponApplied)
                const Text('-1,000원', style: TextStyle(fontFamily: 'Pretendard', color: KColors.primary, fontSize: 13, fontWeight: FontWeight.w700)),
              const SizedBox(width: 10),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 22, height: 22,
                decoration: BoxDecoration(
                  color: _couponApplied ? KColors.primary : Colors.transparent,
                  border: Border.all(color: _couponApplied ? KColors.primary : cs.onSurface.withValues(alpha: 0.3), width: 1.5),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: _couponApplied ? const Icon(Icons.check, color: Colors.white, size: 14) : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCartList() {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: widget.cartItems.length,
      separatorBuilder: (_, _) => const Divider(height: 1, color: Color(0xFFF3F4F6)),
      itemBuilder: (ctx, i) {
        final item = widget.cartItems[i];
        final cs = Theme.of(ctx).colorScheme;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: item.product.imageUrl != null
                    ? Image.network(
                        item.product.imageUrl!,
                        width: 48, height: 48, fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 48, height: 48,
                          color: const Color(0xFFF3F4F6),
                          child: const Icon(Icons.image_outlined, color: Color(0xFFD1D5DB), size: 22),
                        ),
                      )
                    : Container(
                        width: 48, height: 48,
                        color: const Color(0xFFF3F4F6),
                        child: const Icon(Icons.image_outlined, color: Color(0xFFD1D5DB), size: 22),
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.product.name, style: TextStyle(fontFamily: 'Pretendard', color: cs.onSurface, fontSize: 13, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Text(widget.formatPrice(item.totalPrice), style: const TextStyle(fontFamily: 'Pretendard', color: Color(0xFFFF6B4A), fontSize: 12, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => widget.onRemove(item),
                icon: const Icon(Icons.delete_outline, color: Color(0xFFD1D5DB), size: 18),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 8),
              Row(
                children: [
                  _QtyButton(icon: Icons.remove, onTap: () => widget.onDecrement(item)),
                  const SizedBox(width: 10),
                  Text('${item.quantity}', style: TextStyle(fontFamily: 'Pretendard', color: cs.onSurface, fontSize: 14, fontWeight: FontWeight.w700)),
                  const SizedBox(width: 10),
                  _QtyButton(icon: Icons.add, onTap: () => widget.onIncrement(item)),
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
          onPressed: widget.cartItems.isNotEmpty
              ? () => widget.onCheckout(_effectiveTotal, _couponApplied)
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF6B4A),
            disabledBackgroundColor: const Color(0xFFFF6B4A).withOpacity(0.35),
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Text(
            _couponApplied
                ? '${widget.formatPrice(_effectiveTotal)} 결제하기'
                : '결제하기',
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
        decoration: BoxDecoration(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, size: 14, color: Theme.of(context).colorScheme.onSurface),
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
                Icon(Icons.qr_code_rounded, color: Theme.of(context).colorScheme.onSurface, size: 22),
                const SizedBox(width: 8),
                Text('매장 QR 스캔', style: TextStyle(fontFamily: 'Pretendard', color: Theme.of(context).colorScheme.onSurface, fontSize: 18, fontWeight: FontWeight.w700, letterSpacing: -0.3)),
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
                            Text(store['name']!, style: TextStyle(fontFamily: 'Pretendard', color: Theme.of(context).colorScheme.onSurface, fontSize: 15, fontWeight: FontWeight.w700)),
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
  final int? storeId;
  final String? storeName;

  const BuyerProductGrid({
    super.key,
    this.storeId,
    this.storeName,
  });

  @override
  State<BuyerProductGrid> createState() => _BuyerProductGridState();
}

class _BuyerProductGridState extends State<BuyerProductGrid> {
  String _searchQuery = '';
  String _selectedCategory = '전체';
  final List<CartItem> _cartItems = [];
  List<Product> _products = [];
  bool _isLoading = false;

  int get _cartCount => _cartItems.fold(0, (sum, item) => sum + item.quantity);
  int get _cartTotal => _cartItems.fold(0, (sum, item) => sum + item.totalPrice);

  List<String> get _categories {
    final cats = _products.map((p) => p.category).toSet().toList();
    return ['전체', ...cats];
  }

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  @override
  void didUpdateWidget(BuyerProductGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.storeId != widget.storeId) _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    if (widget.storeId == null) return;
    setState(() => _isLoading = true);
    final token = await AuthService.getToken();
    if (token != null) {
      final items = await ApiService.getProducts(
          token: token, storeId: widget.storeId!);
      setState(() {
        _products = items
            .map((e) => Product(
                  name: e.name,
                  price: '${e.price}원',
                  category: e.category,
                  priceValue: e.price,
                  barcode: e.barcode,
                  imageUrl: e.imageUrl,
                ))
            .toList();
      });
    }
    setState(() => _isLoading = false);
  }

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
    if (_cartCount == 0) {
      showDialog(
        context: context,
        barrierColor: Colors.black.withValues(alpha: 0.5),
        builder: (_) => Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 헤더 (기존 장바구니 다이얼로그와 동일)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                  child: Row(
                    children: [
                      Icon(Icons.shopping_cart_rounded, color: Theme.of(context).colorScheme.onSurface, size: 20),
                      const SizedBox(width: 6),
                      Text('장바구니', style: TextStyle(fontFamily: 'Pretendard', color: Theme.of(context).colorScheme.onSurface, fontSize: 17, fontWeight: FontWeight.w700)),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(Icons.close, color: Color(0xFF8B95A1), size: 20),
                      ),
                    ],
                  ),
                ),
                // 빈 장바구니 내용 (기존 _buildEmptyCart와 동일)
                SizedBox(
                  height: 280,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shopping_cart_outlined, color: KColors.navy.withValues(alpha: 0.15), size: 56),
                      const SizedBox(height: 12),
                      Text('장바구니가 비어있습니다', style: TextStyle(fontFamily: 'Pretendard', color: Theme.of(context).colorScheme.onSurface, fontSize: 15, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      const Text('바코드를 스캔하여 상품을 담아보세요', style: TextStyle(fontFamily: 'Pretendard', color: Color(0xFF8B95A1), fontSize: 12)),
                    ],
                  ),
                ),
                // 결제하기 버튼 (비활성화 상태)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF6B4A),
                        disabledBackgroundColor: const Color(0xFFFF6B4A).withOpacity(0.35),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('결제하기', style: TextStyle(fontFamily: 'Pretendard', fontSize: 15, fontWeight: FontWeight.w700, letterSpacing: -0.2)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      return;
    }
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
            storeId: widget.storeId,
            onIncrement: (item) { _incrementQty(item); setDialogState(() {}); },
            onDecrement: (item) { _decrementQty(item); setDialogState(() {}); },
            onRemove: (item) { _removeFromCart(item); setDialogState(() {}); },
            onClear: () { _clearCart(); setDialogState(() {}); },
            onCheckout: (finalAmount, couponUsed) {
              Navigator.pop(context);
              _processTossPayment(finalAmount, couponUsed);
            },
          );
        },
      ),
    );
  }

  Future<void> _processTossPayment(int finalAmount, bool couponUsed) async {
    final token = await AuthService.getToken();
    if (token == null) return;

    final orderName = _cartItems.length == 1
        ? _cartItems.first.product.name
        : '${_cartItems.first.product.name} 외 ${_cartItems.length - 1}건';

    final checkoutInfo = await ApiService.requestTossPayment(
      amount: finalAmount,
      orderName: orderName,
      tossMethod: '간편결제',
    );
    if (checkoutInfo == null || !mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _PaymentProgressOverlay(),
    );

    try {
      final result = await WebAuthHelper.authenticate(
        url: checkoutInfo.checkoutUrl,
        callbackUrlScheme: 'myapp',
      );
      final uri = Uri.parse(result);
      if (!mounted) return;
      if (uri.queryParameters['status'] != 'success') {
        Navigator.pop(context);
        return;
      }

      final paymentKey = uri.queryParameters['paymentKey']!;
      final orderId = uri.queryParameters['orderId']!;
      final amount = int.parse(uri.queryParameters['amount']!);
      final cartSnapshot = List<CartItem>.from(_cartItems);
      final total = finalAmount;
      final count = _cartCount;

      await ApiService.confirmTossPayment(
        token: token,
        paymentKey: paymentKey,
        orderId: orderId,
        amount: amount,
        storeId: widget.storeId ?? 0,
        storeName: widget.storeName ?? '',
        couponUsed: couponUsed,
        items: cartSnapshot.map((i) => {
          'productName': i.product.name,
          'barcode': i.product.barcode,
          'quantity': i.quantity,
          'price': i.totalPrice ~/ i.quantity,
        }).toList(),
      );

      if (!mounted) return;
      Navigator.pop(context);
      _clearCart();
      final nav = Navigator.of(context);
      nav.push(MaterialPageRoute(
        builder: (_) => PaymentCompleteScreen(
          storeName: widget.storeName ?? '',
          paymentMethod: '토스페이',
          cartTotal: total,
          cartCount: count,
          storeId: widget.storeId,
          cartItems: cartSnapshot.map((i) => PaymentCartItem(
            name: i.product.name,
            quantity: i.quantity,
            totalPrice: i.totalPrice,
          )).toList(),
          formatPrice: _formatPrice,
        ),
      ));
    } catch (_) {
      if (mounted) Navigator.pop(context);
    }
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
                      product.imageUrl != null
                          ? Image.network(
                              product.imageUrl!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                              errorBuilder: (_, __, ___) => Container(
                                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.06),
                                child: const Center(child: Icon(Icons.image_outlined, color: Color(0xFFD1D5DB), size: 40)),
                              ),
                              loadingBuilder: (_, child, progress) => progress == null
                                  ? child
                                  : Container(
                                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.06),
                                      child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                                    ),
                            )
                          : Container(
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
                        Text(product.name, style: TextStyle(fontFamily: 'Pretendard', color: Theme.of(context).colorScheme.onSurface, fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: -0.2), maxLines: 2, overflow: TextOverflow.ellipsis),
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
                  decoration: BoxDecoration(color: KColors.primary, shape: BoxShape.circle),
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
// 결제 진행 중 오버레이
// ──────────────────────────────────────────

class _PaymentProgressOverlay extends StatefulWidget {
  const _PaymentProgressOverlay();

  @override
  State<_PaymentProgressOverlay> createState() => _PaymentProgressOverlayState();
}

class _PaymentProgressOverlayState extends State<_PaymentProgressOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))
      ..repeat(reverse: true);
    _pulse = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 24),
            // 아이콘
            AnimatedBuilder(
              animation: _pulse,
              builder: (_, __) => Container(
                width: 80, height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFFF6B4A).withValues(alpha: 0.08 + _pulse.value * 0.08),
                ),
                child: Center(
                  child: Container(
                    width: 60, height: 60,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFFF6B4A),
                    ),
                    child: const Icon(Icons.payment_rounded, color: Colors.white, size: 30),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              '결제가 진행 중입니다.',
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              '다음 단계로 진행되지 않으면\n확인 버튼을 눌러주세요.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 13,
                color: Color(0xFF8B95A1),
                height: 1.6,
              ),
            ),
            SizedBox(height: 280 - 80 - 20 - 30 - 40 - 48),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6B4A),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('확인', style: TextStyle(fontFamily: 'Pretendard', fontSize: 16, fontWeight: FontWeight.w700)),
              ),
            ),
            ),
          ],
        ),
      ),
    );
  }
}
