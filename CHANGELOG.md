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
- Módulo Lista de Preços / Serviços (`lib/repositories/services_repository.dart`, `lib/screens/services_screen.dart`): CRUD completo de serviços com preços padrão em centavos e unidades de medida, botão de auto-preenchimento com sugestões por ofício (preços em branco), integração na HomeScreen.
- Testes do repositório de serviços (`test/repositories/services_repository_test.dart`) cobrindo criação, soft delete, busca e pré-população.
- Módulo de Medições (`lib/measurement/measurement_math.dart`, `lib/repositories/measurements_repository.dart`, `lib/screens/measurements_screen.dart`, `lib/screens/measurement_form_screen.dart`): modelo de geometria bruta do cômodo (comprimento, largura, altura) e vãos (portas/janelas), derivação automática de área de piso, teto, parede e perímetro útil, com navegação integrada a partir do cliente.
- Testes de medição (`test/measurement/measurement_math_test.dart`, `test/repositories/measurements_repository_test.dart`) garantindo cálculo exato de vãos e integração com banco local.
- Repositório de clientes com CRUD local (`lib/repositories/clients_repository.dart`) e tela/listagem de clientes (`lib/screens/clients_screen.dart`, `lib/screens/client_form_screen.dart`) usando o banco local via Riverpod.
- Testes do repositório de clientes (`test/repositories/clients_repository_test.dart`) cobrindo criação, soft delete e busca por nome/telefone/endereço.
- Testes do banco local (`test/database/app_database_test.dart`) cobrindo inserção, dinheiro em centavos, status padrão do orçamento (`draft`) e geometria bruta da medição.
