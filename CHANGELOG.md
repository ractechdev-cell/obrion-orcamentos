# Changelog

Formato baseado em [Keep a Changelog](https://keepachangelog.com/pt-BR/1.1.0/), versionamento em [SemVer](https://semver.org/lang/pt-BR/).

## [Unreleased]

### Added
- Estrutura inicial do repositório: documentação de planejamento (`docs/`), guia operacional para IA (`CLAUDE.md`), README, CI.
- Scaffold do projeto Flutter do Obrion Orçamentos (App #1), com `applicationId`/bundle id `br.com.ractech.obrion.orcamentos`.
- Tema do app (light/dark) com tokens Material 3 (`lib/theme/`: `app_colors`, `app_semantic_colors`, `app_spacing`, `app_theme`).
- Navegação com `go_router` (`lib/routing/app_router.dart`, `app_routes.dart`) e telas placeholder `HomeScreen`/`SettingsScreen`.
- Primeiro componente do Design System: `AppButton` (`lib/widgets/app_button.dart`).
- Banco local (Drift/SQLite) como fonte da verdade (`lib/database/`): schema inicial com `clients`, `projects`, `measurements`/`measurement_openings`, `services`, `budgets`/`budget_items`, `app_settings`; todo registro de negócio com `id` (UUID), `createdAt`, `updatedAt`, `deletedAt` via `EntityMixin`. Dinheiro sempre `int` em centavos; medidas em `double`.
- Riverpod para injeção de dependência (`flutter_riverpod`), com `appDatabaseProvider` expondo a instância única do banco.
- Repositório de clientes com CRUD local (`lib/repositories/clients_repository.dart`) e tela/listagem de clientes (`lib/screens/clients_screen.dart`, `lib/screens/client_form_screen.dart`) usando o banco local via Riverpod.
- Testes do repositório de clientes (`test/repositories/clients_repository_test.dart`) cobrindo criação, soft delete e busca por nome/telefone/endereço.
- Testes do banco local (`test/database/app_database_test.dart`) cobrindo inserção, dinheiro em centavos, status padrão do orçamento (`draft`) e geometria bruta da medição.
