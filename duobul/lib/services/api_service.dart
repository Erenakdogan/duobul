import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class ApiService {
  static const String baseUrl = 'http://192.168.0.6/api';
  final Duration timeout = const Duration(seconds: 10);

  ApiService();

  // Bağlantı kontrolü
  Future<bool> checkConnection() async {
    try {
      print('🔍 Bağlantı kontrolü yapılıyor: $baseUrl/login.php');
      final response = await http.get(
        Uri.parse('$baseUrl/login.php'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(timeout);

      print('📥 Bağlantı yanıtı: ${response.statusCode}');
      print('📥 Yanıt içeriği: ${response.body}');

      return response.statusCode == 200;
    } catch (e) {
      print('❌ Bağlantı kontrolü hatası: $e');
      if (e is SocketException) {
        print('❌ Soket hatası: Sunucuya bağlanılamıyor');
      } else if (e is TimeoutException) {
        print('❌ Zaman aşımı: Sunucu yanıt vermiyor');
      }
      return false;
    }
  }

  // Kullanıcı girişi
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      print('🔍 Giriş denemesi: $email');
      print('🔍 API URL: $baseUrl/login.php');

      final response = await http
          .post(
            Uri.parse('$baseUrl/login.php'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: json.encode({
              'email': email,
              'password': password,
            }),
          )
          .timeout(timeout);

      print('📥 Sunucu yanıtı: ${response.statusCode}');
      print('📥 Yanıt içeriği: ${response.body}');

      if (response.statusCode == 200) {
        try {
          final data = json.decode(response.body);
          return data;
        } catch (e) {
          print('❌ JSON çözümleme hatası: $e');
          throw Exception('Sunucu yanıtı geçersiz format içeriyor');
        }
      } else {
        print('❌ Sunucu hatası: ${response.statusCode}');
        throw Exception('Sunucu hatası: ${response.statusCode}');
      }
    } on SocketException catch (e) {
      print('❌ Soket hatası: $e');
      throw Exception(
          'Sunucuya bağlanılamıyor. Lütfen internet bağlantınızı ve sunucu durumunu kontrol edin.');
    } on TimeoutException catch (e) {
      print('❌ Zaman aşımı: $e');
      throw Exception(
          'Sunucu yanıt vermiyor. Lütfen daha sonra tekrar deneyin.');
    } catch (e) {
      print('❌ Bağlantı hatası: $e');
      throw Exception('Bir hata oluştu: $e');
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

  // Arkadaşlık isteği gönder
  Future<Map<String, dynamic>> sendFriendRequest(
      String senderEmail, String receiverEmail) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/send_friend_request.php'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'sender_email': senderEmail,
          'receiver_email': receiverEmail,
        }),
      );

      return json.decode(response.body);
    } catch (e) {
      throw Exception('Bağlantı hatası: $e');
    }
  }

  // Arkadaşlık isteklerini getir
  Future<List<Map<String, dynamic>>> getFriendRequests(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/get_friend_requests.php'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'email': email,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          return List<Map<String, dynamic>>.from(data['requests']);
        } else {
          throw Exception(data['message']);
        }
      } else {
        throw Exception('Sunucu hatası: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Bağlantı hatası: $e');
    }
  }

  // Arkadaşlık isteğini kabul et/reddet
  Future<Map<String, dynamic>> respondToFriendRequest(
      String senderEmail, String receiverEmail, String status) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/respond_to_friend_request.php'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'sender_email': senderEmail,
          'receiver_email': receiverEmail,
          'status': status,
        }),
      );

      return json.decode(response.body);
    } catch (e) {
      throw Exception('Bağlantı hatası: $e');
    }
  }

  // Arkadaş listesini getir
  Future<List<Map<String, dynamic>>> getFriends(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/get_friends.php'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'email': email,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          return List<Map<String, dynamic>>.from(data['friends']);
        } else {
          throw Exception(data['message']);
        }
      } else {
        throw Exception('Sunucu hatası: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Bağlantı hatası: $e');
    }
  }

  // Ortak favori oyunları getir
  Future<Map<String, dynamic>> getCommonFavoriteGames(
      String email1, String email2) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/get_common_favorite_games.php'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'email1': email1,
          'email2': email2,
        }),
      );

      return json.decode(response.body);
    } catch (e) {
      throw Exception('Bağlantı hatası: $e');
    }
  }

  // Mesaj gönderme
  Future<Map<String, dynamic>> sendMessage(
      String senderEmail, String receiverEmail, String messageText) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/send_message.php'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'sender_email': senderEmail,
          'receiver_email': receiverEmail,
          'message_text': messageText,
        }),
      );

      return json.decode(response.body);
    } catch (e) {
      throw Exception('Bağlantı hatası: $e');
    }
  }

  // Mesajları getirme
  Future<List<Map<String, dynamic>>> getMessages(
      String userEmail, String friendEmail) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/get_messages.php'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'user_email': userEmail,
          'friend_email': friendEmail,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          return List<Map<String, dynamic>>.from(data['messages']);
        } else {
          throw Exception(data['error']);
        }
      } else {
        throw Exception('Sunucu hatası: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Bağlantı hatası: $e');
    }
  }

  // Okunmamış mesaj sayılarını getirme
  Future<Map<String, int>> getUnreadMessageCounts(String userEmail) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/get_unread_messages.php'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'user_email': userEmail,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          Map<String, int> unreadCounts = {};
          for (var item in data['unread_counts']) {
            unreadCounts[item['sender_email']] = item['unread_count'];
          }
          return unreadCounts;
        } else {
          throw Exception(data['error']);
        }
      } else {
        throw Exception('Sunucu hatası: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Bağlantı hatası: $e');
    }
  }

  // Rank kaydetme
  Future<Map<String, dynamic>> savePlayerRank({
    required String email,
    required int rank,
    required String gameType,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/save_player_rank.php'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body:
            json.encode({'email': email, 'rank': rank, 'game_type': gameType}),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Rank kaydedilemedi');
      }
    } catch (e) {
      print('❌ HATA: $e');
      throw Exception('Bağlantı hatası: $e');
    }
  }

  // Rank bilgisini çekmek için
  Future<Map<String, dynamic>> getPlayerRank({
    required String email,
    required String gameType,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/get_player_rank.php'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'email': email,
          'game_type': gameType,
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Rank bilgisi alınamadı');
      }
    } catch (e) {
      throw Exception('Rank sorgulama hatası: $e');
    }
  }

  // En yakın rankı bulma
  Future<Map<String, dynamic>> findClosestRank(String email, int rank) async {
    try {
      print('🔍 En yakın rank aranıyor:');
      print('Email: $email');
      print('Rank: $rank');

      final response = await http
          .post(
            Uri.parse('$baseUrl/find_closest_rank.php'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: json.encode({'email': email, 'rank': rank}),
          )
          .timeout(timeout);

      print('📥 Sunucu yanıtı: ${response.statusCode}');
      print('📥 Yanıt içeriği: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return data;
        } else {
          throw Exception(data['message'] ?? 'En yakın rank bulunamadı');
        }
      } else {
        throw Exception('Sunucu hatası: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ HATA: $e');
      throw Exception('En yakın rank bulunamadı: $e');
    }
  }

  // Rank aralığında kullanıcıları bulma
  Future<Map<String, dynamic>> findUsersInRankRange(
      String email, int minRank, int maxRank) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/find_users_in_rank_range.php'),
        headers: {'Content-Type': 'application/json'},
        body: json
            .encode({'email': email, 'min_rank': minRank, 'max_rank': maxRank}),
      );
      return json.decode(response.body);
    } catch (e) {
      throw Exception('Rank aralığında kullanıcı bulunamadı: $e');
    }
  }
}
