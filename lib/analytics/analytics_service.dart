import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

/// `trackEvent(name, params)` único (ver docs/APP_FACTORY_CORE.md, módulo
/// Analytics) — apps/telas só chamam isto, nunca o SDK do Firebase
/// direto. Nomes de evento em `snake_case` (ver CLAUDE.md, "Analytics —
/// eventos mínimos obrigatórios").
class AnalyticsService {
  const AnalyticsService._();

  /// Registra um evento. Nunca lança — analytics não pode derrubar nem
  /// travar um fluxo do usuário (mesma postura defensiva do `_loadLogo`
  /// do gerador de PDF: falha silenciosa é aceitável aqui).
  static Future<void> trackEvent(String name, [Map<String, Object>? params]) async {
    try {
      await FirebaseAnalytics.instance.logEvent(name: name, parameters: params);
    } catch (error, stack) {
      if (kDebugMode) {
        debugPrint('AnalyticsService.trackEvent("$name") falhou: $error\n$stack');
      }
    }
  }
}
