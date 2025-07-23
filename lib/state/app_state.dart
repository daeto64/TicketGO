import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AppState extends ChangeNotifier {
  User? _current;
  User? get currentUser => _current;

  AppState({User? initialUser}) {
    _current = initialUser;
  }

  void setUser(User? user) {
    // évite rebuilds inutiles
    if (_current?.uid == user?.uid) return;
    _current = user;
    notifyListeners();
  }
}
