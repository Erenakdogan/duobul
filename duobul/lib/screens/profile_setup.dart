import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
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
    'Battlefield 1',
    'Fortnite',
    'PUBG',
    'Apex Legends',
    'Dota 2',
    'Overwatch',
    'Rocket League'
  ];
  File? _profilePhoto;
  final TextEditingController _usernameController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _usernameController.text = widget.username;
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _profilePhoto = File(image.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Fotoğraf seçilirken hata oluştu: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

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
            // Profil Fotoğrafı
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).colorScheme.primary,
                  border: Border.all(
                    color: Theme.of(context).colorScheme.tertiary,
                    width: 2,
                  ),
                ),
                child: _profilePhoto != null
                    ? ClipOval(
                        child: Image.file(
                          _profilePhoto!,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Icon(
                        Icons.add_a_photo,
                        size: 50,
                        color: Theme.of(context).colorScheme.tertiary,
                      ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Profil Fotoğrafı Ekle',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
            const SizedBox(height: 20),
            // Kullanıcı Adı Girişi
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.2),
                    blurRadius: 10,
                    spreadRadius: 5,
                  ),
                ],
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  TextField(
                    controller: _usernameController,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Kullanıcı Adı',
                      labelStyle: TextStyle(
                        color: Theme.of(context).colorScheme.tertiary,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.tertiary,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.tertiary,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.2),
                    blurRadius: 10,
                    spreadRadius: 5,
                  ),
                ],
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    'Hoş geldin, ${_usernameController.text}!',
                    style: TextStyle(
                      fontSize: 20,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ExpansionTile(
                    title: Text(
                      'Favori Oyunlar',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary),
                    ),
                    collapsedIconColor: Theme.of(context).colorScheme.tertiary,
                    collapsedShape: RoundedRectangleBorder(
                        borderRadius: BorderRadiusDirectional.only(
                      topStart: Radius.circular(25),
                      topEnd: Radius.circular(25),
                    )),
                    leading: Icon(Icons.games,
                        color: Theme.of(context).colorScheme.tertiary),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    collapsedBackgroundColor:
                        Theme.of(context).colorScheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                      side: BorderSide(
                          color: Theme.of(context).colorScheme.tertiary,
                          width: 2),
                    ),
                    children: _games
                        .map((game) => CheckboxListTile(
                              title: Text(
                                game,
                                style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimary),
                              ),
                              checkColor:
                                  Theme.of(context).colorScheme.tertiary,
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
                if (_selectedGames.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Lütfen en az bir oyun seçin'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                try {
                  final apiService = ApiService();
                  final response = await apiService.updateProfile(
                    widget.email,
                    _selectedGames.join(','),
                    _profilePhoto,
                    _usernameController.text,
                  );

                  if (response['success'] == true) {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => LoadingScreen(
                          nextScreen: HomeScreen(
                            email: widget.email,
                            username: _usernameController.text,
                            favoriteGames: _selectedGames.join(','),
                          ),
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
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
              ),
              child: const Text('Profili Kaydet'),
            ),
          ],
        ),
      ),
    );
  }
}
