import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';

class ProfileScreen extends StatelessWidget {
  static const routeName = '/profile';
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AppState>().currentUser;
    final displayName = user?.displayName ?? '---';
    final email = user?.email ?? '---';
    final phone = user?.phoneNumber ?? '---';

    return Scaffold(
      appBar: AppBar(title: const Text('Mes informations')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            CircleAvatar(
              radius: 40,
              child: Text(
                displayName.isNotEmpty ? displayName[0].toUpperCase() : '?',
              ),
            ),
            const SizedBox(height: 24),
            _infoRow('Nom complet', displayName),
            _infoRow('Email', email),
            _infoRow('Téléphone', phone),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () =>
                  Navigator.of(context).pushNamed('/profile/perso'),
              child: const Text('Informations personnelles'),
            ),
            ElevatedButton(
              onPressed: () =>
                  Navigator.of(context).pushNamed('/profile/contacts'),
              child: const Text('Contacts'),
            ),
            ElevatedButton(
              onPressed: () =>
                  Navigator.of(context).pushNamed('/profile/prefs'),
              child: const Text('Préférences'),
            ),
            ElevatedButton(
              onPressed: () =>
                  Navigator.of(context).pushNamed('/profile/security'),
              child: const Text('Sécurité'),
            ),
            ElevatedButton(
              onPressed: () =>
                  Navigator.of(context).pushNamed('/profile/payments'),
              child: const Text('Paiements'),
            ),
            ElevatedButton(
              onPressed: () =>
                  Navigator.of(context).pushNamed('/profile/docs'),
              child: const Text('Documents'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(label),
        subtitle: Text(value),
      ),
    );
  }
}
