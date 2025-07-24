import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../services/auth_service.dart';
import 'otp_verification_screen.dart';

class RegisterScreen extends StatefulWidget {
  static const routeName = '/register'; // ✅ Ajout de routeName manquant
  
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailOrPhoneController = TextEditingController();
  final AuthService _authService = AuthService();

  bool isPhoneNumber(String input) {
    final phoneRegex = RegExp(r'^\+?[0-9]{8,15}$');
    return phoneRegex.hasMatch(input);
  }

  void _sendOtp() {
    final input = _emailOrPhoneController.text.trim();
    if (input.isEmpty) {
      Fluttertoast.showToast(msg: "Veuillez saisir un email ou un numéro.");
      return;
    }

    if (isPhoneNumber(input)) {
      // Envoi du code OTP par SMS
      _authService.sendPhoneVerificationCode(
        phoneNumber: input,
        onCodeSent: (verificationId) {
          if (!mounted) return;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => OtpVerificationScreen(
                phoneNumber: input,
                verificationId: verificationId,
              ),
            ),
          );
        },
        onError: (error) {
          Fluttertoast.showToast(msg: "Erreur : ${error.message}");
        },
      );
    } else {
      Fluttertoast.showToast(msg: "Authentification par email non encore implémentée.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Créer un compte")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _emailOrPhoneController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: "Email ou numéro de téléphone",
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ce champ est requis';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _sendOtp,
                child: const Text("Envoyer le code de vérification"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}