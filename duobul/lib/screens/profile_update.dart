import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';

class ProfileUpdate extends StatefulWidget {
  final String email;

  const ProfileUpdate({
    Key? key,
    required this.email,
  }) : super(key: key);

  @override
  _ProfileUpdateState createState() => _ProfileUpdateState();
}

class _ProfileUpdateState extends State<ProfileUpdate> {
  static const String baseUrl = 'http://localhost/api';
  File? _image;
  final ImagePicker _picker = ImagePicker();
  List<String> favoriteGames = [];
  List<String> allGames = [
    'Minecraft',
    'Fortnite',
    'PUBG',
    'Valorant',
    'CS:GO',
    'League of Legends',
    'Dota 2',
    'GTA V'
  ];

  @override
  void initState() {
    super.initState();
    if (widget.email.isEmpty) {
      print('HATA: Email boş olamaz!');
      return;
    }
    print('ProfileUpdate sayfasındaki email: ${widget.email}');
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final response = await http.get(
      Uri.parse('$baseUrl/get_user_data.php?email=${widget.email}'),
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      if (jsonResponse['success'] == true) {
        final data = jsonResponse['data'];
        if (data['profile_photo'] != null) {
          // Base64 formatındaki profil fotoğrafını göster
          final bytes = base64Decode(data['profile_photo']);
          final tempDir = await getTemporaryDirectory();
          final file = File('${tempDir.path}/profile_photo.jpg');
          await file.writeAsBytes(bytes);
          setState(() {
            _image = file;
            if (data['favorite_games'] != null) {
              favoriteGames = List<String>.from(data['favorite_games']);
            }
          });
        } else {
          setState(() {
            if (data['favorite_games'] != null) {
              favoriteGames = List<String>.from(data['favorite_games']);
            }
          });
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  jsonResponse['error'] ?? 'Kullanıcı bilgileri alınamadı')),
        );
      }
    }
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _updateProfile() async {
    print('_updateProfile fonksiyonu başladı');
    print('Email: ${widget.email}');

    // Loading ekranını göster
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/update_profile.php'),
    );

    request.fields['email'] = widget.email;
    request.fields['favorite_games'] = json.encode(favoriteGames);

    print('Gönderilen veriler:');
    print('Email: ${widget.email}');
    print('Favori Oyunlar: ${json.encode(favoriteGames)}');

    if (_image != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'profile_photo',
          _image!.path,
        ),
      );
      print('Profil fotoğrafı eklendi: ${_image!.path}');
    }

    try {
      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      print('API Yanıtı: $responseData');

      final jsonResponse = json.decode(responseData);

      // Loading ekranını kapat
      Navigator.pop(context);

      if (response.statusCode == 200 && jsonResponse['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil başarıyla güncellendi')),
        );

        // Profil sayfasına dön ve yenileme yap
        if (mounted) {
          Navigator.pop(context,
              true); // true değeri ile dön, bu sayede profil sayfası yenilenecek
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(jsonResponse['error'] ??
                  'Profil güncellenirken bir hata oluştu')),
        );
      }
    } catch (e) {
      // Loading ekranını kapat
      Navigator.pop(context);

      print('Hata oluştu: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profili Güncelle'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: _image != null ? FileImage(_image!) : null,
                  child: _image == null
                      ? const Icon(Icons.add_a_photo, size: 40)
                      : null,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Favori Oyunlar',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  children: allGames.map((game) {
                    final isSelected = favoriteGames.contains(game);
                    return FilterChip(
                      label: Text(game),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            favoriteGames.add(game);
                          } else {
                            favoriteGames.remove(game);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 30),
              Container(
                width: 200,
                child: ElevatedButton(
                  onPressed: () {
                    print('Butona basıldı');
                    _updateProfile();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Profili Güncelle',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
