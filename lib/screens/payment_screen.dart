import 'package:flutter/material.dart';
import 'payment_confirm_screen.dart';

/// Écran de paiement.
/// Calcule automatiquement le prix par personne selon le couple (from, to)
/// en s'appuyant sur un barème interne (_routePrices) basé sur les villes
/// connues en base (Douala, Yaoundé, Ebolowa, Bafoussam, Garoua).
///
/// Arguments attendus via ModalRoute:
/// {
///   'category': String,
///   'from': String,
///   'to': String,
///   'date': String,
///   'count': int,
///   'tripType': String,         // 'Aller simple' ou 'Aller-retour' ...
///   'prix': double (facultatif) // si fourni, priorité sur calcul interne
/// }
class PaymentScreen extends StatelessWidget {
  static const routeName = '/payment';
  const PaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    final data = (args is Map) ? args : const <String, dynamic>{};

    final category = data['category']?.toString() ?? 'Général';
    final from = data['from']?.toString() ?? '';
    final to = data['to']?.toString() ?? '';
    final date = data['date']?.toString() ?? '';
    final count = int.tryParse('${data['count'] ?? '1'}') ?? 1;
    final tripType = data['tripType']?.toString() ?? 'Aller simple';

    // Prix transmis (si tu veux forcer un prix venant d'ailleurs).
    final prixArg =
        (data['prix'] is num) ? (data['prix'] as num).toDouble() : null;

    // Prix effectif par personne : argument > table interne.
    final prix = prixArg ?? _priceForRoute(from, to);

    // Total. (Si tu comptes l'aller-retour comme double, applique un facteur 2.)
    final total = prix * count;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF8B5A9C)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Icon(
                Icons.confirmation_number,
                color: Colors.white,
                size: 16,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'Ticket Go',
              style: TextStyle(
                color: Colors.orange,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: const [SizedBox(width: 48)], // équilibre visuel
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            const SizedBox(height: 32),

            // Titre principal (catégorie)
            Text(
              category,
              style: const TextStyle(
                fontSize: 28,
                color: Color(0xFFE8A5A5),
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 40),

            // Section infos billet
            Column(
              children: [
                _buildInfoRow('Destination:', '$from - $to'),
                const SizedBox(height: 20),
                _buildInfoRow('Reference:', tripType),
                const SizedBox(height: 20),
                _buildInfoRow('Description:', '$from - $to'),
                const SizedBox(height: 20),
                _buildInfoRow('A payer:', '${_fmt(prix)} XAF'),
              ],
            ),

            const SizedBox(height: 40),

            // Section total & paiement
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F8F8),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Compte: ${_fmt(total)} XAF',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed(
                        PaymentConfirmScreen.routeName,
                        arguments: {
                          'category': category,
                          'total': total,
                          'from': from,
                          'to': to,
                          'date': date,
                          'count': count,
                          'tripType': tripType,
                          'prixUnit': prix,
                        },
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5D4E75),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 8,
                      ),
                    ),
                    child: const Text(
                      'payer',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // Section moyens de paiement
            const Text(
              'choix de payement',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildPaymentCard(Colors.orange, 'OM'),
                const SizedBox(width: 16),
                _buildPaymentCard(Colors.yellow, 'MTN'),
                const SizedBox(width: 16),
                _buildPaymentCard(Colors.blue, 'VISA'),
              ],
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Widgets utilitaires
  // ---------------------------------------------------------------------------

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black,
          ),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF6B5B95),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentCard(Color color, String text) {
    return Container(
      width: 60,
      height: 40,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Prix par trajet
  // ---------------------------------------------------------------------------

  /// Prix par personne en XAF selon la paire de villes.
  /// Les clés sont **normalisées** (minuscules sans accents) et triées.
  double _priceForRoute(String from, String to) {
    final f = _normCity(from);
    final t = _normCity(to);

    if (f.isEmpty || t.isEmpty) return 0;
    if (f == t) return 0;

    final key = _routeKey(f, t);
    return _routePrices[key] ?? 7000; // fallback
  }

  /// Table des tarifs (aller ou retour = même prix).
  static const Map<String, double> _routePrices = {
    'bafoussam|douala': 6000,
    'bafoussam|ebolowa': 6500,
    'bafoussam|garoua': 8500,
    'bafoussam|yaounde': 5500,
    'douala|ebolowa': 5000,
    'douala|garoua': 10000,
    'douala|yaounde': 3500,
    'ebolowa|garoua': 9500,
    'ebolowa|yaounde': 4000,
    'garoua|yaounde': 9000,
  };

  /// Normalise un nom de ville : minuscule + remplace caractères accentués.
  String _normCity(String raw) {
    var v = raw.trim().toLowerCase();
    v = v
        .replaceAll('é', 'e')
        .replaceAll('è', 'e')
        .replaceAll('ê', 'e')
        .replaceAll('à', 'a')
        .replaceAll('ô', 'o')
        .replaceAll('ï', 'i');
    // Corrige quelques variantes fréquentes
    if (v == 'yaoundé') v = 'yaounde';
    if (v == 'yaounde') v = 'yaounde';
    if (v == 'ebolewa') v = 'ebolowa';
    return v;
  }

  /// Renvoie une clé canonique triée "a|b".
  String _routeKey(String a, String b) {
    final pair = [a, b]..sort();
    return '${pair[0]}|${pair[1]}';
  }

  /// Format prix entier
  static String _fmt(double n) => n.toStringAsFixed(0);
}
