import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/enums.dart';
import '../providers/profile_repository_provider.dart';
import '../theme/app_spacing.dart';
import '../widgets/app_button.dart';
import '../widgets/app_trade_selector.dart';

class _OnboardingPage {
  const _OnboardingPage({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;
}

const _infoPages = [
  _OnboardingPage(
    icon: Icons.straighten_outlined,
    title: 'Meça e cote rápido',
    description:
          'Meça o cômodo, monte o orçamento com seus preços e mande pro cliente em poucos minutos.',
  ),
  _OnboardingPage(
    icon: Icons.wifi_off_outlined,
    title: 'Funciona sem internet',
    description:
          'Tudo salvo no celular. Sem cadastro pra começar, sem precisar de internet.',
  ),
];

/// Total de telas: as 2 informativas + a pergunta de ofício.
final _pageCount = _infoPages.length + 1;

/// Três telas na primeira abertura do app — pensadas pro público de baixa
/// familiaridade digital que o CLAUDE.md descreve (uso ao sol/poeira no
/// canteiro, referência diária é o WhatsApp). Nunca mostrado de novo
/// depois da primeira vez (ver `PreferencesRepository.markOnboardingSeen`)
/// e sempre pulável — segue o princípio 5 do CLAUDE.md: login (e agora
/// onboarding) nunca vira uma barreira de entrada antes de gerar valor.
///
/// A 3ª tela pergunta o ofício em vez de só informar (ver
/// docs/POSICIONAMENTO_E_FEATURES_APP1.md, "camada de ofício") — é o dado
/// de maior retorno do app hoje: sem ele a lista de sugestões da Lista de
/// Preços despeja os 23 serviços de todos os ofícios misturados. Pulável
/// como as outras: quem pula segue com o ofício em branco, e a lista de
/// sugestões volta a mostrar tudo (nunca deixa o botão sem efeito).
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key, required this.onDone});

  final VoidCallback onDone;

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();
  int _index = 0;
  Set<Trade> _selectedTrades = {};

  bool get _isLast => _index == _pageCount - 1;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    if (_selectedTrades.isNotEmpty) {
      await ref.read(profileRepositoryProvider).saveProfile(trades: _selectedTrades);
    }
    widget.onDone();
  }

  void _next() {
    if (_isLast) {
      _finish();
    } else {
      _controller.nextPage(duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: TextButton(
                  onPressed: _finish,
                  child: const Text('Pular'),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pageCount,
                onPageChanged: (index) => setState(() => _index = index),
                itemBuilder: (context, index) {
                  if (index == _infoPages.length) {
                    return _TradeQuestionPage(
                      selected: _selectedTrades,
                      onChanged: (trades) => setState(() => _selectedTrades = trades),
                    );
                  }
                  final page = _infoPages[index];
                  return Padding(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: colorScheme.primaryContainer,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(page.icon, size: 56, color: colorScheme.onPrimaryContainer),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        Text(
                          page.title,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          page.description,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < _pageCount; i++)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: i == _index ? 20 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: i == _index ? colorScheme.primary : colorScheme.outlineVariant,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: AppButton(
                label: _isLast ? 'Começar' : 'Próximo',
                onPressed: _next,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 3ª tela do onboarding: pergunta o ofício em vez de só informar. Muitos
/// profissionais fazem mais de um, por isso é múltipla escolha (ver
/// `AppTradeSelector`). Editável depois em Ajustes — não é uma decisão
/// travada na primeira abertura.
class _TradeQuestionPage extends StatelessWidget {
  const _TradeQuestionPage({required this.selected, required this.onChanged});

  final Set<Trade> selected;
  final ValueChanged<Set<Trade>> onChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.engineering_outlined, size: 56, color: colorScheme.onPrimaryContainer),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            'O que você faz?',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Pode marcar mais de um. Isso ajusta as sugestões da sua lista de preços — dá pra mudar depois em Ajustes.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Center(
            child: AppTradeSelector(selected: selected, onChanged: onChanged),
          ),
        ],
      ),
    );
  }
}
