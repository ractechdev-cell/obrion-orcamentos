import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../database/enums.dart';
import '../providers/profile_repository_provider.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../widgets/app_button.dart';
import '../widgets/app_text_field.dart';
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

/// Total de páginas: 2 informativas + ofício + dados do profissional.
final _pageCount = _infoPages.length + 2;

/// Quatro telas na primeira abertura do app.
///
/// Páginas 1–2: apresentação do app.
/// Página 3: ofício ("O que você faz?") — ajusta a lista de sugestões.
/// Página 4: dados do profissional — nome, telefone, CNPJ e logo que vão
/// aparecer no cabeçalho de todo PDF enviado ao cliente. É o dado de maior
/// impacto imediato: um PDF sem nome do profissional parece amador. Todos
/// os campos são opcionais e editáveis depois em Ajustes.
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

  // Dados do perfil coletados na última página.
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _documentController = TextEditingController();
  String? _logoPath;

  bool get _isLast => _index == _pageCount - 1;

  @override
  void dispose() {
    _controller.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _documentController.dispose();
    super.dispose();
  }

  Future<void> _pickLogo() async {
    final file = await FilePicker.pickFile(type: FileType.image);
    final pickedPath = file?.path;
    if (pickedPath == null) return;

    final documentsDir = await getApplicationDocumentsDirectory();
    final extension = p.extension(pickedPath);
    final destination = p.join(documentsDir.path, 'profile_logo$extension');

    if (_logoPath != null && _logoPath != destination) {
      final previous = File(_logoPath!);
      if (await previous.exists()) await previous.delete();
    }

    await File(pickedPath).copy(destination);
    if (mounted) setState(() => _logoPath = destination);
  }

  Future<void> _finish() async {
    final repo = ref.read(profileRepositoryProvider);
    await repo.saveProfile(
      trades: _selectedTrades.isEmpty ? null : _selectedTrades,
      name: _nameController.text.trim().isEmpty
          ? null
          : _nameController.text.trim(),
      phone: _phoneController.text.trim().isEmpty
          ? null
          : _phoneController.text.trim(),
      document: _documentController.text.trim().isEmpty
          ? null
          : _documentController.text.trim(),
      logoPath: _logoPath,
    );
    widget.onDone();
  }

  void _next() {
    if (_isLast) {
      _finish();
    } else {
      _controller.nextPage(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
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
                  // Página de ofício.
                  if (index == _infoPages.length) {
                    return _TradeQuestionPage(
                      selected: _selectedTrades,
                      onChanged: (trades) =>
                          setState(() => _selectedTrades = trades),
                    );
                  }
                  // Página de perfil.
                  if (index == _infoPages.length + 1) {
                    return _ProfileSetupPage(
                      nameController: _nameController,
                      phoneController: _phoneController,
                      documentController: _documentController,
                      logoPath: _logoPath,
                      onPickLogo: _pickLogo,
                      onRemoveLogo: () => setState(() => _logoPath = null),
                    );
                  }
                  // Páginas informativas.
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
                          child: Icon(
                            page.icon,
                            size: 56,
                            color: colorScheme.onPrimaryContainer,
                          ),
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
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
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
                      color: i == _index
                          ? colorScheme.primary
                          : colorScheme.outlineVariant,
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
            child: Icon(
              Icons.engineering_outlined,
              size: 56,
              color: colorScheme.onPrimaryContainer,
            ),
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
          Center(child: AppTradeSelector(selected: selected, onChanged: onChanged)),
        ],
      ),
    );
  }
}

/// Última página do onboarding: coleta nome, telefone, CNPJ e logo.
///
/// Esses dados aparecem no cabeçalho de todo PDF enviado ao cliente —
/// sem eles o PDF sai sem identificação do profissional, o que parece
/// amador. Todos os campos são opcionais e editáveis depois em Ajustes.
class _ProfileSetupPage extends StatelessWidget {
  const _ProfileSetupPage({
    required this.nameController,
    required this.phoneController,
    required this.documentController,
    required this.logoPath,
    required this.onPickLogo,
    required this.onRemoveLogo,
  });

  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController documentController;
  final String? logoPath;
  final VoidCallback onPickLogo;
  final VoidCallback onRemoveLogo;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.md,
        AppSpacing.xl,
        AppSpacing.xl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSpacing.md),
          Text(
            'Seus dados profissionais',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Aparecem no cabeçalho do PDF enviado ao cliente. Todos opcionais — você edita depois em Ajustes.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: AppSpacing.xl),
          // Logo.
          Row(
            children: [
              _LogoBox(logoPath: logoPath),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Logo da empresa',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Wrap(
                      spacing: AppSpacing.xs,
                      children: [
                        TextButton(
                          onPressed: onPickLogo,
                          child: Text(
                            logoPath == null ? 'Escolher' : 'Trocar',
                          ),
                        ),
                        if (logoPath != null)
                          TextButton(
                            onPressed: onRemoveLogo,
                            child: const Text('Remover'),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            controller: nameController,
            label: 'Seu nome ou da empresa',
            hint: 'Ex: João Pereira Pinturas',
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            controller: phoneController,
            label: 'Telefone',
            hint: 'Ex: (11) 98765-4321',
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            controller: documentController,
            label: 'CPF ou CNPJ',
            hint: 'Ex: 00.000.000/0001-00',
            keyboardType: TextInputType.number,
          ),
        ],
      ),
    );
  }
}

class _LogoBox extends StatelessWidget {
  const _LogoBox({required this.logoPath});

  final String? logoPath;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: logoPath == null
          ? Icon(Icons.add_photo_alternate_outlined,
              color: colorScheme.onSurfaceVariant)
          : Image.file(File(logoPath!), fit: BoxFit.cover),
    );
  }
}
