import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../providers/account_provider.dart';

class EditProfileFormWidget extends StatefulWidget {
  const EditProfileFormWidget({super.key});

  @override
  State<EditProfileFormWidget> createState() => _EditProfileFormWidgetState();
}

class _EditProfileFormWidgetState extends State<EditProfileFormWidget> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late TextEditingController _displayNameController;
  late TextEditingController _bioController;

  File? _selectedAvatar;
  DateTime? _selectedBirthDate;

  @override
  void initState() {
    super.initState();
    // Recupera dados do usuário logado para pré-preencher
    final user = context.read<AccountProvider>().currentUser;

    _usernameController = TextEditingController(text: user?.username ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _displayNameController = TextEditingController(text: user?.profile?.displayName ?? '');
    _bioController = TextEditingController(text: user?.profile?.bio ?? '');
    _selectedBirthDate = user?.profile?.birthDate;
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _displayNameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

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

  Future<void> _selectBirthDate() async {
    final now = DateTime.now();
    final initialDate = _selectedBirthDate ?? DateTime(now.year - 18, now.month, now.day);

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
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

    // Criar a UpdateProfileRequestDto se necessário ou passar os parâmetros diretamente no Provider
    final success = await accountProvider.updateProfile(
      username: _usernameController.text.trim(),
      email: _emailController.text.trim(),
      displayName: _displayNameController.text.trim(),
      bio: _bioController.text.trim(),
      avatar: _selectedAvatar,
      birthDate: _selectedBirthDate,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil atualizado com sucesso!')),
      );
      Navigator.pop(context); // Retorna para a tela de Perfil
    }
  }

  @override
  Widget build(BuildContext context) {
    final accountProvider = context.watch<AccountProvider>();
    final user = accountProvider.currentUser;
    final colorScheme = Theme.of(context).colorScheme;

    // Lógica para decidir qual imagem renderizar no Avatar
    ImageProvider? avatarImage;
    if (_selectedAvatar != null) {
      avatarImage = FileImage(_selectedAvatar!);
    } else if (user?.profile?.avatarUrl != null && user!.profile!.avatarUrl!.isNotEmpty) {
      avatarImage = NetworkImage(user.profile!.avatarUrl!);
    }

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
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

          // Avatar Selector
          Center(
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 48,
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  backgroundImage: avatarImage,
                  child: avatarImage == null
                      ? Text(
                          user?.nameToShow.substring(0, 1).toUpperCase() ?? 'U',
                          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
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
          const SizedBox(height: 24),

          // Botão Salvar
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
                : const Text('Salvar Alterações'),
          ),
        ],
      ),
    );
  }
}