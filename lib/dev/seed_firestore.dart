import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../firebase_options.dart'; // Chemin relatif à vérifier selon ton projet

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await seedVilles();

  runApp(const _DoneApp());
}

/// Insère des villes de test dans la collection "villes"
Future<void> seedVilles() async {
  final villesRef = FirebaseFirestore.instance.collection('villes');

  final data = <String, Map<String, dynamic>>{
    'YAO': {'nom': 'Yaoundé', 'pays': 'Cameroun', 'capitale': true,  'population': 3000000},
    'DLA': {'nom': 'Douala',   'pays': 'Cameroun', 'capitale': false, 'population': 4000000},
    'BFS': {'nom': 'Bafoussam','pays': 'Cameroun', 'capitale': false, 'population': 400000},
    'GAR': {'nom': 'Garoua',   'pays': 'Cameroun', 'capitale': false, 'population': 300000},
    'EBO': {'nom': 'Ebolowa',  'pays': 'Cameroun', 'capitale': false, 'population': 150000},
  };

  for (final entry in data.entries) {
    await villesRef.doc(entry.key).set(entry.value);
    debugPrint('Ville ${entry.key} insérée : ${entry.value['nom']}');
  }

  debugPrint('--- Seed Firestore terminé ---');
}

/// Mini app affichant que c’est terminé
class _DoneApp extends StatelessWidget {
  const _DoneApp();

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text(
            'Seed Firestore terminé.\nFerme cette app et relance ton app principale.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
