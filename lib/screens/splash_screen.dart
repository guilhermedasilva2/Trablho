// lib/screens/splash_screen.dart

import 'package:flutter/material.dart';
import 'package:leafy/locator.dart';
import 'package:leafy/services/prefs/prefs_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkOnboardingStatus();
  }

  Future<void> _checkOnboardingStatus() async {
    // Aguarda 1 segundo (para a splash ser visível)
    await Future.delayed(const Duration(seconds: 1));

    // Busca nosso serviço
    final prefsService = getIt<PrefsService>();
    final isOnboardingComplete = await prefsService.isOnboardingComplete();

    // Navegação (MUITO IMPORTANTE: 'mounted' garante que o widget ainda existe)
    if (!mounted) return;

    if (isOnboardingComplete) {
      // Se já viu o onboarding, vai para a Home
      Navigator.of(context).pushReplacementNamed('/home');
    } else {
      // Se é a primeira vez, vai para o Onboarding
      Navigator.of(context).pushReplacementNamed('/onboarding');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // TODO: Adicionar seu ícone aqui (quando tiver)
            const Icon(Icons.eco, size: 80, color: Color(0xFF22C55E)),
            const SizedBox(height: 24),
            Text(
              'Leafy',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}