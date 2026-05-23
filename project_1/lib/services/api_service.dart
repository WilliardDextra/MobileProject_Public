import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:project_1/models/menu_model.dart';
import 'package:project_1/models/payment_history.dart';
import 'package:project_1/models/bakery_model.dart';
import 'package:project_1/models/order_model.dart';

class ApiService {
  static const String _baseUrl = 'http://192.168.1.102:3000/api';

  Future<List<Bakery>> fetchBakeries() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/bakeries'));

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);

        return body.map((item) => Bakery.fromJson(item)).toList();
      } else {
        throw Exception("Failed To Retrive Data: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error: $e");
    }
  }

  Future<List<PaymentHistoryEntry>> fetchPaymentHistory(int userId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/payment-history/$userId'),
    );
    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((item) => PaymentHistoryEntry.fromJson(item)).toList();
    } else {
      throw Exception("Failed to load payment history");
    }
  }

  Future<Map<String, dynamic>> savePaymentHistory(
    PaymentHistoryEntry entry,
    int userId, {
    int coinsReward = 0,
    List<Map<String, dynamic>>? items,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/payment-history'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          ...entry.toJson(),
          'user_id': userId,
          'coins_reward': coinsReward,
          if (items != null) 'items': items,
        }),
      );

      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      return {'status': 'error', 'message': e.toString()};
    }
  }

  Future<List<Menu>> fetchMenus(int bakeryId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/bakeries/$bakeryId/menus'),
    );

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((item) => Menu.fromJson(item)).toList();
    } else {
      throw Exception("Failed To Load Menu");
    }
  }

  // Merchant-specific endpoints
  Future<List<Menu>> fetchMerchantMenus(int userId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/merchant/$userId/menus'),
    );
    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((item) => Menu.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load merchant menus');
    }
  }

  Future<Map<String, dynamic>> createMerchantMenu({
    required int userId,
    required int bakeryId,
    required String name,
    String? image,
    String? description,
    required double price,
    required int stock,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/merchant/menus'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        'user_id': userId,
        'bakery_id': bakeryId,
        'f_name': name,
        'f_image': image,
        'f_description': description,
        'f_price': price,
        'f_stock': stock,
      }),
    );
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateMerchantMenu({
    required int menuId,
    required int userId,
    String? name,
    String? image,
    String? description,
    double? price,
    int? stock,
    int? isActive,
  }) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/merchant/menus/$menuId'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        'user_id': userId,
        if (name != null) 'f_name': name,
        if (image != null) 'f_image': image,
        if (description != null) 'f_description': description,
        if (price != null) 'f_price': price,
        if (stock != null) 'f_stock': stock,
        if (isActive != null) 'is_active': isActive,
      }),
    );
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> deleteMerchantMenu({
    required int menuId,
    required int userId,
  }) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/merchant/menus/$menuId'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({'user_id': userId}),
    );
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> toggleMerchantMenu({
    required int menuId,
    required int userId,
    int? isActive,
  }) async {
    final response = await http.patch(
      Uri.parse('$_baseUrl/merchant/menus/$menuId/toggle-active'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        'user_id': userId,
        if (isActive != null) 'is_active': isActive,
      }),
    );
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<List<dynamic>> fetchMerchantOrders(int userId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/merchant/$userId/orders'),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    } else {
      throw Exception('Failed to load merchant orders');
    }
  }

  Future<Map<String, dynamic>> registerUser({
    required String nama,
    required String email,
    required String phone,
    required String password,
    required String role,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/register'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "nama": nama,
          "email": email,
          "phone": phone,
          "password": password,
          "role": role,
        }),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {"status": "error", "message": e.toString()};
    }
  }

  Future<Map<String, dynamic>> loginUser(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/login'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {"status": "error", "message": "Failed Connecting To Server"};
    }
  }

  Future<Map<String, dynamic>> fetchUserProfile(int userId) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/users/$userId'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      throw Exception('Failed to load user profile');
    } catch (e) {
      throw Exception('Error fetching profile: $e');
    }
  }

  Future<Map<String, dynamic>> updateUserProfile({
    required int userId,
    required String nama,
    required String address,
    String? password,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/users/$userId'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "nama": nama,
          "address": address,
          if (password != null && password.isNotEmpty) "password": password,
        }),
      );
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      return {"status": "error", "message": e.toString()};
    }
  }

  // ==================== ORDER MANAGEMENT ====================

  Future<Map<String, dynamic>> createOrder(Order order) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/orders'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'user_id': order.userId,
          'merchant_id': order.merchantId,
          'merchant_name': order.merchantName,
          'service_type': order.serviceType,
          'items': order.items
              .map(
                (item) => {
                  'menu_id': item.menuId,
                  'menu_name': item.menuName,
                  'price': item.price,
                  'quantity': item.quantity,
                  'image': item.image,
                },
              )
              .toList(),
          'subtotal': order.subtotal,
          'delivery_fee': order.deliveryFee,
          'packaging_fee': order.packagingFee,
          'app_fee': order.appFee,
          'discount': order.discount,
          'coins_used': order.coinsUsed,
          'total_amount': order.totalAmount,
          'payment_method': order.paymentMethod,
          'voucher': order.voucher,
        }),
      );

      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      return {'status': 'error', 'message': e.toString()};
    }
  }

  Future<Order?> fetchOrder(int orderId) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/orders/$orderId'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        if (data['status'] == 'success') {
          return Order.fromJson(data['data']);
        }
      }
      return null;
    } catch (e) {
      throw Exception('Failed to fetch order: $e');
    }
  }

  Future<List<Order>> fetchCustomerOrders(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/orders/user/$userId'),
      );

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        return body
            .map((item) => Order.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch orders: $e');
    }
  }

  Future<List<Order>> fetchMerchantOrdersList(int merchantId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/orders/merchant/$merchantId'),
      );

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        return body
            .map((item) => Order.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch merchant orders: $e');
    }
  }

  Future<Map<String, dynamic>> updateOrderStatus(
    int orderId,
    String status,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/orders/$orderId/status'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({'status': status}),
      );

      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      return {'status': 'error', 'message': e.toString()};
    }
  }

  Future<List<Order>> fetchOrdersByStatus(
    String status, {
    int? userId,
    int? merchantId,
  }) async {
    try {
      String url = '$_baseUrl/orders/status/$status';
      final queryParams = <String, String>{};

      if (userId != null) queryParams['user_id'] = userId.toString();
      if (merchantId != null)
        queryParams['merchant_id'] = merchantId.toString();

      final uri = Uri.parse(url);
      final uriWithParams = uri.replace(
        queryParameters: queryParams.isEmpty ? null : queryParams,
      );

      final response = await http.get(uriWithParams);

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        return body
            .map((item) => Order.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch orders by status: $e');
    }
  }
}
