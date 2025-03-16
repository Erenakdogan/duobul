import 'package:flutter/material.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _usernameController = TextEditingController();
  bool _isGameListExpanded = false;
  final List<String> _games = [
    'League of Legends',
    'CS:GO',
    'Valorant',
    'Battlefield 1'
  ];

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

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
                  TextFormField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      labelText: 'Kullanıcı Adı',
                      labelStyle: TextStyle(color: Colors.lightBlue[700]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide(
                            color: Colors.lightBlue.withOpacity(0.5)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide:
                            BorderSide(color: Colors.lightBlue[400]!, width: 2),
                      ),
                      prefixIcon:
                          Icon(Icons.person, color: Colors.lightBlue[400]),
                      filled: true,
                      fillColor: Colors.white,
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
                        .map((game) => ListTile(
                              leading: Icon(Icons.gamepad,
                                  color: Colors.lightBlue[400]),
                              title: Text(game),
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 24),
                            ))
                        .toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // Profil kaydetme işlemleri burada yapılacak
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
