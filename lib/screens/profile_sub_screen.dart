
import 'package:flutter/material.dart';

class ProfileSubScreen extends StatelessWidget {
  final String title;
  const ProfileSubScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('TODO: Formulaire $title'),
              const Spacer(),
              ElevatedButton(onPressed: ()=>Navigator.pop(context), child: const Text('Enregistrer')),
            ],
          ),
        ),
      ),
    );
  }
}
