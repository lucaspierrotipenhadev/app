import 'package:flutter/material.dart';

import '../widgets/register_form__widget.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Criar Conta'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: const RegisterFormWidget(),
      ),
    );
  }
}