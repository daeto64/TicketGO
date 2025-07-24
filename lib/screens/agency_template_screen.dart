import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'payment_screen.dart';

class AgencyTemplateScreen extends StatefulWidget {
  final String title;
  final String imagePath;
  final Color mainColor;
  final String categoryForPayment;

  const AgencyTemplateScreen({
    super.key,
    required this.title,
    required this.imagePath,
    required this.categoryForPayment,
    this.mainColor = const Color(0xFF7B68EE),
  });

  @override
  State<AgencyTemplateScreen> createState() => _AgencyTemplateScreenState();
}

class _AgencyTemplateScreenState extends State<AgencyTemplateScreen> {
  bool _roundTrip = true;

  final _dateCtrl = TextEditingController();
  final _countCtrl = TextEditingController(text: '1');

  // Villes (Firestore)
  List<String> _cities = [];
  String? _selectedFrom;
  String? _selectedTo;
  bool _loadingCities = true;

  @override
  void initState() {
    super.initState();
    _loadCities();
  }

  @override
  void dispose() {
    _dateCtrl.dispose();
    _countCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadCities() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('villes').orderBy('nom').get();

      if (snapshot.docs.isNotEmpty) {
        setState(() {
          _cities = snapshot.docs.map((doc) => doc['nom'] as String).toList();
          _selectedFrom = _cities.first;
          _selectedTo = _cities.length > 1 ? _cities[1] : _cities.first;
          _loadingCities = false;
        });
      } else {
        setState(() => _loadingCities = false);
      }
    } catch (e) {
      debugPrint("Erreur de chargement des villes: $e");
      setState(() => _loadingCities = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Impossible de charger les villes. Réessayez plus tard."),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _swapFromTo() {
    setState(() {
      final temp = _selectedFrom;
      _selectedFrom = _selectedTo;
      _selectedTo = temp;
    });
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 1),
    );
    if (picked != null) {
      _dateCtrl.text =
          '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
    }
  }

  void _reserve() {
    final errors = <String>[];

    if (_selectedFrom == null) {
      errors.add('Le champ "De" est obligatoire');
    }
    if (_selectedTo == null) {
      errors.add('Le champ "Destination" est obligatoire');
    }
    if (_dateCtrl.text.isEmpty) {
      errors.add('La date est obligatoire');
    }

    final countText = _countCtrl.text.trim();
    if (countText.isEmpty) {
      errors.add('Le nombre de passagers est obligatoire');
    } else {
      final count = int.tryParse(countText);
      if (count == null || count <= 0) {
        errors.add('Le nombre de passagers doit être un nombre valide supérieur à 0');
      }
    }

    if (errors.isNotEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: Row(
            children: const [
              Icon(Icons.warning, color: Colors.orange),
              SizedBox(width: 8),
              Text('Champs requis'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Veuillez compléter tous les champs obligatoires :',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 12),
              ...errors.map(
                (error) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '• ',
                        style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                      ),
                      Expanded(child: Text(error)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(foregroundColor: widget.mainColor),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    // Tous les champs valides -> aller paiement
    Navigator.of(context).pushNamed(
      PaymentScreen.routeName,
      arguments: {
        'category': widget.categoryForPayment,
        'tripType': _roundTrip ? 'Aller-retour' : 'Aller simple',
        'from': _selectedFrom!,
        'to': _selectedTo!,
        'date': _dateCtrl.text,
        'count': int.parse(_countCtrl.text.trim()),
        'prix': 15000.0, // Prix par ticket (placeholder)
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final mainColor = widget.mainColor;
    // Compat : évite l'utilisation de withOpacity déprécié et withValues non dispo partout.
    final gradTop = mainColor.withAlpha((0.90 * 255).round());
    final gradBottom = mainColor.withAlpha((0.70 * 255).round());

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Row(
          children: const [
            Icon(Icons.confirmation_num, color: Colors.orange),
            SizedBox(width: 8),
            Text('Ticket Go', style: TextStyle(color: Colors.black)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.black),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onPressed: () {},
          ),
        ],
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [gradTop, gradBottom],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 16),

              // --- Image section ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(
                        widget.imagePath,
                        fit: BoxFit.cover,
                        height: 200,
                        width: double.infinity,
                        errorBuilder: (_, __, ___) => Container(
                          height: 200,
                          width: double.infinity,
                          color: Colors.black26,
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.image_not_supported,
                            size: 48,
                            color: Colors.white70,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 16,
                      bottom: 16,
                      child: Text(
                        widget.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              offset: Offset(0, 1),
                              blurRadius: 4,
                              color: Colors.black54,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 16,
                      right: 16,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black54,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                            vertical: 4,
                            horizontal: 8,
                          ),
                        ),
                        onPressed: () {
                          
                        },
                        icon: const Icon(Icons.arrow_forward,
                            color: Colors.white, size: 16),
                        label: const Text(
                          "Details",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    )
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // --- Formulaire ---
              Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Onglets Aller-retour / Aller simple
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _roundTrip = true),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: _roundTrip ? mainColor : Colors.white,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(8),
                                  bottomLeft: Radius.circular(8),
                                ),
                                border: Border.all(color: mainColor),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                "Aller-retour",
                                style: TextStyle(
                                  color: _roundTrip ? Colors.white : mainColor,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _roundTrip = false),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: !_roundTrip ? mainColor : Colors.white,
                                borderRadius: const BorderRadius.only(
                                  topRight: Radius.circular(8),
                                  bottomRight: Radius.circular(8),
                                ),
                                border: Border.all(color: mainColor),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                "Aller simple",
                                style: TextStyle(
                                  color: !_roundTrip ? Colors.white : mainColor,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Villes
                    _buildCityDropdown(
                      value: _selectedFrom,
                      hint: "De...",
                      icon: Icons.location_on,
                      color: mainColor,
                      onChanged: (newValue) {
                        setState(() => _selectedFrom = newValue);
                      },
                    ),
                    _buildCityDropdown(
                      value: _selectedTo,
                      hint: "Destination...",
                      icon: Icons.swap_vert,
                      color: mainColor,
                      onChanged: (newValue) {
                        setState(() => _selectedTo = newValue);
                      },
                      onIconTap: _swapFromTo,
                    ),

                    // Date & nombre
                    _buildTextField(
                      controller: _dateCtrl,
                      hint: "Date...",
                      icon: Icons.calendar_today,
                      color: mainColor,
                      readOnly: true,
                      onIconTap: _pickDate,
                    ),
                    _buildTextField(
                      controller: _countCtrl,
                      hint: "Nombre de passagers...",
                      icon: Icons.person,
                      color: mainColor,
                      keyboardType: TextInputType.number,
                    ),

                    const SizedBox(height: 24),

                    // Réserver
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: mainColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: _reserve,
                        child: const Text(
                          "Reserver",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    )
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // --- Réseaux sociaux ---
              const Text(
                "Nous suivre...",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              const SizedBox(height: 12),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  _SocialIconSquare(
                    icon: Icons.facebook,
                    color: Color(0xFF1877F2),
                    label: 'Facebook',
                  ),
                  SizedBox(width: 16),
                  _SocialIconSquare(
                    icon: Icons.chat,
                    color: Color(0xFF25D366),
                    label: 'WhatsApp',
                  ),
                  SizedBox(width: 16),
                  _SocialIconSquare(
                    icon: Icons.work,
                    color: Color(0xFF0A66C2),
                    label: 'LinkedIn',
                  ),
                ],
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // Dropdown villes
  Widget _buildCityDropdown({
    required String? value,
    required String hint,
    required IconData icon,
    required Color color,
    required ValueChanged<String?> onChanged,
    VoidCallback? onIconTap,
  }) {
    if (_loadingCities) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: const [
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Chargement...',
                  suffixIcon: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                ),
                enabled: false,
              ),
            ),
          ],
        ),
      );
    }

    if (_cities.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Aucune ville disponible",
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: _loadCities,
                    color: color,
                  ),
                ),
                enabled: false,
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: InputDecorator(
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.grey),
          suffixIcon: IconButton(
            icon: Icon(icon, color: color),
            onPressed: onIconTap,
          ),
          enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.deepPurple),
          ),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.deepPurple, width: 2),
          ),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: value,
            isDense: true,
            isExpanded: true,
            icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
            elevation: 8,
            style: TextStyle(color: Colors.grey[800], fontSize: 16),
            hint: Text(hint, style: const TextStyle(color: Colors.grey)),
            onChanged: onChanged,
            items: _cities
                .map(
                  (city) => DropdownMenuItem<String>(
                    value: city,
                    child: Text(city),
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }

  // TextField
  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required Color color,
    TextInputType? keyboardType,
    bool readOnly = false,
    VoidCallback? onIconTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.grey),
          suffixIcon: IconButton(
            icon: Icon(icon, color: color),
            onPressed: onIconTap,
          ),
          enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.deepPurple),
          ),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.deepPurple, width: 2),
          ),
        ),
      ),
    );
  }
}

// Réseaux sociaux
class _SocialIconSquare extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  const _SocialIconSquare({
    required this.icon,
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.white),
        ),
      ],
    );
  }
}
