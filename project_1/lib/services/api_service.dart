import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:project_1/models/menu_model.dart';
import '../models/bakery_model.dart';

class ApiService {
  static const String _baseUrl = 'http://10.20.138.235:3000/api';

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
}
