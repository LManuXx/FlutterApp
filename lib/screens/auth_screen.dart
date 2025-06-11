import 'package:flutter/material.dart';
import 'auth_form.dart';

class AuthScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: AuthForm(),
        ),
      ),
    );
  }
}
