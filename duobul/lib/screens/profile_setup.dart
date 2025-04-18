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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Profil Oluştur'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
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
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ExpansionTile(
                    title: Text(
                      'Favori Oyunlar',
                      style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
                    ),
                    collapsedIconColor: Theme.of(context).colorScheme.tertiary,
                    collapsedShape: RoundedRectangleBorder(
                      borderRadius: BorderRadiusDirectional.only(
                        topStart: Radius.circular(25),
                        topEnd: Radius.circular(25),
                      )),
                    leading: Icon(Icons.games, color: Theme.of(context).colorScheme.tertiary),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    collapsedBackgroundColor: Theme.of(context).colorScheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                      side:
                          BorderSide(color: Theme.of(context).colorScheme.tertiary, width: 2),
                    ),
                    children: _games
                        .map((game) => CheckboxListTile(
                              title: Text(game),
                              checkColor: Theme.of(context).colorScheme.tertiary,
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
