import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/enums.dart';
import '../providers/measurements_repository_provider.dart';
import '../widgets/app_button.dart';
import '../widgets/app_card.dart';
import '../widgets/app_number_input.dart';
import '../widgets/app_text_field.dart';

class MeasurementFormScreen extends ConsumerStatefulWidget {
  const MeasurementFormScreen({super.key, required this.projectId});

  final String projectId;

  @override
  ConsumerState<MeasurementFormScreen> createState() => _MeasurementFormScreenState();
}

class _MeasurementFormScreenState extends ConsumerState<MeasurementFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  double? _length;
  double? _width;
  double? _height;
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);
    final repo = ref.read(measurementsRepositoryProvider);
    final measurement = await repo.createMeasurement(
      projectId: widget.projectId,
      name: _nameController.text.trim(),
      lengthMeters: _length!,
      widthMeters: _width!,
      heightMeters: _height!,
    );
    await repo.addOpening(
      measurementId: measurement.id,
      type: OpeningType.door,
      widthMeters: 0.8,
      heightMeters: 2.1,
    );
    if (mounted) Navigator.of(context).pop();
    if (mounted) setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nova medição')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            AppTextField(
              controller: _nameController,
              label: 'Nome do cômodo',
              validator: (value) =>
                  value == null || value.trim().isEmpty ? 'Informe o nome' : null,
            ),
            const SizedBox(height: 16),
            AppNumberInput(
              label: 'Comprimento',
              suffixText: 'm',
              onChanged: (value) => _length = value,
            ),
            const SizedBox(height: 16),
            AppNumberInput(
              label: 'Largura',
              suffixText: 'm',
              onChanged: (value) => _width = value,
            ),
            const SizedBox(height: 16),
            AppNumberInput(
              label: 'Altura',
              suffixText: 'm',
              onChanged: (value) => _height = value,
            ),
            const SizedBox(height: 24),
            AppCard(
              child: Text(
                'Os vãos serão adicionados no próximo passo da tela (porta/janela).\n\nNesta versão inicial, já criamos a geometria bruta do cômodo e um vão padrão de porta para validar o fluxo.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            const SizedBox(height: 24),
            AppButton(
              label: 'Salvar medição',
              loading: _saving,
              onPressed: _saving ? null : _save,
            ),
          ],
        ),
      ),
    );
  }
}
