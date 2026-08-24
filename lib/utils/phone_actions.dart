import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../widgets/app_snackbar.dart';

/// Ações rápidas a partir de um telefone salvo (ligar / WhatsApp) — ver
/// docs/ANALISE_CONCORRENCIA_E_ESCOPO.md, Parte 5, item 6 ("Ações rápidas
/// no cliente"). Sem `canLaunchUrl` de propósito: em Android 11+ isso
/// exige declarar `<queries>` no `AndroidManifest.xml` pra funcionar
/// direito (mudança nativa); chamar `launchUrl` direto e tratar falha
/// com um snackbar evita essa dependência — abrir um app externo via
/// intent implícito não precisa da visibilidade de pacote que só o
/// `canLaunchUrl` exige.
class PhoneActions {
  const PhoneActions._();

  static Future<void> call(BuildContext context, String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    await _launch(context, uri);
  }

  /// [message], quando informado, vai pré-preenchido na conversa (ex.:
  /// follow-up de orçamento aguardando resposta — ver
  /// docs/ROADMAP_UX_UI_E_FEATURES_APP1.md, seção 10). Nunca enviado
  /// automaticamente: só pré-preenche, quem manda é o usuário.
  static Future<void> openWhatsApp(BuildContext context, String phone, {String? message}) async {
    final digits = _normalizeToBrazilianDigits(phone);
    final uri = Uri.parse('https://wa.me/$digits').replace(
      queryParameters: (message == null || message.isEmpty) ? null : {'text': message},
    );
    await _launch(context, uri);
  }

  static Future<void> _launch(BuildContext context, Uri uri) async {
    try {
      final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!opened && context.mounted) {
        AppSnackBar.show(context, 'Não consegui abrir.', variant: AppSnackBarVariant.warning);
      }
    } catch (_) {
      if (context.mounted) {
        AppSnackBar.show(context, 'Não consegui abrir.', variant: AppSnackBarVariant.warning);
      }
    }
  }

  /// `wa.me` exige código do país. Remove tudo que não é dígito e
  /// prepende "55" se o número já não vier com ele (telefone salvo aqui
  /// é sempre brasileiro — ver escopo do plano de negócio).
  static String _normalizeToBrazilianDigits(String phone) {
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    return digits.startsWith('55') ? digits : '55$digits';
  }
}
