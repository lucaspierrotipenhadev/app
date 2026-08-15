import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../../app/routes/app_routes.dart';
import '../../data/models/register_request_dto.dart';
import '../providers/account_provider.dart';

class RegisterFormWidget extends StatefulWidget {
  const RegisterFormWidget({super.key});

  @override
  State<RegisterFormWidget> createState() => _RegisterFormWidgetState();
}

class _RegisterFormWidgetState extends State<RegisterFormWidget> {
  final _formKey = GlobalKey<FormState>();

  // Controllers locais
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _displayNameController = TextEditingController();
  final _bioController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();

  File? _selectedAvatar;
  DateTime? _selectedBirthDate;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _displayNameController.dispose();
    _bioController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    super.dispose();
  }

  // Seleção de Imagem (Galeria/Câmera)
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      setState(() {
        _selectedAvatar = File(pickedFile.path);
      });
    }
  }

  // Seleção de Data de Nascimento
  Future<void> _selectBirthDate() async {
    final now = DateTime.now();
    final initialDate = DateTime(now.year - 18, now.month, now.day);
    
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedBirthDate ?? initialDate,
      firstDate: DateTime(1900),
      lastDate: now,
    );

    if (picked != null) {
      setState(() {
        _selectedBirthDate = picked;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();

    final accountProvider = context.read<AccountProvider>();

    final dto = RegisterRequestDto(
      username: _usernameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      passwordConfirm: _passwordConfirmController.text,
      displayName: _displayNameController.text.trim(),
      bio: _bioController.text.trim(),
      avatar: _selectedAvatar,
      birthDate: _selectedBirthDate,
    );

    final success = await accountProvider.register(dto);

    if (success && mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.main);
    }
  }

  @override
  Widget build(BuildContext context) {
    final accountProvider = context.watch<AccountProvider>();
    final colorScheme = Theme.of(context).colorScheme;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Exibição de Erro
          if (accountProvider.erro != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                accountProvider.erro!,
                style: TextStyle(color: colorScheme.onErrorContainer),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Picker de Avatar
          Center(
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 48,
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  backgroundImage: _selectedAvatar != null
                      ? FileImage(_selectedAvatar!)
                      : null,
                  child: _selectedAvatar == null
                      ? Icon(
                          Icons.person,
                          size: 48,
                          color: colorScheme.onSurfaceVariant,
                        )
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Material(
                    color: colorScheme.primary,
                    shape: const CircleBorder(),
                    elevation: 2,
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: _pickImage,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(
                          Icons.camera_alt,
                          size: 18,
                          color: colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Username
          TextFormField(
            controller: _usernameController,
            decoration: const InputDecoration(
              labelText: 'Usuário *',
              prefixIcon: Icon(Icons.alternate_email),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Informe um nome de usuário.';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Email
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'E-mail *',
              prefixIcon: Icon(Icons.email_outlined),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Informe seu e-mail.';
              }
              if (!value.contains('@')) {
                return 'Informe um e-mail válido.';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Display Name
          TextFormField(
            controller: _displayNameController,
            decoration: const InputDecoration(
              labelText: 'Nome de exibição',
              prefixIcon: Icon(Icons.badge_outlined),
            ),
          ),
          const SizedBox(height: 16),

          // Bio
          TextFormField(
            controller: _bioController,
            maxLines: 2,
            maxLength: 500,
            decoration: const InputDecoration(
              labelText: 'Biografia',
              prefixIcon: Icon(Icons.description_outlined),
            ),
          ),
          const SizedBox(height: 16),

          // Data de Nascimento
          InkWell(
            onTap: _selectBirthDate,
            borderRadius: BorderRadius.circular(12),
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Data de nascimento',
                prefixIcon: Icon(Icons.cake_outlined),
              ),
              child: Text(
                _selectedBirthDate == null
                    ? 'Selecione uma data'
                    : '${_selectedBirthDate!.day.toString().padLeft(2, '0')}/${_selectedBirthDate!.month.toString().padLeft(2, '0')}/${_selectedBirthDate!.year}',
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Senha
          TextFormField(
            controller: _passwordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Senha *',
              prefixIcon: Icon(Icons.lock_outline),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Informe uma senha.';
              }
              if (value.length < 6) {
                return 'A senha deve ter pelo menos 6 caracteres.';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Confirmar Senha
          TextFormField(
            controller: _passwordConfirmController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Confirmar Senha *',
              prefixIcon: Icon(Icons.lock_reset_outlined),
            ),
            validator: (value) {
              if (value != _passwordController.text) {
                return 'As senhas não coincidem.';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),

          // Botão Cadastrar
          ElevatedButton(
            onPressed: accountProvider.loading ? null : _submit,
            child: accountProvider.loading
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colorScheme.onPrimary,
                    ),
                  )
                : const Text('Criar Conta'),
          ),
        ],
      ),
    );
  }
}