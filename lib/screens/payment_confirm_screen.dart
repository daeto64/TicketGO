import 'package:flutter/material.dart';
import 'reservation_receipt_screen.dart';

class PaymentConfirmScreen extends StatelessWidget {
  static const routeName = '/paymentConfirm';
  const PaymentConfirmScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    final data = (args is Map) ? args : const <String, dynamic>{};

    final category = data['category']?.toString() ?? '---';
    final total = (data['total'] is num) ? (data['total'] as num).toDouble() : 0.0;

    return Scaffold(
      appBar: AppBar(title: const Text('Confirmer Paiement')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text('Vous allez payer ${total.toStringAsFixed(0)} XFA.'),
            Text('Catégorie: $category'),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushNamed(
                  ReservationReceiptScreen.routeName,
                  arguments: data, // transmet tout
                );
              },
              child: const Text('Payer / Valider'),
            ),
          ],
        ),
      ),
    );
  }
}
