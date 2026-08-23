import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';
import '../widgets/app_button.dart';

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

const _pages = [
  _OnboardingPage(
    icon: Icons.straighten_outlined,
    title: 'Meça e cote rápido',
    description:
        'Meça o ambiente, monte o orçamento com sua lista de preços e mande pro cliente em poucos minutos.',
  ),
  _OnboardingPage(
    icon: Icons.wifi_off_outlined,
    title: 'Funciona sem internet',
    description:
        'Tudo fica salvo no aparelho. Sem cadastro pra começar, sem depender de sinal na obra.',
  ),
  _OnboardingPage(
    icon: Icons.touch_app_outlined,
    title: 'Tudo num toque só',
    description:
        'Clientes, lista de preços e orçamentos ficam na barra debaixo da tela. Pode começar.',
  ),
];

/// Três telas na primeira abertura do app — pensadas pro público de baixa
/// familiaridade digital que o CLAUDE.md descreve (uso ao sol/poeira no
/// canteiro, referência diária é o WhatsApp). Nunca mostrado de novo
/// depois da primeira vez (ver `PreferencesRepository.markOnboardingSeen`)
/// e sempre pulável — segue o princípio 5 do CLAUDE.md: login (e agora
/// onboarding) nunca vira uma barreira de entrada antes de gerar valor.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, required this.onDone});

  final VoidCallback onDone;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _index = 0;

  bool get _isLast => _index == _pages.length - 1;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    if (_isLast) {
      widget.onDone();
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
                  onPressed: widget.onDone,
                  child: const Text('Pular'),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (index) => setState(() => _index = index),
                itemBuilder: (context, index) {
                  final page = _pages[index];
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
                for (var i = 0; i < _pages.length; i++)
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
