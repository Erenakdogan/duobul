import 'package:duobul/screens/profile_page.dart';
import 'package:duobul/utility/chat_box.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  final String email;
  final String username;

  const HomeScreen({
    super.key,
    required this.email,
    required this.username,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
                color: Theme.of(context)
                    .colorScheme
                    .secondary
                    .withValues(alpha: 0.6),
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
                color: Theme.of(context)
                    .colorScheme
                    .secondary
                    .withValues(alpha: 0.6),
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
                color: Theme.of(context)
                    .colorScheme
                    .secondary
                    .withValues(alpha: 0.4),
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
                            .withValues(alpha: 0.2),
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
                SizedBox(
                  height: 150,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _buildGameCard('League of Legends', context),
                      _buildGameCard('Valorant', context),
                      _buildGameCard('CS:GO', context),
                      _buildGameCard('Fortnite', context),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Son aktiviteler
                Center(
                  child: Text(
                    'Son Aktiviteler',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                _buildActivityList(),
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
              builder: (context) => const chat_box(),
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

  Widget _buildGameCard(String gameName, context) {
    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.games,
            size: 40,
            color: Theme.of(context).colorScheme.tertiary,
          ),
          const SizedBox(height: 8),
          Text(
            gameName,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimary,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActivityList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 3,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context)
                    .colorScheme
                    .primary
                    .withValues(alpha: 0.2),
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
                      'Kullanıcı Adı',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                    Text(
                      'League of Legends oyunu için eşleşme arıyor',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.message,
                    color: Theme.of(context).colorScheme.tertiary),
                onPressed: () {
                  // Mesaj gönderme işlemi
                },
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
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
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
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                if (selectedGame != null && selectedRank != null && selectedRegion != null) {
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

    final results = games.where((game) => 
      game.toLowerCase().contains(query.toLowerCase())).toList();
    
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

    final suggestions = games.where((game) => 
      game.toLowerCase().contains(query.toLowerCase())).toList();
    
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
