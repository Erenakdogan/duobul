import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'istatistikler.dart'; // İstatistikler sayfası için import

class SteamPage extends StatefulWidget {
  final String steamId;

  const SteamPage({super.key, required this.steamId});

  @override
  _SteamPageState createState() => _SteamPageState();
}

class _SteamPageState extends State<SteamPage> {
  final String _steamApiKey = '9F5BFDF324E3A7ECF9AA01B77FB511B2'; // Steam API anahtarı
  Map<String, dynamic>? _playerData;
  List<Map<String, dynamic>>? _friendsList;
  List<dynamic>? _ownedGames;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchSteamData();
  }

  Future<void> _fetchSteamData() async {
    try {
      String steamId = widget.steamId;
      print('Başlangıç Steam ID: $steamId'); // Debug için
      
      // Eğer gelen değer bir URL ise ve custom ID içeriyorsa
      if (steamId.contains('steamcommunity.com/id/')) {
        final customId = steamId.split('/id/')[1].split('/')[0];
        print('Custom ID: $customId'); // Debug için
        
        // Steam API'den custom ID'yi Steam ID'ye çevir
        final resolveUrl = 'https://api.steampowered.com/ISteamUser/ResolveVanityURL/v1/?key=$_steamApiKey&vanityurl=$customId';
        print('Resolve URL: $resolveUrl'); // Debug için
        
        final resolveVanityUrlResponse = await http.get(Uri.parse(resolveUrl));
        print('Resolve Response Status: ${resolveVanityUrlResponse.statusCode}'); // Debug için
        print('Resolve Response Body: ${resolveVanityUrlResponse.body}'); // Debug için

        final resolveData = json.decode(resolveVanityUrlResponse.body);
        if (resolveData['response']['success'] == 1) {
          steamId = resolveData['response']['steamid'];
          print('Resolved Steam ID: $steamId'); // Debug için
        } else {
          throw Exception('Steam profil bulunamadı: ${resolveData['response']['message'] ?? 'Bilinmeyen hata'}');
        }
      }

      // Kullanıcı bilgilerini çek
      final playerUrl = 'https://api.steampowered.com/ISteamUser/GetPlayerSummaries/v2/?key=$_steamApiKey&steamids=$steamId';
      print('Player URL: $playerUrl'); // Debug için
      
      final playerResponse = await http.get(Uri.parse(playerUrl));
      print('Player Response Status: ${playerResponse.statusCode}'); // Debug için
      print('Player Response Body: ${playerResponse.body}'); // Debug için

      final playerData = json.decode(playerResponse.body);
      if (playerData['response']['players'] == null || playerData['response']['players'].isEmpty) {
        throw Exception('Steam profili bulunamadı');
      }
      final player = playerData['response']['players'][0];

      // Arkadaş listesini çek
      final friendsUrl = 'https://api.steampowered.com/ISteamUser/GetFriendList/v1/?key=$_steamApiKey&steamid=$steamId';
      print('Friends URL: $friendsUrl'); // Debug için
      
      final friendsResponse = await http.get(Uri.parse(friendsUrl));
      print('Friends Response Status: ${friendsResponse.statusCode}'); // Debug için
      print('Friends Response Body: ${friendsResponse.body}'); // Debug için

      final friendsData = json.decode(friendsResponse.body);
      if (friendsData['friendslist'] == null || friendsData['friendslist']['friends'] == null) {
        throw Exception('Arkadaş listesi alınamadı');
      }
      final friends = friendsData['friendslist']['friends'];

      // Arkadaşların detaylarını çek
      final friendIds = friends.map((friend) => friend['steamid']).join(',');
      final friendsDetailsUrl = 'https://api.steampowered.com/ISteamUser/GetPlayerSummaries/v2/?key=$_steamApiKey&steamids=$friendIds';
      print('Friends Details URL: $friendsDetailsUrl'); // Debug için
      
      final friendsDetailsResponse = await http.get(Uri.parse(friendsDetailsUrl));
      print('Friends Details Response Status: ${friendsDetailsResponse.statusCode}'); // Debug için
      print('Friends Details Response Body: ${friendsDetailsResponse.body}'); // Debug için

      final friendsDetails = json.decode(friendsDetailsResponse.body);
      if (friendsDetails['response']['players'] == null) {
        throw Exception('Arkadaş detayları alınamadı');
      }

      // Sahip olunan oyunları çek
      final gamesUrl = 'https://api.steampowered.com/IPlayerService/GetOwnedGames/v1/?key=$_steamApiKey&steamid=$steamId&include_appinfo=true';
      print('Games URL: $gamesUrl'); // Debug için
      
      final gamesResponse = await http.get(Uri.parse(gamesUrl));
      print('Games Response Status: ${gamesResponse.statusCode}'); // Debug için
      print('Games Response Body: ${gamesResponse.body}'); // Debug için

      final gamesData = json.decode(gamesResponse.body);
      if (gamesData['response'] == null || gamesData['response']['games'] == null) {
        throw Exception('Oyun listesi alınamadı');
      }

      setState(() {
        _playerData = player;
        _friendsList = List<Map<String, dynamic>>.from(friendsDetails['response']['players']);
        _ownedGames = gamesData['response']['games'];
        _isLoading = false;
      });
    } catch (e) {
      print('Steam API Hatası: $e');
      setState(() {
        _isLoading = false;
      });
      // Hata mesajını kullanıcıya göster
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Steam profili yüklenirken hata oluştu: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.purple,
        title: const Text('Steam Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {},
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Kullanıcı Bilgileri
                    if (_playerData != null) ...[
                      Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Colors.purple,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 40,
                              backgroundImage: NetworkImage(_playerData?['avatarfull'] ??
                                  'https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/placeholder.jpg'),
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _playerData?['personaname'] ?? 'Kullanıcı Adı',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  _playerData?['personastate'] == 1
                                      ? 'Çevrimiçi'
                                      : 'Çevrimdışı',
                                  style: const TextStyle(color: Colors.white70),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Arkadaş Listesi
                    const Text(
                      'Arkadaşlar:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 200, // Kaydırılabilir alanın yüksekliği
                      child: ListView.builder(
                        itemCount: _friendsList?.length ?? 0,
                        itemBuilder: (context, index) {
                          final friend = _friendsList![index];
                          return Card(
                            color: Colors.purple,
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundImage: NetworkImage(friend['avatarfull'] ??
                                    'https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/placeholder.jpg'),
                              ),
                              title: Text(
                                friend['personaname'] ?? 'Arkadaş Adı',
                                style: const TextStyle(color: Colors.white),
                              ),
                              subtitle: Text(
                                friend['personastate'] == 1
                                    ? 'Çevrimiçi'
                                    : 'Çevrimdışı',
                                style: const TextStyle(color: Colors.white70),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Sahip Olunan Oyunlar
                    const Text(
                      'Sahip Olunan Oyunlar:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 200, // Kaydırılabilir alanın yüksekliği
                      child: ListView.builder(
                        itemCount: _ownedGames?.length ?? 0,
                        itemBuilder: (context, index) {
                          final game = _ownedGames![index];
                          return Card(
                            color: Colors.purple,
                            child: ListTile(
                              leading: const Icon(Icons.videogame_asset, color: Colors.green),
                              title: Text(
                                game['name'] ?? 'Oyun Adı',
                                style: const TextStyle(color: Colors.white),
                              ),
                              subtitle: Text(
                                'Oynanma Süresi: ${(game['playtime_forever'] ?? 0) ~/ 60} saat',
                                style: const TextStyle(color: Colors.white70),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 20),

                    // İstatistikler Butonu
                    Center(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => IstatistiklerPage(
                                      steamApiKey: _steamApiKey, // Steam API anahtarı
                                      steamId: widget.steamId, // Kullanıcının Steam ID'si
                                    )),
                          );
                        },
                        child: const Text(
                          'CS 2 istatistikler',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}