import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ProfilePage extends StatefulWidget {
  final String email;
  final String username;

  const ProfilePage({
    super.key,
    required this.email,
    required this.username,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Future<Map<String, dynamic>> _profileFuture;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _profileFuture = _apiService.getProfile(widget.email);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text('Profil'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
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
          // Ana içerik
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: FutureBuilder<Map<String, dynamic>>(
              future: _profileFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Hata: ${snapshot.error}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  );
                }

                final profileData = snapshot.data!;
                final favoriteGames =
                    profileData['favorite_games']?.toString().split(',') ?? [];

                return Column(
                  children: [
                    // Profil bilgileri kartı
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
                        children: [
                          // Profil fotoğrafı
                          Container(
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
                            child: profileData['profile_photo'] != null
                                ? ClipOval(
                                    child: Image.memory(
                                      profileData['profile_photo'],
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : Icon(
                                    Icons.person,
                                    size: 100,
                                    color:
                                        Theme.of(context).colorScheme.tertiary,
                                  ),
                          ),
                          const SizedBox(height: 20),
                          // Kullanıcı adı
                          Text(
                            widget.username,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                          ),
                          const SizedBox(height: 10),
                          // E-posta
                          Text(
                            widget.email,
                            style: TextStyle(
                              fontSize: 16,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Favori oyunlar kartı
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Favori Oyunlar',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: favoriteGames
                                .map((game) => _buildGameChip(game))
                                .toList(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Profil düzenleme butonu
                    ElevatedButton(
                      onPressed: () {
                        // Profil düzenleme sayfasına yönlendirme
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor:
                            Theme.of(context).colorScheme.onPrimary,
                      ),
                      child: const Text('Profili Düzenle'),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameChip(String gameName) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.tertiary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        gameName,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onPrimary,
          fontSize: 14,
        ),
      ),
    );
  }
}
