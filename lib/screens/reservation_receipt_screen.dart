import 'package:flutter/material.dart';

class ReservationReceiptScreen extends StatelessWidget {
  static const routeName = '/reservationReceipt';
  const ReservationReceiptScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    final data = (args is Map) ? args : const <String, dynamic>{};

    final category = data['category']?.toString() ?? '---';
    final total = (data['total'] is num) ? (data['total'] as num).toDouble() : 0.0;
    final from = data['from']?.toString() ?? '---';
    final to = data['to']?.toString() ?? '---';
    final date = data['date']?.toString() ?? '---';
    final count = data['count']?.toString() ?? '---';

    return Scaffold(
      appBar: AppBar(title: const Text('Réservation')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Catégorie: $category'),
            Text('Trajet: $from → $to'),
            Text('Date: $date'),
            Text('Nombre: $count'),
            const SizedBox(height: 16),
            Text(
              'Total: ${total.toStringAsFixed(0)} XFA',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
              child: const Text('Terminer'),
            ),
          ],
        ),
      ),
    );
  }
}
