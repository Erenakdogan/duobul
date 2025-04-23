
import 'package:flutter/material.dart';
import 'SteamPage.dart'; // SteamPage'i import ediyoruz

class SteamPageWithID extends StatelessWidget {
  final String steamId;

  const SteamPageWithID({super.key, required this.steamId});

  @override
  Widget build(BuildContext context) {
    return SteamPage(steamId: steamId); // SteamPage'i başlatır
  }
}