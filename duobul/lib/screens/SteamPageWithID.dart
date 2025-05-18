import 'package:flutter/material.dart';
import 'SteamPage.dart'; // SteamPage'i import ediyoruz

class SteamPageWithID extends StatelessWidget {
  final String steamUrl;

  const SteamPageWithID({super.key, required this.steamUrl});

  String _extractSteamId(String url) {
    try {
      // URL'yi temizle
      url = url.trim();
      print('Gelen URL: $url'); // Debug için
      
      // URL formatını kontrol et
      if (!url.startsWith('http://') && !url.startsWith('https://')) {
        url = 'https://' + url;
        print('URL düzeltildi: $url'); // Debug için
      }

      // Steam profil URL'sinden Steam ID'yi çıkar
      if (url.contains('/profiles/')) {
        // Doğrudan Steam ID içeren URL
        final parts = url.split('/profiles/');
        if (parts.length > 1) {
          final steamId = parts[1].split('/')[0];
          print('Steam ID bulundu (profiles): $steamId'); // Debug için
          return steamId;
        }
      } else if (url.contains('/id/')) {
        // Custom URL ID içeren URL
        final parts = url.split('/id/');
        if (parts.length > 1) {
          final customId = parts[1].split('/')[0];
          print('Custom ID bulundu: $customId'); // Debug için
          return url; // URL'yi olduğu gibi döndür, SteamPage'de işlenecek
        }
      }
      
      // Eğer URL formatı tanınmıyorsa, gelen değeri olduğu gibi döndür
      print('URL formatı tanınmadı, orijinal değer döndürülüyor: $url'); // Debug için
      return url;
    } catch (e) {
      print('URL işleme hatası: $e'); // Debug için
      return url; // Hata durumunda orijinal değeri döndür
    }
  }

  @override
  Widget build(BuildContext context) {
    final steamId = _extractSteamId(steamUrl);
    print('SteamPageWithID - Final Steam ID: $steamId'); // Debug için
    return SteamPage(steamId: steamId); // SteamPage'i başlatır
  }
}