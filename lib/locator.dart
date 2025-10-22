// lib/locator.dart

import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/prefs/prefs_service.dart';

final getIt = GetIt.instance;

Future<void> setupLocator() async {
  // 1. Registra o SharedPreferences (Assíncrono)
  // Precisamos esperar ele carregar antes do app rodar
  final prefs = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(prefs);

  // 2. Registra nosso PrefsService
  // Usamos registerLazySingleton para ele ser criado só na primeira vez que for usado.
  getIt.registerLazySingleton<PrefsService>(
    () => PrefsServiceImpl(getIt<SharedPreferences>()),
  );
}