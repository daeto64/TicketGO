
class Trip {
  final String id;
  final String category; // General, Touristique, etc.
  final String depart;
  final String arrivee;
  final DateTime dateDepart;
  final double prix;

  Trip({
    required this.id,
    required this.category,
    required this.depart,
    required this.arrivee,
    required this.dateDepart,
    required this.prix,
  });
}
