class CartItem {
  final int menuId;
  final int bakeryId;
  final String bakeryName;
  final String name;
  final String image;
  final double price;
  int quantity;

  CartItem({
    required this.menuId,
    required this.bakeryId,
    required this.bakeryName,
    required this.name,
    required this.image,
    required this.price,
    required this.quantity,
  });

  double get totalPrice => price * quantity;
}
