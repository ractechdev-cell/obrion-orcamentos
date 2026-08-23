# Changelog

Formato baseado em [Keep a Changelog](https://keepachangelog.com/pt-BR/1.1.0/), versionamento em [SemVer](https://semver.org/lang/pt-BR/).

## [Unreleased]

### Added
- Confirmação antes de excluir cliente, serviço ou orçamento (`AppDialog.confirm` com estilo destrutivo em vermelho), em vez de exclusão direta ao toque.
- Validadores de formulário centralizados (`lib/utils/validators.dart`: campo obrigatório, telefone, número positivo), substituindo lambdas duplicadas em cada tela.
- Filtro por status (chips: Todos/Rascunho/Enviado/Aceito/Recusado) na listagem de orçamentos (`budgets_screen.dart`).
- Preferência de tema claro/escuro/sistema, persistida em `app_settings` (`lib/repositories/preferences_repository.dart`) e selecionável em Configurações; `main.dart` carrega a preferência salva no boot em vez de fixar `ThemeMode.system`.
- Logo do profissional no cabeçalho do PDF de orçamento: seletor de imagem em Configurações (`file_picker`), arquivo salvo em `ApplicationDocumentsDirectory`, campo `logoPath` em `ProfileRepository`/`ProfessionalProfile`, renderizado em `budget_pdf_generator.dart` (falha silenciosa se o arquivo não existir mais).

- Roadmap revisado (`CLAUDE.md`, `docs/PLANO_DE_NEGOCIO_INICIAL.md`, `docs/ANALISE_E_MELHORIAS.md`): nova Fase 1.5 de polimento interno (UI/UX, features, tela de login só de interface) entre a Fase 1 e a ★ Validação, testada só pelo fundador; adoção de atualização OTA via Shorebird no lugar de reinstalação manual a cada build.
- Setup inicial do Shorebird (OTA): CLI instalada e app inicializado (`shorebird.yaml` com `app_id`), permissão `INTERNET` adicionada ao `AndroidManifest.xml`. **Pausado** — o primeiro `shorebird release android` não completou nesta máquina (suspeita de Windows Defender interferindo no build do Gradle); retomar após ajustar exclusões do Defender. Ver nota em `CLAUDE.md`, decisão 6.

### Changed
- R8/minificação desligada temporariamente em `android/app/build.gradle.kts` (release) — religar antes da Fase 4 (Play Store).

### Fixed
- Busca em Clientes e Lista de Preços quebrava a reatividade da lista (usava `Stream.fromFuture(repository.search(...))`, que não atualiza sozinha); trocado por filtro client-side sobre a stream viva (`watchAll()`).
- Erro de compilação em `budgets_screen.dart` (assinatura de `build` desatualizada após a conversão de `ConsumerWidget` para `ConsumerStatefulWidget` para suportar o filtro por status).
- Estrutura inicial do repositório: documentação de planejamento (`docs/`), guia operacional para IA (`CLAUDE.md`), README, CI.
- Scaffold do projeto Flutter do Obrion Orçamentos (App #1), com `applicationId`/bundle id `br.com.ractech.obrion.orcamentos`.
- Tema do app (light/dark) com tokens Material 3 (`lib/theme/`: `app_colors`, `app_semantic_colors`, `app_spacing`, `app_theme`).
- Navegação com `go_router` (`lib/routing/app_router.dart`, `app_routes.dart`) e telas placeholder `HomeScreen`/`SettingsScreen`.
- Primeiro componente do Design System: `AppButton` (`lib/widgets/app_button.dart`).
- Banco local (Drift/SQLite) como fonte da verdade (`lib/database/`): schema inicial com `clients`, `projects`, `measurements`/`measurement_openings`, `services`, `budgets`/`budget_items`, `app_settings`; todo registro de negócio com `id` (UUID), `createdAt`, `updatedAt`, `deletedAt` via `EntityMixin`. Dinheiro sempre `int` em centavos; medidas em `double`.
- Riverpod para injeção de dependência (`flutter_riverpod`), com `appDatabaseProvider` expondo a instância única do banco.
- Módulo Orçamentos (`lib/budget/budget_calculations.dart`, `lib/repositories/budgets_repository.dart`, `lib/screens/budgets_screen.dart`, `lib/screens/budget_form_screen.dart`): criação de orçamento a partir do cliente, seleção de serviços da lista de preços, cálculo de itens em centavos (arredondamento meio para cima), desconto, totais, status como mecanismo de retenção (`rascunho → enviado → aceito/recusado`) e duplicação de orçamento anterior.
- Testes de cálculo (`test/budget/budget_calculations_test.dart`) e de repositório (`test/repositories/budgets_repository_test.dart`) cobrindo arredondamento monetário, desconto, ciclo de status e duplicação.
- Módulo Lista de Preços / Serviços (`lib/repositories/services_repository.dart`, `lib/screens/services_screen.dart`): CRUD completo de serviços com preços padrão em centavos e unidades de medida, botão de auto-preenchimento com sugestões por ofício (preços em branco), integração na HomeScreen.
- Testes do repositório de serviços (`test/repositories/services_repository_test.dart`) cobrindo criação, soft delete, busca e pré-população.
- Módulo de Medições (`lib/measurement/measurement_math.dart`, `lib/repositories/measurements_repository.dart`, `lib/screens/measurements_screen.dart`, `lib/screens/measurement_form_screen.dart`): modelo de geometria bruta do cômodo (comprimento, largura, altura) e vãos (portas/janelas), derivação automática de área de piso, teto, parede e perímetro útil, com navegação integrada a partir do cliente.
- Testes de medição (`test/measurement/measurement_math_test.dart`, `test/repositories/measurements_repository_test.dart`) garantindo cálculo exato de vãos e integração com banco local.
- Repositório de clientes com CRUD local (`lib/repositories/clients_repository.dart`) e tela/listagem de clientes (`lib/screens/clients_screen.dart`, `lib/screens/client_form_screen.dart`) usando o banco local via Riverpod.
- Testes do repositório de clientes (`test/repositories/clients_repository_test.dart`) cobrindo criação, soft delete e busca por nome/telefone/endereço.
- Testes do banco local (`test/database/app_database_test.dart`) cobrindo inserção, dinheiro em centavos, status padrão do orçamento (`draft`) e geometria bruta da medição.
- Geração de PDF (`lib/budget/budget_pdf.dart`, `printing`) e compartilhamento via `share_plus` (WhatsApp e outros apps).
- Detalhes do orçamento (`lib/screens/budget_detail_screen.dart`) com totais, dados do cliente e origem na medição/projeto.
- Duplicar orçamento (cria novo orçamento a partir de um existente, status `draft`) e excluir (soft delete via `deletedAt`) na listagem.
- Home útil (`lib/screens/home_screen.dart`): atalhos para Clientes, Medições, Lista de Preços e Orçamentos, com contadores e último orçamento aberto.
- Integração Firebase (Fase 0, item "CrashReporting"): `firebase_core`, `firebase_crashlytics`, `firebase_analytics`; inicialização no `main()` e interceptação de erros não tratados do Flutter (`FlutterError.onError` + `PlatformDispatcher.onError`) indo para o Crashlytics. Plugins Gradle `com.google.gms.google-services` e `com.google.firebase.crashlytics` aplicados; `google-services.json` do projeto Firebase `obrion-orcamentos` commitado. Sem `firebase_options.dart` ainda — só Android por ora (será necessário quando entrar iOS/web, via `flutterfire configure`).
