// lib/main.dart

import 'package:flutter/material.dart';
import 'locator.dart';
import 'screens/consent_screen.dart';
import 'screens/home_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/splash_screen.dart';

Future<void> main() async {
  // Garante que o Flutter está inicializado
  WidgetsFlutterBinding.ensureInitialized();
  
  // ESPERA nossos serviços (SharedPreferences) carregarem
  await setupLocator();
  
  // Roda o App
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Aplicando a paleta de cores do tema Leafy (Corrigido para M3)
    final ColorScheme leafyColorScheme = ColorScheme.dark(
      primary: const Color(0xFF22C55E),   // Green
      secondary: const Color(0xFF0EA5E9), // Blue
      surface: const Color(0xFF1F2937),    // Slate (fundo do app e componentes)
      onPrimary: Colors.black, // Texto em cima do Verde
      onSecondary: Colors.black, // Texto em cima do Azul
      onSurface: Colors.white,    // Texto em cima do Slate
      error: Colors.redAccent,
      onError: Colors.white,
      brightness: Brightness.dark,
    );

    return MaterialApp(
      title: 'Leafy',
      theme: ThemeData(
        colorScheme: leafyColorScheme,
        useMaterial3: true,
        appBarTheme: AppBarTheme(
          backgroundColor: leafyColorScheme.surface,
          foregroundColor: leafyColorScheme.onSurface,
        ),
      ),
      
      // 1. Ponto de entrada do App
      initialRoute: '/',
      
      // 2. Rotas Nomeadas (Requisito do PRD)
      routes: {
        '/': (context) => const SplashScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/consent': (context) => const ConsentScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}