import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:project_1/colorPallette.dart';
import 'package:project_1/models/payment_history.dart';
import 'package:project_1/providers/app_state_provider.dart';
import 'package:project_1/providers/cart_provider.dart';
import 'package:project_1/services/api_service.dart';
import 'package:provider/provider.dart';
import 'package:project_1/models/cart_item.dart';

enum ServiceType { delivery, pickUp }

class PaymentPage extends StatefulWidget {
  final ServiceType serviceType;

  const PaymentPage({super.key, required this.serviceType});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final List<String> paymentMethods = ['Credit Card', 'GoPay', 'OVO', 'Cash'];

  final List<String> voucherOptions = [
    'None',
    '10% OFF',
    '20K OFF',
    'Free Delivery',
  ];

  String selectedPaymentMethod = 'Credit Card';
  String selectedVoucher = 'None';
  double selectedCoins = 0;
  bool _showSuccessOverlay = false;

  double _deliveryFee() =>
      widget.serviceType == ServiceType.delivery ? 15000 : 0;
  double _packagingFee() => 2000;
  double _appFee() => 3000;

  double _voucherDiscount(double orderTotal) {
    switch (selectedVoucher) {
      case '10% OFF':
        return orderTotal * 0.1;
      case '20K OFF':
        return 20000;
      case 'Free Delivery':
        return widget.serviceType == ServiceType.delivery ? _deliveryFee() : 0;
      default:
        return 0;
    }
  }

  double _totalDue(double orderTotal) {
    final discount = _voucherDiscount(orderTotal) + selectedCoins;
    final total =
        orderTotal + _deliveryFee() + _packagingFee() + _appFee() - discount;
    return total < 0 ? 0 : total;
  }

  String _serviceLabel() {
    return widget.serviceType == ServiceType.delivery ? 'Delivery' : 'Pick Up';
  }

  String _pickupEstimate() {
    return '1.3 km • 14 min walk';
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();
    final availableCoins = context.watch<AppStateProvider>().coins.toDouble();
    final currency = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );

    if (selectedCoins > availableCoins) {
      selectedCoins = availableCoins;
    }

    if (cartProvider.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset("images/FoodSaver_Orange_Main.png", height: 30),
              const SizedBox(width: 6),
              const Text(
                "FoodSaver",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.tigerFlame,
                ),
              ),
            ],
          ),
        ),
        body: const Center(
          child: Text('Cart is empty. Add items before payment.'),
        ),
      );
    }

    final orderTotal = cartProvider.totalPrice;
    final voucherDiscount = _voucherDiscount(orderTotal);
    final totalDue = _totalDue(orderTotal);
    final int rewardCoins = (totalDue * 0.1).round();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.stormyTeal,
        elevation: 6,
        centerTitle: true,
        shadowColor: Colors.black,
        leading: IconButton(
          icon: CircleAvatar(
            backgroundColor: Colors.white,
            radius: 18,
            child: const Icon(Icons.arrow_back, color: Colors.black, size: 20),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset("images/FoodSaver_Orange_Main.png", height: 30),
            const SizedBox(width: 6),
            const Text(
              "FoodSaver",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.tigerFlame,
              ),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order Summary',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 14),

                  Container(
                    padding: const EdgeInsets.all(4.0),
                    decoration: BoxDecoration(
                      color: AppColors.cream,
                      border: Border.all(
                        width: 0.5,
                        color: const Color.fromARGB(255, 137, 137, 137),
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: const Color.fromARGB(
                            255,
                            0,
                            0,
                            0,
                          ).withAlpha(100),
                          spreadRadius: 2,
                          blurRadius: 4,
                          offset: const Offset(3, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ...cartProvider.items.values
                            .map((item) => _buildOrderItem(item, currency))
                            .toList(),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(150),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Text(
                            'Service',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),

                        Text(
                          'Type: ${_serviceLabel()}',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),

                        SizedBox(height: 6),

                        Text(
                          widget.serviceType == ServiceType.delivery
                              ? 'Delivery with additional delivery fee.'
                              : 'Pick Up with estimated walking distance and duration.',
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 13,
                          ),
                        ),

                        const SizedBox(height: 6),
                        if (widget.serviceType == ServiceType.pickUp)
                          Text(
                            'Estimate: ${_pickupEstimate()}',
                            style: const TextStyle(color: Colors.black87),
                          ),
                        if (widget.serviceType == ServiceType.delivery)
                          const Text(
                            'Delivery fee will be added.',
                            style: TextStyle(color: Colors.black87),
                          ),

                        SizedBox(height: 8),

                        const Divider(
                          color: Color.fromARGB(255, 0, 0, 0),
                          thickness: 1.5,
                          indent: 5,
                          endIndent: 5,
                        ),

                        SizedBox(height: 10),

                        Center(
                          child: Text(
                            'Payment Method',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text('Choose how to pay for your order.'),

                        const SizedBox(height: 8),

                        DropdownButtonFormField<String>(
                          dropdownColor: AppColors.stormyTeal,
                          value: selectedPaymentMethod,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: AppColors.stormyTeal,
                                width: 1.5,
                              ),
                            ),

                            filled: true,
                            fillColor: AppColors.stormyTeal,
                          ),
                          borderRadius: BorderRadius.circular(14),
                          items: paymentMethods
                              .map(
                                (method) => DropdownMenuItem(
                                  value: method,
                                  child: Text(
                                    method,
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value == null) return;
                            setState(() => selectedPaymentMethod = value);
                          },
                        ),

                        SizedBox(height: 8),

                        const Divider(
                          color: Color.fromARGB(255, 0, 0, 0),
                          thickness: 1.5,
                          indent: 5,
                          endIndent: 5,
                        ),

                        SizedBox(height: 10),

                        Center(
                          child: Text(
                            'Voucher',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        SizedBox(height: 8),

                        Text('Apply your voucher for extra savings'),

                        SizedBox(height: 8),

                        DropdownButtonFormField<String>(
                          dropdownColor: AppColors.stormyTeal,
                          value: selectedVoucher,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: AppColors.stormyTeal,
                                width: 1.5,
                              ),
                            ),

                            filled: true,
                            fillColor: AppColors.stormyTeal,
                          ),
                          borderRadius: BorderRadius.circular(14),

                          items: voucherOptions
                              .map(
                                (voucher) => DropdownMenuItem(
                                  value: voucher,
                                  child: Text(
                                    voucher,
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value == null) return;
                            setState(() => selectedVoucher = value);
                          },
                        ),

                        SizedBox(height: 8),

                        const Divider(
                          color: Color.fromARGB(255, 0, 0, 0),
                          thickness: 1.5,
                          indent: 5,
                          endIndent: 5,
                        ),

                        SizedBox(height: 10),

                        Center(
                          child: Text(
                            'Coins',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        SizedBox(height: 8),

                        Text('Take your savings to the next level eith Coins'),

                        SizedBox(height: 8),

                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Slider(
                              value: selectedCoins,
                              min: 0,
                              max: availableCoins,
                              divisions: 10,
                              label: currency.format(selectedCoins),
                              activeColor: AppColors.tigerFlame,
                              onChanged: (value) {
                                setState(() {
                                  selectedCoins = value;
                                });
                              },
                            ),
                            Text(
                              'Available: ${currency.format(availableCoins)}',
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Applied coins: ${currency.format(selectedCoins)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  _buildSummaryCard(
                    currency: currency,
                    orderTotal: orderTotal,
                    deliveryFee: _deliveryFee(),
                    packagingFee: _packagingFee(),
                    appFee: _appFee(),
                    voucherDiscount: voucherDiscount,
                    coinsDiscount: selectedCoins,
                    totalDue: totalDue,
                    rewardCoins: rewardCoins,
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 55,

                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 0, 96, 96),
                      ),
                      onPressed: () async {
                        if (_showSuccessOverlay) return;

                        final historyEntry = PaymentHistoryEntry(
                          restaurantName: cartProvider.bakeryName ?? 'Unknown',
                          itemCount: cartProvider.totalItems,
                          totalAmount: totalDue,
                          paymentMethod: selectedPaymentMethod,
                          serviceType: _serviceLabel(),
                          voucher: selectedVoucher,
                          coinsUsed: selectedCoins,
                          date: DateTime.now(),
                        );

                        final userId = context.read<AppStateProvider>().userId;
                        if (userId != null) {
                          final itemsList = cartProvider.items.values
                              .map(
                                (item) => {
                                  'menuId': item.menuId,
                                  'quantity': item.quantity,
                                },
                              )
                              .toList();

                          final result = await ApiService().savePaymentHistory(
                            historyEntry,
                            userId,
                            coinsReward: rewardCoins,
                            items: itemsList,
                          );
                          if (result['status'] == 'success') {
                            if (result['coins'] != null) {
                              final updatedCoins =
                                  int.tryParse(result['coins'].toString()) ??
                                  (context.read<AppStateProvider>().coins -
                                      selectedCoins.toInt() +
                                      rewardCoins);
                              context.read<AppStateProvider>().coins =
                                  updatedCoins;
                            }
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  result['message'] ??
                                      'Payment history failed to save',
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }
                        }

                        cartProvider.addHistory(historyEntry);

                        setState(() {
                          _showSuccessOverlay = true;
                        });

                        Future.delayed(const Duration(seconds: 4), () {
                          if (!mounted) return;
                          cartProvider.clearCart();
                          context.read<AppStateProvider>().selectedIndex = 0;
                          Navigator.popUntil(context, (route) => route.isFirst);
                        });
                      },
                      child: const Text(
                        'Pay Now',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.tigerFlame,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_showSuccessOverlay) _buildSuccessOverlay(),
        ],
      ),
    );
  }

  Widget _buildSuccessOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.black54,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.asset(
                'animation/Payment_Success.json',
                width: 200,
                height: 200,
                repeat: true,
              ),
              const SizedBox(height: 24),

              const Text(
                'Payment Success',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Your payment has been processed successfully.',
                style: TextStyle(color: Colors.white70, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderItem(CartItem item, NumberFormat currency) {
    return Card(
      elevation: 0,
      color: AppColors.stormyTeal,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Colors.black12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                item.image,
                width: 66,
                height: 62,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${item.quantity} x ${currency.format(item.price)}',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
            Text(
              currency.format(item.totalPrice),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard({
    required NumberFormat currency,
    required double orderTotal,
    required double deliveryFee,
    required double packagingFee,
    required double appFee,
    required double voucherDiscount,
    required double coinsDiscount,
    required double totalDue,
    required int rewardCoins,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: Colors.black12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                'Payment Details',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 12),
            _buildLine('Order total', currency.format(orderTotal)),
            _buildLine('Delivery fee', currency.format(deliveryFee)),
            _buildLine('Packaging fee', currency.format(packagingFee)),
            _buildLine('App fee', currency.format(appFee)),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
              decoration: BoxDecoration(
                color: AppColors.cream,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'You will get $rewardCoins coins for this purchase',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.stormyTeal,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),
            _buildLine(
              'Voucher discount',
              '- ${currency.format(voucherDiscount)}',
            ),
            _buildLine('Coins discount', '- ${currency.format(coinsDiscount)}'),
            const SizedBox(height: 12),
            const Divider(height: 28, thickness: 1.1),
            _buildLine('Total', currency.format(totalDue), isBold: true),
          ],
        ),
      ),
    );
  }

  Widget _buildLine(String title, String value, {bool isBold = false}) {
    final textStyle = TextStyle(
      fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: textStyle),
          Text(value, style: textStyle),
        ],
      ),
    );
  }
}
