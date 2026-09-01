import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

/// Provider que checa o status atual da permissão de notificações.
/// A Home escuta este provider e mostra um banner de alerta caso
/// a permissão esteja negada ou nunca tenha sido pedida.
///
/// **Por que um FutureProvider e não NotifierProvider:** a checagem
/// de permissão é assíncrona (platform channel) e não precisa de
/// estado mutável — só queremos o resultado. O provider é invalidado
/// automaticamente quando o app volta do background (via WidgetsBinding
/// lifecycle observers na Home), então o status é rechecado toda vez
/// que o usuário voltar das Configurações do sistema após habilitar
/// as notificações.
final notificationPermissionProvider = FutureProvider<PermissionStatus>((ref) async {
  final status = await Permission.notification.status;
  return status;
});
