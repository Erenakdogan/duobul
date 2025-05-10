import 'package:duobul/Provider/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text('Ayarlar'),
        centerTitle: true,
      ),
      body: Center(
        child: ListView.builder(
          itemCount: 1,
          itemBuilder: (BuildContext context, int index) {
            return Card(
              elevation: 3,
              margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              color: Theme.of(context).cardColor,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  switch (index) {
                    case 0:
                      showDialog(
                        context: context,
                        builder: (context) {
                          return Consumer<ThemeProvider>(
                            builder: (context, themeProvider, _) {
                              return AlertDialog(
                                title: const Text("Tema Ayarı"),
                                content: SwitchListTile(
                                  title: const Text("Koyu Mod"),
                                  value: themeProvider.isDarkMode,
                                  onChanged: (value) {
                                    themeProvider.toggleTheme(value);
                                    Navigator.of(context).pop();
                                  },
                                ),
                              );
                            },
                          );
                        },
                      );
                      break;
                    case 1:
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Ayar 2 tıklandı')),
                      );
                      // Ayar 2'ye tıklandığında yapılacak işlemler
                      break;
                  }
                },
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Icon(
                        Icons.settings,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Tema Ayarı',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Koyu mod ve açık mod arasında geçiş yapabilirsiniz.',
                              style: TextStyle(
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.color,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios, size: 16),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
