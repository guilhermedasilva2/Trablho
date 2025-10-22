// test/widget_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:leafy/locator.dart';
import 'package:leafy/main.dart'; // Importa o seu App
import 'package:leafy/screens/home_screen.dart';
import 'package:leafy/services/prefs/prefs_service.dart';
import 'package:shared_preferences/shared_preferences.dart'; // <-- IMPORTAR

// --- "Fake" PrefsService (Mais simples que Mockito) ---
class FakePrefsService implements PrefsService {
  
  String? _avatarPath;
  bool _onboardingComplete = true; // Começa como true para pular o onboarding

  @override
  Future<String?> getAvatarPath() async {
    return _avatarPath;
  }

  @override
  Future<bool> isOnboardingComplete() async {
    return _onboardingComplete;
  }

  @override
  Future<String?> getPolicyAcceptedVersion() async => '1.0';

  @override
  Future<void> revokePolicy() async {
    _avatarPath = null;
    _onboardingComplete = false;
  }

  @override
  Future<void> setAvatarPath(String path) async {
    _avatarPath = path;
  }

  @override
  Future<void> setOnboardingComplete() async {
    _onboardingComplete = true;
  }

  @override
  Future<void> setPolicyAccepted(String version) async {}
  
  // --- Funções de Controle para o Teste ---
  void setAvatarPathForTest(String? path) {
    _avatarPath = path;
  }
  void setOnboardingCompleteForTest(bool complete) {
    _onboardingComplete = complete;
  }
}
// --- Fim do FakePrefsService ---


void main() {
  late FakePrefsService fakePrefsService;

  // --- Setup do Teste ---
  setUp(() async {
    // Inicializa o SharedPreferences falso para todos os testes
    // Isto garante que o nosso outro ficheiro de teste não interfere
    SharedPreferences.setMockInitialValues({});
    
    fakePrefsService = FakePrefsService();

    // *** INÍCIO DA CORREÇÃO ***
    // Reset completo do GetIt para cada teste
    await getIt.reset();
    getIt.allowReassignment = true;
    // *** FIM DA CORREÇÃO ***

    // Regista o nosso Fake
    // Isto irá SOBRESCREVER qualquer registo real (se houver),
    // ou irá criar um novo registo se 'getIt' estiver vazio.
    getIt.registerSingleton<PrefsService>(fakePrefsService);
  });

  // --- TearDown do Teste ---
  tearDown(() async {
    // Limpa o GetIt após cada teste
    await getIt.reset();
  });
  // --- Fim do TearDown ---

  
  testWidgets('PR 5.4a - Deve exibir iniciais (fallback "GU") por padrão', (WidgetTester tester) async {
    // 1. Setup (Stub):
    fakePrefsService.setAvatarPathForTest(null);
    // Garantimos que o onboarding ESTÁ completo para irmos para a Home
    fakePrefsService.setOnboardingCompleteForTest(true); 

    // 2. Ação (Act):
    await tester.pumpWidget(const MyApp()); // Renderiza o App
    await tester.pumpAndSettle(); // Espera a SplashScreen terminar

    // 3. Verificação (Assert):
    expect(find.byType(HomeScreen), findsOneWidget); // Verifica se chegou na Home

    // 4. Ação (Act):
    // Abre o Drawer (menu lateral)
    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle(); // Espera a animação do drawer

    // 5. Verificação (Assert):
    // Procura o Texto 'GU' do fallback.
    expect(find.text('GU'), findsOneWidget);
  });


  testWidgets('PR 5.4b/c - Deve mostrar ModalBottomSheet ao tocar no avatar', (WidgetTester tester) async {
    // 1. Setup (Stub):
    fakePrefsService.setAvatarPathForTest(null);
    fakePrefsService.setOnboardingCompleteForTest(true);

    // 2. Ação (Act):
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();
    
    // Abre o Drawer
    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();

    // 3. Ação (Act) - Requisito 4b:
    // Simula o toque no Avatar - usando finder mais específico
    await tester.tap(find.byWidgetPredicate((widget) => 
      widget is Semantics && 
      widget.properties.label == 'Avatar do usuário'
    ));
    await tester.pumpAndSettle(); // Espera a animação do sheet

    // 4. Verificação (Assert) - Requisito 4c:
    // Verifica se o BottomSheet apareceu
    expect(find.byType(BottomSheet), findsOneWidget);
    // Verifica se as opções estão visíveis
    expect(find.text('Tirar Foto'), findsOneWidget);
    expect(find.text('Escolher da Galeria'), findsOneWidget);
  });
}