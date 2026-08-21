import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../measurement/measurement_math.dart';
import '../providers/measurements_repository_provider.dart';
import '../repositories/measurements_repository.dart';
import '../widgets/app_card.dart';
import '../widgets/app_empty_state.dart';
import '../widgets/app_error.dart';
import '../widgets/app_loading.dart';
import 'measurement_form_screen.dart';

class MeasurementsScreen extends ConsumerStatefulWidget {
  const MeasurementsScreen({super.key, required this.projectId});

  final String projectId;

  @override
  ConsumerState<MeasurementsScreen> createState() => _MeasurementsScreenState();
}

class _MeasurementsScreenState extends ConsumerState<MeasurementsScreen> {
  @override
  Widget build(BuildContext context) {
    final repository = ref.watch(measurementsRepositoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Medições')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => MeasurementFormScreen(projectId: widget.projectId),
          ),
        ),
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<List<MeasurementWithDetails>>(
        stream: repository.watchByProject(widget.projectId),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const AppError(message: 'Falha ao carregar medições.');
          }
          if (!snapshot.hasData) {
            return const AppLoading();
          }
          final items = snapshot.data!;
          if (items.isEmpty) {
            return AppEmptyState(
              message: 'Nenhuma medição cadastrada ainda.',
              actionLabel: 'Nova medição',
              onAction: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => MeasurementFormScreen(projectId: widget.projectId),
                ),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = items[index];
              final derived = RoomDerivedQuantities.fromMeasurement(
                lengthMeters: item.measurement.lengthMeters,
                widthMeters: item.measurement.widthMeters,
                heightMeters: item.measurement.heightMeters,
                openings: item.openings,
              );

              return AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.measurement.name, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Text('Piso: ${derived.floorAreaSqM.toStringAsFixed(2)} m²'),
                    Text('Paredes: ${derived.wallAreaSqM.toStringAsFixed(2)} m²'),
                    Text('Perímetro: ${derived.perimeterMeters.toStringAsFixed(2)} m'),
                    Text('Vãos: ${item.openings.length}'),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
