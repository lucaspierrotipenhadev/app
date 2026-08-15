import 'package:flutter/material.dart';
import '../widgets/login_form_widget.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Entrar na Conta'),
        // O centerTitle já pode ser controlado pelo Tema se preferir
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Ícone utilizando a cor primária dinâmica do Tema
              Icon(
                Icons.account_circle_outlined,
                size: 80,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 32),

              const LoginFormWidget(),
            ],
          ),
        ),
      ),
    );
  }
}