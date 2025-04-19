import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class ApiService {
  static const String baseUrl = 'http://192.168.0.4/api'; // kendi IP'n

  // Kullanıcı girişi
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      // Giden veriyi logla
      print('📤 GÖNDERİLEN VERİ:');
      print('email: $email');
      print('password: $password');

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

      // Sunucudan gelen yanıtı logla
      print('📥 YANIT STATUS CODE: ${response.statusCode}');
      print('📥 YANIT BODY: ${response.body}');

      if (response.statusCode == 200) {
        try {
          final data = json.decode(response.body);
          return data;
        } catch (e) {
          print('❌ JSON DECODE HATASI: $e');
          throw Exception('Sunucu yanıtı geçersiz format içeriyor');
        }
      } else {
        print('❌ SUNUCU HATASI: ${response.statusCode}');
        print('❌ HATA MESAJI: ${response.body}');
        throw Exception('Sunucu hatası: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ BAĞLANTI HATASI: $e');
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

  // Profil güncelleme
  Future<Map<String, dynamic>> updateProfile(String email, String favoriteGames,
      File? profilePhoto, String username) async {
    try {
      var request = http.MultipartRequest(
          'POST', Uri.parse('$baseUrl/update_profile.php'));

      // Temel verileri ekle
      request.fields['email'] = email;
      request.fields['favorite_games'] = favoriteGames;
      request.fields['username'] = username;

      // Profil fotoğrafı varsa ekle
      if (profilePhoto != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'profile_photo',
            profilePhoto.path,
            contentType: MediaType('image', 'jpeg'),
          ),
        );
      }

      // Debug için gönderilen verileri yazdır
      print('📤 GÖNDERİLEN VERİLER:');
      print('email: $email');
      print('username: $username');
      print('favorite_games: $favoriteGames');
      print('profile_photo: ${profilePhoto != null ? "Var" : "Yok"}');

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      // Debug için gelen yanıtı yazdır
      print('📥 YANIT STATUS CODE: ${response.statusCode}');
      print('📥 YANIT BODY: $responseBody');

      if (response.statusCode == 200) {
        try {
          final data = json.decode(responseBody);
          return data;
        } catch (e) {
          print('❌ JSON DECODE HATASI: $e');
          throw Exception('Sunucu yanıtı geçersiz format içeriyor');
        }
      } else {
        print('❌ SUNUCU HATASI: ${response.statusCode}');
        print('❌ HATA MESAJI: $responseBody');
        throw Exception('Sunucu hatası: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ BAĞLANTI HATASI: $e');
      throw Exception('Bağlantı hatası: $e');
    }
  }

  // Profil bilgilerini getir
  Future<Map<String, dynamic>> getProfile(String email) async {
    try {
      print('📤 Profil bilgileri isteniyor: $email');

      final response = await http.post(
        Uri.parse('$baseUrl/get_profile.php'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'email': email,
        }),
      );

      print('📥 Sunucu yanıtı: ${response.statusCode}');
      print('📥 Yanıt gövdesi: ${response.body}');

      if (response.statusCode == 200) {
        try {
          final data = json.decode(response.body);
          print('📥 Çözümlenen veri: $data');

          if (data['success'] == true) {
            // Profil fotoğrafını base64'ten çöz
            if (data['profile_photo'] != null) {
              try {
                data['profile_photo'] = base64Decode(data['profile_photo']);
                print('✅ Profil fotoğrafı başarıyla çözüldü');
              } catch (e) {
                print('❌ Profil fotoğrafı çözme hatası: $e');
                data['profile_photo'] = null;
              }
            }
            return data;
          } else {
            throw Exception(data['error'] ?? 'Profil getirilemedi');
          }
        } catch (e) {
          print('❌ JSON çözümleme hatası: $e');
          throw Exception(
              'Sunucu yanıtı geçersiz format içeriyor: ${response.body}');
        }
      } else {
        throw Exception('Sunucu hatası: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Bağlantı hatası: $e');
      throw Exception('Bağlantı hatası: $e');
    }
  }
}
