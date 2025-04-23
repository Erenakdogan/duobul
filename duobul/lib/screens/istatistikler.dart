import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class IstatistiklerPage extends StatefulWidget {
  final String steamApiKey;
  final String steamId;
  final String appId; // Örneğin CS:GO için App ID: 730

  const IstatistiklerPage({
    super.key,
    required this.steamApiKey,
    required this.steamId,
    this.appId = '730', // Varsayılan olarak CS:GO
  });

  @override
  _IstatistiklerPageState createState() => _IstatistiklerPageState();
}

class _IstatistiklerPageState extends State<IstatistiklerPage> {
  Map<String, dynamic>? _userStats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserStats();
  }

  Future<void> _fetchUserStats() async {
    try {
      final statsResponse = await http.get(Uri.parse(
          'https://api.steampowered.com/ISteamUserStats/GetUserStatsForGame/v2/?key=${widget.steamApiKey}&steamid=${widget.steamId}&appid=${widget.appId}'));
      if (statsResponse.statusCode == 200) {
        final statsData = json.decode(statsResponse.body)['playerstats'];
        setState(() {
          _userStats = statsData;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        print('İstatistikler alınamadı: ${statsResponse.statusCode}');
      }
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
        title: const Text('İstatistikler'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _userStats != null
              ? Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Başlık
                      Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Colors.purple,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'CS 2 İstatistikleri',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // İstatistik Listesi
                      Expanded(
                        child: ListView.builder(
                          itemCount: _userStats?['stats']?.length ?? 0,
                          itemBuilder: (context, index) {
                            final stat = _userStats!['stats'][index];
                            return Card(
                              color: Colors.purple,
                              margin: const EdgeInsets.symmetric(vertical: 8.0),
                              child: ListTile(
                                leading: const Icon(Icons.bar_chart, color: Colors.green),
                                title: Text(
                                  stat['name'] ?? 'İstatistik Adı',
                                  style: const TextStyle(color: Colors.white),
                                ),
                                subtitle: Text(
                                  'Değer: ${stat['value'] ?? 'Yok'}',
                                  style: const TextStyle(color: Colors.white70),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                )
              : const Center(
                  child: Text(
                    'İstatistikler bulunamadı.',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
    );
  }
}