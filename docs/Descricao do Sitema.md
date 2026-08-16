🏗️ Documentação da Arquitetura - Sistema Flutter
Versão: 1.0.0
Última atualização: Agosto 2026
Tecnologia: Flutter (Dart)

📋 Índice
- Visão Geral
- Estrutura de Features
    Domain
    Data
    Presentation

- Core (Configurações Centrais)
    API
    Auth
    Storage

- DI (Injeção de Dependências)
    Theme
    App

- Main (Ponto de Entrada)

- Estrutura de Pastas

- Fluxo de Exemplo: Login

- Padrões de Nomenclatura

- Testes

- Benefícios da Arquitetura

*Visão Geral*
- O sistema foi desenvolvido com uma arquitetura baseada em features modulares, onde cada feature é isolada e desacoplada das demais. Esta abordagem segue os princípios do Clean Architecture, garantindo:
    Separação clara de responsabilidades
    Alta testabilidade
    Manutenção facilitada
    Independência de fontes externas (APIs, bancos de dados)
    Escalabilidade para novos recursos

- Cada feature é composta por três camadas: Domain, Data e Presentation, que juntas formam um ecossistema coeso e independente.

*Estrutura de Features*
1. Domain
A camada Domain é o núcleo do negócio. Ela contém as regras de negócio e é completamente independente de qualquer fonte de dados externa.

📂 Domain/entities
- Responsabilidade: Definir os modelos de dados da aplicação.
- Características: Classes imutáveis (com @immutable), utilizando freezed ou equatable para comparação.

Exemplo: UserEntity, ProductEntity, OrderEntity

dart
********************************************************************************************
// Exemplo de Entity
class UserEntity {
  final String id;
  final String name;
  final String email;
  
  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
  });
}
********************************************************************************************

📂 Domain/repositories
- Responsabilidade: Definir contratos (interfaces) para acesso a dados.
- Características: Apenas assinaturas de métodos, sem implementação.

Exemplo: IAuthRepository, IProductRepository

dart
********************************************************************************************
// Exemplo de Repository (contrato)
abstract class IAuthRepository {
  Future<UserEntity> login(String email, String password);
  Future<void> logout();
  Future<bool> isAuthenticated();
}
********************************************************************************************

📂 Domain/usecases
- Responsabilidade: Implementar as regras de negócio e orquestrar o fluxo de dados entre repositórios.
- Características: Cada usecase deve ter uma única responsabilidade (SRP).

Exemplo: LoginUseCase, GetUserProfileUseCase

dart
********************************************************************************************
// Exemplo de UseCase
class LoginUseCase {
  final IAuthRepository _authRepository;
  
  LoginUseCase(this._authRepository);
  
  Future<UserEntity> execute(String email, String password) async {
    // Validação de negócio
    if (email.isEmpty || password.isEmpty) {
      throw InvalidCredentialsException();
    }
    
    return await _authRepository.login(email, password);
  }
}
********************************************************************************************

2. Data
- A camada Data é responsável pela implementação concreta da manipulação de dados, tanto de fontes remotas quanto locais.

📂 Data/datasources
- Responsabilidade: Buscar dados de fontes externas (APIs, bancos de dados, cache).
- Características:
    Remote DataSources: Para APIs REST, GraphQL, WebSocket.
    Local DataSources: Para SQLite, Hive, SharedPreferences.

Exemplo: AuthRemoteDataSource, UserLocalDataSource

dart
********************************************************************************************
// Exemplo de Remote DataSource
class AuthRemoteDataSource {
  final Dio _dio;
  
  AuthRemoteDataSource(this._dio);
  
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await _dio.post(
      Endpoints.login,
      data: {'email': email, 'password': password},
    );
    return response.data;
  }
}
********************************************************************************************

📂 Data/models
- Responsabilidade: Mapear dados entre o formato externo (JSON, XML) e as entidades de domínio.
- Características: Incluem métodos fromJson() e toJson().

Exemplo: UserModel, ProductModel

dart
********************************************************************************************
// Exemplo de Model
class UserModel extends UserEntity {
  const UserModel({
    required String id,
    required String name,
    required String email,
  }) : super(id: id, name: name, email: email);
  
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
    };
  }
}
********************************************************************************************

📂 Data/repositories
- Responsabilidade: Implementar os contratos definidos na camada Domain.
- Características: Utilizam DataSources para obter dados e Models para conversão.

Exemplo: AuthRepositoryImpl, ProductRepositoryImpl

dart
********************************************************************************************
// Exemplo de Repository (implementação)
class AuthRepositoryImpl implements IAuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource _localDataSource;
  
  AuthRepositoryImpl(this._remoteDataSource, this._localDataSource);
  
  @override
  Future<UserEntity> login(String email, String password) async {
    final data = await _remoteDataSource.login(email, password);
    final user = UserModel.fromJson(data);
    await _localDataSource.saveUser(user);
    return user;
  }
}
********************************************************************************************

3. Presentation
- A camada Presentation é responsável pela interface com o usuário e gerenciamento de estado.

📂 Presentation/pages
- Responsabilidade: Representar telas completas da aplicação.
- Características: Widgets que consomem Providers e exibem dados.

Exemplo: LoginPage, HomePage, ProfilePage

dart
********************************************************************************************
// Exemplo de Page
class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<LoginProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          body: Column(
            children: [
              TextField(
                onChanged: provider.setEmail,
                decoration: InputDecoration(labelText: 'Email'),
              ),
              TextField(
                onChanged: provider.setPassword,
                obscureText: true,
                decoration: InputDecoration(labelText: 'Password'),
              ),
              ElevatedButton(
                onPressed: provider.isLoading ? null : provider.login,
                child: provider.isLoading 
                  ? CircularProgressIndicator() 
                  : Text('Login'),
              ),
            ],
          ),
        );
      },
    );
  }
}
********************************************************************************************

📂 Presentation/providers
- Responsabilidade: Gerenciar o estado da interface e orquestrar a interação com Usecases.
- Características: Utilizam ChangeNotifier, Riverpod, Bloc ou GetX.

Exemplo: LoginProvider, HomeProvider

dart
********************************************************************************************
// Exemplo de Provider (ChangeNotifier)
class LoginProvider extends ChangeNotifier {
  final LoginUseCase _loginUseCase;
  
  String _email = '';
  String _password = '';
  bool _isLoading = false;
  String? _errorMessage;
  
  LoginProvider(this._loginUseCase);
  
  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  // Setters
  void setEmail(String value) {
    _email = value;
    notifyListeners();
  }
  
  void setPassword(String value) {
    _password = value;
    notifyListeners();
  }
  
  // Actions
  Future<void> login() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final user = await _loginUseCase.execute(_email, _password);
      // Navegar para Home
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
********************************************************************************************

📂 Presentation/widgets
- Responsabilidade: Componentes reutilizáveis que aparecem em múltiplas telas.
- Características: Widgets pequenos e específicos.

Exemplo: CustomButton, LoadingIndicator, ErrorDialog

dart
********************************************************************************************
// Exemplo de Widget reutilizável
class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  
  const CustomButton({
    required this.text,
    required this.onPressed,
    this.isLoading = false,
  });
  
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      child: isLoading 
        ? SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : Text(text),
    );
  }
}
********************************************************************************************

*Core (Configurações Centrais)*
- O diretório core contém serviços e configurações compartilhadas por toda a aplicação.

1. API
📂 Api/api
- Responsabilidade: Configurações globais da API.
- Características: URL base, timeouts, headers, interceptors.

Exemplo: ApiClient (com Dio)

dart
********************************************************************************************
class ApiClient {
  static final Dio _dio = Dio(BaseOptions(
    baseUrl: 'https://api.example.com',
    connectTimeout: Duration(seconds: 30),
    receiveTimeout: Duration(seconds: 30),
    headers: {'Content-Type': 'application/json'},
  ));
  
  static Dio get instance => _dio;
}
********************************************************************************************

📂 Api/exceptions
- Responsabilidade: Tratamento centralizado de exceções.
- Características: Classes de exceção personalizadas.

Exemplo: ServerException, NetworkException, UnauthorizedException

dart
********************************************************************************************
class ServerException implements Exception {
  final String message;
  final int? statusCode;
  
  ServerException(this.message, {this.statusCode});
  
  @override
  String toString() => 'ServerException: $message';
}
********************************************************************************************

📂 Api/endpoints
- Responsabilidade: Armazenar todas as rotas da API.
- Características: Centralização para facilitar manutenção.

Exemplo:

dart
********************************************************************************************
class Endpoints {
  static const String login = '/auth/login';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh';
  static const String userProfile = '/user/profile';
  static const String products = '/products';
}
********************************************************************************************

2. Auth
📂 Auth/interceptor
- Responsabilidade: Gerenciar tokens durante as requisições.
- Características: Adiciona token ao header, lida com renovação e logout.

dart
********************************************************************************************
class AuthInterceptor extends Interceptor {
  final TokenManager _tokenManager;
  
  AuthInterceptor(this._tokenManager);
  
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = _tokenManager.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
  
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      try {
        await _tokenManager.refreshToken();
        // Repetir requisição com novo token
      } catch (_) {
        _tokenManager.logout();
      }
    }
    handler.next(err);
  }
}
********************************************************************************************

📂 Auth/token_manager
- Responsabilidade: Gerenciar tokens de autenticação.
- Características: Salvar, recuperar, renovar e invalidar tokens.

dart
********************************************************************************************
class TokenManager {
  final StorageService _storage;
  
  TokenManager(this._storage);
  
  Future<void> saveTokens(String accessToken, String refreshToken) async {
    await _storage.write('access_token', accessToken);
    await _storage.write('refresh_token', refreshToken);
  }
  
  String? getAccessToken() {
    return _storage.read('access_token');
  }
  
  Future<void> refreshToken() async {
    // Lógica para renovar token usando refresh_token
  }
  
  Future<void> logout() async {
    await _storage.delete('access_token');
    await _storage.delete('refresh_token');
  }
}
********************************************************************************************

3. Storage
- Responsabilidade: Armazenamento seguro de dados.
- Características: Utiliza flutter_secure_storage para dados sensíveis e shared_preferences para dados não sensíveis.

dart
********************************************************************************************
class StorageService {
  final FlutterSecureStorage _secureStorage;
  final SharedPreferences _preferences;
  
  StorageService(this._secureStorage, this._preferences);
  
  Future<void> write(String key, String value) async {
    if (key.contains('token') || key.contains('password')) {
      await _secureStorage.write(key: key, value: value);
    } else {
      await _preferences.setString(key, value);
    }
  }
  
  String? read(String key) {
    // Lógica para ler de secure ou shared preferences
  }
}
********************************************************************************************

4. DI (Injeção de Dependências)
- Responsabilidade: Gerenciar a criação e injeção de dependências.
- Características: Utiliza get_it ou riverpod para injeção.

dart
********************************************************************************************
// Exemplo com GetIt
final getIt = GetIt.instance;

void setupDI() {
  // Core
  getIt.registerLazySingleton<Dio>(() => ApiClient.instance);
  getIt.registerLazySingleton<StorageService>(() => StorageService());
  getIt.registerLazySingleton<TokenManager>(() => TokenManager(getIt()));
  
  // Auth Feature
  getIt.registerLazySingleton<IAuthRepository>(
    () => AuthRepositoryImpl(
      getIt<AuthRemoteDataSource>(),
      getIt<AuthLocalDataSource>(),
    ),
  );
  getIt.registerLazySingleton<LoginUseCase>(
    () => LoginUseCase(getIt<IAuthRepository>()),
  );
  getIt.registerFactory<LoginProvider>(
    () => LoginProvider(getIt<LoginUseCase>()),
  );
}
********************************************************************************************

5. Theme
- Responsabilidade: Centralizar a estilização do projeto.
- Características: Cores, tipografia, temas claro/escuro.

dart
********************************************************************************************
class AppTheme {
  static const Color primaryColor = Color(0xFF6200EE);
  static const Color secondaryColor = Color(0xFF03DAC6);
  static const Color backgroundColor = Color(0xFFF5F5F5);
  
  static const TextStyle headline1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: primaryColor,
  );
  
  static ThemeData lightTheme = ThemeData(
    primaryColor: primaryColor,
    colorScheme: ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
    ),
    fontFamily: 'Roboto',
    textTheme: TextTheme(
      headline1: headline1,
      // ...
    ),
  );
}
********************************************************************************************

6. App
- Responsabilidade: Configurações gerais do aplicativo.
- Características: Rotas nomeadas, middleware, widgets raiz.

dart
********************************************************************************************
class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Flutter App',
      theme: AppTheme.lightTheme,
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginPage(),
        '/home': (context) => HomePage(),
        '/profile': (context) => ProfilePage(),
      },
    );
  }
}
********************************************************************************************

*Main (Ponto de Entrada)*
- O arquivo main.dart é o ponto de entrada da aplicação.

dart
********************************************************************************************
void main() async {
  // Garantir inicialização do Flutter
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar dependências
  await setupDI();
  
  // Rodar aplicação
  runApp(App());
}
********************************************************************************************

Estrutura de Pastas
text
lib/
├── core/
│   ├── api/
│   │   ├── api_client.dart
│   │   ├── endpoints.dart
│   │   └── exceptions/
│   │       └── exception_handler.dart
│   ├── auth/
│   │   ├── auth_interceptor.dart
│   │   └── token_manager.dart
│   ├── storage/
│   │   └── storage_service.dart
│   ├── di/
│   │   └── injection.dart
│   ├── theme/
│   │   └── app_theme.dart
│   └── app/
│       └── app_routes.dart
│
├── features/
│   ├── auth/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── user_entity.dart
│   │   │   ├── repositories/
│   │   │   │   └── i_auth_repository.dart
│   │   │   └── usecases/
│   │   │       ├── login_usecase.dart
│   │   │       └── logout_usecase.dart
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   ├── auth_remote_datasource.dart
│   │   │   │   └── auth_local_datasource.dart
│   │   │   ├── models/
│   │   │   │   └── user_model.dart
│   │   │   └── repositories/
│   │   │       └── auth_repository_impl.dart
│   │   └── presentation/
│   │       ├── pages/
│   │       │   ├── login_page.dart
│   │       │   └── register_page.dart
│   │       ├── providers/
│   │       │   └── login_provider.dart
│   │       └── widgets/
│   │           └── custom_button.dart
│   │
│   ├── home/
│   │   ├── domain/
│   │   ├── data/
│   │   └── presentation/
│   │
│   └── profile/
│       ├── domain/
│       ├── data/
│       └── presentation/
│
└── main.dart

*Fluxo de Exemplo: Login*
- Para ilustrar como os dados fluem através da arquitetura, vamos acompanhar o processo de login do usuário.
- Passo a Passo Detalhado:
    Usuário interage com a LoginPage → Preenche email e senha.
    LoginPage chama LoginProvider.login() → Provider gerencia o estado.
    LoginProvider chama LoginUseCase.execute() → Usecase contém regras de negócio.
    LoginUseCase valida dados → Verifica se email/senha são válidos.
    LoginUseCase chama IAuthRepository.login() → Através do contrato.
    AuthRepositoryImpl implementa login() → Utiliza DataSources.
    AuthRemoteDataSource faz requisição HTTP → Para o endpoint /auth/login.
    API retorna dados em JSON → Ex: {'id': '1', 'name': 'João', 'email': 'joao@email.com'}.
    AuthRemoteDataSource retorna o JSON → Para o Repository.
    AuthRepositoryImpl converte para UserModel → Utiliza fromJson().
    AuthRepositoryImpl retorna UserEntity → Para o Usecase.
    LoginUseCase retorna UserEntity → Para o Provider.
    LoginProvider atualiza o estado → isLoading = false, salva usuário.
    LoginProvider notifica LoginPage → Através do notifyListeners().
    LoginPage navega para HomePage → Login concluído com sucesso.

*Padrões de Nomenclatura*
- Para manter a consistência em todo o projeto, adotamos os seguintes padrões:

----------------------------------------------------------------------------------------
🏷️ Classes/Arquivos
Tipo	                    Padrão	                Exemplo
Entity	                    XxxEntity	            UserEntity, ProductEntity
Model	                    XxxModel	            UserModel, ProductModel
Repository (contrato)	    IXxxRepository	        IAuthRepository
Repository (implementação)	XxxRepositoryImpl	    AuthRepositoryImpl
Remote DataSource	        XxxRemoteDataSource	    AuthRemoteDataSource
Local DataSource	        XxxLocalDataSource	    AuthLocalDataSource
UseCase	                    XxxUseCase	            LoginUseCase, GetUserUseCase
Provider	                XxxProvider	            LoginProvider, HomeProvider
Page	                    XxxPage	                LoginPage, HomePage
Widget	                    XxxWidget	            CustomButton, LoadingIndicator
Exception	                XxxException	        ServerException, NetworkException
----------------------------------------------------------------------------------------

*📝 Convenções de Código*
- Imutabilidade: Entidades e Models devem ser imutáveis (usar @immutable, freezed).
- Injeção de Dependências: Sempre injetar dependências via construtor.
- Async/Await: Sempre usar async/await para operações assíncronas.
- Tratamento de Erros: Usar try-catch com exceções personalizadas.
- Nomes de Métodos: Usar verbos no infinitivo: login(), saveUser(), getProducts().
- Nomes de Variáveis: Usar camelCase: userName, isLoading, errorMessage.

Testes
- A arquitetura foi projetada para facilitar a testabilidade em todos os níveis.

🧪 Testes Unitários
- Onde: test/features/xxx/domain/, test/features/xxx/data/

O que testar:
- UseCases (regras de negócio)
- Entities (métodos de comparação)
- Models (conversão de JSON)
- Repositories (com mocks de DataSources)

🖥️ Testes de Widget
- Onde: test/features/xxx/presentation/
- O que testar:
    Pages (comportamento visual)
    Widgets (reutilizáveis)
    Providers (estado e interações)

🔗 Testes de Integração
- Onde: integration_test/
- O que testar:
    Fluxos completos (ex: login → home → logout)
    Comunicação com API real (em ambiente de homologação)

📐 Exemplo de Teste Unitário
dart
********************************************************************************************
// Teste do LoginUseCase
void main() {
  late LoginUseCase usecase;
  late MockAuthRepository mockRepository;
  
  setUp(() {
    mockRepository = MockAuthRepository();
    usecase = LoginUseCase(mockRepository);
  });
  
  test('Deve retornar UserEntity quando login é bem-sucedido', () async {
    // Arrange
    const email = 'test@email.com';
    const password = '123456';
    final user = UserEntity(id: '1', name: 'Test', email: email);
    
    when(mockRepository.login(email, password))
        .thenAnswer((_) async => user);
    
    // Act
    final result = await usecase.execute(email, password);
    
    // Assert
    expect(result, user);
    verify(mockRepository.login(email, password)).called(1);
  });
  
  test('Deve lançar exceção quando email está vazio', () async {
    // Act & Assert
    expect(
      () => usecase.execute('', '123456'),
      throwsA(isA<InvalidCredentialsException>()),
    );
  });
}
********************************************************************************************

*Benefícios da Arquitetura*
Benefício	                            Descrição
✅ Separação de Responsabilidades	   Cada camada tem uma função clara e bem definida.
✅ Alta Testabilidade	               Cada camada pode ser testada isoladamente com mocks.
✅ Manutenibilidade	                   Mudanças em uma camada não afetam as outras.
✅ Escalabilidade	                   Novas features podem ser adicionadas sem afetar as existentes.
✅ Independência de Tecnologias	       É possível trocar a implementação de DataSources (ex: Dio   
                                        por HTTP) sem afetar o Domain.
✅ Reutilização de Código	           Widgets e UseCases podem ser reutilizados em diferentes 
                                        partes do app.
✅ Onboarding Facilitado	               Novos desenvolvedores entendem rapidamente a estrutura do 
                                        projeto.


*Considerações Finais*
- Esta arquitetura foi projetada para garantir a qualidade, escalabilidade e manutenibilidade do sistema Flutter. Ao seguir estas diretrizes, a equipe de desenvolvimento pode trabalhar de forma colaborativa e eficiente, mantendo o código limpo e organizado.


📌 Versão do Documento: 1.0.0
📅 Última Revisão: 16 de Agosto de 2026
✍️ Autor: Lucas Pierroti Penha