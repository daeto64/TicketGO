import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const TestFirestoreApp());
}

class TestFirestoreApp extends StatelessWidget {
  const TestFirestoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TestFirestoreScreen(),
    );
  }
}

class TestFirestoreScreen extends StatefulWidget {
  const TestFirestoreScreen({super.key});

  @override
  State<TestFirestoreScreen> createState() => _TestFirestoreScreenState();
}

class _TestFirestoreScreenState extends State<TestFirestoreScreen> {
  List<String> cities = [];
  bool loading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadCities();
  }

  Future<void> _loadCities() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('villes')
          .orderBy('nom')
          .get();

      if (snapshot.docs.isNotEmpty) {
        setState(() {
          cities = snapshot.docs.map((doc) => doc['nom'] as String).toList();
          loading = false;
        });
      } else {
        setState(() {
          errorMessage = "La collection 'villes' est vide.";
          loading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Erreur Firestore: $e";
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Firestore'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Center(
        child: loading
            ? const CircularProgressIndicator()
            : errorMessage.isNotEmpty
                ? Text(
                    errorMessage,
                    style: const TextStyle(color: Colors.red),
                  )
                : ListView.builder(
                    itemCount: cities.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: const Icon(Icons.location_city),
                        title: Text(cities[index]),
                      );
                    },
                  ),
      ),
    );
  }
}
