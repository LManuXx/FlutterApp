import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static Future<void> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      print('Login exitoso');
    } catch (e) {
      print('Error al iniciar sesión: $e');
    }
  }

  static Future<void> register(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(email: email, password: password);
      print('Usuario registrado correctamente');
    } catch (e) {
      print('Error al registrarse: $e');
    }
  }

  static Future<void> signOut() async {
    await _auth.signOut();
  }
}
