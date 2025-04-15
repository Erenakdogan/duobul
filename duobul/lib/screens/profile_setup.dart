import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'loading_screen.dart';
import 'homepage.dart';

class ProfileSetupScreen extends StatefulWidget {
  final String email;
  final String username;

  const ProfileSetupScreen({
    super.key,
    required this.email,
    required this.username,
  });

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final List<String> _selectedGames = [];
  final List<String> _games = [
    'League of Legends',
    'CS:GO',
    'Valorant',
    'Battlefield 1'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        title: const Text('Profil Oluştur'),
        centerTitle: true,
        backgroundColor: Colors.blue[100],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.lightBlue.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 5,
                  ),
                ],
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    'Hoş geldin, ${widget.username}!',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.lightBlue[700],
                    ),
                  ),
                  const SizedBox(height: 20),
                  ExpansionTile(
                    title: Text(
                      'Favori Oyunlar',
                      style: TextStyle(color: Colors.lightBlue[700]),
                    ),
                    leading: Icon(Icons.games, color: Colors.lightBlue[400]),
                    backgroundColor: Colors.white,
                    collapsedBackgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                      side:
                          BorderSide(color: Colors.lightBlue.withOpacity(0.5)),
                    ),
                    children: _games
                        .map((game) => CheckboxListTile(
                              title: Text(game),
                              value: _selectedGames.contains(game),
                              onChanged: (bool? value) {
                                setState(() {
                                  if (value == true) {
                                    _selectedGames.add(game);
                                  } else {
                                    _selectedGames.remove(game);
                                  }
                                });
                              },
                            ))
                        .toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                try {
                  final apiService = ApiService();
                  final response = await apiService.updateProfile(
                    widget.email,
                    _selectedGames.join(','),
                  );

                  if (response['success'] == true) {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => LoadingScreen(
                          nextScreen: const HomeScreen(),
                          delay: const Duration(seconds: 2),
                        ),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Hata: ${response['error']}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Bağlantı hatası: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                backgroundColor: Colors.lightBlue[400],
                foregroundColor: Colors.white,
              ),
              child: const Text('Profili Kaydet'),
            ),
          ],
        ),
      ),
    );
  }
}
