import 'package:flutter/material.dart';

class DiaryPage extends StatelessWidget {
  const DiaryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Diary Page'),
      ),
      body: const Center(
        child: Text('Welcome to your Diary'),
      ),
    );
  }
}