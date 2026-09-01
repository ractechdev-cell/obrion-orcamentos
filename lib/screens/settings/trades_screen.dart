import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../database/enums.dart';
import '../../providers/profile_repository_provider.dart';
import '../../theme/app_spacing.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_loading.dart';
import '../../widgets/app_snackbar.dart';
import '../../widgets/app_trade_selector.dart';

/// Sub-tela de Ajustes — quais ofícios o profissional atende, usado para
/// filtrar as sugestões da Lista de Preços.
class TradesScreen extends ConsumerStatefulWidget {
  const TradesScreen({super.key});

  @override
  ConsumerState<TradesScreen> createState() => _TradesScreenState();
}

class _TradesScreenState extends ConsumerState<TradesScreen> {
  Set<Trade> _selected = {};
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final repo = ref.read(profileRepositoryProvider);
    final profile = await repo.getProfile();
    if (!mounted) return;
    setState(() {
      _selected = profile.trades;
      _loading = false;
    });
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final repo = ref.read(profileRepositoryProvider);
    await repo.saveProfile(trades: _selected);
    if (!mounted) return;
    setState(() => _saving = false);
    AppSnackBar.show(context, 'Ofícios salvos.');
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Meus Ofícios')),
      body: _loading
          ? const AppLoading()
          : ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                Text(
                  'Selecione suas áreas de atuação para personalizar os modelos de orçamento.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: AppSpacing.lg),
                AppTradeSelector(
                  selected: _selected,
                  onChanged: (trades) => setState(() => _selected = trades),
                ),
                const SizedBox(height: AppSpacing.lg),
                AppButton(
                  label: 'Salvar',
                  icon: Icons.save,
                  loading: _saving,
                  onPressed: _saving ? null : _save,
                ),
              ],
            ),
    );
  }
}
