import 'package:flutter/material.dart';
import 'auth_form.dart';

class AuthScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Autenticación')),
      body: AuthForm(),
    );
  }
}
