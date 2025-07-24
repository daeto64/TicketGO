import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class OTPScreen extends StatefulWidget {
  final String verificationId;
  final String? smsCode; // ✅ Paramètre optionnel ajouté

  const OTPScreen({
    super.key, 
    required this.verificationId,
    this.smsCode,
  });
  
  static const routeName = '/otp';

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  final TextEditingController _otpController = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    // Si smsCode est fourni, le pré-remplir
    if (widget.smsCode != null) {
      _otpController.text = widget.smsCode!;
    }
  }

  Future<void> _verifyCode() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    
    try {
      // ✅ Correction : passer les paramètres nommés correctement
      await AuthService().verifyOtpCode(
        verificationId: widget.verificationId,
        smsCode: _otpController.text.trim(),
      );
      
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/home');
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vérification OTP')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text('Entrez le code OTP reçu par SMS'),
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Code OTP'),
              maxLength: 6, // Limite habituelle pour les codes OTP
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(_error!, style: const TextStyle(color: Colors.red)),
              ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loading ? null : _verifyCode,
              child: _loading 
                ? const CircularProgressIndicator() 
                : const Text('Valider'),
            ),
          ],
        ),
      ),
    );
  }
}