enum OrderStatus {
  orderConfirmed,
  preparing,
  onDelivery,
  readyToPickUp,
  completed,
}

extension OrderStatusExtension on OrderStatus {
  String get displayName {
    switch (this) {
      case OrderStatus.orderConfirmed:
        return 'Order Confirmed';
      case OrderStatus.preparing:
        return 'Preparing';
      case OrderStatus.onDelivery:
        return 'On Delivery';
      case OrderStatus.readyToPickUp:
        return 'Ready To Pick Up';
      case OrderStatus.completed:
        return 'Completed';
    }
  }

  String get description {
    switch (this) {
      case OrderStatus.orderConfirmed:
        return 'Your order has been confirmed';
      case OrderStatus.preparing:
        return 'Your food is being prepared';
      case OrderStatus.onDelivery:
        return 'Sedang diantar ke alamat Anda';
      case OrderStatus.readyToPickUp:
        return 'Siap diambil di toko';
      case OrderStatus.completed:
        return 'Order completed';
    }
  }
}

class Order {
  final int? id;
  final int userId;
  final int merchantId;
  final String merchantName;
  final String serviceType; // 'delivery' or 'pickUp'
  final List<OrderItem> items;
  final double subtotal;
  final double deliveryFee;
  final double packagingFee;
  final double appFee;
  final double discount;
  final double coinsUsed;
  final double totalAmount;
  final String paymentMethod;
  final String voucher;
  final OrderStatus status;
  final DateTime createdAt;
  final DateTime? completedAt;

  Order({
    this.id,
    required this.userId,
    required this.merchantId,
    required this.merchantName,
    required this.serviceType,
    required this.items,
    required this.subtotal,
    required this.deliveryFee,
    required this.packagingFee,
    required this.appFee,
    required this.discount,
    required this.coinsUsed,
    required this.totalAmount,
    required this.paymentMethod,
    required this.voucher,
    required this.status,
    required this.createdAt,
    this.completedAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as int?,
      userId: int.parse(json['user_id'].toString()),
      merchantId: int.parse(json['merchant_id'].toString()),
      merchantName: json['merchant_name'] as String? ?? 'Unknown',
      serviceType: json['service_type'] as String? ?? 'delivery',
      items:
          (json['items'] as List<dynamic>?)
              ?.map((item) => OrderItem.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      subtotal: double.tryParse(json['subtotal'].toString()) ?? 0.0,
      deliveryFee: double.tryParse(json['delivery_fee'].toString()) ?? 0.0,
      packagingFee: double.tryParse(json['packaging_fee'].toString()) ?? 0.0,
      appFee: double.tryParse(json['app_fee'].toString()) ?? 0.0,
      discount: double.tryParse(json['discount'].toString()) ?? 0.0,
      coinsUsed: double.tryParse(json['coins_used'].toString()) ?? 0.0,
      totalAmount: double.tryParse(json['total_amount'].toString()) ?? 0.0,
      paymentMethod: json['payment_method'] as String? ?? 'Credit Card',
      voucher: json['voucher'] as String? ?? 'None',
      status: _parseStatus(json['status'] as String?),
      createdAt:
          DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now(),
      completedAt: json['completed_at'] != null
          ? DateTime.tryParse(json['completed_at'].toString())
          : null,
    );
  }

  static OrderStatus _parseStatus(String? status) {
    switch (status) {
      case 'order_confirmed':
        return OrderStatus.orderConfirmed;
      case 'preparing':
        return OrderStatus.preparing;
      case 'on_delivery':
        return OrderStatus.onDelivery;
      case 'ready_to_pickup':
        return OrderStatus.readyToPickUp;
      case 'completed':
        return OrderStatus.completed;
      default:
        return OrderStatus.orderConfirmed;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'merchant_id': merchantId,
      'merchant_name': merchantName,
      'service_type': serviceType,
      'items': items.map((item) => item.toJson()).toList(),
      'subtotal': subtotal,
      'delivery_fee': deliveryFee,
      'packaging_fee': packagingFee,
      'app_fee': appFee,
      'discount': discount,
      'coins_used': coinsUsed,
      'total_amount': totalAmount,
      'payment_method': paymentMethod,
      'voucher': voucher,
      'status': status.name,
      'created_at': createdAt.toIso8601String(),
      if (completedAt != null) 'completed_at': completedAt!.toIso8601String(),
    };
  }
}

class OrderItem {
  final int menuId;
  final String menuName;
  final double price;
  final int quantity;
  final String? image;

  OrderItem({
    required this.menuId,
    required this.menuName,
    required this.price,
    required this.quantity,
    this.image,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      menuId: int.parse(json['menu_id'].toString()),
      menuName: json['menu_name'] as String? ?? 'Unknown',
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      quantity: int.parse(json['quantity'].toString()),
      image: json['image'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'menu_id': menuId,
      'menu_name': menuName,
      'price': price,
      'quantity': quantity,
      if (image != null) 'image': image,
    };
  }
}
