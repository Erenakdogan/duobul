import 'package:duobul/screens/profile_page.dart';
import "SteamPage.dart";
import 'SteamPageWithID.dart';
import 'package:duobul/utility/chat_box.dart';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/game_dialog.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'rank_search_page.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  final String email;
  final String username;
  final String favoriteGames;

  const HomeScreen({
    super.key,
    required this.email,
    required this.username,
    required this.favoriteGames,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late List<String> _favoriteGamesList;
  final ApiService _apiService = ApiService();
  int? _currentCSGORating;
  bool _isLoadingRank = false;
  final TextEditingController _ratingController = TextEditingController();
  List<Map<String, dynamic>> _friendsWithLastGame = [];
  bool _isLoadingActivities = true;

  @override
  void initState() {
    super.initState();
    _favoriteGamesList = widget.favoriteGames
        .split(',')
        .where((game) => game.isNotEmpty)
        .toList();
    _loadProfile();
    _loadCSGORating();
    _loadFriendsWithLastGame();
  }

  Future<void> _loadCSGORating() async {
    if (!mounted) return;

    setState(() => _isLoadingRank = true);
    try {
      final response = await _apiService.getPlayerRank(
        email: widget.email,
        gameType: 'csgo',
      );

      if (mounted && response['success'] == true && response['rank'] != null) {
        setState(() {
          _currentCSGORating = response['rank'];
          _isLoadingRank = false;
        });
      }
    } catch (e) {
      print('Rating yüklenirken hata: $e');
      if (mounted) {
        setState(() => _isLoadingRank = false);
      }
    }
  }

  Future<void> _saveCSGORating(int rating) async {
    if (!mounted) return;

    if (rating <= 0 || rating > 100000) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Lütfen geçerli bir rank puanı girin (1-100000)')),
      );
      return;
    }

    setState(() => _isLoadingRank = true);
    try {
      final response = await _apiService.savePlayerRank(
        email: widget.email,
        gameType: 'csgo',
        rank: rating,
      );

      if (mounted) {
        if (response['success'] == true) {
          setState(() {
            _currentCSGORating = rating;
            _isLoadingRank = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Rank kaydedildi: $rating')),
          );
        } else {
          setState(() => _isLoadingRank = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text('Hata: ${response['message'] ?? 'Bilinmeyen hata'}')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingRank = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: ${e.toString()}')),
        );
      }
    }
  }

  void _showCSGORankDialog(BuildContext context) {
    _ratingController.text = _currentCSGORating?.toString() ?? '';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("CS:GO Rankiniz"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "CS:GO rankinizi girin",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _ratingController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(6),
              ],
              decoration: const InputDecoration(
                hintText: "Örn: 25640",
                labelText: "Rank Puanınız",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Not: Rank puanınızı Steam profilinizden öğrenebilirsiniz.",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("İptal"),
          ),
          ElevatedButton(
            onPressed: () {
              final ratingText = _ratingController.text.trim();
              if (ratingText.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Lütfen bir rank puanı girin!')),
                );
                return;
              }

              final rating = int.tryParse(ratingText);
              if (rating == null || rating <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Lütfen geçerli bir rank puanı girin!')),
                );
                return;
              }

              _saveCSGORating(rating);
              Navigator.pop(ctx);
            },
            child: const Text("Kaydet"),
          ),
        ],
      ),
    );
  }

  Future<void> _loadProfile() async {
    try {
      final profileData = await _apiService.getProfile(widget.email);
      if (profileData['success'] == true) {
        setState(() {
          _favoriteGamesList = (profileData['favorite_games'] ?? '')
              .toString()
              .split(',')
              .where((game) => game.isNotEmpty)
              .map((game) => game
                  .replaceAll('"', '')
                  .replaceAll('[', '')
                  .replaceAll(']', '')
                  .trim())
              .toList();
        });
      }
    } catch (e) {
      print('Profil yüklenirken hata: $e');
    }
  }

  Future<void> _loadFriendsWithLastGame() async {
    setState(() => _isLoadingActivities = true);
    try {
      final friends = await _apiService.getFriends(widget.email);
      List<Map<String, dynamic>> result = [];
      for (var friend in friends) {
        String? lastGame;
        String? personastate;
        String? lastlogoff;
        if (friend['steam_url'] != null &&
            friend['steam_url'].toString().isNotEmpty) {
          final steamId = await _extractSteamId(friend['steam_url']);
          if (steamId.isNotEmpty) {
            lastGame = await _getLastPlayedGame(steamId);
            final playerInfo = await _getPlayerInfo(steamId);
            if (playerInfo != null) {
              personastate = _getPersonaStateText(playerInfo['personastate']);
              lastlogoff = _formatLastLogoff(playerInfo['lastlogoff']);
            }
          }
        }
        result.add({
          'username': friend['username'],
          'lastGame': lastGame,
          'personastate': personastate,
          'lastlogoff': lastlogoff,
        });
      }
      setState(() {
        _friendsWithLastGame = result;
        _isLoadingActivities = false;
      });
    } catch (e) {
      setState(() => _isLoadingActivities = false);
    }
  }

  Future<String> _extractSteamId(String url) async {
    if (url.contains('/profiles/')) {
      return url.split('/profiles/')[1].split('/')[0];
    } else if (url.contains('/id/')) {
      final customId = url.split('/id/')[1].split('/')[0];
      final apiKey = '9F5BFDF324E3A7ECF9AA01B77FB511B2';
      final response = await http.get(Uri.parse(
          'https://api.steampowered.com/ISteamUser/ResolveVanityURL/v1/?key=$apiKey&vanityurl=$customId'));
      final data = json.decode(response.body);
      if (data['response']['success'] == 1) {
        return data['response']['steamid'];
      }
    }
    return '';
  }

  Future<String?> _getLastPlayedGame(String steamId) async {
    final apiKey = '9F5BFDF324E3A7ECF9AA01B77FB511B2';
    final url =
        'https://api.steampowered.com/IPlayerService/GetRecentlyPlayedGames/v1/?key=$apiKey&steamid=$steamId';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final games = data['response']['games'];
      if (games != null && games.isNotEmpty) {
        return games[0]['name'];
      }
    }
    return null;
  }

  Future<Map<String, dynamic>?> _getPlayerInfo(String steamId) async {
    final apiKey = '9F5BFDF324E3A7ECF9AA01B77FB511B2';
    final url =
        'https://api.steampowered.com/ISteamUser/GetPlayerSummaries/v2/?key=$apiKey&steamids=$steamId';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['response']['players'] != null &&
            data['response']['players'].isNotEmpty) {
          return data['response']['players'][0];
        }
      }
    } catch (e) {
      print('Steam API Hatası: $e');
    }
    return null;
  }

  String _getPersonaStateText(int? state) {
    switch (state) {
      case 0:
        return 'Çevrimdışı';
      case 1:
        return 'Çevrimiçi';
      case 2:
        return 'Meşgul';
      case 3:
        return 'Uzakta';
      case 4:
        return 'Uyku Modu';
      case 5:
        return 'Ticaret İçin Hazır';
      case 6:
        return 'Oyun İçin Hazır';
      default:
        return 'Bilinmiyor';
    }
  }

  String _formatLastLogoff(int? timestamp) {
    if (timestamp == null) return 'Bilinmiyor';
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays} gün önce';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} saat önce';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} dakika önce';
    } else {
      return 'Az önce';
    }
  }

  final List<String> _popularGames = [
    'League of Legends',
    'Valorant',
    'CS:GO',
    'Fortnite',
    'PUBG',
    'Apex Legends',
    'Dota 2',
    'Rocket League',
  ];

  void _showGameSearch(BuildContext context) {
    showSearch(
      context: context,
      delegate: GameSearchDelegate(_popularGames),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text('DuoBul'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
        leading: IconButton(
          icon: const Icon(Icons.search),
          onPressed: () => _showGameSearch(context),
          color: Theme.of(context).colorScheme.tertiary,
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.person,
                color: Theme.of(context).colorScheme.tertiary),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfilePage(
                    email: widget.email,
                    username: widget.username,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Arka plan ikonları
          Positioned(
            top: 0,
            right: 130,
            child: Transform.rotate(
              angle: -0.7,
              child: Icon(
                Icons.sports_esports,
                size: 200,
                color: Theme.of(context).colorScheme.secondary.withOpacity(0.6),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -30,
            child: Transform.rotate(
              angle: 0.5,
              child: Icon(
                Icons.gamepad,
                size: 200,
                color: Theme.of(context).colorScheme.secondary.withOpacity(0.6),
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.4,
            right: -20,
            child: Transform.rotate(
              angle: -0.3,
              child: Icon(
                Icons.games,
                size: 150,
                color: Theme.of(context).colorScheme.secondary.withOpacity(0.4),
              ),
            ),
          ),
          // Ana içerik
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hoş geldin kartı
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Hoş Geldin!',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Oyun arkadaşını bulmaya hazır mısın?',
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Favori Oyunlar
                if (_favoriteGamesList.isNotEmpty) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Favori Oyunların',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: _favoriteGamesList
                              .map((game) => GestureDetector(
                                    onTap: () {
                                      if (game == 'CS:GO') {
                                        _showCSGORankDialog(context);
                                      } else {
                                        showDialog(
                                          context: context,
                                          builder: (context) =>
                                              GameDialog(gameName: game),
                                        );
                                      }
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 15, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .tertiary,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.games,
                                            size: 20,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onPrimary,
                                          ),
                                          const SizedBox(width: 5),
                                          Text(
                                            game,
                                            style: TextStyle(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onPrimary,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          if (game == 'CS:GO' &&
                                              _currentCSGORating != null) ...[
                                            const SizedBox(width: 5),
                                            Text(
                                              '(${_currentCSGORating})',
                                              style: TextStyle(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onPrimary
                                                    .withOpacity(0.8),
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                          if (game == 'CS:GO' &&
                                              _isLoadingRank) ...[
                                            const SizedBox(width: 5),
                                            SizedBox(
                                              width: 12,
                                              height: 12,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onPrimary,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ))
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
                // Son aktiviteler
                Text(
                  'Son Aktiviteler',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
                const SizedBox(height: 10),
                _buildActivityList(),
                const SizedBox(
                    height: 20), // Buton ile üst içerik arasında boşluk
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_currentCSGORating == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content:
                                  Text('Lütfen önce CS:GO ratinginizi girin')),
                        );
                        return;
                      }
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RankSearchPage(
                            email: widget.email,
                            rank: _currentCSGORating!,
                          ),
                        ),
                      );
                    },
                    child: const Text('Rank Arama'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => chat_box(currentUserEmail: widget.email),
            ),
          );
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: Icon(
          Icons.chat,
          color: Theme.of(context).colorScheme.onPrimary,
        ),
      ),
    );
  }

  Widget _buildActivityList() {
    if (_isLoadingActivities) {
      return const Center(child: CircularProgressIndicator());
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _friendsWithLastGame.length,
      itemBuilder: (context, index) {
        final friend = _friendsWithLastGame[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: Icon(Icons.person,
                    color: Theme.of(context).colorScheme.tertiary),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      friend['username'],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                    if (friend['personastate'] != null)
                      Text(
                        'Durum: ${friend['personastate']}',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontSize: 12,
                        ),
                      ),
                    if (friend['lastGame'] != null)
                      Text(
                        'Son oynadığı oyun: ${friend['lastGame']}',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontSize: 12,
                        ),
                      ),
                    if (friend['lastlogoff'] != null)
                      Text(
                        'Son görülme: ${friend['lastlogoff']}',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontSize: 12,
                        ),
                      ),
                    if (friend['lastGame'] == null &&
                        friend['personastate'] == null)
                      Text(
                        'Steam bağlı değil veya bilgi bulunamadı',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class GameSearchDelegate extends SearchDelegate<String> {
  final List<String> games;

  GameSearchDelegate(this.games);

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.filter_list),
        onPressed: () {
          _showFilterDialog(context);
        },
      ),
      IconButton(
        icon: const Icon(Icons.search),
        onPressed: () {
          _searchWithSteamID(context); // Yeni buton burada çağrılıyor
        },
        tooltip: 'Search with Steam ID',
      ),
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  void _searchWithSteamID(BuildContext context) {
    final TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Steam Profili Ara'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'Steam profil URL\'si girin',
                helperText:
                    'Örnek: https://steamcommunity.com/id/username veya https://steamcommunity.com/profiles/76561198xxxxxxxxx',
              ),
              onSubmitted: (steamUrl) {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SteamPageWithID(steamUrl: steamUrl),
                  ),
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              final steamUrl = controller.text;
              if (steamUrl.isNotEmpty) {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SteamPageWithID(steamUrl: steamUrl),
                  ),
                );
              }
            },
            child: const Text('Ara'),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    String? selectedGame;
    String? selectedRank;
    String? selectedRegion;
    final List<String> regions = [
      'Türkiye',
      'Avrupa',
      'Kuzey Amerika',
      'Güney Amerika',
      'Asya',
      'Okyanusya'
    ];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Filtrele'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Oyun Seçin',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: selectedGame,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  items: games.map((game) {
                    return DropdownMenuItem(
                      value: game,
                      child: Text(game),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedGame = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                if (selectedGame != null) ...[
                  const Text(
                    'Rank Seçin',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: selectedRank,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    items: _getRanksForGame(selectedGame!).map((rank) {
                      return DropdownMenuItem(
                        value: rank,
                        child: Text(rank),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedRank = value;
                      });
                    },
                  ),
                ],
                const SizedBox(height: 16),
                const Text(
                  'Bölge Seçin',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: selectedRegion,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  items: regions.map((region) {
                    return DropdownMenuItem(
                      value: region,
                      child: Text(region),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedRegion = value;
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () {
                if (selectedGame != null &&
                    selectedRank != null &&
                    selectedRegion != null) {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SearchResultsScreen(
                        game: selectedGame!,
                        rank: selectedRank!,
                        region: selectedRegion!,
                      ),
                    ),
                  );
                }
              },
              child: const Text('Ara'),
            ),
          ],
        ),
      ),
    );
  }

  List<String> _getRanksForGame(String game) {
    switch (game) {
      case 'League of Legends':
        return [
          'Iron',
          'Bronze',
          'Silver',
          'Gold',
          'Platinum',
          'Diamond',
          'Master',
          'Grandmaster',
          'Challenger'
        ];
      case 'Valorant':
        return [
          'Iron',
          'Bronze',
          'Silver',
          'Gold',
          'Platinum',
          'Diamond',
          'Ascendant',
          'Immortal',
          'Radiant'
        ];
      case 'CS:GO':
        return [
          'Silver I',
          'Silver II',
          'Silver III',
          'Silver IV',
          'Silver Elite',
          'Silver Elite Master',
          'Gold Nova I',
          'Gold Nova II',
          'Gold Nova III',
          'Gold Nova Master',
          'Master Guardian I',
          'Master Guardian II',
          'Master Guardian Elite',
          'Distinguished Master Guardian',
          'Legendary Eagle',
          'Legendary Eagle Master',
          'Supreme Master First Class',
          'Global Elite'
        ];
      case 'Fortnite':
        return [
          'Bronze',
          'Silver',
          'Gold',
          'Platinum',
          'Diamond',
          'Elite',
          'Champion',
          'Unreal'
        ];
      case 'PUBG':
        return [
          'Bronze',
          'Silver',
          'Gold',
          'Platinum',
          'Diamond',
          'Master',
          'Grandmaster'
        ];
      case 'Apex Legends':
        return [
          'Bronze',
          'Silver',
          'Gold',
          'Platinum',
          'Diamond',
          'Master',
          'Predator'
        ];
      case 'Dota 2':
        return [
          'Herald',
          'Guardian',
          'Crusader',
          'Archon',
          'Legend',
          'Ancient',
          'Divine',
          'Immortal'
        ];
      case 'Rocket League':
        return [
          'Bronze I',
          'Bronze II',
          'Bronze III',
          'Silver I',
          'Silver II',
          'Silver III',
          'Gold I',
          'Gold II',
          'Gold III',
          'Platinum I',
          'Platinum II',
          'Platinum III',
          'Diamond I',
          'Diamond II',
          'Diamond III',
          'Champion I',
          'Champion II',
          'Champion III',
          'Grand Champion I',
          'Grand Champion II',
          'Grand Champion III',
          'Supersonic Legend'
        ];
      default:
        return [
          'Bronze',
          'Silver',
          'Gold',
          'Platinum',
          'Diamond',
          'Master',
          'Grandmaster',
          'Challenger'
        ];
    }
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    if (query.isEmpty) {
      return _buildEmptySearch(context);
    }

    final results = games
        .where((game) => game.toLowerCase().contains(query.toLowerCase()))
        .toList();

    if (results.isEmpty) {
      return _buildNoResults(context);
    }

    return _buildResultsList(context, results);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return _buildEmptySearch(context);
    }

    final suggestions = games
        .where((game) => game.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return _buildResultsList(context, suggestions);
  }

  Widget _buildEmptySearch(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: MediaQuery.of(context).size.width * 0.8,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Oyun ara...',
                border: InputBorder.none,
                icon: Icon(
                  Icons.search,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              onChanged: (value) {
                query = value;
              },
            ),
          ),
          const SizedBox(height: 32),
          Icon(
            Icons.games,
            size: 64,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            'Oyun aramak için yazın veya filtre butonuna tıklayın',
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.onBackground,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResults(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: MediaQuery.of(context).size.width * 0.8,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Oyun ara...',
                border: InputBorder.none,
                icon: Icon(
                  Icons.search,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              onChanged: (value) {
                query = value;
              },
            ),
          ),
          const SizedBox(height: 32),
          Icon(
            Icons.search_off,
            size: 64,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            'Sonuç bulunamadı',
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.onBackground,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsList(BuildContext context, List<String> results) {
    return Column(
      children: [
        Container(
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Oyun ara...',
              border: InputBorder.none,
              icon: Icon(
                Icons.search,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            onChanged: (value) {
              query = value;
            },
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: results.length,
            itemBuilder: (context, index) {
              final game = results[index];
              return ListTile(
                leading: Icon(
                  Icons.games,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: Text(game),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SearchResultsScreen(
                        game: game,
                        rank: 'Tüm Ranklar',
                        region: 'Tüm Bölgeler',
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class SearchResultsScreen extends StatelessWidget {
  final String game;
  final String rank;
  final String region;

  const SearchResultsScreen({
    super.key,
    required this.game,
    required this.rank,
    required this.region,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$game - $rank - $region'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Arama sonuçları burada gösterilecek',
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.onBackground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
