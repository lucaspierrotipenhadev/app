import 'package:app/features/accounts/presentation/pages/edit_profile_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'login_page.dart';
import '../providers/account_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final accountProvider = context.watch<AccountProvider>();
    final user = accountProvider.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu Perfil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            tooltip: 'Sair',
            onPressed: () async {
              await context.read<AccountProvider>().logout();
              // A navegação ou reatividade do estado cuidará de redirecionar para a LoginScreen
              if (context.mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                  (route) => false, // Remove TODAS as telas anteriores da pilha
                );
              }
            },
          ),
        ],
      ),
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                await context.read<AccountProvider>().checkLogin();
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    // Avatar do Usuário
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                      backgroundImage: (user.profile?.avatarUrl != null && user.profile!.avatarUrl!.isNotEmpty)
                          ? NetworkImage(user.profile!.avatarUrl!)
                          : null,
                      child: (user.profile?.avatarUrl == null || user.profile!.avatarUrl!.isEmpty)
                          ? Text(
                              user.nameToShow.substring(0, 1).toUpperCase(),
                              style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
                            )
                          : null,
                    ),
                    const SizedBox(height: 16),

                    // Nome e Username
                    Text(
                      user.nameToShow,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      '@${user.username}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                    const SizedBox(height: 12),

                    // Biografia (se houver)
                    if (user.profile?.bio != null && user.profile!.bio.isNotEmpty) ...[
                      Text(
                        user.profile!.bio,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontStyle: FontStyle.italic),
                      ),
                      const SizedBox(height: 16),
                    ],

                    const Divider(height: 32),

                    // Card de Seguidores / Seguindo (métricas das entidades)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStatItem('Seguidores', user.followersCount),
                        _buildStatItem('Seguindo', user.followingCount),
                      ],
                    ),

                    const Divider(height: 32),

                    // Detalhes da Conta
                    ListTile(
                      leading: const Icon(Icons.email_outlined),
                      title: const Text('E-mail'),
                      subtitle: Text(user.email),
                    ),
                    if (user.profile?.birthDate != null)
                      ListTile(
                        leading: const Icon(Icons.cake_outlined),
                        title: const Text('Data de Nascimento'),
                        subtitle: Text(_formatBirthDate(user.profile!.birthDate!)),
                      ),

                    const SizedBox(height: 24),

                    // Botão para editar perfil (Para o próximo passo!)
                    OutlinedButton.icon(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfilePage()));
                      },
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text('Editar Perfil'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStatItem(String label, int value) {
    return Column(
      children: [
        Text(
          '$value',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(color: Colors.grey[600]),
        ),
      ],
    );
  }

  String _formatBirthDate(DateTime birthDate) {
    // Format as dd/MM/yyyy or any format you prefer
    return '${birthDate.day.toString().padLeft(2, '0')}/${birthDate.month.toString().padLeft(2, '0')}/${birthDate.year}';
  }
}