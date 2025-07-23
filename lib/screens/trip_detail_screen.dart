import 'package:flutter/material.dart';
import '../models/trip.dart';
import 'payment_screen.dart';

class TripDetailScreen extends StatelessWidget {
  static const routeName = '/tripDetail';
  const TripDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final trip = ModalRoute.of(context)?.settings.arguments as Trip?;
    if (trip == null) {
      return const Scaffold(
        body: Center(child: Text('Aucun trajet.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Détails du trajet')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${trip.depart} → ${trip.arrivee}',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text('Catégorie: ${trip.category}'),
            const SizedBox(height: 8),
            Text('Date: ${trip.dateDepart}'),
            const SizedBox(height: 8),
            Text('Prix: ${trip.prix.toStringAsFixed(0)} XFA'),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushNamed(
                  PaymentScreen.routeName,
                  arguments: {
                    'category': trip.category,
                    'from': trip.depart,
                    'to': trip.arrivee,
                    'date': trip.dateDepart.toIso8601String(),
                    'count': '1',
                    'prix': trip.prix,
                  },
                );
              },
              child: const Text('Payer'),
            ),
          ],
        ),
      ),
    );
  }
}
