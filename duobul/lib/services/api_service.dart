import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://192.168.0.6/api'; // kendi IP’n

  // Kullanıcı girişi
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login.php'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        try {
          final data = json.decode(response.body);
          return data;
        } catch (e) {
          throw Exception('Sunucu yanıtı geçersiz format içeriyor');
        }
      } else {
        throw Exception('Sunucu hatası: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Bağlantı hatası: $e');
    }
  }

  // Kullanıcı kaydı (güncellenmiş debug'lu)
  Future<Map<String, dynamic>> register(
      String username, String email, String password) async {
    try {
      // Giden veriyi logla
      print('📤 GÖNDERİLEN VERİ:');
      print('username: $username');
      print('email: $email');
      print('password: $password');

      final response = await http.post(
        Uri.parse('$baseUrl/register.php'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'username': username,
          'email': email,
          'password': password,
        }),
      );

      // Sunucudan gelen yanıtı logla
      print('📥 YANIT STATUS CODE: ${response.statusCode}');
      print('📥 YANIT BODY: ${response.body}');

      final data = json.decode(response.body);
      return data;
    } catch (e) {
      throw Exception('Bağlantı hatası: $e');
    }
  }
}
