// test/services/prefs_service_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:leafy/services/prefs/prefs_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  // Define um grupo de testes para o PrefsService
  group('PrefsServiceImpl Unit Tests', () {
    
    // Este teste verifica o requisito principal do PR 3:
    // Salvar e ler o caminho do avatar.
    test('setAvatarPath e getAvatarPath devem funcionar corretamente', () async {
      // 1. Setup:
      // Prepara um SharedPreferences "falso" na memória
      SharedPreferences.setMockInitialValues({
        'onboarding_complete': true, // (um valor de exemplo)
      });

      final prefs = await SharedPreferences.getInstance();
      final service = PrefsServiceImpl(prefs); // Cria o serviço
      const testPath = 'meu/caminho/teste/avatar.jpg';

      // 2. Ação (Act):
      // Tenta salvar o caminho
      await service.setAvatarPath(testPath);

      // 3. Verificação (Assert):
      // Verifica se o serviço consegue ler o mesmo caminho de volta
      final result = await service.getAvatarPath();
      expect(result, testPath);
      
      // Verifica diretamente no SharedPreferences falso
      expect(prefs.getString('avatar_path'), testPath);
    });

    test('revokePolicy deve limpar o caminho do avatar', () async {
      // 1. Setup:
      SharedPreferences.setMockInitialValues({
        'onboarding_complete': true,
        'avatar_path': 'caminho/para/apagar.jpg', // (Um avatar que existe)
      });

      final prefs = await SharedPreferences.getInstance();
      final service = PrefsServiceImpl(prefs);

      // 2. Ação (Act):
      await service.revokePolicy(); // Chama a revogação

      // 3. Verificação (Assert):
      // O caminho do avatar deve estar nulo (limpo)
      final result = await service.getAvatarPath();
      expect(result, isNull);
    });
  });
}