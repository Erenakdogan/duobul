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
  final String _steamApiKey = '72C9ABCBC62AE377956BCE7213F08D35'; // Steam API anahtarı
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
      final steamId = widget.steamId; // Kullanıcıdan alınan Steam ID
      // Kullanıcı bilgilerini çek
      final playerResponse = await http.get(Uri.parse(
          'https://api.steampowered.com/ISteamUser/GetPlayerSummaries/v2/?key=$_steamApiKey&steamids=$steamId'));
      final playerData = json.decode(playerResponse.body)['response']['players'][0];

      // Arkadaş listesini çek
      final friendsResponse = await http.get(Uri.parse(
          'https://api.steampowered.com/ISteamUser/GetFriendList/v1/?key=$_steamApiKey&steamid=$steamId'));
      final friendsData = json.decode(friendsResponse.body)['friendslist']['friends'];

      // Arkadaşların detaylarını çek
      final friendIds = friendsData.map((friend) => friend['steamid']).join(',');
      final friendsDetailsResponse = await http.get(Uri.parse(
          'https://api.steampowered.com/ISteamUser/GetPlayerSummaries/v2/?key=$_steamApiKey&steamids=$friendIds'));
      final friendsDetails = json.decode(friendsDetailsResponse.body)['response']['players'];

      // Sahip olunan oyunları çek
      final gamesResponse = await http.get(Uri.parse(
          'https://api.steampowered.com/IPlayerService/GetOwnedGames/v1/?key=$_steamApiKey&steamid=$steamId&include_appinfo=true'));
      final gamesData = json.decode(gamesResponse.body)['response']['games'];

      setState(() {
        _playerData = playerData; // Kullanıcı bilgilerini güncelle
        _friendsList = List<Map<String, dynamic>>.from(friendsDetails);
        _ownedGames = gamesData;
        _isLoading = false;
      });
    } catch (e) {
      print('Hata: $e');
      setState(() {
        _isLoading = false;
      });
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