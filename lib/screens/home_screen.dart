import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../services/auth_service.dart';
import '../widgets/app_logo.dart';

import 'login_screen.dart';
import 'payment_screen.dart';
import 'agency_template_screen.dart'; // <-- écran factorisé

class HomeScreen extends StatefulWidget {
  static const routeName = '/home';
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // ---------------------------------------------------------------------------
  // ACTIONS
  // ---------------------------------------------------------------------------
  Future<void> _logout() async {
    await AuthService().signOut();
    if (!mounted) return;
    context.read<AppState>().setUser(null);
    Navigator.of(context).pushNamedAndRemoveUntil(
      LoginScreen.routeName,
      (_) => false,
    );
  }

  void _goPayment({String? category}) {
    Navigator.of(context).pushNamed(
      PaymentScreen.routeName,
      arguments: category,
    );
  }

  /// Ouvre l’écran générique d’agence avec une config.
  /// `categoryForPayment` sera réutilisé dans l’écran pour déclencher Payment.
  void _openAgency({
    required String title,
    required String imagePath,
    required Color mainColor,
    required String categoryForPayment,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AgencyTemplateScreen(
          title: title,
          imagePath: imagePath,
          mainColor: mainColor,
          categoryForPayment: categoryForPayment,
        ),
      ),
    );
  }

  // Raccourcis pour les 3 boutons
  void _goAgencyGeneral() => _openAgency(
        title: 'General',
        imagePath: 'assets/images/general.jpg',
        mainColor: const Color(0xFF7B68EE),
        categoryForPayment: 'General',
      );

  void _goFinex() => _openAgency(
        title: 'finex',
        imagePath: 'assets/images/finex.jpg',
        mainColor: Colors.pinkAccent,
        categoryForPayment: 'finex',
      );

  void _goTouristique() => _openAgency(
        title: 'touristique',
        imagePath: 'assets/images/touristique.jpg',
        mainColor: Colors.teal,
        categoryForPayment: 'touristique',
      );

  // ---------------------------------------------------------------------------
  // UI
  // ---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    const violet = Color(0xFF8B5A9C);
    const greyBg = Color(0xFFF5F5F5);
    final borderColor = Colors.grey.shade300;

    return Scaffold(
      backgroundColor: greyBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        title: const Padding(
          padding: EdgeInsets.only(left: 16),
          child: AppLogo(size: 40),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black87),
            onPressed: () {},
            tooltip: 'Rechercher',
          ),
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.black87),
            onPressed: () {},
            tooltip: 'Notifications',
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black87),
            onPressed: () {},
            tooltip: 'Menu',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),

            // ----- Conteneur principal -----
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 24,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: borderColor, width: 1),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // --- Historique ---
                    const Text(
                      'Historique',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: violet,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),

                    // --- Bouton MES TICKET ---
                    _MesTicketButton(
                      borderColor: borderColor,
                      onTap: () => _goPayment(category: 'mesTickets'),
                    ),

                    const SizedBox(height: 40),

                    // --- AGENCY ---
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'AGENCY',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: violet,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Grille 3 boutons G/F/T
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _AgencyButton(
                          label: 'Général',
                          letter: 'G',
                          letterColor: Colors.orange,
                          borderColor: borderColor,
                          onTap:
                              _goAgencyGeneral, // <-- vers AgencyTemplate (General)
                        ),
                        _AgencyButton(
                          label: 'Finex',
                          letter: 'F',
                          letterColor: Colors.pinkAccent,
                          borderColor: borderColor,
                          onTap: _goFinex, // <-- vers AgencyTemplate (Finex)
                        ),
                        _AgencyButton(
                          label: 'Touristique',
                          letter: 'T',
                          letterColor: Colors.teal,
                          borderColor: borderColor,
                          onTap:
                              _goTouristique, // <-- vers AgencyTemplate (Touristique)
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Icône info en bas droite
                    Align(
                      alignment: Alignment.centerRight,
                      child: Icon(
                        Icons.info_outline,
                        size: 18,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const Spacer(),

            // ----- Barre de nav inférieure custom -----
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: borderColor, width: 1),
                ),
              ),
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 32),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  _BottomNavItem(
                      icon: Icons.favorite_border, label: 'Favorités'),
                  _BottomNavItem(icon: Icons.schedule, label: 'Horaire'),
                  _BottomNavItem(icon: Icons.lightbulb_outline, label: 'Aide'),
                ],
              ),
            ),

            // ----- Footer se déconnecter -----
            Container(
              width: double.infinity,
              color: greyBg,
              padding: const EdgeInsets.only(top: 8, bottom: 16),
              child: GestureDetector(
                onTap: _logout,
                child: const Text(
                  'se déconnecter',
                  style: TextStyle(
                    color: Color(0xFF0066CC),
                    decoration: TextDecoration.underline,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Widgets privés
// -----------------------------------------------------------------------------
class _MesTicketButton extends StatelessWidget {
  final VoidCallback onTap;
  final Color borderColor;
  const _MesTicketButton({
    required this.onTap,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: borderColor, width: 1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text(
              'MES TICKET',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            SizedBox(width: 8),
            Text(
              '•',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF007AFF),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AgencyButton extends StatelessWidget {
  final String letter;
  final Color letterColor;
  final String label;
  final VoidCallback onTap;
  final Color borderColor;
  const _AgencyButton({
    required this.letter,
    required this.letterColor,
    required this.label,
    required this.onTap,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Column(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: borderColor, width: 1),
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Text(
                letter,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: letterColor,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  const _BottomNavItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20, color: Colors.black54),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.black87),
        ),
      ],
    );
  }
}
