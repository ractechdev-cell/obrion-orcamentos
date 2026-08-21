import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/database.dart';
import '../providers/clients_repository_provider.dart';
import '../providers/measurements_repository_provider.dart';
import '../widgets/app_bottom_sheet.dart';
import '../widgets/app_card.dart';
import '../widgets/app_empty_state.dart';
import '../widgets/app_error.dart';
import '../widgets/app_loading.dart';
import '../widgets/app_text_field.dart';
import 'budgets_screen.dart';
import 'client_form_screen.dart';
import 'measurements_screen.dart';

/// Lista de clientes — primeiro passo concreto da Fase 1.
class ClientsScreen extends ConsumerStatefulWidget {
  const ClientsScreen({super.key});

  @override
  ConsumerState<ClientsScreen> createState() => _ClientsScreenState();
}

class _ClientsScreenState extends ConsumerState<ClientsScreen> {
  String _query = '';

  Future<void> _navigateToMeasurements(BuildContext context, Client client) async {
    final repo = ref.read(measurementsRepositoryProvider);
    final projects = await repo.watchProjectsByClient(client.id).first;
    Project project;
    if (projects.isEmpty) {
      project = await repo.createProject(
        clientId: client.id,
        name: 'Obra Principal',
      );
    } else {
      project = projects.first;
    }
    if (context.mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => MeasurementsScreen(projectId: project.id),
        ),
      );
    }
  }

  Future<void> _openClientActions(BuildContext context, Client client) async {
    final action = await AppBottomSheet.showActions<String>(
      context,
      title: client.name,
      actions: const [
        AppBottomSheetAction(label: 'Medições', value: 'measurements', icon: Icons.straighten),
        AppBottomSheetAction(label: 'Orçamentos', value: 'budgets', icon: Icons.request_quote_outlined),
      ],
    );

    if (!context.mounted || action == null) return;

    if (action == 'measurements') {
      await _navigateToMeasurements(context, client);
    } else if (action == 'budgets') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => BudgetsScreen(clientId: client.id),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final repository = ref.watch(clientsRepositoryProvider);

    final clientsAsync = _query.isEmpty
        ? repository.watchAll()
        : Stream<List<Client>>.fromFuture(repository.search(_query));

    return Scaffold(
      appBar: AppBar(title: const Text('Clientes')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const ClientFormScreen()),
        ),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: AppTextField(
              label: 'Buscar cliente',
              hint: 'Nome, telefone ou endereço',
              onChanged: (value) => setState(() => _query = value),
              prefixIcon: const Icon(Icons.search),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Client>>(
              stream: clientsAsync,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const AppError(message: 'Falha ao carregar clientes.');
                }
                if (!snapshot.hasData) {
                  return const AppLoading();
                }
                final clients = snapshot.data!;
                if (clients.isEmpty) {
                  return AppEmptyState(
                    message: 'Nenhum cliente cadastrado ainda.',
                    actionLabel: 'Cadastrar cliente',
                    onAction: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ClientFormScreen()),
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: clients.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final client = clients[index];
                    return AppCard(
                      onTap: () => _openClientActions(context, client),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(client.name, style: Theme.of(context).textTheme.titleMedium),
                          if (client.phone != null && client.phone!.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(client.phone!),
                          ],
                          if (client.address != null && client.address!.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(client.address!),
                          ],
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
