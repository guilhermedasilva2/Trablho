// lib/services/prefs/prefs_service.dart

import 'package:shared_preferences/shared_preferences.dart';

// 1. A Classe Abstrata (A "Interface" que a UI vai usar)
// A UI não saberá que estamos usando SharedPreferences.
abstract class PrefsService {
  Future<void> setOnboardingComplete();
  Future<bool> isOnboardingComplete();
  Future<void> setPolicyAccepted(String version);
  Future<String?> getPolicyAcceptedVersion();
  Future<void> revokePolicy();
}

// 2. A Implementação (A lógica real com SharedPreferences)
class PrefsServiceImpl implements PrefsService {
  final SharedPreferences _prefs;

  // Chaves de armazenamento
  static const String _kOnboardingComplete = 'onboarding_complete';
  static const String _kPolicyAcceptedVersion = 'policy_accepted_version';

  // O construtor recebe a instância do SharedPreferences
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
    // Revogar significa apagar o aceite e resetar o onboarding
    await _prefs.remove(_kPolicyAcceptedVersion);
    await _prefs.remove(_kOnboardingComplete);
  }
}