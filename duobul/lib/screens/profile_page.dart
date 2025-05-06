import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'settings.dart';

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
  late Future<List<Map<String, dynamic>>> _friendsFuture;
  late Future<List<Map<String, dynamic>>> _friendRequestsFuture;
  final ApiService _apiService = ApiService();
  final TextEditingController _friendEmailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _profileFuture = _apiService.getProfile(widget.email);
    _loadFriendsAndRequests();
  }

  void _loadFriendsAndRequests() {
    setState(() {
      _friendsFuture = _apiService.getFriends(widget.email);
      _friendRequestsFuture = _apiService.getFriendRequests(widget.email);
    });
  }

  Future<void> _showAddFriendDialog() async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Arkadaş Ekle'),
        content: TextField(
          controller: _friendEmailController,
          decoration: const InputDecoration(
            labelText: 'Arkadaşın E-posta Adresi',
            hintText: 'ornek@email.com',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () async {
              if (_friendEmailController.text.isNotEmpty) {
                final response = await _apiService.sendFriendRequest(
                  widget.email,
                  _friendEmailController.text,
                );
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(response['message']),
                      backgroundColor:
                          response['success'] ? Colors.green : Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Ekle'),
          ),
        ],
      ),
    );
  }

  Future<void> _showCommonGamesDialog(String friendEmail) async {
    try {
      final response = await _apiService.getCommonFavoriteGames(
        widget.email,
        friendEmail,
      );

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Ortak Favori Oyunlar'),
            content: SizedBox(
              width: double.maxFinite,
              child: response['common_games'] != null &&
                      response['common_games'].isNotEmpty
                  ? ListView.builder(
                      shrinkWrap: true,
                      itemCount: response['common_games'].length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(response['common_games'][index]),
                        );
                      },
                    )
                  : const Text('Ortak favori oyun bulunamadı'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Kapat'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
                final username = profileData['username'] ?? widget.username;

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
                            username,
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
                    // Arkadaşlar kartı
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Arkadaşlar',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.person_add),
                                onPressed: _showAddFriendDialog,
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          FutureBuilder<List<Map<String, dynamic>>>(
                            future: _friendsFuture,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              }

                              if (snapshot.hasError) {
                                return Text(
                                  'Hata: ${snapshot.error}',
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                                );
                              }

                              final friends = snapshot.data ?? [];

                              if (friends.isEmpty) {
                                return Text(
                                  'Henüz arkadaşınız yok',
                                  style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.onPrimary,
                                  ),
                                );
                              }

                              return ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: friends.length,
                                itemBuilder: (context, index) {
                                  final friend = friends[index];
                                  return ListTile(
                                    title: Text(
                                      friend['username'],
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimary,
                                      ),
                                    ),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.games),
                                      onPressed: () => _showCommonGamesDialog(
                                          friend['email']),
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary,
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Arkadaşlık istekleri kartı
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
                            'Arkadaşlık İstekleri',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                          ),
                          const SizedBox(height: 10),
                          FutureBuilder<List<Map<String, dynamic>>>(
                            future: _friendRequestsFuture,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              }

                              if (snapshot.hasError) {
                                return Text(
                                  'Hata: ${snapshot.error}',
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                                );
                              }

                              final requests = snapshot.data ?? [];

                              if (requests.isEmpty) {
                                return Text(
                                  'Bekleyen arkadaşlık isteği yok',
                                  style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.onPrimary,
                                  ),
                                );
                              }

                              return ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: requests.length,
                                itemBuilder: (context, index) {
                                  final request = requests[index];
                                  return ListTile(
                                    title: Text(
                                      request['username'],
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimary,
                                      ),
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.check),
                                          onPressed: () async {
                                            final response = await _apiService
                                                .respondToFriendRequest(
                                              request['email'],
                                              widget.email,
                                              'accepted',
                                            );
                                            if (mounted) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content:
                                                      Text(response['message']),
                                                  backgroundColor:
                                                      response['success']
                                                          ? Colors.green
                                                          : Colors.red,
                                                ),
                                              );
                                              _loadFriendsAndRequests();
                                            }
                                          },
                                          color: Colors.green,
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.close),
                                          onPressed: () async {
                                            final response = await _apiService
                                                .respondToFriendRequest(
                                              request['email'],
                                              widget.email,
                                              'rejected',
                                            );
                                            if (mounted) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content:
                                                      Text(response['message']),
                                                  backgroundColor:
                                                      response['success']
                                                          ? Colors.green
                                                          : Colors.red,
                                                ),
                                              );
                                              _loadFriendsAndRequests();
                                            }
                                          },
                                          color: Colors.red,
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
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
                    const SizedBox(height: 10),
                    // Ayarlar butonu
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SettingsScreen(),
                          ),
                        );
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
                      child: const Text('Ayarlar'),
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

  Widget _buildGameChip(String game) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.tertiary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        game,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onTertiary,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _friendEmailController.dispose();
    super.dispose();
  }
}
