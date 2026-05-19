class PaymentHistoryEntry {
  final int? userId;
  final String restaurantName;
  final int itemCount;
  final double totalAmount;
  final String paymentMethod;
  final String serviceType;
  final String voucher;
  final double coinsUsed;
  final DateTime date;

  PaymentHistoryEntry({
    this.userId,
    required this.restaurantName,
    required this.itemCount,
    required this.totalAmount,
    required this.paymentMethod,
    required this.serviceType,
    required this.voucher,
    required this.coinsUsed,
    required this.date,
  });

  factory PaymentHistoryEntry.fromJson(Map<String, dynamic> json) {
    return PaymentHistoryEntry(
      userId: json['user_id'] != null
          ? int.tryParse(json['user_id'].toString())
          : null,
      restaurantName:
          json['restaurant_name'] ?? json['restaurantName'] ?? 'Unknown',
      itemCount: json['item_count'] != null
          ? int.tryParse(json['item_count'].toString()) ?? 0
          : 0,
      totalAmount: json['total_amount'] != null
          ? double.tryParse(json['total_amount'].toString()) ?? 0
          : 0,
      paymentMethod:
          json['payment_method'] ?? json['paymentMethod'] ?? 'Unknown',
      serviceType: json['service_type'] ?? json['serviceType'] ?? 'Unknown',
      voucher: json['voucher'] ?? 'None',
      coinsUsed: json['coins_used'] != null
          ? double.tryParse(json['coins_used'].toString()) ?? 0
          : 0,
      date: DateTime.tryParse(json['date']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (userId != null) 'user_id': userId,
      'restaurant_name': restaurantName,
      'item_count': itemCount,
      'total_amount': totalAmount,
      'payment_method': paymentMethod,
      'service_type': serviceType,
      'voucher': voucher,
      'coins_used': coinsUsed,
      'date': date.toIso8601String(),
    };
  }
}
