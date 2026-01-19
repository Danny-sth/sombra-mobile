import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api/sombra_api.dart';

/// Shared preferences provider
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Initialize in main.dart');
});

/// Settings providers
final apiUrlProvider = StateProvider<String>((ref) {
  return 'http://90.156.230.49:8080';
});

final sessionIdProvider = StateProvider<String>((ref) {
  return 'owner';
});

/// Sombra API provider
final sombraApiProvider = Provider<SombraApi>((ref) {
  final baseUrl = ref.watch(apiUrlProvider);
  final sessionId = ref.watch(sessionIdProvider);

  return SombraApi(
    baseUrl: baseUrl,
    sessionId: sessionId,
  );
});

/// Recording state
final isRecordingProvider = StateProvider<bool>((ref) => false);

/// Loading state
final isLoadingProvider = StateProvider<bool>((ref) => false);
