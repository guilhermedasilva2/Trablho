// lib/screens/onboarding_screen.dart

import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

// As 3 páginas do onboarding
final List<Widget> onboardingPages = [
  _buildOnboardingPage(
    icon: Icons.eco,
    title: 'Bem-vindo ao Leafy!',
    description: 'Seu assistente pessoal para nunca mais esquecer de cuidar das suas plantas.',
    color: const Color(0xFF22C55E), // Green
  ),
  _buildOnboardingPage(
    icon: Icons.notifications_active,
    title: 'Lembretes Inteligentes',
    description: 'Receba notificações no dia e hora certos para regar, adubar ou podar.',
    color: const Color(0xFF0EA5E9), // Blue
  ),
  _buildOnboardingPage(
    icon: Icons.privacy_tip,
    title: 'Sua Privacidade',
    description: 'Seus dados são 100% locais. O próximo passo é sobre nossa política de privacidade.',
    color: const Color(0xFF6B7280), // Gray
  ),
];

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onSkip() {
    // Pula direto para a tela de consentimento
    Navigator.of(context).pushReplacementNamed('/consent');
  }

  void _onNext() {
    if (_currentPage == onboardingPages.length - 1) {
      // Última página
      _onSkip();
    } else {
      // Vai para a próxima página
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLastPage = _currentPage == onboardingPages.length - 1;

    return Scaffold(
      appBar: AppBar(
        // Botão "Pular" (Acessibilidade: min 48dp)
        actions: [
          // *** CORREÇÃO AQUI ***
          // Garantindo área de toque de 48dp (A11Y)
          Semantics(
            label: 'Pular introdução',
            child: Container(
              constraints: const BoxConstraints(minHeight: 48, minWidth: 48),
              alignment: Alignment.center,
              margin: const EdgeInsets.only(right: 8.0), // Margem
              child: TextButton(
                onPressed: _onSkip,
                child: Text(
                  'Pular',
                  style: TextStyle(color: theme.colorScheme.onSurface),
                ),
              ),
            ),
          ),
          // *** FIM DA CORREÇÃO ***
        ],
      ),
      body: Column(
        children: [
          // 1. As Páginas (PageView)
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (page) {
                setState(() {
                  _currentPage = page;
                });
              },
              children: onboardingPages,
            ),
          ),
          
          // 2. Os "Dots" (Animados)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24.0),
            child: SmoothPageIndicator(
              controller: _pageController,
              count: onboardingPages.length,
              effect: ExpandingDotsEffect(
                activeDotColor: theme.colorScheme.primary,
                dotColor: theme.colorScheme.surface,
                dotHeight: 10,
                dotWidth: 10,
              ),
            ),
          ),

          // 3. Botão de Ação (Avançar/Concluir)
          // (Acessibilidade: min 48dp de altura)
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton(
                onPressed: _onNext,
                style: FilledButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                ),
                child: Text(
                  isLastPage ? 'Concluir' : 'Avançar',
                  style: TextStyle(color: theme.colorScheme.onPrimary, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Widget helper para construir uma página
Widget _buildOnboardingPage({
  required IconData icon,
  required String title,
  required String description,
  required Color color,
}) {
  return Padding(
    padding: const EdgeInsets.all(32.0),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 100, color: color),
        const SizedBox(height: 32),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          description,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.white70,
          ),
        ),
      ],
    ),
  );
}