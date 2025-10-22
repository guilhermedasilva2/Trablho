// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:leafy/locator.dart';
import 'package:leafy/services/prefs/prefs_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Usamos um Builder aqui para obter o Scaffold.context
      // correto para o SnackBar
      body: Builder(
        builder: (context) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Minhas Plantas'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    // TODO: Implementar "Adicionar Planta"
                  },
                ),
              ],
            ),
            drawer: _buildDrawer(context),
            body: const Center(
              child: Text('Home Screen (Conteúdo do App)'),
            ),
          );
        },
      ),
    );
  }

  Drawer _buildDrawer(BuildContext context) {
    final theme = Theme.of(context);

    return Drawer(
      child: Column(
        children: [
          // O Header do Drawer (Onde o Avatar da Fase 2 vai entrar)
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(color: theme.colorScheme.surface),
            accountName: const Text(
              'Guilherme da Silva', // TODO: Puxar nome do usuário
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            accountEmail: const Text('aluno@institucional.com'),
            // O AVATAR DE INICIAIS (Nosso ponto de partida para a Fase 2)
            currentAccountPicture: CircleAvatar(
              radius: 40,
              backgroundColor: theme.colorScheme.primary,
              child: Text(
                'GU', // Iniciais
                style: TextStyle(fontSize: 40, color: theme.colorScheme.onPrimary),
              ),
            ),
          ),
          
          // Itens do Menu
          ListTile(
            leading: const Icon(Icons.eco),
            title: const Text('Minhas Plantas'),
            onTap: () {
              Navigator.pop(context); // Fecha o drawer
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Configurações'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          
          const Spacer(), // Empurra o "Revogar" para baixo

          // "Revogar Consentimento" (Requisito do PRD)
          ListTile(
            leading: Icon(Icons.gpp_bad, color: theme.colorScheme.error),
            title: Text(
              'Revogar Consentimento',
              style: TextStyle(color: theme.colorScheme.error),
            ),
            onTap: () {
              _showRevokeConsentSnackbar(context);
            },
          ),
          const SizedBox(height: 24), // Margem inferior
        ],
      ),
    );
  }

  // Requisito PRD: Revogação com "Desfazer"
  void _showRevokeConsentSnackbar(BuildContext context) {
    // Fecha o Drawer
    Navigator.pop(context);

    // Cria o SnackBar com a ação "Desfazer"
    final snackBar = SnackBar(
      content: const Text('Consentimento será revogado em 5 segundos...'),
      duration: const Duration(seconds: 5),
      action: SnackBarAction(
        label: 'Desfazer',
        onPressed: () {
          // Se o usuário clicar em "Desfazer", não fazemos nada.
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Revogação cancelada.')),
          );
        },
      ),
    );

    // Mostra o SnackBar e aguarda ele fechar
    ScaffoldMessenger.of(context).showSnackBar(snackBar).closed.then((reason) async {
      // Se o SnackBar fechou porque o "Desfazer" foi clicado, não faz nada.
      if (reason == SnackBarClosedReason.action) {
        return;
      }

      // Se o SnackBar fechou por tempo (timeout),
      // o usuário NÃO clicou em "Desfazer".
      // Então, executamos a revogação.
      final prefsService = getIt<PrefsService>();
      await prefsService.revokePolicy();
      
      if (!context.mounted) return;
      // Manda o usuário de volta para o início do fluxo (Splash)
      Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
    });
  }
}