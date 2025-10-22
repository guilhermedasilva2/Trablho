// lib/screens/consent_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // <-- CORREÇÃO 1: Importar
// import 'package:markdown_widget/markdown_widget.dart'; // Removido temporariamente
import 'package:leafy/locator.dart';
import 'package:leafy/services/prefs/prefs_service.dart';

// Texto da política em Markdown (simulado)
const String kPolicyMarkdown = """
# Política de Privacidade e Termos de Uso (v1.0)

Última atualização: 22/10/2025

## 1. O que coletamos

O Leafy é um aplicativo focado 100% na sua privacidade.

* **NÃO** coletamos dados pessoais de identificação.
* **NÃO** enviamos seus dados para servidores.
* Todos os dados (nomes das plantas, lembretes, fotos) são salvos **localmente** no seu dispositivo.

## 2. Permissões

### Notificações
Para lhe enviar lembretes de rega, o app solicitará permissão de Notificação.

### Câmera e Galeria (Fase 2)
Para adicionar uma foto de perfil ou fotos das suas plantas, o app solicitará permissão de Câmera e/ou Galeria. **Nós removemos todos os metadados (EXIF/GPS) das fotos** para proteger sua privacidade (LGPD).

## 3. Consentimento

Ao marcar "Li e aceito os termos" e continuar, você consente com o uso das permissões necessárias (como Notificações) para o funcionamento do app, ciente de que seus dados são processados localmente.

Você pode **revogar** este consentimento a qualquer momento no menu lateral do aplicativo.
""";

class ConsentScreen extends StatefulWidget {
  const ConsentScreen({super.key});

  @override
  State<ConsentScreen> createState() => _ConsentScreenState();
}

class _ConsentScreenState extends State<ConsentScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _hasReadPolicy = false; // "Marcar como lido"
  bool _isOptInAccepted = false; // "Opt-in"
  double _scrollProgress = 0.0; // "Barra de leitura"

  @override
  void initState() {
    super.initState();
    debugPrint('ConsentScreen initState()');
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Verifica se o widget ainda está montado
    if (!mounted) return;
    
    // Lógica da Barra de Leitura
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    
    setState(() {
      _scrollProgress = (maxScroll > 0) ? (currentScroll / maxScroll) : 1.0;
    });

    // Lógica do "Marcar como lido"
    // Se o usuário chegou a 95% do scroll, consideramos lido
    if (_scrollProgress > 0.95 && !_hasReadPolicy) {
      if (mounted) {
        setState(() {
          _hasReadPolicy = true;
        });
      }
    }
  }

  Future<void> _onAccept() async {
    if (!_isFormValid()) return;

    final prefsService = getIt<PrefsService>();
    
    // Cumprindo os requisitos do PRD:
    await prefsService.setPolicyAccepted("1.0"); // 1. Versionamento
    await prefsService.setOnboardingComplete(); // 2. Finaliza o Onboarding
    
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed('/home');
  }

  // *** CORREÇÃO 2: Função de Recusar (LGPD) ***
  Future<void> _onRefuse(BuildContext context) async {
    final bool? shouldExit = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Recusar Termos'),
        content: const Text(
          'Para usar o Leafy, você precisa aceitar os termos.\n\nSe recusar, o aplicativo será fechado. Deseja sair?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false), // "Não"
            child: const Text('Não'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true), // "Sim"
            child: Text(
              'Sim, Sair',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );

    // Se o usuário clicou em "Sim, Sair"
    if (shouldExit == true) {
      SystemNavigator.pop(); // Fecha o aplicativo
    }
  }
  // *** FIM DA CORREÇÃO 2 ***

  bool _isFormValid() {
    return _hasReadPolicy && _isOptInAccepted;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Termos e Privacidade'),
        // *** CORREÇÃO 3: Botão de Recusar na AppBar ***
        leading: IconButton(
          icon: const Icon(Icons.close), // Ícone 'X'
          tooltip: 'Recusar e sair do app',
          onPressed: () => _onRefuse(context),
        ),
        // *** FIM DA CORREÇÃO 3 ***
      ),
      body: Column(
        children: [
          // 1. Barra de Leitura (Requisito do PRD)
          LinearProgressIndicator(
            value: _scrollProgress,
            backgroundColor: theme.colorScheme.surface,
            color: theme.colorScheme.primary,
          ),

          // 2. O Viewer de Markdown (Requisito do PRD)
          Expanded(
            child: Scrollbar(
              controller: _scrollController,
              thumbVisibility: true,
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    kPolicyMarkdown,
                    style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),
                  ),
                ),
              ),
            ),
          ),

          // 3. O Consentimento (Opt-in) (Requisito do PRD)
          _buildConsentFooter(theme),
        ],
      ),
    );
  }

  Container _buildConsentFooter(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16.0).copyWith(bottom: 32.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(top: BorderSide(color: theme.dividerColor)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // "Marcar como lido" (Aparece após o scroll)
          if (_hasReadPolicy)
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 16),
                SizedBox(width: 8),
                Text('Marcado como lido.', style: TextStyle(color: Colors.green)),
              ],
            ),
          
          // Checkbox (Opt-in)
          CheckboxListTile(
            value: _isOptInAccepted,
            // Só habilita o checkbox DEPOIS que o usuário leu
            onChanged: _hasReadPolicy 
              ? (bool? value) {
                  setState(() {
                    _isOptInAccepted = value ?? false;
                  });
                } 
              : null,
            title: Text(
              'Li e aceito os Termos e a Política de Privacidade (v1.0).',
              style: theme.textTheme.bodySmall?.copyWith(
                color: _hasReadPolicy ? Colors.white : Colors.grey,
              ),
            ),
            controlAffinity: ListTileControlAffinity.leading,
            activeColor: theme.colorScheme.primary,
          ),
          
          // Botão "Avançar"
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton(
              // SÓ HABILITA se leu E aceitou
              onPressed: _isFormValid() ? _onAccept : null,
              style: FilledButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                disabledBackgroundColor: theme.colorScheme.surface,
                disabledForegroundColor: Colors.grey,
              ),
              child: Text(
                'Avançar',
                style: TextStyle(
                  color: _isFormValid() ? theme.colorScheme.onPrimary : Colors.grey,
                  fontWeight: FontWeight.bold
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}