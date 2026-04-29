import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/bakery_model.dart'; // Import model yang sudah dibuat

class BakeryService {
  // Gunakan IP 10.0.2.2 untuk Emulator Android
  // Atau IP laptop (contoh: 192.168.1.5) untuk HP Fisik
  static const String _baseUrl = 'http://192.168.1.102:3000/api/bakeries';

  Future<List<Bakery>> fetchBakeries() async {
    try {
      final response = await http.get(Uri.parse(_baseUrl));

      if (response.statusCode == 200) {
        // Dekode response body
        List<dynamic> body = jsonDecode(response.body);

        // Ubah list JSON menjadi List of Bakery objects
        return body.map((item) => Bakery.fromJson(item)).toList();
      } else {
        throw Exception("Gagal mengambil data: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error: $e");
    }
  }
}
