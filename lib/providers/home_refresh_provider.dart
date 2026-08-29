import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Contador incrementado sempre que uma ação relevante para o resumo da
/// Home acontece em outra tela (registrar pagamento, mudar status de
/// orçamento, criar/editar orçamento) — a `HomeScreen` fica montada o
/// tempo todo via `IndexedStack` (ver `main_shell.dart`), então seu
/// `initState` só roda uma vez; sem isso, o resumo (Recebidos/Aguardando/
/// Aprovados) nunca atualizava depois da primeira abertura da aba.
///
/// Uso: `ref.read(homeRefreshProvider.notifier).bump()` após qualquer
/// escrita que mude os totais exibidos na Home; a Home escuta com
/// `ref.watch(homeRefreshProvider)` e recarrega o resumo quando o valor
/// muda.
class HomeRefreshNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void bump() => state++;
}

final homeRefreshProvider = NotifierProvider<HomeRefreshNotifier, int>(
  HomeRefreshNotifier.new,
);
