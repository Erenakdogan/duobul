import 'package:flutter/material.dart';

class chat_box extends StatefulWidget {
  const chat_box({super.key});

  @override
  State<chat_box> createState() => _chat_boxState();
}

class _chat_boxState extends State<chat_box> {
  // Örnek arkadaş listesi
  final List<Friend> _friends = [
    Friend(name: "Ahmet", lastMessage: "Selam! Nasılsın?", time: "12:30", unreadCount: 1),
    Friend(name: "Mehmet", lastMessage: "Oyun oynayalım mı?", time: "11:45", unreadCount: 0),
    Friend(name: "Ayşe", lastMessage: "League rank atalım", time: "10:20", unreadCount: 3),
    Friend(name: "Fatma", lastMessage: "Valorant oynuyor musun?", time: "09:15", unreadCount: 0),
  ];

  // Örnek mesaj geçmişi
  final Map<String, List<Message>> _chatHistory = {
    "Ahmet": [
      Message(text: "Selam! Nasılsın?", isUser: false, senderName: "Ahmet"),
      Message(text: "İyiyim, sen nasılsın?", isUser: true, senderName: "Ben"),
      Message(text: "Bende iyiyim, oyun oynayalım mı?", isUser: false, senderName: "Ahmet"),
    ],
    "Mehmet": [
      Message(text: "Oyun oynayalım mı?", isUser: false, senderName: "Mehmet"),
      Message(text: "Tabii, hangi oyunu oynayalım?", isUser: true, senderName: "Ben"),
    ],
    "Ayşe": [
      Message(text: "League rank atalım", isUser: false, senderName: "Ayşe"),
      Message(text: "Hadi, ben hazırım", isUser: true, senderName: "Ben"),
    ],
    "Fatma": [
      Message(text: "Valorant oynuyor musun?", isUser: false, senderName: "Fatma"),
      Message(text: "Evet, oynuyorum", isUser: true, senderName: "Ben"),
    ],
  };

  void _navigateToChat(BuildContext context, Friend friend) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          friend: friend,
          messages: _chatHistory[friend.name] ?? [],
        ),
      ),
    );
  }

  void _navigateToAddFriend(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddFriendScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Arkadaşlar'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: () => _navigateToAddFriend(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Arama çubuğu
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Arkadaş ara...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
            ),
          ),
          // Arkadaş listesi
          Expanded(
            child: ListView.builder(
              itemCount: _friends.length,
              itemBuilder: (context, index) {
                final friend = _friends[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: Text(
                      friend.name[0],
                      style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
                    ),
                  ),
                  title: Text(
                    friend.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    friend.lastMessage,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        friend.time,
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                      if (friend.unreadCount > 0)
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            friend.unreadCount.toString(),
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimary,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                  onTap: () => _navigateToChat(context, friend),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ChatScreen extends StatefulWidget {
  final Friend friend;
  final List<Message> messages;

  const ChatScreen({
    super.key,
    required this.friend,
    required this.messages,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  late List<Message> _messages;

  @override
  void initState() {
    super.initState();
    _messages = widget.messages;
  }

  void _sendMessage() {
    if (_messageController.text.trim().isNotEmpty) {
      setState(() {
        _messages.add(Message(
          text: _messageController.text,
          isUser: true,
          senderName: "Ben",
        ));
        _messageController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Text(
                widget.friend.name[0],
                style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.friend.name,
                  style: const TextStyle(fontSize: 18),
                ),
                const Text(
                  "Çevrimiçi",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          // Mesajlar
          Expanded(
            child: ListView.builder(
              reverse: true,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[_messages.length - 1 - index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: message.isUser
                        ? MainAxisAlignment.end
                        : MainAxisAlignment.start,
                    children: [
                      if (!message.isUser)
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          child: Text(
                            message.senderName[0],
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimary,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: message.isUser
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context)
                                  .colorScheme
                                  .secondary
                                  .withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          message.text,
                          style: TextStyle(
                            color: message.isUser
                                ? Colors.white
                                : Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          // Mesaj gönderme alanı
          Container(
            padding: const EdgeInsets.all(8),
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
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: "Mesajınızı yazın...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _sendMessage,
                  icon: const Icon(Icons.send),
                  color: Theme.of(context).colorScheme.primary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}

class Friend {
  final String name;
  final String lastMessage;
  final String time;
  final int unreadCount;

  Friend({
    required this.name,
    required this.lastMessage,
    required this.time,
    required this.unreadCount,
  });
}

class Message {
  final String text;
  final bool isUser;
  final String senderName;

  Message({required this.text, required this.isUser, required this.senderName});
}

class AddFriendScreen extends StatefulWidget {
  const AddFriendScreen({super.key});

  @override
  State<AddFriendScreen> createState() => _AddFriendScreenState();
}

class _AddFriendScreenState extends State<AddFriendScreen> {
  final TextEditingController _searchController = TextEditingController();
  final List<Friend> _searchResults = [
    Friend(name: "Ali", lastMessage: "", time: "", unreadCount: 0),
    Friend(name: "Veli", lastMessage: "", time: "", unreadCount: 0),
    Friend(name: "Ayşe", lastMessage: "", time: "", unreadCount: 0),
    Friend(name: "Fatma", lastMessage: "", time: "", unreadCount: 0),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Arkadaş Ekle'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          // Arama çubuğu
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Kullanıcı adı veya e-posta ile ara...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              onChanged: (value) {
                // Arama işlemi burada yapılacak
                setState(() {});
              },
            ),
          ),
          // Arama sonuçları
          Expanded(
            child: ListView.builder(
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                final user = _searchResults[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: Text(
                      user.name[0],
                      style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
                    ),
                  ),
                  title: Text(
                    user.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  trailing: ElevatedButton(
                    onPressed: () {
                      // Arkadaş ekleme işlemi
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${user.name} arkadaşlık isteği gönderildi'),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text('Ekle'),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
