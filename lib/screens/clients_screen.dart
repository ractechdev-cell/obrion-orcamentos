import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/budgets_repository_provider.dart';
import '../providers/clients_repository_provider.dart';
import '../repositories/clients_repository.dart';
import '../repositories/example_data_seeder.dart';
import '../theme/app_spacing.dart';
import '../widgets/app_avatar.dart';
import '../widgets/app_card.dart';
import '../widgets/app_empty_state.dart';
import '../widgets/app_error.dart';
import '../widgets/app_loading.dart';
import '../widgets/app_search_field.dart';
import '../widgets/app_status_chip.dart';
import 'client_detail_screen.dart';
import 'client_form_screen.dart';

/// Lista de clientes — primeiro passo concreto da Fase 1. Tocar num
/// cliente abre o histórico dele (`ClientDetailScreen`): medições e
/// orçamentos juntos numa linha do tempo, em vez de dois menus
/// separados pra descobrir.
class ClientsScreen extends ConsumerStatefulWidget {
  const ClientsScreen({super.key});

  @override
  ConsumerState<ClientsScreen> createState() => _ClientsScreenState();
}

class _ClientsScreenState extends ConsumerState<ClientsScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final repository = ref.watch(clientsRepositoryProvider);

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
            padding: const EdgeInsets.all(AppSpacing.md),
            child: AppSearchField(
              hint: 'Nome, telefone ou endereço',
              onChanged: (value) => setState(() => _query = value),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<ClientWithBudgetCount>>(
              stream: repository.watchAllWithBudgetCount(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const AppError(message: 'Falha ao carregar clientes.');
                }
                if (!snapshot.hasData) {
                  return const AppLoading();
                }
                // Filtro client-side — mantém reatividade da Stream
                final allClients = snapshot.data!;
                final clients = _query.isEmpty
                    ? allClients
                    : allClients.where((entry) {
                        final c = entry.client;
                        final query = _query.toLowerCase();
                        return c.name.toLowerCase().contains(query) ||
                            (c.phone?.toLowerCase().contains(query) ?? false) ||
                            (c.address?.toLowerCase().contains(query) ?? false);
                      }).toList();

                if (clients.isEmpty) {
                  return AppEmptyState(
                    message: _query.isEmpty
                        ? 'Você ainda não tem nenhum cliente cadastrado.\n\n'
                            'Cadastre o primeiro para criar um orçamento mais rápido.'
                        : 'Nenhum cliente encontrado para "$_query".',
                    actionLabel: _query.isEmpty ? 'Cadastrar cliente' : null,
                    onAction: _query.isEmpty
                        ? () => Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const ClientFormScreen()),
                            )
                        : null,
                    secondaryActionLabel: _query.isEmpty ? 'Ver um exemplo' : null,
                    onSecondaryAction: _query.isEmpty
                        ? () => ExampleDataSeeder.seed(
                              clientsRepo: ref.read(clientsRepositoryProvider),
                              budgetsRepo: ref.read(budgetsRepositoryProvider),
                            )
                        : null,
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    0,
                    AppSpacing.md,
                    // Espaço extra pra que o último card não fique atrás
                    // do botão flutuante.
                    AppSpacing.xxl + AppSpacing.lg,
                  ),
                  itemCount: clients.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (context, index) {
                    final entry = clients[index];
                    final client = entry.client;
                    final subtitle = [
                      if ((client.phone ?? '').isNotEmpty) client.phone!,
                      if ((client.address ?? '').isNotEmpty) client.address!,
                    ].join(' • ');

                    return AppCard(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ClientDetailScreen(client: client),
                        ),
                      ),
                      child: Row(
                        children: [
                          AppAvatar(name: client.name),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  client.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                ),
                                if (subtitle.isNotEmpty) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    subtitle,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurfaceVariant,
                                        ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          // Verde quando já rendeu trabalho, neutro quando
                          // é só cadastro — dá pra ver de relance quem
                          // ainda não virou orçamento nenhum.
                          AppStatusChip(
                            pill: true,
                            tone: entry.budgetCount > 0
                                ? AppStatusTone.success
                                : AppStatusTone.neutral,
                            label: entry.budgetCount == 1
                                ? '1 orçamento'
                                : '${entry.budgetCount} orçamentos',
                          ),
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
