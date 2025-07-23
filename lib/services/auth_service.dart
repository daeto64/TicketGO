import 'package:firebase_auth/firebase_auth.dart' as fb;
import '../models/app_user.dart';

class AuthService {
  final fb.FirebaseAuth _auth = fb.FirebaseAuth.instance;

  Stream<AppUser?> get userChanges =>
      _auth.userChanges().map(_userFromFirebaseUser);

  AppUser? _userFromFirebaseUser(fb.User? user) {
    if (user == null) return null;
    return AppUser(
      uid: user.uid,
      name: user.displayName,
      email: user.email,
      phone: user.phoneNumber,
    );
  }

  Future<AppUser?> signInWithEmailPassword(String email, String password) async {
    try {
      // Log debug (EN CLAIR : évite en prod)
      // ignore: avoid_print
      print('>> AuthService.signIn email="$email" (len=${email.length}) pwLen=${password.length}');
      final cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return _userFromFirebaseUser(cred.user);
    } on fb.FirebaseAuthException catch (e) {
      // ignore: avoid_print
      print('!! SIGN-IN ERROR code=${e.code} message=${e.message}');
      throw Exception(_mapSignInError(e));
    } catch (e) {
      // ignore: avoid_print
      print('!! SIGN-IN UNKNOWN ERROR $e');
      throw Exception('Erreur de connexion : $e');
    }
  }

  Future<AppUser?> registerWithEmailPassword(
      String name, String email, String password) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await cred.user?.updateDisplayName(name);
      return _userFromFirebaseUser(cred.user);
    } on fb.FirebaseAuthException catch (e) {
      // ignore: avoid_print
      print('!! REGISTER ERROR code=${e.code} message=${e.message}');
      throw Exception(_mapRegisterError(e));
    } catch (e) {
      // ignore: avoid_print
      print('!! REGISTER UNKNOWN ERROR $e');
      throw Exception('Erreur lors de la création du compte : $e');
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  // --- mapping erreurs vers messages FR lisibles ---

  String _mapSignInError(fb.FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return "Adresse email invalide.";
      case 'user-disabled':
        return "Ce compte est désactivé.";
      case 'user-not-found':
        return "Aucun compte trouvé pour cet email.";
      case 'wrong-password':
        return "Mot de passe incorrect.";
      case 'invalid-credential':
        return "Identifiants invalides (email/mot de passe).";
      case 'network-request-failed':
        return "Pas de connexion réseau.";
      case 'invalid-api-key':
        return "Clé API Firebase invalide.";
      default:
        return "Erreur de connexion (${e.code}) : ${e.message}";
    }
  }

  String _mapRegisterError(fb.FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return "Cet email est déjà utilisé.";
      case 'invalid-email':
        return "Adresse email invalide.";
      case 'operation-not-allowed':
        return "La création de compte est désactivée.";
      case 'weak-password':
        return "Mot de passe trop faible (min 6 caractères).";
      default:
        return "Erreur inscription (${e.code}) : ${e.message}";
    }
  }
}
