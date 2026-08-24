import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:upgrader/upgrader.dart';

import 'analytics/analytics_service.dart';
import 'notifications/notification_service.dart';
import 'routing/app_router.dart';
import 'theme/app_theme.dart';

/// Liga a checagem de atualização (ver decisão do plano de 23/08/2026,
/// módulo AppUpdate). Desligada nos widget tests — `UpgradeAlert` faz uma
/// chamada de rede real pra loja, que fica pendente e trava o ambiente de
/// teste (mesmo motivo de `appDatabaseProvider` ser sobrescrito em teste).
final showUpgradeAlertProvider = Provider<bool>((ref) => true);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // `AppDatePicker` formata data com `DateFormat(..., 'pt_BR')` — sem
  // isso, o pacote `intl` nunca carrega os símbolos de pt_BR e o widget
  // lança uma exceção assim que uma data é escolhida (ficava um bloco
  // cinza no lugar do campo, achado em teste manual real no aparelho —
  // `flutter test` não pega isso porque a formatação só quebra com o
  // locale de verdade carregado em runtime).
  await initializeDateFormatting('pt_BR');

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
    AnalyticsService.trackEvent('app_open');
    NotificationService.initialize();
  }

  @override
  Widget build(BuildContext context) {
    final showUpgradeAlert = ref.watch(showUpgradeAlertProvider);
    return MaterialApp.router(
      title: 'Obrion Orçamentos',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      // Força pt_BR independente do idioma do aparelho — interface do
      // app já é 100% português (ver CLAUDE.md), incluindo os diálogos
      // nativos do Flutter (calendário do `AppDatePicker`, etc.).
      locale: const Locale('pt', 'BR'),
      supportedLocales: const [Locale('pt', 'BR')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: appRouter,
      // Verifica se há versão mais nova na loja e recomenda atualizar
      // no boot — mecanismo de segurança para quando um patch OTA
      // (Shorebird) ou build quebrada sair (ver CLAUDE.md, decisão 6).
      // Sem efeito antes da primeira publicação: a checagem contra a
      // ficha da loja simplesmente não encontra o app e não mostra nada.
      builder: (context, child) {
        final content = child ?? const SizedBox.shrink();
        return showUpgradeAlert ? UpgradeAlert(child: content) : content;
      },
    );
  }
}
