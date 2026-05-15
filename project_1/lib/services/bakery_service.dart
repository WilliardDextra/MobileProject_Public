import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:project_1/models/menu_model.dart';
import '../models/bakery_model.dart';

class BakeryService {
  static const String _baseUrl = 'http://192.168.1.102:3000/api/bakeries';

  Future<List<Bakery>> fetchBakeries() async {
    try {
      final response = await http.get(Uri.parse(_baseUrl));

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);

        return body.map((item) => Bakery.fromJson(item)).toList();
      } else {
        throw Exception("Gagal mengambil data: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error: $e");
    }
  }

  Future<List<Menu>> fetchMenus(int bakeryId) async {
    final response = await http.get(Uri.parse('$_baseUrl/$bakeryId/menus'));

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((item) => Menu.fromJson(item)).toList();
    } else {
      throw Exception("Gagal mengambil menu");
    }
  }
}
