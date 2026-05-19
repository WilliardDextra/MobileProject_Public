import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:project_1/models/menu_model.dart';
import 'package:project_1/models/payment_history.dart';
import '../models/bakery_model.dart';

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
}
