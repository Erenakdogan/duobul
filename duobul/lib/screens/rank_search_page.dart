import 'package:flutter/material.dart';
import '../services/api_service.dart';

class RankSearchPage extends StatefulWidget {
  final String email;
  final int rank;
  const RankSearchPage({Key? key, required this.email, required this.rank}) : super(key: key);

  @override
  _RankSearchPageState createState() => _RankSearchPageState();
}

class _RankSearchPageState extends State<RankSearchPage> {
  String? selectedGame;
  String? selectedOption;
  int? minRank;
  int? maxRank;
  List<Map<String, dynamic>>? _closestUsers;
  bool _isSearching = false;
  String? _searchError;
  final ApiService _apiService = ApiService();

  final List<String> games = ['CS:GO', 'League of Legends', 'Valorant'];
  final List<String> options = ['Bana En Yakın Rank', 'Rank Aralığı'];

  Future<void> _search() async {
    setState(() {
      _isSearching = true;
      _searchError = null;
      _closestUsers = null;
    });
    if (selectedOption == 'Bana En Yakın Rank') {
      try {
        final result = await _apiService.findClosestRank(widget.email, widget.rank);
        if (result['success'] == true) {
          final closest = result['closest'];
          if (closest is List) {
            setState(() {
              _closestUsers = List<Map<String, dynamic>>.from(closest);
            });
          } else if (closest is Map) {
            setState(() {
              _closestUsers = [Map<String, dynamic>.from(closest)];
            });
          } else {
            setState(() {
              _closestUsers = [];
            });
          }
        } else {
          setState(() {
            _searchError = result['error'] ?? 'Bilinmeyen hata';
          });
        }
      } catch (e) {
        setState(() {
          _searchError = e.toString();
        });
      } finally {
        setState(() {
          _isSearching = false;
        });
      }
    } else if (selectedOption == 'Rank Aralığı' && minRank != null && maxRank != null) {
      try {
        final result = await _apiService.findUsersInRankRange(widget.email, minRank!, maxRank!);
        if (result['success'] == true) {
          final users = result['users'];
          if (users is List) {
            setState(() {
              _closestUsers = List<Map<String, dynamic>>.from(users);
            });
          } else if (users is Map) {
            setState(() {
              _closestUsers = [Map<String, dynamic>.from(users)];
            });
          } else {
            setState(() {
              _closestUsers = [];
            });
          }
        } else {
          setState(() {
            _searchError = result['error'] ?? 'Bilinmeyen hata';
          });
        }
      } catch (e) {
        setState(() {
          _searchError = e.toString();
        });
      } finally {
        setState(() {
          _isSearching = false;
        });
      }
    } else {
      setState(() {
        _isSearching = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lütfen tüm alanları doldurun!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Rank Arama'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Oyun Seçimi
            DropdownButtonFormField<String>(
              decoration: InputDecoration(labelText: 'Oyun Seçin'),
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
            const SizedBox(height: 20),

            // Seçenekler
            DropdownButtonFormField<String>(
              decoration: InputDecoration(labelText: 'Seçenek Seçin'),
              items: options.map((option) {
                return DropdownMenuItem(
                  value: option,
                  child: Text(option),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedOption = value;
                });
              },
            ),
            const SizedBox(height: 20),

            // Rank Aralığı Girişi (Sadece "Rank Aralığı" seçildiğinde gösterilir)
            if (selectedOption == 'Rank Aralığı') ...[
              TextField(
                decoration: InputDecoration(labelText: 'Minimum Rank'),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  minRank = int.tryParse(value);
                },
              ),
              const SizedBox(height: 10),
              TextField(
                decoration: InputDecoration(labelText: 'Maksimum Rank'),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  maxRank = int.tryParse(value);
                },
              ),
              const SizedBox(height: 20),
            ],

            // Arama Butonu
            Center(
              child: ElevatedButton(
                onPressed: _isSearching ? null : _search,
                child: Text('Ara'),
              ),
            ),
            const SizedBox(height: 20),
            if (_isSearching)
              Center(child: CircularProgressIndicator()),
            if (_closestUsers != null)
              ..._closestUsers!.map((user) => Card(
                child: ListTile(
                  title: Text('Kullanıcı Adı: \\${user['username']}'),
                  subtitle: Text('Rank: \\${user['rank']}'),
                ),
              )),
            if (_searchError != null)
              Center(child: Text('Hata: \\$_searchError', style: TextStyle(color: Colors.red))),
          ],
        ),
      ),
    );
  }
}