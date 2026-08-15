//accounts
import 'package:app/features/accounts/data/datasources/auth_api.dart';
import 'package:app/features/accounts/domain/repositories/account_repository.dart';
import 'package:app/features/accounts/data/repositories/account_repository_impl.dart';
import 'package:app/features/accounts/presentation/providers/account_provider.dart';
//posts and feed
import 'package:app/features/posts/presentation/providers/feed_provider.dart';
import 'package:app/features/posts/domain/repositories/feed_repository.dart';
import 'package:app/features/posts/data/datasources/feed_api.dart';
import 'package:app/features/posts/data/repositories/feed_repository_impl.dart';

import 'package:get_it/get_it.dart';

// Core
import 'package:app/core/api/api_client.dart';
import 'package:app/core/auth/auth_interceptor.dart';
import 'package:app/core/auth/token_manager.dart';
import 'package:app/core/storage/token_storage.dart';

final getIt = GetIt.instance;

Future<void> setupInjector() async {
  // 1. Core Services & Storage
  getIt.registerLazySingleton<TokenStorage>(() => TokenStorage());
  
  getIt.registerLazySingleton<TokenManager>(
    () => TokenManager(tokenStorage: getIt<TokenStorage>()),
  );

  // 1.1 AuthInterceptor (Precisa vir ANTES do ApiClient)
  getIt.registerLazySingleton<AuthInterceptor>(
    () => AuthInterceptor(tokenManager: getIt<TokenManager>()),
  );

  // 1.2 ApiClient
  getIt.registerLazySingleton<ApiClient>(
    () => ApiClient(interceptors: [getIt<AuthInterceptor>()]),
  );

  // 2. Data Sources (APIs)
  getIt.registerLazySingleton<AuthApi>(
    () => AuthApi(getIt<ApiClient>()),
  );

  getIt.registerLazySingleton<FeedApi>(
    () => FeedApi(getIt<ApiClient>()),
  );

  // 3. Repositories
  getIt.registerLazySingleton<AccountRepository>(
    () => AccountRepositoryImpl(getIt<AuthApi>()),
  );

  // Fixed: FeedRepository is abstract, need to register the implementation
  getIt.registerLazySingleton<FeedRepository>(
    () => FeedRepositoryImpl(getIt<FeedApi>()), // Assuming you have FeedRepositoryImpl
  );

  // 4. Providers
  getIt.registerFactory<AccountProvider>(
    () => AccountProvider(
      repository: getIt<AccountRepository>(),
      tokenManager: getIt<TokenManager>(),
    ),
  );

  getIt.registerFactory<FeedProvider>(
    () => FeedProvider(repository: getIt<FeedRepository>()),
  );
}