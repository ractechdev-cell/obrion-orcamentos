import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'analytics/analytics_service.dart';
import 'providers/preferences_repository_provider.dart';
import 'providers/theme_mode_provider.dart';
import 'routing/app_router.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Crashlytics: intercepta todos os erros não tratados do Flutter
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  runApp(const ProviderScope(child: ObrionOrcamentosApp()));
}

class ObrionOrcamentosApp extends ConsumerStatefulWidget {
  const ObrionOrcamentosApp({super.key});

  @override
  ConsumerState<ObrionOrcamentosApp> createState() => _ObrionOrcamentosAppState();
}

class _ObrionOrcamentosAppState extends ConsumerState<ObrionOrcamentosApp> {
  @override
  void initState() {
    super.initState();
    _loadThemeMode();
    AnalyticsService.trackEvent('app_open');
  }

  Future<void> _loadThemeMode() async {
    final repo = ref.read(preferencesRepositoryProvider);
    final mode = await repo.getThemeMode();
    if (mounted) {
      ref.read(themeModeProvider.notifier).set(mode);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    return MaterialApp.router(
      title: 'Obrion Orçamentos',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      routerConfig: appRouter,
    );
  }
}
