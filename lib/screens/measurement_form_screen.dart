import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../analytics/analytics_service.dart';
import '../database/enums.dart';
import '../providers/measurements_repository_provider.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../utils/validators.dart';
import '../widgets/app_button.dart';
import '../widgets/app_loading.dart';
import '../widgets/app_number_input.dart';
import '../widgets/app_snackbar.dart';
import '../widgets/app_text_field.dart';

typedef _OpeningDraft = ({OpeningType type, double widthMeters, double heightMeters});

String _openingLabel(OpeningType type) => type == OpeningType.door ? 'Porta' : 'Janela';

/// Formulário de medição — cria uma nova ou edita uma existente, conforme
/// [measurementId] seja nulo ou não. Vãos (portas/janelas) são geridos
/// como uma lista editável, não mais um valor fixo — ver CLAUDE.md,
/// "Medição guarda geometria bruta, não 'a área'".
class MeasurementFormScreen extends ConsumerStatefulWidget {
  const MeasurementFormScreen({super.key, required this.projectId, this.measurementId});

  final String projectId;
  final String? measurementId;

  @override
  ConsumerState<MeasurementFormScreen> createState() => _MeasurementFormScreenState();
}

class _MeasurementFormScreenState extends ConsumerState<MeasurementFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _lengthController = TextEditingController();
  final _widthController = TextEditingController();
  final _heightController = TextEditingController();
  final _openings = <_OpeningDraft>[];
  bool _saving = false;
  bool _loading = true;

  bool get _isEditing => widget.measurementId != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _loadMeasurement();
    } else {
      // Ponto de partida rápido: a maioria dos cômodos tem pelo menos uma
      // porta. Continua 100% editável/removível na lista abaixo.
      _openings.add((type: OpeningType.door, widthMeters: 0.8, heightMeters: 2.1));
      _loading = false;
      AnalyticsService.trackEvent('measurement_started');
    }
  }

  Future<void> _loadMeasurement() async {
    final repo = ref.read(measurementsRepositoryProvider);
    final details = await repo.getById(widget.measurementId!);
    if (!mounted) return;
    if (details != null) {
      _nameController.text = details.measurement.name;
      _lengthController.text = details.measurement.lengthMeters.toString().replaceAll('.', ',');
      _widthController.text = details.measurement.widthMeters.toString().replaceAll('.', ',');
      _heightController.text = details.measurement.heightMeters.toString().replaceAll('.', ',');
      _openings.addAll(details.openings.map((o) => (
            type: o.type,
            widthMeters: o.widthMeters,
            heightMeters: o.heightMeters,
          )));
    }
    setState(() => _loading = false);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _lengthController.dispose();
    _widthController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  Future<void> _addOpening() async {
    final draft = await showDialog<_OpeningDraft>(
      context: context,
      builder: (context) => const _OpeningDialog(),
    );
    if (draft != null) setState(() => _openings.add(draft));
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);
    final repo = ref.read(measurementsRepositoryProvider);

    final name = _nameController.text.trim();
    final length = double.parse(_lengthController.text.replaceAll(',', '.'));
    final width = double.parse(_widthController.text.replaceAll(',', '.'));
    final height = double.parse(_heightController.text.replaceAll(',', '.'));

    final String measurementId;
    if (_isEditing) {
      measurementId = widget.measurementId!;
      await repo.updateMeasurement(
        id: measurementId,
        name: Value(name),
        lengthMeters: Value(length),
        widthMeters: Value(width),
        heightMeters: Value(height),
      );
    } else {
      final measurement = await repo.createMeasurement(
        projectId: widget.projectId,
        name: name,
        lengthMeters: length,
        widthMeters: width,
        heightMeters: height,
      );
      measurementId = measurement.id;
    }
    await repo.replaceOpenings(measurementId: measurementId, openings: _openings);
    if (!_isEditing) AnalyticsService.trackEvent('measurement_completed');

    if (mounted) {
      AppSnackBar.show(context, _isEditing ? 'Medição atualizada.' : 'Medição salva.');
      Navigator.of(context).pop();
    }
    if (mounted) setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Editar medição' : 'Nova medição')),
      body: _loading
          ? const AppLoading()
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.md),
                children: [
                  AppTextField(
                    controller: _nameController,
                    label: 'Nome do cômodo',
                    validator: requiredValidator('o nome'),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppNumberInput(
                    controller: _lengthController,
                    label: 'Comprimento',
                    suffixText: 'm',
                    validator: positiveNumberValidator('o comprimento'),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppNumberInput(
                    controller: _widthController,
                    label: 'Largura',
                    suffixText: 'm',
                    validator: positiveNumberValidator('a largura'),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppNumberInput(
                    controller: _heightController,
                    label: 'Altura',
                    suffixText: 'm',
                    validator: positiveNumberValidator('a altura'),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text('Vãos (portas e janelas)', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: AppSpacing.sm),
                  if (_openings.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                      child: Text(
                        'Nenhum vão adicionado — a parede será calculada sem descontos.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  for (var i = 0; i < _openings.length; i++)
                    Card(
                      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: ListTile(
                        leading: Icon(
                          _openings[i].type == OpeningType.door
                              ? Icons.sensor_door_outlined
                              : Icons.window_outlined,
                        ),
                        title: Text(
                          '${_openingLabel(_openings[i].type)} — '
                          '${_openings[i].widthMeters.toStringAsFixed(2)} × '
                          '${_openings[i].heightMeters.toStringAsFixed(2)} m',
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.error),
                          tooltip: 'Remover vão',
                          onPressed: () => setState(() => _openings.removeAt(i)),
                        ),
                      ),
                    ),
                  OutlinedButton.icon(
                    onPressed: _addOpening,
                    icon: const Icon(Icons.add),
                    label: const Text('Adicionar vão'),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AppButton(
                    label: _isEditing ? 'Salvar alterações' : 'Salvar medição',
                    loading: _saving,
                    onPressed: _saving ? null : _save,
                  ),
                ],
              ),
            ),
    );
  }
}

class _OpeningDialog extends StatefulWidget {
  const _OpeningDialog();

  @override
  State<_OpeningDialog> createState() => _OpeningDialogState();
}

class _OpeningDialogState extends State<_OpeningDialog> {
  final _formKey = GlobalKey<FormState>();
  final _widthController = TextEditingController(text: '0,8');
  final _heightController = TextEditingController(text: '2,1');
  OpeningType _type = OpeningType.door;

  @override
  void dispose() {
    _widthController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  void _confirm() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    Navigator.of(context).pop((
      type: _type,
      widthMeters: double.parse(_widthController.text.replaceAll(',', '.')),
      heightMeters: double.parse(_heightController.text.replaceAll(',', '.')),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Adicionar vão'),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SegmentedButton<OpeningType>(
              segments: const [
                ButtonSegment(value: OpeningType.door, label: Text('Porta'), icon: Icon(Icons.sensor_door_outlined)),
                ButtonSegment(value: OpeningType.window, label: Text('Janela'), icon: Icon(Icons.window_outlined)),
              ],
              selected: {_type},
              onSelectionChanged: (selection) => setState(() => _type = selection.first),
            ),
            const SizedBox(height: AppSpacing.md),
            AppNumberInput(
              controller: _widthController,
              label: 'Largura',
              suffixText: 'm',
              validator: positiveNumberValidator('a largura'),
            ),
            const SizedBox(height: AppSpacing.md),
            AppNumberInput(
              controller: _heightController,
              label: 'Altura',
              suffixText: 'm',
              validator: positiveNumberValidator('a altura'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        AppButton(label: 'Adicionar', onPressed: _confirm),
      ],
    );
  }
}
