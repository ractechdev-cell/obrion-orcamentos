import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../measurement/measurement_math.dart';
import '../providers/measurements_repository_provider.dart';
import '../repositories/measurements_repository.dart';
import '../theme/app_spacing.dart';
import '../widgets/app_card.dart';
import '../widgets/app_dialog.dart';
import '../widgets/app_empty_state.dart';
import '../widgets/app_error.dart';
import '../widgets/app_loading.dart';
import '../widgets/app_metric_card.dart';
import '../widgets/app_snackbar.dart';
import 'measurement_form_screen.dart';

/// "Casa do Cliente" — lista os cômodos já medidos de uma obra, com um
/// resumo agregado (soma de m² de piso/teto/parede) no topo.
///
/// Criada em 01/09/2026 para separar medição de orçamento na navegação:
/// antes os dois apareciam juntos na timeline da ficha do cliente, o que
/// confundia (ver conversa 01/09/2026). Agora cada cômodo vive aqui,
/// acessível por um ícone de casa na ficha do cliente; a timeline mostra
/// só orçamentos.
class HouseScreen extends ConsumerStatefulWidget {
  const HouseScreen({
    super.key,
    required this.clientId,
    required this.clientName,
  });

  final String clientId;
  final String clientName;

  @override
  ConsumerState<HouseScreen> createState() => _HouseScreenState();
}

class _HouseScreenState extends ConsumerState<HouseScreen> {
  bool _loading = true;
  String? _error;
  String? _projectId;
  List<MeasurementWithDetails> _rooms = const [];
  HouseTotals _totals = const HouseTotals.empty();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (mounted) setState(() => _loading = true);
    try {
      final repo = ref.read(measurementsRepositoryProvider);
      final projects = await repo.watchProjectsByClient(widget.clientId).first;
      final projectId = projects.isEmpty ? null : projects.first.id;

      final rooms = projectId == null
          ? const <MeasurementWithDetails>[]
          : await repo.watchByProject(projectId).first;
      final totals = projectId == null
          ? const HouseTotals.empty()
          : await repo.watchHouseTotals(projectId).first;

      if (mounted) {
        setState(() {
          _projectId = projectId;
          _rooms = rooms;
          _totals = totals;
          _error = null;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _error = 'Falha ao carregar os cômodos.';
          _loading = false;
        });
      }
    }
  }

  Future<void> _addRoom() async {
    var projectId = _projectId;
    if (projectId == null) {
      final repo = ref.read(measurementsRepositoryProvider);
      final project = await repo.createProject(
        clientId: widget.clientId,
        name: 'Obra Principal',
      );
      projectId = project.id;
    }
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MeasurementFormScreen(projectId: projectId!),
      ),
    );
    _load();
  }

  Future<void> _openRoom(String measurementId) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MeasurementFormScreen(
          projectId: _projectId!,
          measurementId: measurementId,
        ),
      ),
    );
    _load();
  }

  Future<void> _deleteRoom(String measurementId, String name) async {
    final confirmed = await AppDialog.confirm(
      context,
      isDestructive: true,
      title: 'Excluir "$name"?',
      message: 'Esta ação não pode ser desfeita.',
      confirmLabel: 'Excluir',
    );
    if (confirmed == true) {
      await ref.read(measurementsRepositoryProvider).softDeleteMeasurement(measurementId);
      if (mounted) {
        AppSnackBar.show(
          context,
          'Cômodo excluído.',
          variant: AppSnackBarVariant.destructive,
        );
        _load();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Casa de ${widget.clientName}')),
      floatingActionButton: FloatingActionButton(
        onPressed: _addRoom,
        tooltip: 'Adicionar cômodo',
        child: const Icon(Icons.add),
      ),
      body: _loading
          ? const AppLoading()
          : _error != null
              ? AppError(message: _error!, onRetry: _load)
              : _rooms.isEmpty
                  ? AppEmptyState(
                      icon: Icons.home_outlined,
                      message:
                          'Nenhum cômodo medido ainda.\n\n'
                          'Meça quarto, sala, cozinha... e some tudo aqui '
                          'automaticamente.',
                      actionLabel: 'Medir primeiro cômodo',
                      onAction: _addRoom,
                    )
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.md,
                          AppSpacing.md,
                          AppSpacing.md,
                          AppSpacing.xxl + AppSpacing.lg,
                        ),
                        children: [
                          _buildTotalsSummary(context),
                          const SizedBox(height: AppSpacing.lg),
                          for (final room in _rooms) ...[
                            _RoomCard(
                              room: room,
                              onTap: () => _openRoom(room.measurement.id),
                              onDelete: () => _deleteRoom(
                                room.measurement.id,
                                room.measurement.name,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                          ],
                        ],
                      ),
                    ),
    );
  }

  Widget _buildTotalsSummary(BuildContext context) {
    return Column(
      children: [
        AppMetricCard.featured(
          label: '${_totals.roomCount} cômodo(s) medido(s)',
          value: '${_totals.floorAreaSqM.toStringAsFixed(2)} m²',
          icon: Icons.grid_on_outlined,
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: AppMetricCard(
                label: 'Área de Teto',
                value: '${_totals.ceilingAreaSqM.toStringAsFixed(2)} m²',
                icon: Icons.roofing_outlined,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: AppMetricCard(
                label: 'Área de Parede',
                value: '${_totals.wallAreaSqM.toStringAsFixed(2)} m²',
                icon: Icons.foundation_outlined,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _RoomCard extends StatelessWidget {
  const _RoomCard({
    required this.room,
    required this.onTap,
    required this.onDelete,
  });

  final MeasurementWithDetails room;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final derived = RoomDerivedQuantities.fromMeasurement(
      lengthMeters: room.measurement.lengthMeters,
      widthMeters: room.measurement.widthMeters,
      heightMeters: room.measurement.heightMeters,
      openings: room.openings,
    );

    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  room.measurement.name,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 2),
                Text(
                  '${room.measurement.lengthMeters.toStringAsFixed(2)} × '
                  '${room.measurement.widthMeters.toStringAsFixed(2)} × '
                  '${room.measurement.heightMeters.toStringAsFixed(2)} m',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${derived.floorAreaSqM.toStringAsFixed(2)} m² piso · '
                  '${derived.wallAreaSqM.toStringAsFixed(2)} m² parede',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.error),
            tooltip: 'Excluir cômodo',
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}
