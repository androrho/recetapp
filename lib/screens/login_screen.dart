import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'main_home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;

  Future<void> _loginWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      // 1. Inicia flujo de Google Sign-In
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        // El usuario canceló
        return;
      }

      // 2. Obtiene credenciales de autenticación
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken:     googleAuth.idToken,
      );

      // 3. Autentica en Firebase
      await FirebaseAuth.instance.signInWithCredential(credential);

      // 4. Navega a la pantalla principal
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainHomeScreen()),
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error de Firebase: ${e.message}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al autenticar: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: ElevatedButton.icon(
              icon: Image.asset(
                'assets/google_logo.png',
                height: 24,
                width: 24,
              ),
              label: _isLoading
                  ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
                  : const Text('Iniciar sesión con Google'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: _isLoading ? null : _loginWithGoogle,
            ),
          ),
        ),
      ),
    );
  }
}