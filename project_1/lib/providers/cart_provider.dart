import 'package:flutter/material.dart';
import 'package:project_1/models/cart_item.dart';
import 'package:project_1/models/menu_model.dart';
import 'package:project_1/models/bakery_model.dart';

class CartProvider extends ChangeNotifier {
  final Map<int, CartItem> _items = {};
  int? _bakeryId;
  String? _bakeryName;

  Map<int, CartItem> get items => _items;
  int? get bakeryId => _bakeryId;
  String? get bakeryName => _bakeryName;

  int get totalItems =>
      _items.values.fold(0, (sum, item) => sum + item.quantity);
  double get totalPrice =>
      _items.values.fold(0, (sum, item) => sum + item.totalPrice);

  bool get isEmpty => _items.isEmpty;

  bool isSameRestaurant(int bakeryId) {
    return _bakeryId == null || _bakeryId == bakeryId;
  }

  void clearCart() {
    _items.clear();
    _bakeryId = null;
    _bakeryName = null;
    notifyListeners();
  }

  bool addItem({
    required Menu menu,
    required Bakery bakery,
    required int quantity,
    bool replaceExisting = false,
  }) {
    if (_bakeryId != null && _bakeryId != bakery.id) {
      if (!replaceExisting) {
        return false;
      }
      clearCart();
    }

    _bakeryId = bakery.id;
    _bakeryName = bakery.name;

    if (_items.containsKey(menu.id)) {
      _items[menu.id]!.quantity += quantity;
    } else {
      _items[menu.id] = CartItem(
        menuId: menu.id,
        bakeryId: bakery.id,
        bakeryName: bakery.name,
        name: menu.fName,
        image: menu.fImage,
        price: menu.fPrice,
        quantity: quantity,
      );
    }

    notifyListeners();
    return true;
  }

  void removeItem(int menuId) {
    _items.remove(menuId);
    if (_items.isEmpty) {
      _bakeryId = null;
      _bakeryName = null;
    }
    notifyListeners();
  }

  void updateQuantity(int menuId, int quantity) {
    if (!_items.containsKey(menuId)) return;
    if (quantity <= 0) {
      removeItem(menuId);
      return;
    }
    _items[menuId]!.quantity = quantity;
    notifyListeners();
  }
}
