// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:leafy/locator.dart';
import 'package:leafy/services/prefs/prefs_service.dart';

import 'dart:io'; // Para File
import 'package:image/image.dart' as img; // Para processamento de imagem
import 'package:path_provider/path_provider.dart'; // Para achar a pasta
import 'package:path/path.dart' as p; // Para juntar caminhos (path.join)

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // --- INÍCIO DA MODIFICAÇÃO (PR 4) ---

  // Requisito 1: Variável de estado para o caminho do avatar
  String? _avatarFilePath;

  // Requisito 2: Adicionar initState para carregar o avatar salvo
  @override
  void initState() {
    super.initState();
    _loadAvatar(); // Carrega o avatar ao iniciar a tela
  }

  /// Carrega o caminho do avatar salvo no PrefsService
  Future<void> _loadAvatar() async {
    final prefsService = getIt<PrefsService>();
    final path = await prefsService.getAvatarPath();
    if (path != null && mounted) {
      setState(() {
        _avatarFilePath = path;
      });
    }
  }

  // --- FIM DA MODIFICAÇÃO (PR 4) ---

  void _onAvatarTapped() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Tirar Foto'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Escolher da Galeria'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final Permission permission = (source == ImageSource.camera)
        ? Permission.camera
        : Permission.photos;

    final PermissionStatus status = await permission.request();

    if (status.isGranted) {
      try {
        final ImagePicker picker = ImagePicker();
        final XFile? image = await picker.pickImage(source: source);

        if (image != null) {
          _showLoadingDialog();
          
          final bytes = await image.readAsBytes();
          final imageDecoded = img.decodeImage(bytes);

          if (imageDecoded == null) {
            _hideLoadingDialog();
            _showErrorSnackBar('Formato de imagem não suportado.');
            return;
          }

          final processedImageBytes = img.encodeJpg(imageDecoded, quality: 80);

          final dir = await getApplicationDocumentsDirectory();
          final newPath = p.join(dir.path, 'avatar.jpg');
          await File(newPath).writeAsBytes(processedImageBytes);

          final prefsService = getIt<PrefsService>();
          await prefsService.setAvatarPath(newPath);

          _hideLoadingDialog();
          _showSuccessSnackBar('Avatar atualizado com sucesso!');

          // --- INÍCIO DA MODIFICAÇÃO (PR 4) ---
          // Requisito 4: Atualizar a UI imediatamente com setState
          if (mounted) {
            setState(() {
              _avatarFilePath = newPath;
            });
          }
          // --- FIM DA MODIFICAÇÃO (PR 4) ---

        }
      } catch (e) {
        _hideLoadingDialog();
        _showErrorSnackBar('Erro ao processar imagem: $e');
      }
    } else if (status.isDenied) {
      _showErrorSnackBar('Permissão negada. Não é possível selecionar a imagem.');
    } else if (status.isPermanentlyDenied) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Permissão negada permanentemente. Abra as configurações para permitir.'),
            action: SnackBarAction(
              label: 'Configurações',
              onPressed: () {
                openAppSettings();
              },
            ),
          ),
        );
      }
    }
  }

  // --- Helpers (sem alteração) ---
  void _showLoadingDialog() {
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return const Dialog(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 20),
                Text('Processando imagem...'),
              ],
            ),
          ),
        );
      },
    );
  }
  void _hideLoadingDialog() {
    if (!mounted) return;
    Navigator.of(context).pop();
  }
  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }
  void _showSuccessSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }
  // --- Fim dos Helpers ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(color: theme.colorScheme.surface),
            accountName: const Text(
              'Guilherme da Silva',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            accountEmail: const Text('aluno@institucional.com'),
            currentAccountPicture: Semantics(
              label: 'Avatar do usuário',
              hint: 'Toque para alterar sua foto de perfil',
              child: InkWell(
                onTap: _onAvatarTapped,
                child: Material(
                  shape: const CircleBorder(),
                  clipBehavior: Clip.antiAlias,
                  color: Colors.transparent,
                  
                  // --- INÍCIO DA MODIFICAÇÃO (PR 4) ---
                  // Requisito 3: Exibição condicional (Imagem ou Fallback)
                  child: CircleAvatar(
                    radius: 40,
                    backgroundColor: theme.colorScheme.primary,
                    // a. Se _avatarFilePath não for nulo, mostra a imagem
                    backgroundImage: _avatarFilePath != null
                        ? FileImage(File(_avatarFilePath!))
                        : null,
                    // b. Se _avatarFilePath for nulo, mostra o fallback (iniciais)
                    child: _avatarFilePath == null
                        ? Text(
                            'GU', // Iniciais
                            style: TextStyle(fontSize: 40, color: theme.colorScheme.onPrimary),
                          )
                        : null, // O child fica nulo quando a imagem de fundo existe
                  ),
                  // --- FIM DA MODIFICAÇÃO (PR 4) ---

                ),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.eco),
            title: const Text('Minhas Plantas'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Configurações'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          const Spacer(),
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
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  void _showRevokeConsentSnackbar(BuildContext context) {
    Navigator.pop(context);

    final snackBar = SnackBar(
      content: const Text('Consentimento será revogado em 5 segundos...'),
      duration: const Duration(seconds: 5),
      action: SnackBarAction(
        label: 'Desfazer',
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Revogação cancelada.')),
          );
        },
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar).closed.then((reason) async {
      if (reason == SnackBarClosedReason.action) {
        return;
      }
      final prefsService = getIt<PrefsService>();
      await prefsService.revokePolicy();
      
      if (!mounted) return;
      if (context.mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      }
    });
  }
}