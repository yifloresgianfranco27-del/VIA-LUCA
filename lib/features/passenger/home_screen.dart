import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('VIA LUCA', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1E88E5),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.local_taxi, size: 80, color: Color(0xFF1E88E5)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Solicitar VIA LUCA'),
            ),
          ],
        ),
      ),
    );
  }
}
