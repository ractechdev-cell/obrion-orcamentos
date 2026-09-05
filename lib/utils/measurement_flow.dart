import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/enums.dart';
import '../measurement/measurement_math.dart';
import '../measurement/measurement_quantities.dart';
import '../providers/measurements_repository_provider.dart';
import '../repositories/measurements_repository.dart';
import '../screens/measurement_form_screen.dart';
import '../theme/app_spacing.dart';
import '../widgets/app_button.dart';
import '../widgets/app_dialog.dart';
import '../widgets/app_number_input.dart';

/// Carrega os cômodos já medidos do cliente e, se não houver nenhum,
/// oferece medir o primeiro ali mesmo.
///
/// Antes, "Usar medição" sem cômodo cadastrado só mostrava um aviso e
/// parava — beco sem saída bem no meio do fluxo que é o diferencial do
/// app (medir e orçar sem redigitar). Quem chegava ali tinha que
/// adivinhar que precisava sair, achar a "Casa do Cliente", medir o
/// cômodo e voltar.
///
/// Retorna a lista já recarregada quando a pessoa mede o cômodo, ou
/// vazia se ela desistir.
Future<List<MeasurementWithDetails>> loadMeasurementsOrOfferToCreate({
  required BuildContext context,
  required WidgetRef ref,
  required String clientId,
}) async {
  Future<List<MeasurementWithDetails>> load() async {
    final repo = ref.read(measurementsRepositoryProvider);
    final projects = await repo.watchProjectsByClient(clientId).first;
    final all = <MeasurementWithDetails>[];
    for (final project in projects) {
      all.addAll(await repo.watchByProject(project.id).first);
    }
    return all;
  }

  final existing = await load();
  if (existing.isNotEmpty) return existing;

  if (!context.mounted) return const [];
  final wantsToCreate = await AppDialog.confirm(
    context,
    title: 'Nenhum cômodo medido ainda',
    message: 'Para puxar a quantidade automaticamente, este cliente '
        'precisa de um cômodo medido. Quer medir agora?',
    confirmLabel: 'Medir cômodo',
    cancelLabel: 'Agora não',
  );
  if (wantsToCreate != true || !context.mounted) return const [];

  // O cômodo pende de uma obra; se o cliente ainda não tem nenhuma,
  // cria a padrão — mesmo caminho de `HouseScreen._addRoom`.
  final repo = ref.read(measurementsRepositoryProvider);
  final projects = await repo.watchProjectsByClient(clientId).first;
  final projectId = projects.isEmpty
      ? (await repo.createProject(clientId: clientId, name: 'Obra Principal'))
            .id
      : projects.first.id;

  if (!context.mounted) return const [];
  await Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => MeasurementFormScreen(projectId: projectId),
    ),
  );

  // Recarrega: a pessoa pode ter salvo ou desistido na tela do cômodo.
  return load();
}

/// Pede a espessura da camada (em centímetros, a unidade que o
/// profissional digita na obra) e devolve convertida em metros — a
/// entrada que `RoomDerivedQuantities.volumeCubicMeters` espera.
///
/// Só usada para serviços m³ (contrapiso, concreto, regularização): o
/// volume = área do piso × espessura. Retorna `null` se o usuário
/// cancelar, zerar ou digitar um valor inválido.
Future<double?> pickSlabThicknessMeters(BuildContext context) async {
  final controller = TextEditingController();
  final formKey = GlobalKey<FormState>();

  final valueInCm = await showModalBottomSheet<double>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (context) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Espessura da camada', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Define o volume em m³. Ex.: contrapiso de 5 cm num '
              'cômodo de 20 m² resulta em 1 m³.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: AppSpacing.md),
            AppNumberInput(
              controller: controller,
              label: 'Espessura',
              suffixText: 'cm',
              hint: 'Ex: 5',
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (value) {
                if (value == null || value.trim().isEmpty) return 'Preencha a espessura';
                final parsed = double.tryParse(value.replaceAll(',', '.'));
                if (parsed == null || parsed <= 0) {
                  return 'Use um valor maior que zero';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.lg),
            AppButton(
              label: 'Usar volume',
              onPressed: () {
                if (!(formKey.currentState?.validate() ?? false)) return;
                final cm = double.parse(controller.text.replaceAll(',', '.'));
                Navigator.of(context).pop(cm);
              },
            ),
            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    ),
  );

  return centimetersToMeters(valueInCm);
}

/// Ponte medição → item de orçamento: pede pro usuário escolher (se
/// houver mais de uma) qual medição do cliente usar, depois qual grandeza
/// dela — e devolve o valor pronto pra preencher a quantidade (ainda
/// editável depois). `null` se não houver medição cadastrada ou o usuário
/// cancelar em qualquer passo.
///
/// Para serviço m³ (contrapiso/concreto) a única grandeza é o volume, que
/// depende da espessura — pergunta a espessura primeiro (ver
/// `pickSlabThicknessMeters`) e devolve área do piso × espessura.
///
/// Centralizado aqui para o wizard de orçamento e o formulário de gestão
/// terem exatamente o mesmo comportamento (e a mesma futura correção).
Future<double?> pickMeasurementQuantity(
  BuildContext context,
  WidgetRef ref, {
  required String clientId,
  required ServiceUnit unit,
}) async {
  final options = measurementQuantityOptions(unit);
  if (options.isEmpty) return null;

  // Sem medição, oferece criar na hora em vez de só avisar.
  final allMeasurements = await loadMeasurementsOrOfferToCreate(
    context: context,
    ref: ref,
    clientId: clientId,
  );
  if (allMeasurements.isEmpty || !context.mounted) return null;

  MeasurementWithDetails? chosen = allMeasurements.first;
  if (allMeasurements.length > 1) {
    chosen = await showModalBottomSheet<MeasurementWithDetails>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Qual cômodo?',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            for (final m in allMeasurements)
              ListTile(
                title: Text(m.measurement.name),
                onTap: () => Navigator.of(context).pop(m),
              ),
            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
    if (chosen == null || !context.mounted) return null;
  }

  final derived = RoomDerivedQuantities.fromMeasurement(
    lengthMeters: chosen.measurement.lengthMeters,
    widthMeters: chosen.measurement.widthMeters,
    heightMeters: chosen.measurement.heightMeters,
    openings: chosen.openings,
  );

  if (!context.mounted) return null;

  // Serviço m³: volume é a única grandeza e depende da espessura —
  // pergunta a espessura primeiro.
  if (options.contains(MeasurementQuantity.volume)) {
    final slabMeters = await pickSlabThicknessMeters(context);
    if (slabMeters == null || !context.mounted) return null;
    return derived.volumeCubicMeters(slabMeters);
  }

  return showModalBottomSheet<double>(
    context: context,
    showDragHandle: true,
    builder: (context) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Qual grandeza?',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          for (final option in options)
            ListTile(
              title: Text(measurementQuantityLabel(option)),
              trailing: Text(
                measurementQuantityValue(option, derived).toStringAsFixed(2),
              ),
              onTap: () => Navigator.of(context)
                  .pop(measurementQuantityValue(option, derived)),
            ),
          const SizedBox(height: AppSpacing.md),
        ],
      ),
    ),
  );
}
