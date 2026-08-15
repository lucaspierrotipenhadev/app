import 'package:app/features/accounts/presentation/pages/profile_screen.dart';
import 'package:app/features/accounts/presentation/providers/account_provider.dart';
import 'package:app/features/posts/presentation/pages/scroll_controller_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  // Lista de telas/abas do app
  final List<Widget> _screens = const [
    // 0: Feed / Home (Placeholder)
    FeedScreen(),
    // 1: Explorar (Placeholder)
    Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('Explorar em breve...'),
        ],
      ),
    ),
    // 2: Perfil do Usuário
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final accountProvider = context.watch<AccountProvider>();
    final user = accountProvider.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('FakeSocialMedia'),
        centerTitle: true,
        elevation: 0,
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.search_outlined),
            activeIcon: Icon(Icons.search),
            label: 'Buscar',
          ),
          BottomNavigationBarItem(
            icon: _buildProfileIcon(user, isSelected: _currentIndex == 2),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }

  /// Constrói o ícone do perfil com o avatar do usuário se existir
  Widget _buildProfileIcon(dynamic user, {required bool isSelected}) {
    final avatarUrl = user?.profile?.avatarUrl;

    if (avatarUrl != null && avatarUrl.isNotEmpty) {
      return Container(
        padding: const EdgeInsets.all(1.5),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Theme.of(context).primaryColor : Colors.transparent,
            width: 2,
          ),
        ),
        child: CircleAvatar(
          radius: 11,
          backgroundImage: NetworkImage(avatarUrl),
        ),
      );
    }

    return Icon(isSelected ? Icons.person : Icons.person_outline);
  }
}