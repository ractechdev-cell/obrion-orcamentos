import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/database.dart';
import '../providers/clients_repository_provider.dart';
import '../widgets/app_card.dart';
import '../widgets/app_empty_state.dart';
import '../widgets/app_error.dart';
import '../widgets/app_loading.dart';
import '../widgets/app_text_field.dart';
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
              stream: repository.watchAll(),
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
                    : allClients.where((c) {
                        final query = _query.toLowerCase();
                        return c.name.toLowerCase().contains(query) ||
                            (c.phone?.toLowerCase().contains(query) ?? false) ||
                            (c.address?.toLowerCase().contains(query) ?? false);
                      }).toList();

                if (clients.isEmpty) {
                  return AppEmptyState(
                    message: _query.isEmpty
                        ? 'Nenhum cliente cadastrado ainda.'
                        : 'Nenhum cliente encontrado para "$_query".',
                    actionLabel: _query.isEmpty ? 'Cadastrar cliente' : null,
                    onAction: _query.isEmpty
                        ? () => Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const ClientFormScreen()),
                            )
                        : null,
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: clients.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final client = clients[index];
                    return AppCard(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ClientDetailScreen(client: client),
                        ),
                      ),
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
