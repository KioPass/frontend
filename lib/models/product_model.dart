class Product {
  final String name;
  final String price;
  final String category;
  final int priceValue;

  const Product({
    required this.name,
    required this.price,
    required this.category,
    required this.priceValue,
  });
}

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  int get totalPrice => product.priceValue * quantity;
}