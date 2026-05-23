import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project_1/colorPallette.dart';
import 'package:project_1/models/order_model.dart';
import 'package:project_1/services/api_service.dart';
import 'package:project_1/providers/app_state_provider.dart';
import 'package:provider/provider.dart';

class MerchantOrdersPage extends StatefulWidget {
  const MerchantOrdersPage({super.key});

  @override
  State<MerchantOrdersPage> createState() => _MerchantOrdersPageState();
}

class _MerchantOrdersPageState extends State<MerchantOrdersPage> {
  late Future<List<Order>> _ordersFuture;
  String _selectedFilter = 'all';
  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  void _loadOrders() {
    final merchantId = context.read<AppStateProvider>().userId ?? 0;
    _ordersFuture = ApiService().fetchMerchantOrdersList(merchantId);
  }

  Future<void> _refresh() async {
    setState(() {
      _loadOrders();
    });
  }

  Future<void> _markFoodReady(Order order) async {
    if (order.status != OrderStatus.preparing) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Only "Preparing" orders can be marked as ready'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final newStatus = order.serviceType == 'delivery'
        ? 'on_delivery'
        : 'ready_to_pickup';
    final result = await ApiService().updateOrderStatus(order.id!, newStatus);

    if (!mounted) return;

    if (result['status'] == 'success') {
      setState(() {
        _loadOrders();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            order.serviceType == 'delivery'
                ? 'Food marked as on delivery'
                : 'Food marked as ready to pick up',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Failed to update status'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  List<Order> _filterOrders(List<Order> orders) {
    if (_selectedFilter == 'all') return orders;
    return orders.where((order) {
      switch (_selectedFilter) {
        case 'preparing':
          return order.status == OrderStatus.preparing;
        case 'on_delivery':
          return order.status == OrderStatus.onDelivery;
        case 'ready_to_pickup':
          return order.status == OrderStatus.readyToPickUp;
        case 'completed':
          return order.status == OrderStatus.completed;
        default:
          return true;
      }
    }).toList();
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
        title: const Text('Orders Management'),
        backgroundColor: AppColors.stormyTeal,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<Order>>(
        future: _ordersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final orders = snapshot.data ?? [];
          final filteredOrders = _filterOrders(orders);

          if (orders.isEmpty) {
            return const Center(child: Text('No orders yet'));
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: Column(
              children: [
                // Filter Tabs
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip('All', 'all'),
                        const SizedBox(width: 8),
                        _buildFilterChip('Preparing', 'preparing'),
                        const SizedBox(width: 8),
                        _buildFilterChip('Delivery', 'on_delivery'),
                        const SizedBox(width: 8),
                        _buildFilterChip('Ready', 'ready_to_pickup'),
                        const SizedBox(width: 8),
                        _buildFilterChip('Completed', 'completed'),
                      ],
                    ),
                  ),
                ),
                // Orders List
                Expanded(
                  child: filteredOrders.isEmpty
                      ? Center(
                          child: Text(
                            'No $_selectedFilter orders',
                            style: const TextStyle(color: Colors.grey),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(12),
                          itemCount: filteredOrders.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final order = filteredOrders[index];
                            return _buildOrderCard(
                              order,
                              currency,
                              onFoodReady: () => _markFoodReady(order),
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = value;
        });
      },
      backgroundColor: Colors.grey.shade200,
      selectedColor: AppColors.stormyTeal,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildOrderCard(
    Order order,
    NumberFormat currency, {
    required VoidCallback onFoodReady,
  }) {
    final statusColor = _getStatusColor(order.status);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order #${order.id}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat(
                          'dd MMM yyyy, HH:mm',
                        ).format(order.createdAt),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: statusColor),
                  ),
                  child: Text(
                    order.status.displayName,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 12),

            // Customer Info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Service Type:'),
                Text(
                  order.serviceType == 'delivery' ? 'Delivery' : 'Pick Up',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Items Summary
            Text(
              '${order.items.length} item${order.items.length > 1 ? 's' : ''}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: order.items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 4),
                itemBuilder: (context, index) {
                  final item = order.items[index];
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          item.menuName,
                          style: const TextStyle(fontSize: 13),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        'x${item.quantity}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 12),

            // Total Amount
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Amount:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  currency.format(order.totalAmount),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.tigerFlame,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Action Button
            if (order.status == OrderStatus.preparing)
              SizedBox(
                width: double.infinity,
                height: 40,
                child: ElevatedButton(
                  onPressed: onFoodReady,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Food Ready',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              )
            else if (order.status == OrderStatus.completed)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green),
                ),
                child: const Text(
                  'Completed',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
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
