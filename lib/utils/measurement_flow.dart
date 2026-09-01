import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/measurements_repository_provider.dart';
import '../repositories/measurements_repository.dart';
import '../screens/measurement_form_screen.dart';
import '../widgets/app_dialog.dart';

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
