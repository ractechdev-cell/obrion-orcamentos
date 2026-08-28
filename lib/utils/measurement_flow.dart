import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/measurements_repository_provider.dart';
import '../repositories/measurements_repository.dart';
import '../screens/measurement_form_screen.dart';
import '../widgets/app_dialog.dart';

/// Carrega as medições do cliente e, se não houver nenhuma, oferece criar
/// a primeira ali mesmo.
///
/// Antes, "Usar medição" sem medição cadastrada só mostrava um aviso e
/// parava — beco sem saída bem no meio do fluxo que é o diferencial do
/// app (medir e orçar sem redigitar). Quem chegava ali tinha que
/// adivinhar que precisava sair, achar a ficha do cliente, criar a
/// medição e voltar.
///
/// Retorna a lista já recarregada quando a pessoa cria a medição, ou
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
    title: 'Nenhuma medição ainda',
    message: 'Para puxar a quantidade automaticamente, este cliente '
        'precisa de uma medição. Quer criar agora?',
    confirmLabel: 'Criar medição',
    cancelLabel: 'Agora não',
  );
  if (wantsToCreate != true || !context.mounted) return const [];

  // A medição pende de uma obra; se o cliente ainda não tem nenhuma,
  // cria a padrão — mesmo caminho de `ClientDetailScreen._addMeasurement`.
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

  // Recarrega: a pessoa pode ter salvo ou desistido na tela de medição.
  return load();
}
