import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project_1/colorPallette.dart';
import 'package:project_1/models/order_model.dart';
import 'package:project_1/services/api_service.dart';

class OrderStatusPage extends StatefulWidget {
  final int orderId;

  const OrderStatusPage({super.key, required this.orderId});

  @override
  State<OrderStatusPage> createState() => _OrderStatusPageState();
}

class _OrderStatusPageState extends State<OrderStatusPage> {
  late Future<Order?> _orderFuture;
  Order? _currentOrder;

  @override
  void initState() {
    super.initState();
    _loadOrder();
  }

  void _loadOrder() {
    _orderFuture = ApiService().fetchOrder(widget.orderId);
  }

  Future<void> _completeOrder() async {
    if (_currentOrder == null) return;

    final result = await ApiService().updateOrderStatus(
      widget.orderId,
      'completed',
    );

    if (!mounted) return;

    if (result['status'] == 'success') {
      setState(() {
        _loadOrder();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Order completed successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Order Status",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.tigerFlame,
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.stormyTeal,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<Order?>(
        future: _orderFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Order not found'));
          }

          _currentOrder = snapshot.data!;
          final order = _currentOrder!;

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- Status Timeline ---
                _buildStatusTimeline(order),
                const SizedBox(height: 24),

                // --- Order Details Card ---
                _buildOrderDetailsCard(order, currency),
                const SizedBox(height: 16),

                // --- Order Items ---
                _buildOrderItemsSection(order),
                const SizedBox(height: 16),

                // --- Payment Summary ---
                _buildPaymentSummary(order, currency),
                const SizedBox(height: 28),

                // --- DYNAMIC BUTTONS SECTION ---
                if (order.status == OrderStatus.onDelivery ||
                    order.status == OrderStatus.readyToPickUp)
                  SizedBox(
                    width: double.infinity,
                    height:
                        52, // Ditinggikan sedikit agar lebih ergonomis untuk ditekan
                    child: ElevatedButton(
                      onPressed: _completeOrder,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.stormyTeal,
                        foregroundColor: Colors.white,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            16,
                          ), // Kelengkungan sudut modern
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle_outline_rounded, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'I Have Received My Order',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else if (order.status == OrderStatus.preparing)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 20,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors
                          .cream, // Menggunakan warna palet cream dasar Anda
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.tigerFlame.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.tigerFlame,
                            ),
                            strokeWidth: 2.5,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            'Waiting for merchant to finish preparing',
                            style: TextStyle(
                              color: AppColors
                                  .tigerFlame, // Memakai warna aksen utama Anda
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 20,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(
                        0xFFE8F5E9,
                      ), // Lembutnya warna hijau sukses
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.green.shade200,
                        width: 1,
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.stars_rounded,
                          color: Colors.green,
                          size: 22,
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Order Completed',
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusTimeline(Order order) {
    final statuses = [
      OrderStatus.orderConfirmed,
      OrderStatus.preparing,
      order.serviceType == 'delivery'
          ? OrderStatus.onDelivery
          : OrderStatus.readyToPickUp,
      OrderStatus.completed,
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.local_shipping_outlined,
                color: AppColors.stormyTeal,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'Order Status',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.stormyTeal,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // --- TIMELINE ROW ---
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(statuses.length, (index) {
                final status = statuses[index];
                final isCompleted = order.status.index >= status.index;
                final isCurrent = order.status == status;
                final isLast = index == statuses.length - 1;

                return Row(
                  verticalDirection: VerticalDirection.down,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- INDIVIDUAL STATUS NODE ---
                    SizedBox(
                      width:
                          85, // Memberikan fixed width yang aman agar teks 2 baris tidak saling tabrakan
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Lingkaran Status
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: isCompleted
                                  ? AppColors.stormyTeal
                                  : Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isCompleted
                                    ? AppColors.stormyTeal
                                    : (isCurrent
                                          ? AppColors.tigerFlame
                                          : Colors.grey.shade300),
                                width: isCurrent ? 2.5 : 1.5,
                              ),
                              boxShadow: isCurrent
                                  ? [
                                      BoxShadow(
                                        color: AppColors.tigerFlame.withOpacity(
                                          0.3,
                                        ),
                                        blurRadius: 6,
                                      ),
                                    ]
                                  : [],
                            ),
                            child: Center(
                              child: isCompleted
                                  ? const Icon(
                                      Icons.check_rounded,
                                      color: Colors.white,
                                      size: 18,
                                    )
                                  : Text(
                                      (index + 1).toString(),
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: isCurrent
                                            ? AppColors.tigerFlame
                                            : Colors.grey.shade400,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 10),

                          // Label Teks Status
                          Text(
                            status.displayName,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11,
                              height: 1.2,
                              fontWeight: isCurrent
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                              color: isCurrent
                                  ? AppColors.stormyTeal
                                  : (isCompleted
                                        ? Colors.black87
                                        : Colors.grey.shade400),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // --- GARIS PENGHUBUNG (CONNECTOR) ---
                    if (!isLast)
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 17,
                        ), // Mengatur posisi vertikal garis di tengah lingkaran
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: 40, // Panjang garis antar status
                          height: 3, // Ketebalan garis
                          color: isCompleted
                              ? AppColors.stormyTeal
                              : Colors.grey.shade200,
                        ),
                      ),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderDetailsCard(Order order, NumberFormat currency) {
    final bool isDelivery = order.serviceType == 'delivery';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- HEADER CARD (ORDER ID) ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Order Details',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.stormyTeal,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '#${order.id}',
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(color: Colors.black, height: 1),
            ),

            Row(
              children: [
                Icon(
                  Icons.storefront_rounded,
                  size: 18,
                  color: Colors.grey.shade500,
                ),
                const SizedBox(width: 10),
                const Text(
                  'Merchant',
                  style: TextStyle(color: Colors.black54, fontSize: 14),
                ),
                const Spacer(),
                Text(
                  order.merchantName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Icon(
                  isDelivery
                      ? Icons.local_shipping_outlined
                      : Icons.store_mall_directory_outlined,
                  size: 18,
                  color: Colors.grey.shade500,
                ),
                const SizedBox(width: 10),
                const Text(
                  'Service Type',
                  style: TextStyle(color: Colors.black54, fontSize: 14),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isDelivery
                        ? AppColors.tigerFlame.withAlpha(25)
                        : AppColors.stormyTeal.withAlpha(25),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    isDelivery ? 'Delivery' : 'Pick Up',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: isDelivery
                          ? AppColors.tigerFlame
                          : AppColors.stormyTeal,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // --- INFORMASI TANGGAL ORDER ---
            Row(
              children: [
                Icon(
                  Icons.access_time_rounded,
                  size: 18,
                  color: Colors.grey.shade500,
                ),
                const SizedBox(width: 10),
                const Text(
                  'Order Date',
                  style: TextStyle(color: Colors.black54, fontSize: 14),
                ),
                const Spacer(),
                Text(
                  DateFormat('dd MMM yyyy').format(order.createdAt),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                    fontSize: 14,
                  ),
                ),
              ],
            ),

            if (order.status == OrderStatus.completed &&
                order.completedAt != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(
                    Icons.check_circle_outline_rounded,
                    size: 18,
                    color: Colors.green,
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Completed At',
                    style: TextStyle(color: Colors.black54, fontSize: 14),
                  ),
                  const Spacer(),
                  Text(
                    DateFormat('dd MMM yyyy, HH:mm').format(order.completedAt!),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 18),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _getStatusColor(order.status).withAlpha(25),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 18,
                    color: _getStatusColor(order.status),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    order.status.displayName,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _getStatusColor(order.status),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '•  ${order.status.description}',
                      textAlign: TextAlign.end,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: _getStatusColor(order.status).withAlpha(200),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItemsSection(Order order) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- TITLE SECTION ---
            const Row(
              children: [
                Icon(
                  Icons.restaurant_menu_rounded,
                  color: AppColors.stormyTeal,
                  size: 20,
                ),
                SizedBox(width: 8),
                Text(
                  'Items Ordered',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.stormyTeal,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // --- LIST OF ITEMS ---
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: order.items.length,
              separatorBuilder: (context, index) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Divider(color: Colors.grey.shade100, height: 1),
              ),
              itemBuilder: (context, index) {
                final item = order.items[index];
                final double totalItemPrice = item.price * item.quantity;

                return Row(
                  children: [
                    // --- MINI IMAGE CONTAINER (ASSET ONLY WITH WINDOW SHADOW) ---
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: AppColors.cream,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: item.image != null && item.image!.isNotEmpty
                            ? Image.asset(
                                item.image!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(
                                  Icons.fastfood_outlined,
                                  color: AppColors.stormyTeal,
                                  size: 20,
                                ),
                              )
                            : const Icon(
                                Icons.fastfood_outlined,
                                color: AppColors.stormyTeal,
                                size: 20,
                              ),
                      ),
                    ),
                    const SizedBox(width: 14),

                    // --- ITEM DETAILS ---
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  item.menuName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              // Multiplier Badge
                              Text(
                                'x${item.quantity}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: AppColors
                                      .tigerFlame, // Menonjolkan jumlah belanjaan
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Rp${item.price.toStringAsFixed(0)} / unit',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),

                    // --- TOTAL PRICE PER ITEM TYPE ---
                    Text(
                      'Rp${totalItemPrice.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: AppColors.stormyTeal,
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentSummary(Order order, NumberFormat currency) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- TITLE SECTION ---
            const Row(
              children: [
                Icon(
                  Icons.receipt_long_rounded,
                  color: AppColors.stormyTeal,
                  size: 20,
                ),
                SizedBox(width: 8),
                Text(
                  'Payment Summary',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.stormyTeal,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // --- BILL DETAILS ---
            _buildSummaryRow('Subtotal', currency.format(order.subtotal)),

            if (order.deliveryFee > 0) ...[
              const SizedBox(height: 10),
              _buildSummaryRow(
                'Delivery Fee',
                currency.format(order.deliveryFee),
              ),
            ],

            const SizedBox(height: 10),
            _buildSummaryRow(
              'Packaging Fee',
              currency.format(order.packagingFee),
            ),

            const SizedBox(height: 10),
            _buildSummaryRow('App Fee', currency.format(order.appFee)),

            // --- DEDUCTION ITEMS (DISCOUNT / COINS) ---
            if (order.discount > 0) ...[
              const SizedBox(height: 10),
              _buildSummaryRow(
                'Discount',
                '- ${currency.format(order.discount)}',
                color: Colors.green.shade600,
              ),
            ],

            if (order.coinsUsed > 0) ...[
              const SizedBox(height: 10),
              _buildSummaryRow(
                'Coins Used',
                '- ${currency.format(order.coinsUsed)}',
                color: Colors.green.shade600,
              ),
            ],

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Divider(color: Colors.grey.shade100, height: 1),
            ),

            // --- TOTAL AMOUNT ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Amount',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  currency.format(order.totalAmount),
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    color: AppColors
                        .tigerFlame, // Menyoroti total akhir dengan warna aksen api Anda
                  ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Divider(color: Colors.grey.shade100, height: 1),
            ),

            Row(
              children: [
                Text(
                  'Payment Method',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.stormyTeal.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    order.paymentMethod.toUpperCase(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                      color: AppColors.stormyTeal,
                    ),
                  ),
                ),
              ],
            ),

            if (order.voucher != 'None') ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  Text(
                    'Voucher Applied',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.local_activity_outlined,
                    size: 14,
                    color: Colors.amber.shade700,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    order.voucher,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Colors.amber.shade800,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: color != null ? color : Colors.black54,
            fontWeight: color != null ? FontWeight.w600 : FontWeight.normal,
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color != null ? color : Colors.black87,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.orderConfirmed:
        return Colors.blue;
      case OrderStatus.preparing:
        return Colors.orange;
      case OrderStatus.onDelivery:
      case OrderStatus.readyToPickUp:
        return Colors.purple;
      case OrderStatus.completed:
        return Colors.green;
    }
  }
}
