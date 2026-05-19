class PaymentHistoryEntry {
  final String restaurantName;
  final int itemCount;
  final double totalAmount;
  final String paymentMethod;
  final String serviceType;
  final String voucher;
  final double coinsUsed;
  final DateTime date;

  PaymentHistoryEntry({
    required this.restaurantName,
    required this.itemCount,
    required this.totalAmount,
    required this.paymentMethod,
    required this.serviceType,
    required this.voucher,
    required this.coinsUsed,
    required this.date,
  });
}
