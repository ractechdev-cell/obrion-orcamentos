import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../analytics/analytics_service.dart';
import '../database/database.dart';
import '../database/enums.dart';
import '../measurement/measurement_math.dart';
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

/// Formulário de cômodo — cria um novo ou edita um existente, conforme
/// [measurementId] seja nulo ou não. Vãos (portas/janelas) são geridos
/// como uma lista editável, não mais um valor fixo — ver CLAUDE.md,
/// "Medição guarda geometria bruta, não 'a área'".
///
/// **Nome na UI é "cômodo", não "medição"** (decisão 01/09/2026): em obra
/// civil, "medição" tem significado próprio — o boletim financeiro que
/// mede % da obra executada pra liberar pagamento. Nada a ver com medir
/// as dimensões de um ambiente. O nome de tabela/classe no banco
/// (`Measurement`) não muda — é dado, não é UI.
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

  /// Espessura de camada (contrapiso, concreto) em centímetros, a
  /// unidade que se fala em obra. **Não é persistida** — a espessura não é
  /// uma propriedade do cômodo (o mesmo cômodo pode ter contrapiso de 5cm
  /// ou 10cm), é contexto do serviço m³; entra aqui só para o profissional
  /// ver o volume na hora e depois alimenta o item de orçamento.
  final _thicknessCmController = TextEditingController();

  /// Espessura convertida em metros, ou `null` quando não preenchida.
  double? get _thicknessMeters {
    final text = _thicknessCmController.text.trim();
    if (text.isEmpty) return null;
    final cm = double.tryParse(text.replaceAll(',', '.'));
    return centimetersToMeters(cm);
  }

  bool get _isEditing => widget.measurementId != null;

  /// Grandezas recalculadas a cada mudança de medida ou vão — ver "Nova
  /// medição" no design Safety Industrial, seção "Grandezas Derivadas":
  /// o modelo mostra o cálculo ao vivo em vez de só salvar cego.
  RoomDerivedQuantities get _derived => RoomDerivedQuantities.fromMeasurement(
        lengthMeters: double.tryParse(_lengthController.text.replaceAll(',', '.')) ?? 0,
        widthMeters: double.tryParse(_widthController.text.replaceAll(',', '.')) ?? 0,
        heightMeters: double.tryParse(_heightController.text.replaceAll(',', '.')) ?? 0,
        openings: [
          for (final o in _openings)
            MeasurementOpening(
              id: '',
              measurementId: '',
              type: o.type,
              widthMeters: o.widthMeters,
              heightMeters: o.heightMeters,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ),
        ],
      );

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
    _thicknessCmController.dispose();
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
    
    try {
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
        AppSnackBar.show(context, _isEditing ? 'Cômodo atualizado.' : 'Cômodo salvo.');
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.show(context, 'Erro ao salvar o cômodo. Tente novamente.');
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final derived = _derived;

    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Editar cômodo' : 'Medir cômodo')),
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
                    hint: 'Ex: Quarto, Sala, Cozinha',
                    validator: requiredValidator('o nome'),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  // Duas linhas de dois campos em vez de uma única de
                  // três: em tela de 320dp o touch target de cada medida
                  // ficava apertado demais pra uma mão na obra (ver
                  // `PROGRESSO_DESIGN_SAFETY_INDUSTRIAL.md`). O par
                  // Comp/Larg + Altura/Espessura mantém o formulário curto
                  // e cada campo legível.
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: AppNumberInput(
                          controller: _lengthController,
                          label: 'Comp.',
                          suffixText: 'm',
                          validator: positiveNumberValidator('o comprimento'),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: AppNumberInput(
                          controller: _widthController,
                          label: 'Larg.',
                          suffixText: 'm',
                          validator: positiveNumberValidator('a largura'),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: AppNumberInput(
                          controller: _heightController,
                          label: 'Altura',
                          suffixText: 'm',
                          validator: positiveNumberValidator('a altura'),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: AppNumberInput(
                          controller: _thicknessCmController,
                          label: 'Espessura',
                          suffixText: 'cm',
                          hint: '5',
                          // Opcional: útil só quando o serviço for m³
                          // (contrapiso, concreto). Sem preencher, o
                          // volume não aparece no painel derivado.
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.meeting_room_outlined,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Text(
                                'Descontar Vãos',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                            OutlinedButton.icon(
                              onPressed: _addOpening,
                              style: OutlinedButton.styleFrom(
                                minimumSize: Size.zero,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.md,
                                  vertical: AppSpacing.sm,
                                ),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              icon: const Icon(Icons.add, size: 18),
                              label: const Text('Adicionar'),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        if (_openings.isEmpty)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surfaceContainerLowest,
                              borderRadius: BorderRadius.circular(AppRadius.sm),
                              border: Border.all(
                                color: Theme.of(context).colorScheme.outlineVariant,
                                style: BorderStyle.solid,
                              ),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.sensor_window_outlined,
                                  size: 32,
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                Text(
                                  'Nenhum vão adicionado.\nAdicione portas e janelas para descontar da área de parede.',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                                      ),
                                ),
                              ],
                            ),
                          )
                        else
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
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.calculate_outlined,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Text(
                              'Grandezas Derivadas',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        _DerivedQuantityRow(
                          icon: Icons.grid_on_outlined,
                          label: 'Área de Piso',
                          value: derived.floorAreaSqM,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        _DerivedQuantityRow(
                          icon: Icons.roofing_outlined,
                          label: 'Área de Teto',
                          value: derived.ceilingAreaSqM,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        _DerivedQuantityRow(
                          icon: Icons.foundation_outlined,
                          label: 'Área de Parede',
                          caption: '(já descontando vãos)',
                          value: derived.wallAreaSqM,
                        ),
                        if (_thicknessMeters != null) ...[
                          const SizedBox(height: AppSpacing.sm),
                          _DerivedQuantityRow(
                            icon: Icons.layers_outlined,
                            label: 'Volume',
                            caption:
                                '(área de piso × espessura)',
                            unitSuffix: ' m³',
                            value: derived.volumeCubicMeters(
                              _thicknessMeters!,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AppButton(
                    label: _isEditing ? 'Salvar alterações' : 'Salvar cômodo',
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

/// Uma linha do painel "Grandezas Derivadas" — ícone, rótulo (+ legenda
/// opcional) à esquerda, valor em destaque à direita. Ver modelo
/// `docs/stitch_document_theme_generator/nova_medi_o_obrion/`.
class _DerivedQuantityRow extends StatelessWidget {
  const _DerivedQuantityRow({
    required this.icon,
    required this.label,
    required this.value,
    this.caption,
    this.unitSuffix = ' m²',
  });

  final IconData icon;
  final String label;
  final String? caption;

  /// Nome da grandeza em destaque — m² por padrão (piso/teto/parede), m³
  /// para o volume derivado da espessura.
  final String unitSuffix;
  final double value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Row(
        children: [
          Icon(icon, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: caption == null
                ? Text(label, style: theme.textTheme.bodyLarge)
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(label, style: theme.textTheme.bodyLarge),
                      Text(
                        caption!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
          ),
          RichText(
            text: TextSpan(
              style: theme.textTheme.titleLarge?.copyWith(color: theme.colorScheme.onSurface),
              children: [
                TextSpan(text: value.toStringAsFixed(2)),
                TextSpan(
                  text: unitSuffix,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
