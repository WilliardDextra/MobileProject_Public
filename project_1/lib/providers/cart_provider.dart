import 'package:flutter/material.dart';
import 'package:project_1/models/cart_item.dart';
import 'package:project_1/models/menu_model.dart';
import 'package:project_1/models/bakery_model.dart';
import 'package:project_1/models/payment_history.dart';

class CartProvider extends ChangeNotifier {
  final Map<int, CartItem> _items = {};
  final List<PaymentHistoryEntry> _history = [];
  Bakery? _bakery;

  Map<int, CartItem> get items => _items;
  Bakery? get bakery => _bakery;
  int? get bakeryId => _bakery?.id;
  String? get bakeryName => _bakery?.name;
  double? get bakeryDistance => _bakery?.distance;

  int get totalItems =>
      _items.values.fold(0, (sum, item) => sum + item.quantity);
  double get totalPrice =>
      _items.values.fold(0, (sum, item) => sum + item.totalPrice);

  List<PaymentHistoryEntry> get history => List.unmodifiable(_history);

  bool get isEmpty => _items.isEmpty;

  bool isSameRestaurant(int bakeryId) {
    return _bakery == null || _bakery?.id == bakeryId;
  }

  void clearCart() {
    _items.clear();
    _bakery = null;
    notifyListeners();
  }

  void addHistory(PaymentHistoryEntry entry) {
    _history.add(entry);
    notifyListeners();
  }

  void setHistory(List<PaymentHistoryEntry> history) {
    _history
      ..clear()
      ..addAll(history);
    notifyListeners();
  }

  bool addItem({
    required Menu menu,
    required Bakery bakery,
    required int quantity,
    bool replaceExisting = false,
  }) {
    if (bakeryId != null && bakeryId != bakery.id) {
      if (!replaceExisting) {
        return false;
      }
      clearCart();
    }

    _bakery = bakery;

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
      _bakery = null;
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
