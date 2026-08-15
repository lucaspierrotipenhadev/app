// lib/main.dart
import 'package:app/app/routes/app_routes.dart';
import 'package:app/core/api/api_client.dart';

import 'package:app/features/accounts/presentation/pages/login_page.dart';
import 'package:app/features/accounts/presentation/pages/profile_screen.dart';
import 'package:app/features/accounts/presentation/pages/register_page.dart';
import 'package:app/features/accounts/presentation/pages/splash_page.dart';
import 'package:app/features/accounts/presentation/providers/account_provider.dart';
import 'package:app/features/posts/presentation/providers/feed_provider.dart';

import 'package:app/features/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/di/injector.dart';
import 'core/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa o GetIt (TokenStorage, TokenManager, AuthInterceptor, ApiClient)
  await setupInjector();

  runApp(
    MultiProvider(
      providers: [
        Provider<ApiClient>(create: (context) => getIt<ApiClient>()),
        ChangeNotifierProvider(create: (_) => getIt<AccountProvider>()),
        ChangeNotifierProvider(create: (_) => getIt<FeedProvider>()),
      ],
      child: SocialApp(),
    ),
  );
}

class SocialApp extends StatelessWidget {
  const SocialApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Social App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      initialRoute: AppRoutes.splash,
      routes: {
        AppRoutes.splash: (_) => const SplashPage(),
        AppRoutes.login:  (_) => const LoginPage(),
        AppRoutes.register: (_) => const RegisterPage(),
        AppRoutes.main:   (_) => const MainScreen(),
        AppRoutes.me: (_) => const ProfileScreen(),
      },
    );
  }
}