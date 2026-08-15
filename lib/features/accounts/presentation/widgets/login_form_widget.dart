import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/routes/app_routes.dart';
import '../providers/account_provider.dart';

class LoginFormWidget extends StatefulWidget {
  const LoginFormWidget({super.key});

  @override
  State<LoginFormWidget> createState() => _LoginFormWidgetState();
}

class _LoginFormWidgetState extends State<LoginFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();

    final authProvider = context.read<AccountProvider>();

    final success = await authProvider.login(
      username: _usernameController.text.trim(),
      password: _passwordController.text,
    );

    if (success && mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.main);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AccountProvider>();
    final colorScheme = Theme.of(context).colorScheme;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Mensagem de Erro adaptada para Light/Dark Mode via ColorScheme
          if (authProvider.erro != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                authProvider.erro!,
                style: TextStyle(color: colorScheme.onErrorContainer),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Campo de Usuário (Herdando 100% do AppTheme)
          TextFormField(
            controller: _usernameController,
            decoration: const InputDecoration(
              labelText: 'Usuário',
              prefixIcon: Icon(Icons.person_outline),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Informe seu nome de usuário.';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Campo de Senha (Herdando 100% do AppTheme)
          TextFormField(
            controller: _passwordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Senha',
              prefixIcon: Icon(Icons.lock_outline),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Informe sua senha.';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),

          // Botão de Login (Herdando 100% do AppTheme)
          ElevatedButton(
            onPressed: authProvider.loading ? null : _submit,
            child: authProvider.loading
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colorScheme.onPrimary,
                    ),
                  )
                : const Text('Entrar'),
          ),
          // Adicionar ao final do Column na LoginFormWidget:
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.register);
            },
            child: const Text('Não tem uma conta? Cadastre-se'),
          ),
        ],
      ),
    );
  }
}
