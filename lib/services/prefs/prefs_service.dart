// lib/services/prefs/prefs_service.dart

import 'package:shared_preferences/shared_preferences.dart';

// 1. A Classe Abstrata (A "Interface")
abstract class PrefsService {
  Future<void> setOnboardingComplete();
  Future<bool> isOnboardingComplete();
  Future<void> setPolicyAccepted(String version);
  Future<String?> getPolicyAcceptedVersion();
  Future<void> revokePolicy();

  // --- INÍCIO DA MODIFICAÇÃO (PR 3) ---
  Future<void> setAvatarPath(String path);
  Future<String?> getAvatarPath();
  // --- FIM DA MODIFICAÇÃO (PR 3) ---
}

// 2. A Implementação (A lógica real)
class PrefsServiceImpl implements PrefsService {
  final SharedPreferences _prefs;

  // Chaves de armazenamento
  static const String _kOnboardingComplete = 'onboarding_complete';
  static const String _kPolicyAcceptedVersion = 'policy_accepted_version';
  // --- INÍCIO DA MODIFICAÇÃO (PR 3) ---
  static const String _kAvatarPath = 'avatar_path'; // Nova chave
  // --- FIM DA MODIFICAÇÃO (PR 3) ---

  PrefsServiceImpl(this._prefs);

  @override
  Future<bool> isOnboardingComplete() async {
    return _prefs.getBool(_kOnboardingComplete) ?? false;
  }

  @override
  Future<void> setOnboardingComplete() async {
    await _prefs.setBool(_kOnboardingComplete, true);
  }

  @override
  Future<String?> getPolicyAcceptedVersion() async {
    return _prefs.getString(_kPolicyAcceptedVersion);
  }

  @override
  Future<void> setPolicyAccepted(String version) async {
    await _prefs.setString(_kPolicyAcceptedVersion, version);
  }

  @override
  Future<void> revokePolicy() async {
    await _prefs.remove(_kPolicyAcceptedVersion);
    await _prefs.remove(_kOnboardingComplete);
    // --- INÍCIO DA MODIFICAÇÃO (PR 3) ---
    // (IMPORTANTE: Se o usuário revoga, também apagamos o avatar)
    await _prefs.remove(_kAvatarPath);
    // (TODO: Também devemos apagar o 'avatar.jpg' do disco)
    // --- FIM DA MODIFICAÇÃO (PR 3) ---
  }

  // --- INÍCIO DA MODIFICAÇÃO (PR 3) ---
  @override
  Future<String?> getAvatarPath() async {
    return _prefs.getString(_kAvatarPath);
  }

  @override
  Future<void> setAvatarPath(String path) async {
    await _prefs.setString(_kAvatarPath, path);
  }
  // --- FIM DA MODIFICAÇÃO (PR 3) ---
}