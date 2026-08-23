import 'package:in_app_review/in_app_review.dart';

/// Avaliação in-app (ver docs/APP_FACTORY_CORE.md, módulo Review) —
/// disparada no momento de sucesso (logo após compartilhar um orçamento),
/// canal de aquisição orgânica mais barato disponível. O SDK do sistema
/// controla sozinho a frequência real de exibição (a Play Store não
/// mostra o diálogo toda vez que é pedido) — este serviço só decide
/// *quando faz sentido pedir*, não *se* vai aparecer.
class ReviewService {
  const ReviewService._();

  static Future<void> requestReviewIfAvailable() async {
    final inAppReview = InAppReview.instance;
    try {
      if (await inAppReview.isAvailable()) {
        await inAppReview.requestReview();
      }
    } catch (_) {
      // Nunca pode travar o fluxo de compartilhamento por causa disso.
    }
  }
}
