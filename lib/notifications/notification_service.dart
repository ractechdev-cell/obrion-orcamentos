import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// Lembrete local (ver docs/APP_FACTORY_CORE.md, módulo Notifications) —
/// "orçamento aguardando resposta há 3 dias" (CLAUDE.md, "Retenção
/// precisa de mecanismo, não só de métrica"). Sem servidor: agendado no
/// próprio aparelho quando o orçamento vira "Enviado", cancelado se o
/// status mudar antes disso ou o orçamento for excluído (ver
/// `BudgetsRepository.updateStatus`/`softDelete`).
///
/// Agendamento inexato (`AndroidScheduleMode.inexactAllowWhileIdle`) de
/// propósito — evita depender da permissão especial "Alarmes e
/// lembretes" do Android 12+ (`SCHEDULE_EXACT_ALARM`), que exige o
/// usuário liberar manualmente nas configurações do aparelho. Um
/// lembrete que chega com algumas horas de folga é aceitável; a
/// permissão especial não seria, pro público deste app.
class NotificationService {
  const NotificationService._();

  static const _channelId = 'budget_reminders';
  static const _channelName = 'Lembretes de orçamento';
  static const _channelDescription =
      'Avisa quando um orçamento enviado está esperando resposta há alguns dias.';

  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  /// Chamado uma vez no boot do app (`main.dart`). Nunca lança — a falta
  /// de lembrete não pode travar o app (mesma postura defensiva de
  /// `AnalyticsService`/`ReviewService`). Fica silenciosamente inativo em
  /// ambiente de teste (sem plugin nativo disponível) e simplesmente não
  /// agenda nada depois — ver guarda `_initialized` nos outros métodos.
  static Future<void> initialize() async {
    if (_initialized) return;
    try {
      tz_data.initializeTimeZones();
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      await _plugin.initialize(settings: const InitializationSettings(android: androidSettings));
      await _plugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
      _initialized = true;
    } catch (error, stack) {
      if (kDebugMode) {
        debugPrint('NotificationService.initialize() falhou: $error\n$stack');
      }
    }
  }

  /// Agenda o lembrete de "aguardando resposta" para 3 dias a partir de
  /// agora — chamado quando um orçamento vira "Enviado".
  static Future<void> scheduleAwaitingResponseReminder(String budgetId) async {
    if (!_initialized) return;
    try {
      // `tz.UTC` só como referência de fuso pro tipo exigido pela API —
      // o instante agendado (`from`) preserva o horário absoluto local
      // corretamente, não precisa detectar o fuso real do aparelho pra
      // isso (não exibimos esse horário em lugar nenhum da UI).
      final targetInstant = DateTime.now().add(const Duration(days: 3));
      final scheduledDate = tz.TZDateTime.from(targetInstant, tz.UTC);
      await _plugin.zonedSchedule(
        id: _notificationId(budgetId),
        title: 'Orçamento aguardando resposta',
        body: 'Já faz 3 dias que esse orçamento foi enviado — vale a pena dar um alô pro cliente.',
        scheduledDate: scheduledDate,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            _channelName,
            channelDescription: _channelDescription,
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    } catch (error, stack) {
      if (kDebugMode) {
        debugPrint('NotificationService.scheduleAwaitingResponseReminder() falhou: $error\n$stack');
      }
    }
  }

  /// Cancela o lembrete — chamado quando o orçamento sai de "Enviado"
  /// (aceito/recusado) ou é excluído.
  static Future<void> cancelAwaitingResponseReminder(String budgetId) async {
    if (!_initialized) return;
    try {
      await _plugin.cancel(id: _notificationId(budgetId));
    } catch (error, stack) {
      if (kDebugMode) {
        debugPrint('NotificationService.cancelAwaitingResponseReminder() falhou: $error\n$stack');
      }
    }
  }

  /// Agenda o lembrete de validade — 1 dia antes de `validUntil` (`Budgets`
  /// já guarda esse campo, nunca esteve ligado a uma notificação, ver
  /// docs/POSICIONAMENTO_E_FEATURES_APP1.md, Parte 4, item 5). Não agenda
  /// se a data já passou — mandar notificação de algo que já venceu não
  /// ajuda em nada.
  static Future<void> scheduleValidUntilReminder(String budgetId, DateTime validUntil) async {
    if (!_initialized) return;
    final targetInstant = validUntil.subtract(const Duration(days: 1));
    if (targetInstant.isBefore(DateTime.now())) return;
    try {
      final scheduledDate = tz.TZDateTime.from(targetInstant, tz.UTC);
      await _plugin.zonedSchedule(
        id: _notificationId(budgetId, salt: 'valid_until'),
        title: 'Orçamento perto de vencer',
        body: 'Esse orçamento vence amanhã — vale a pena dar um retorno pro cliente antes disso.',
        scheduledDate: scheduledDate,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            _channelName,
            channelDescription: _channelDescription,
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    } catch (error, stack) {
      if (kDebugMode) {
        debugPrint('NotificationService.scheduleValidUntilReminder() falhou: $error\n$stack');
      }
    }
  }

  /// Cancela o lembrete de validade — chamado quando `validUntil` é
  /// limpo/alterado (reagenda com a data nova) ou o orçamento é excluído.
  static Future<void> cancelValidUntilReminder(String budgetId) async {
    if (!_initialized) return;
    try {
      await _plugin.cancel(id: _notificationId(budgetId, salt: 'valid_until'));
    } catch (error, stack) {
      if (kDebugMode) {
        debugPrint('NotificationService.cancelValidUntilReminder() falhou: $error\n$stack');
      }
    }
  }

  /// IDs de notificação do Android são `int32` — reduz o hash da UUID do
  /// orçamento a um inteiro positivo de 32 bits. `salt` dá um id diferente
  /// por tipo de lembrete do mesmo orçamento; vazio preserva exatamente a
  /// fórmula original (`budgetId.hashCode`), pra não perder a referência
  /// de lembretes de "aguardando resposta" já agendados em aparelhos com
  /// versões anteriores do app instaladas.
  static int _notificationId(String budgetId, {String salt = ''}) =>
      (salt.isEmpty ? budgetId : '$budgetId::$salt').hashCode & 0x7FFFFFFF;
}
