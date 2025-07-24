import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'firebase_options.dart';
import 'state/app_state.dart';

// Screens
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/trip_detail_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/profile_sub_screen.dart';
import 'screens/payment_screen.dart';
import 'screens/payment_confirm_screen.dart';
import 'screens/reservation_receipt_screen.dart';
import 'screens/otp_verification_screen.dart';
import 'screens/otp_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final currentUser = FirebaseAuth.instance.currentUser;
  runApp(TicketGoApp(initialUser: currentUser));
}

class TicketGoApp extends StatelessWidget {
  final User? initialUser;
  const TicketGoApp({super.key, this.initialUser});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AppState>(
      create: (_) => AppState(initialUser: initialUser),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Ticket Go',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        home: const AuthGate(),
        routes: {
          LoginScreen.routeName: (_) => const LoginScreen(),
          RegisterScreen.routeName: (_) => const RegisterScreen(),
          HomeScreen.routeName: (_) => const HomeScreen(),
          TripDetailScreen.routeName: (_) => const TripDetailScreen(),
          ProfileScreen.routeName: (_) => const ProfileScreen(),
          '/profile/perso': (_) =>
              const ProfileSubScreen(title: 'Informations personnelles'),
          '/profile/contacts': (_) =>
              const ProfileSubScreen(title: 'Contacts'),
          '/profile/prefs': (_) =>
              const ProfileSubScreen(title: 'Préférences'),
          '/profile/security': (_) =>
              const ProfileSubScreen(title: 'Sécurité'),
          '/profile/payments': (_) =>
              const ProfileSubScreen(title: 'Paiements'),
          '/profile/docs': (_) =>
              const ProfileSubScreen(title: 'Documents'),
          PaymentScreen.routeName: (_) => const PaymentScreen(),
          PaymentConfirmScreen.routeName: (_) => const PaymentConfirmScreen(),
          ReservationReceiptScreen.routeName: (_) =>
              const ReservationReceiptScreen(),
          OTPScreen.routeName: (_) => const OTPScreen(verificationId: ''),
          '/otp-verification': (_) => const OtpVerificationScreen(
                verificationId: '',
                phoneNumber: '',
              ),
        },
      ),
    );
  }
}

/// Routeur d'accueil : écoute FirebaseAuth, synchronise AppState.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (ctx, snap) {
        final appState = ctx.read<AppState>();

        if (snap.connectionState == ConnectionState.active) {
          final u = snap.data;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (ctx.mounted) appState.setUser(u);
          });
          return u == null ? const LoginScreen() : const HomeScreen();
        }

        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}