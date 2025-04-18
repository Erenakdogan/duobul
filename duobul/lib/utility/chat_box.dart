import 'package:flutter/material.dart';

class chat_box extends StatefulWidget {
  const chat_box({super.key});

  @override
  State<chat_box> createState() => _chat_boxState();
}

class _chat_boxState extends State<chat_box> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      resizeToAvoidBottomInset: true,
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
              bottom: -8,
              right: -22,
              child: FloatingActionButton(
            onPressed: Navigator.of(context).pop,
            child: const Icon(Icons.close),
            backgroundColor: Theme.of(context).colorScheme.primary,
          )),
          Positioned(
            bottom: 90,
            right: 16,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              width: 280,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text("Yeni Sohbet",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text("Selam! Yardımcı olabileceğim bir şey var mı?"),
                ],
              ),
            ),
          ),
          
        ],
      ),
    );
  }
}
