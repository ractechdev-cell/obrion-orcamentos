# Documentação Completa — Obrion Orçamentos

> **Arquivo gerado automaticamente juntando todos os `.md` do projeto num só, pra leitura/repasse fácil.**
> Não é fonte de verdade — os arquivos originais (`README.md`, `CLAUDE.md`, `docs/*.md`, `CHANGELOG.md`) continuam existindo e sendo atualizados normalmente. Se este arquivo divergir deles no futuro, os originais prevalecem. Regenerado em 24/08/2026.
>
> Ordem de leitura: README → CLAUDE.md → Plano de Negócio → Regras da Fábrica → Catálogo do Core → Análise Crítica → Posicionamento e Features → Análise de Concorrência → Roadmap UX/UI → Progresso do Roadmap → Changelog.

---

# 1. README.md

# Obrion Orçamentos

App de orçamento e medição rápidos para profissionais da construção civil (pedreiro, pintor, gesseiro, azulejista, eletricista, encanador, pequeno empreiteiro).

**Proposta de valor:** medir, montar o orçamento e enviar ao cliente pelo WhatsApp em poucos minutos — direto do celular, inclusive no canteiro.

Este é o App #1 da família **Obrion**, da RACTECH. Proprietário — todos os direitos reservados.

## Documentação

Leia nesta ordem antes de mexer no código:

1. [`CLAUDE.md`](./CLAUDE.md) — guia operacional para IA de programação: regras de engenharia, roadmap vigente, decisões tomadas.
2. [`docs/PLANO_DE_NEGOCIO_INICIAL.md`](./docs/PLANO_DE_NEGOCIO_INICIAL.md) — contexto de negócio, mercado, roadmap, KPIs.
3. [`docs/APP_FACTORY_RULES.md`](./docs/APP_FACTORY_RULES.md) — regras mestras: arquitetura, stack, banco, monetização, LGPD, testes.
4. [`docs/APP_FACTORY_CORE.md`](./docs/APP_FACTORY_CORE.md) — catálogo dos módulos reutilizáveis do Core (extraído a partir do App #2).
5. [`docs/ANALISE_E_MELHORIAS.md`](./docs/ANALISE_E_MELHORIAS.md) — análise crítica que originou a revisão de 21/08/2026 (roadmap invertido, paywall por recurso, AdMob adiado).

## Stack

Flutter · Drift/SQLite (banco local, fonte da verdade) · Supabase (backup/sync) · Firebase (Analytics, Crashlytics, Remote Config, Cloud Messaging) · Google Play Billing.

## Rodando o projeto

```bash
flutter pub get
flutter run
```

## Testes

```bash
flutter analyze
flutter test
```

## Identificadores

- `applicationId` / bundle id: `br.com.ractech.obrion.orcamentos`
- Repositório: parte da família Obrion — ver `docs/APP_FACTORY_CORE.md` para os identificadores dos demais apps.

## Versionamento

SemVer (`MAJOR.MINOR.PATCH`) em `pubspec.yaml`, com tags Git `vX.Y.Z`. Enquanto a versão for `0.x.y`, o produto está em desenvolvimento inicial — sem garantia de estabilidade de API/schema entre versões menores. Ver `CHANGELOG.md`.

## Commits

[Conventional Commits](https://www.conventionalcommits.org/): `feat:`, `fix:`, `chore:`, `docs:`, `refactor:`, `test:`, `ci:`.

---

# 2. CLAUDE.md

# CLAUDE.md

Guia para o Claude Code trabalhar neste repositório. Leia isto antes de gerar qualquer código.

## O projeto

**RACTECH** está construindo a **Obrion** — uma família de apps para profissionais da construção civil (pedreiro, pintor, gesseiro, azulejista, eletricista, encanador, pequeno empreiteiro), sobre uma base técnica única e reutilizável: o **Obrion Core**.

Primeiro produto: **Obrion Orçamentos** (App #1) — medir, montar orçamento e enviar ao cliente por WhatsApp em poucos minutos. Próximos da fila: Obrion Materiais (#2), Obrion Diário (#3), Obrion Medições (#4), Obrion Calculadora (#5).

**Estado atual: Fases 0 e 1 concluídas. Fase 1.5 em andamento — polimento interno (UI/UX, features, tela de login local) testado pelo próprio fundador. Ninguém externo instala o app ainda; ★ Validação (3–5 profissionais reais) só começa depois do polimento.**

Já feito: projeto Flutter (`applicationId` `br.com.ractech.obrion.orcamentos`), tema Material 3 único claro (`lib/theme/` — dark mode removido em 23/08/2026, ver nota própria abaixo), navegação `go_router` (`lib/routing/`), banco local Drift/SQLite (`lib/database/`) com schema completo (`clients`, `projects`, `measurements`, `services`, `budgets`/`budget_items`, `payments`, `app_settings`), DI com Riverpod, design system base (`lib/widgets/`), Crashlytics + Analytics inicializados no boot, barra de navegação inferior (`lib/screens/main_shell.dart`), tela de login/cadastro só de interface (decisão 5, `lib/screens/login_screen.dart`), lembrete local de orçamento aguardando resposta (`lib/notifications/notification_service.dart`, módulo Notifications do Core), controle básico de pagamentos por orçamento (`lib/repositories/payments_repository.dart`, semente do plano Pro), camada de ofício no onboarding/Ajustes/Lista de Preços (`database/enums.dart#Trade`), ponte medição → item de orçamento, descrição da obra e assinatura no PDF, desconto percentual, reajuste de preços em massa, lembrete de validade, recibo em PDF, e os módulos de negócio: **Clientes → Medições → Lista de Preços → Orçamentos** (criação, status rascunho→enviado→aceito/recusado, duplicação, soft delete) com geração de PDF e compartilhamento via `share_plus` (WhatsApp na ponta). Ver `CHANGELOG.md` para o histórico exato.

## Documentos-fonte (ler antes de gerar módulos)

- `docs/APP_FACTORY_CORE.md` — catálogo dos módulos reutilizáveis do Core (Authentication, Database, Analytics, Ads, Purchases/Subscriptions, Notifications, Settings, Theme, UI Components, User) e módulos específicos do Obrion Orçamentos.
- `docs/APP_FACTORY_RULES.md` — regras mestras: princípios, arquitetura, stack, schema de banco, monetização, autenticação, analytics, design system, tema, LGPD, publicação, testes.
- `docs/PLANO_DE_NEGOCIO_INICIAL.md` — contexto de negócio: mercado, problema, público-alvo, diferencial, roadmap, riscos, KPIs.
- `docs/ANALISE_E_MELHORIAS.md` — análise crítica do plano: riscos, lacunas e correções. **Onde este arquivo diverge dos três acima, ele explica o porquê e prevalece nos pontos técnicos já incorporados aqui.**
- `docs/POSICIONAMENTO_E_FEATURES_APP1.md` e `docs/ANALISE_CONCORRENCIA_E_ESCOPO.md` — análises de posicionamento/concorrência de 24/08/2026 (o segundo corrige o primeiro em alguns pontos, ver Parte 6 dele).
- `docs/ROADMAP_UX_UI_E_FEATURES_APP1.md` — roadmap de UX/UI e features trazido pelo fundador em 24/08/2026, novo ponto de partida pra elevar o app a nível profissional antes da ★ Validação. **`docs/PROGRESSO_ROADMAP_UX_UI.md` é o checklist vivo dele — sempre olhar esse arquivo primeiro** pra saber o que já saiu do papel antes de reimplementar algo.

Este CLAUDE.md resume o essencial para o dia a dia de código; para qualquer dúvida de detalhe, a fonte de verdade são os arquivos acima — releia-os se algo aqui parecer desatualizado.

### Decisões estratégicas tomadas (21/08/2026)

Três decisões do fundador que **substituem** o que está escrito nos documentos originais:

1. **Produto primeiro, Core extraído depois.** O App #1 é construído inteiro antes de qualquer infraestrutura genérica. O Core nasce da extração durante o App #2. Ver roadmap abaixo.
2. **Paywall por recurso, não por volume.** O fluxo central é ilimitado no Free; paga-se por acabamento profissional (logo, PDF sem marca, histórico, backup, controle de pagamentos).
3. **AdMob adiado.** Sem anúncios no MVP — vira diferencial na ficha da loja. Reavaliar só quando houver base de usuários que torne a receita não-trivial.

### Decisões estratégicas tomadas (23/08/2026)

Três decisões adicionais do fundador, que inserem uma fase entre a Fase 1 e a ★ Validação:

4. **Polimento interno antes de validação externa.** Antes de recrutar os 3–5 profissionais da ★ Validação, o fundador conduz uma rodada fechada de UI/UX, features adicionais e caça a bugs, testando o app ele mesmo. Ninguém de fora instala o app nesta rodada.
5. **Tela de login é só interface por enquanto.** Entra a tela/fluxo de login e perfil, mas **sem Supabase e sem conta real** — o app continua 100% local (ver "Local-first" abaixo). Autenticação de verdade (anônimo→e-mail) permanece na Fase 2, como já previsto; construir o login de verdade duas vezes seria retrabalho.
6. **Distribuição por OTA (Shorebird), não reinstalação manual.** Durante o polimento (e depois, em produção), atualizações de código Dart chegam por patch OTA via [Shorebird](https://shorebird.dev) — sem passar pela Play Store nem pedir reinstalação. Reinstalar (novo APK/build) só quando a mudança exigir: plugin nativo novo/atualizado, mudança em `android/`/`ios/`, ou upgrade de versão do Flutter/engine. Substitui o fluxo atual de baixar um APK novo do Firebase App Distribution a cada mudança.

**O que conta como "mudança nativa" pra fins de patch (aprendido 23/08/2026):** não é só plugin Android/iOS com pasta `android/`/`ios/` própria. Um pacote que adiciona **native assets** (o sistema mais novo de FFI do Dart, ex.: `shorebird_code_push`) também muda `NativeAssetsManifest.json`/`NOTICES.Z` no build — e o Shorebird recusa o patch (`UnpatchableChangeException`) mesmo sem nenhuma mudança em Gradle/Xcode. Não dá pra saber isso só olhando se o pacote tem pasta `android/`; o jeito seguro é tentar `shorebird patch` e, se ele recusar com esse erro, tratar como mudança nativa de verdade (bump de versão + `shorebird release` novo).

**Lembrete local = mudança nativa (23/08/2026).** `flutter_local_notifications` mexe em Gradle (`multiDex`, `coreLibraryDesugaring`) e `AndroidManifest.xml` (permissões, dois `<receiver>`) — build local trava pelo mesmo motivo de RAM documentado abaixo. Versão bumped pra `0.1.0+3`; publicar com o novo workflow `.github/workflows/shorebird-release.yml` (`shorebird release android --artifact=apk`, disparo manual no GitHub Actions, sobe o APK como artefato do run), não localmente.

**Autorização permanente para publicar patch sozinho, mas em lote (23/08/2026, ajustado 23/08/2026).** Patches na nuvem levam ~10-15min cada — publicar um por commit trava o ritmo de desenvolvimento. Daqui pra frente: **implementar, testar (`flutter analyze` + `flutter test`), commitar e enviar (`git push`) cada mudança normalmente, sem disparar `shorebird-patch.yml` a cada uma.** Só disparar o patch (via `gh workflow run shorebird-patch.yml -f release_version=<versão do release ativo>`, sem pedir confirmação antes de disparar) quando o fundador pedir explicitamente pra publicar/subir/testar no aparelho — nesse momento, o patch carrega todos os commits acumulados desde o último patch, não só o mais recente. Isso **não** vale pra release completo (mudança nativa) — aí sempre confirmar antes de disparar `shorebird-release.yml`, porque exige reinstalação manual do fundador no aparelho.

**R8/minificação religada em 23/08, desligada de novo em 24/08 — quebrou de verdade.** Religada em 23/08/2026 (`isMinifyEnabled`/`isShrinkResources = true`), nunca testada num aparelho real antes de ir pro ar. Em 24/08/2026 o fundador reportou o app instalado travando em **tela branca ao abrir** — diagnosticado como o R8 removendo/renomeando uma classe que o Firebase precisa achar via reflexão em runtime (`Firebase.initializeApp()` trava antes de `runApp()` rodar, sem handler de erro do Flutter ativo ainda — por isso trava em branco em vez de crashar visivelmente). CI verde (`flutter analyze`/`flutter test`) não pegou isso: os testes rodam contra o Dart VM, nunca contra o APK minificado de verdade — só um teste manual num aparelho pega esse tipo de bug. **Voltou pra `isMinifyEnabled = false`/`isShrinkResources = false`** (sem `proguardFiles`), versão bumped pra `0.1.5+5`. Pra religar de novo no futuro: escrever regra `-keep` específica pros componentes de descoberta do Firebase em `proguard-rules.pro` **e** testar instalando de verdade num aparelho antes de considerar resolvido — nunca só confiar em build verde.

**Achado relacionado: `build-distribute.yml` estava rodando em paralelo com o Shorebird, sem ninguém perceber (24/08/2026).** Esse workflow (Firebase App Distribution) é o fluxo antigo, substituído pela decisão 6 (Shorebird OTA) — mas o gatilho `on: push` nunca foi removido, então ele buildava e distribuía um APK novo a cada commit no `main`, inclusive commits só de documentação. É o motivo mais provável do fundador ter instalado por engano um build fora do fluxo Shorebird (o da camada de ofício, já com o R8 quebrado religado) achando que era a mesma coisa. Trocado pra `workflow_dispatch` (disparo manual), mesmo padrão dos workflows do Shorebird.

**Novo esquema de versionamento (23/08/2026), a partir do próximo release completo.** Trocar `x.y.z+build` (ex.: `0.1.0+3`, terceiro dígito sempre zero, build number solto) por `x.y.build+build` — ex.: `0.1.3+3`, `0.1.4+4`, `0.1.5+5`. O terceiro dígito do "nome" da versão (`versionName` no Android, o que aparece pro usuário) passa a andar junto com o build number (`versionCode`, precisa ser inteiro sempre crescente — não dá pra ter só "0.1.3" sem essa parte), incrementando 1 a cada release completo novo. Só se aplica a partir da próxima vez que um release completo (não patch) for necessário — não mexer na versão `0.1.0+3` enquanto ela for a base ativa de algum patch, pra não gerar inconsistência num patch futuro contra essa mesma base.

**Build local instável nesta máquina (23/08/2026).** `shorebird patch android` local trava repetidamente no meio do `bundleRelease` do Gradle (CPU para de crescer, processo fica "Responding" mas sem avançar) — memória livre do Windows caía a ~4.7GB de 16.6GB durante o build, batendo com o padrão de travamento sempre perto do mesmo ponto (etapa de empacotamento/dexing, a mais pesada em RAM). **Solução adotada:** publicar patches pela nuvem em vez da máquina local — `.github/workflows/shorebird-patch.yml`, disparo manual (Actions → "Shorebird Patch (Android)" → Run workflow, informando a versão do release base, ex. `0.1.0+2`). Reaproveita a mesma infra do `build-distribute.yml` que já builda na nuvem. **Passo único e manual (só o fundador pode fazer, mexe com credencial de conta):** rodar `shorebird login:ci` em qualquer máquina, copiar o token impresso, e cadastrar como secret `SHOREBIRD_TOKEN` no repositório GitHub (Settings → Secrets and variables → Actions → New repository secret). Sem isso o workflow falha na autenticação. Build local (`shorebird release`/`shorebird patch` direto no terminal) continua funcionando como alternativa quando a máquina tiver RAM livre suficiente.

**Status da configuração (23/08/2026): funcionando.** CLI instalada, `shorebird login` feito, `shorebird init` rodou (`shorebird.yaml` com `app_id` commitado, permissão `INTERNET` no `AndroidManifest.xml`). R8/minificação religada em 23/08, desligada de novo em 24/08 (quebrou o app em produção) — ver nota própria acima. **Primeiro release publicado:** `shorebird release android` — Release 0.1.0+1, `app-release.apk` (30.5MB) instalado no celular do fundador. Build muito lento nesta máquina mesmo após excluir `.gradle`/`.shorebird`/`Pub\Cache`/pasta do projeto do Windows Defender (~1h, com pausas longas de CPU parada por I/O que se resolveram sozinhas) — não confundir pausa lenta com travamento; confirmar via `Get-NetTCPConnection`/CPU do processo antes de cancelar. **Daqui pra frente:** mudanças só em código Dart vão por `shorebird patch android --release-version=0.1.0+1` (sem reinstalar); mudança nativa (plugin novo, `android/`/`ios/`, versão do Flutter) exige `shorebird release` de novo + reinstalação.

## Roadmap vigente

| Fase | Conteúdo | Estado |
|---|---|---|
| **0 — Fundação mínima** (1 sprint) | Projeto Flutter, navegação, tokens de tema, componentes que o App #1 usa de fato, banco local (Drift), Crashlytics | ✅ **concluída** |
| **1 — O fluxo que vale dinheiro** (3–4 sprints) | Clientes → Medição → Lista de preços → Orçamento → PDF → Compartilhar. **Tudo local: sem conta, sem nuvem, sem billing** | ✅ **concluída** — fluxo completo, PDF, compartilhamento (WhatsApp), duplicar/excluir |
| **1.5 — Polimento interno** (sem prazo fixo) | UI/UX, features adicionais, tela de login/perfil (só interface — decisão 5), correção de bugs. **2ª rodada (23/08/2026): identidade visual/distintividade, caça a bugs visuais, tema único claro.** Testado só pelo fundador | 🔄 **em andamento** |
| **★ Validação** | 3–5 profissionais reais usando de verdade, antes de nuvem ou monetização | ⏸️ aguardando fim do polimento |
| **2 — Conta e nuvem** (1–2 sprints) | Supabase, login anônimo→e-mail, sync push, backup | ⏸️ aguardando validação |
| **3 — Monetização** (1 sprint) | Play Billing, paywall por recurso. Sem ads | ⏸️ aguardando validação |
| **4 — Publicar e medir** | Play Store, 30 dias lendo funil e retenção | ⏸️ |
| **★ Extração do Core** | Ao construir o App #2, extrair o que comprovadamente repetiu | ⏸️ |

**Consequência prática para quem escreve código:** nas Fases 0, 1 e 1.5 não existe Supabase, não existe AdMob, não existe Play Billing — a tela de login da Fase 1.5 é interface e estado local, sem chamada de rede. Escrever em camadas limpas (repositórios atrás de interface, nenhuma tela falando com banco direto) para que a extração posterior seja mecânica — mas **não** criar abstração genérica para apps que ainda não existem.

## Princípios inegociáveis

1. **Não recriar infraestrutura em cada app.** Auth, banco, analytics, ads, assinatura, notificações, tema e componentes de UI vivem no Core e são só consumidos.
2. **Primeiro produto pequeno, depois plataforma.** Nenhum app nasce como "sistema completo".
3. **IA não é feature de lançamento.** Cada app nasce funcional sem IA; recursos de IA entram depois como diferencial Pro+.
4. **Dado antes de opinião.** Priorização apoiada em funil/retenção (D1/D7/D30), não em achismo.
5. **Fricção mínima de entrada.** Login nunca é a primeira tela; o usuário cria valor (ex.: 1 orçamento) antes de qualquer barreira de cadastro.
6. **Consistência de marca por tema, não por tela.** Cor/tipografia/espaçamento sempre via tokens de tema, nunca hardcoded.

## Regras de engenharia inegociáveis

Estas valem desde a primeira linha de código. Violá-las custa reescrita, não refatoração.

### Dinheiro é `int` em centavos — nunca `double`

Ponto flutuante quebra soma de dinheiro (`0.1 + 0.2 != 0.3`). Num app cuja função é **cotar preços**, isso gera orçamento cujo total não bate com a soma dos itens.

- Todo valor monetário é `int` em centavos, do banco à tela.
- Formatação para `R$` só na borda de apresentação (`AppCurrencyInput` e widgets de exibição).
- `quantidade × preço_unitário` arredonda ao centavo, meio para cima — regra definida uma vez, coberta por teste unitário.
- Medidas (m², m³, metro linear) continuam `double` — ali a precisão de ponto flutuante é irrelevante.

### Idioma: código em inglês, interface em português

- Identificadores de código (classes, métodos, campos, tabelas, eventos) **sempre em inglês**: `startAnonymousSession()`, `signUp()`, `signIn()`, `upgrade(plan)`, `trackEvent(name, params)`.
- Texto visível ao usuário **em português**, centralizado em arquivo de tradução desde o dia 1 (iOS e expansão estão no roadmap).
- Nunca string de UI hardcoded no widget.

> Os nomes em português no `docs/APP_FACTORY_CORE.md` (`iniciarModoAnonimo()`, `criarConta()`) foram substituídos por esta regra — ver T4 em `docs/ANALISE_E_MELHORIAS.md`.

### Local-first: o banco local é a fonte da verdade

O app precisa funcionar sem sinal no canteiro. Não construir sincronização bidirecional genérica — este produto não precisa dela (um dono, um dispositivo escrevendo por registro).

- Toda leitura e escrita da UI é **local** (Drift/SQLite), sempre instantânea, sempre funcional offline.
- Supabase é **destino de backup e sincronização**, nunca dependência de execução. Nenhuma tela pode travar esperando rede.
- Sincronização por registro com `updated_at`; último a escrever vence. Sem CRDT, sem tela de resolução de conflito.
- Todo registro carrega: `id` (UUID gerado no cliente), `updated_at`, `deleted_at` (exclusão lógica, para propagar remoção).

### Identidade do usuário nunca muda

Usar **login anônimo do Supabase**, depois vinculado a e-mail — o `user_id` permanece o mesmo. Não existe "migrar dados locais para a conta": existe apenas vincular identidade. Isso elimina a rotina de migração e o risco de perda de dados no cadastro.

Se o primeiro uso for offline, gerar o UUID localmente e criar o usuário remoto na primeira conexão **mantendo o mesmo id**.

### Medição guarda geometria bruta, não "a área"

Cada ofício mede coisa diferente do mesmo cômodo. Guardar um único campo `area` faz o app servir só para pintura.

O ambiente armazena **comprimento, largura, altura e a lista de vãos** (portas/janelas com dimensões). As grandezas são **derivadas**:

```
area_piso      = comprimento × largura
area_teto      = comprimento × largura
perimetro      = 2 × (comprimento + largura)
area_parede    = perimetro × altura − Σ(vãos)
perimetro_util = perimetro − Σ(largura das portas)
volume         = area_piso × espessura
```

Cada item do orçamento escolhe **qual grandeza** consumir, conforme a unidade do serviço (m², m, m³, un, ponto).

### Retenção precisa de mecanismo, não só de métrica

Baixa retenção é o risco nº 2 do plano, e "acompanhar D1/D7/D30" é medição, não mitigação. O MVP inclui três mecanismos baratos que dão motivo estrutural para reabrir o app:

1. **Lista de preços pessoal** (abaixo) — o segundo orçamento fica ~6× mais rápido.
2. **Status do orçamento**: `rascunho → enviado → aceito → recusado`, atualizável em um toque. Dá motivo para voltar ("o cliente respondeu?"), alimenta a notificação já prevista no Core ("orçamento aguardando resposta há 3 dias"), gera taxa de fechamento como dado, e é a semente natural do "controle de pagamentos" do plano Pro.
3. **Duplicar orçamento anterior** como ponto de partida — uma linha de UI, alto uso real.

### Lista de preços pessoal é funcionalidade central do MVP

A tabela `services` é o coração do produto, não um detalhe. Sem ela, o segundo orçamento demora tanto quanto o primeiro e não há motivo para o usuário voltar.

```
service
├── name                "Reboco de parede"
├── unit                m² | m | un | ponto | diária | verba
├── default_price_cents int
├── includes_material   bool
└── default_note        texto reaproveitado no orçamento
```

Pré-carregar lista sugerida por ofício (pedreiro, pintor, gesseiro, azulejista, eletricista, encanador) com a unidade correta e **preço em branco**. **Nunca sugerir valores de preço** — preço é regional, e errar destrói credibilidade com este público.

---

## Arquitetura e regra de dependência

```
OBRION
├── Core (Obrion Core): Authentication, Database, Analytics, Ads,
│   Purchases, Subscriptions, Notifications, Settings, Theme, UI Components
├── Design System: Buttons, Cards, Inputs, Dialogs, Bottom Sheets,
│   Navigation, Empty/Loading States
├── User: Profile, Preferences, Subscription
└── App (camada específica de cada produto)
    └── Obrion Orçamentos: Clientes, Obras, Medições, Orçamentos, PDF
```

`App` pode depender de `Core` e `Design System`. **`Core` nunca depende de `App`.** Isso é o que permite reaproveitar o Core em Obrion Materiais, Diário, Medições etc. sem refatoração.

Ao criar um app/módulo novo:
1. Importar o Core existente sem modificá-lo (salvo bugfix ou extensão genérica aprovada).
2. Criar apenas a camada `App/<nome-do-app>` com o que é específico daquele produto.
3. Reaproveitar componentes do Design System antes de criar um novo — se criar, ele entra no Core, nunca fica isolado no app.

## Stack

| Camada | Tecnologia |
|---|---|
| Front-end | Flutter (Android primeiro, iOS depois sem reescrever) |
| **Atualização OTA** | **Shorebird** — patch de código Dart sem passar pela loja (ver decisão 6). Reinstalação manual só quando algo nativo muda |
| **State management / DI** | **Riverpod** (`flutter_riverpod`) — decisão tomada ao implementar o banco local; provider expõe o `AppDatabase` e, na Fase 1, os repositórios |
| **Banco local (fonte da verdade)** | **Drift / SQLite**, via `drift_flutter` (`sqlite3_flutter_libs` está obsoleto — não usar) |
| Backend/BaaS | Supabase (Auth, PostgreSQL, storage, RLS) — backup e sync, não dependência de execução |
| Analytics | Firebase Analytics |
| **Crash reporting** | **Firebase Crashlytics** — para dev solo, vale mais que analytics |
| **Feature flags / limites** | **Firebase Remote Config** — permite mudar regra de negócio sem release na loja |
| ~~Anúncios~~ | ~~Google AdMob~~ — **cortado do MVP** (decisão 3) |
| Assinaturas | Google Play Billing (só na Fase 3; avaliar RevenueCat quando houver múltiplos apps) |
| Notificações | Firebase Cloud Messaging |
| PDF | `pdf` + `printing` (Flutter) |
| Compartilhamento | `share_plus` (folha de compartilhamento do sistema) |

**Nota sobre WhatsApp:** `wa.me/<telefone>?text=` abre conversa com texto pré-preenchido mas **não anexa arquivo**. Anexar o PDF exige a folha de compartilhamento do sistema, onde o usuário escolhe o app e o contato. Considerar também **exportar como imagem** (PNG da primeira página) — muitos clientes finais abrem imagem no WhatsApp e ignoram PDF.

Confirmar o estado de manutenção dos pacotes Flutter no momento de adicioná-los.

## Módulos do Core (resumo — ver `docs/APP_FACTORY_CORE.md` para interface completa)

- **Authentication** — estado do usuário (anônimo/free/pro), `startAnonymousSession()`, `signUp()`/`signIn()`, `onAuthStateChanged`. Identidade nunca muda (ver regras de engenharia). Nunca criar tela de login própria por app.
- **Database** — banco local Drift como fonte da verdade + Supabase para backup/sync com RLS; repositório CRUD genérico (`clients`, `projects`, `payments`, `subscriptions`, `app_settings`). Nunca abrir conexão própria.
- **Analytics** — `trackEvent(name, params)` único; apps só adicionam eventos específicos em `snake_case`. Nunca integrar o SDK do Firebase direto na tela.
- ~~**Ads**~~ — **fora do escopo** (decisão 3). Não implementar. Quando/se voltar: `AppAdContainer`, `showInterstitial(context)` com regras de frequência centralizadas, e nunca chamar o SDK do AdMob direto da tela.
- **Purchases/Subscriptions** — estado do plano (`free`/`pro`/`pro_plus`), `AppSubscriptionCard`, `AppPremiumBadge`, `upgrade(plan)`. Nunca implementar checagem "sou premium?" local. Limites do plano vêm de Remote Config, não de constante em Dart.
- **Notifications** — `scheduleNotification(type, data)`, templates padronizados.
- **Settings** — `AppSettingsScreen` base + persistência em `app_settings`.
- **Theme** — tokens `primary`, `secondary`, `background`, `surface`, `text`, `error`, `success`, `warning`; Light/Dark desde o dia 1.
- **UI Components** — ver tabela abaixo. Regra de ouro: montar telas combinando estes componentes antes de criar algo novo.
- **User** — perfil profissional (nome, telefone, logo, tipo de serviço), preferências, espelho do estado de assinatura.

Módulos ausentes do catálogo original e que **todo** app da família vai precisar (ver T5 na análise):

- **CrashReporting** — Crashlytics. Sem isso, bugs são descobertos por avaliação 1 estrela.
- **RemoteConfig** — limites do Free, flags de funcionalidade, sem release na loja.
- **AppUpdate** — atualização forçada/recomendada, para quando uma build quebrada for publicada.
- **Review** — `in_app_review` disparado no momento de sucesso (logo após compartilhar o PDF). Canal de aquisição orgânica mais barato disponível.
- **Connectivity** — estado da conexão, para a UI local-first ("salvo no aparelho" / "sincronizado").

### Catálogo de componentes (Design System)

`AppButton`, `AppTextField`, `AppCard`, `AppDialog`, `AppBottomSheet`, `AppHeader`, `AppEmptyState`, `AppLoading`, `AppError`, `AppCurrencyInput`, `AppNumberInput`, `AppDatePicker`, `AppPremiumBadge`, `AppAdContainer`, `AppSubscriptionCard`.

## Banco de dados (schema inicial)

```
users
 ├── profiles
 ├── clients
 ├── projects
 ├── measurements
 ├── budgets
 ├── budget_items
 ├── payments
 ├── services
 ├── materials
 ├── subscriptions
 └── app_settings
```

- Todo dado de negócio vinculado a `user_id` com RLS — cada usuário só vê seus próprios dados.
- `clients`, `projects`, `payments`, `subscriptions` devem servir sem alteração de schema para os próximos apps.
- `budgets`/`budget_items` são específicos do Obrion Orçamentos; convenção a espelhar em novos apps: `<entidade>` + `<entidade>_items`.

## Monetização (Freemium)

**Paywall por recurso, não por volume** (decisão 2). O fluxo central nunca é bloqueado — cada PDF gratuito é peça de aquisição circulando no WhatsApp.

| Free | Pro (~R$14,90/mês ou R$99,90/ano) |
|---|---|
| Clientes, medições e orçamentos **ilimitados** | **Logo própria no PDF** |
| Lista de preços pessoal completa | **PDF sem a marca do app** |
| Fluxo completo medir → orçar → enviar | Histórico e backup na nuvem |
| PDF com rodapé "Feito com Obrion" | Templates e condições de pagamento salvas |
| **Sem anúncios** | Controle de pagamentos |

**Pro+** (~R$24,90–29,90/mês) — IA por voz, análise de orçamento, financeiro, relatórios, lucro.

- **Sem AdMob no MVP** (decisão 3). Não implementar `AppAdContainer` nem `showInterstitial` por enquanto.
- Se algum teto for necessário para custo de infra, usar valor que o uso normal nunca encosta (~30 orçamentos/mês), nunca 5 — e configurável via Remote Config.
- O rodapé "Feito com Obrion — obrion.app" é **canal de aquisição projetado**, não marca d'água acidental. Tratar com o mesmo cuidado de design do resto do PDF.

## Autenticação — fluxo

Login nunca é a primeira tela. Fluxo: `Começar agora → cria 1 orçamento sem conta → convite para criar conta grátis`. Dados criados no modo anônimo migram para a conta no cadastro, nunca são perdidos.

## Analytics — eventos mínimos obrigatórios

```
app_open, signup, create_budget, budget_created, budget_shared,
pdf_generated, subscription_started, premium_screen_view
```

(`ad_view` sai junto com o AdMob — decisão 3.)

Acrescentar (ver T6 na análise — os degraus do funil que a lista original não cobre):

```
measurement_started, measurement_completed   # tela mais complexa = maior ponto de abandono
upgrade_blocked(limit, origin)               # evento de monetização mais valioso: qual limite converte
subscription_cancelled, subscription_renewed # sem isso só se enxerga a metade boa do churn
price_list_item_created                      # adoção do fosso competitivo
budget_duplicated                            # principal sinal de retenção real
```

Parâmetros obrigatórios: `budget_shared` leva `channel` (whatsapp/email/outro) — sem ele não dá para validar a hipótese central de distribuição. `pdf_generated` leva `format` (pdf/imagem).

Funil de referência: `Instalou → Abriu → Começou orçamento → Criou orçamento → Gerou PDF → Compartilhou → Criou conta → Voltou → Assinou`.

## Segurança e LGPD

- RLS ativo em todas as tabelas Supabase.
- Dados pessoais de clientes (nome, telefone, endereço de obra): coleta mínima, finalidade explícita, exclusão de conta apaga dados.
- **Dado de terceiro:** o app guarda dados pessoais dos *clientes do usuário*, que nunca aceitaram nada com a RACTECH. O profissional é o **controlador**; a RACTECH é a **operadora**. Consequências práticas: a política de privacidade precisa descrever essa relação; a exclusão de conta precisa **cascatear** para os registros de clientes; o PDF circula por WhatsApp contendo dado pessoal de terceiro (uma linha nos termos sobre a responsabilidade do usuário nesse envio).
- Política de privacidade e termos publicados antes do lançamento na Play Store.
- Backups (Pro) criptografados em trânsito e repouso.
- **Nunca versionar credenciais/chaves de API em texto puro** — usar variáveis de ambiente/secrets.

## Testes

Focar no que erra silenciosamente e custa caro:

- **Unitários:** derivação de grandezas da medição, soma de orçamento com desconto, **arredondamento monetário**.
- **Teste de conteúdo do PDF** (`test/pdf/budget_pdf_content_test.dart`) — confere se cliente, itens, subtotal/desconto/total e observações vão certos pro PDF, via `lib/pdf/budget_pdf_content.dart` (o "que texto vai no PDF", separado de "como é desenhado"). Golden test visual pixel-a-pixel (o ideal, já que o PDF é o que chega ao cliente final) **não é viável no `flutter test` comum** — `Printing.raster` exige host de plataforma real (device/emulador via `integration_test`), trava indefinidamente em ambiente headless (confirmado 23/08/2026). Se um dia isso importar o suficiente pra justificar o custo de infra (emulador no CI), revisitar com `integration_test`.
- **CI simples** (GitHub Actions) rodando `flutter analyze` + `flutter test` a cada push. Sem CI, "rodar regressão contra todos os apps" não acontece na prática.
- Teste manual de fluxo completo antes de cada release: criar cliente → medir → gerar orçamento → gerar PDF → compartilhar.
- Ao alterar um módulo do Core, rodar regressão contra **todos** os apps que o consomem, não só o mais recente.

### Usuário-alvo confirmado: prestador solo, não coordenador/empreiteiro (24/08/2026)

`docs/ANALISE_CONCORRENCIA_E_ESCOPO.md` (teardown de 2 concorrentes) levantou a hipótese de pivotar o usuário-alvo pra coordenador/empreiteiro (perfil de uso do próprio fundador, que coordena pintor/pedreiro/caldeireiro/soldador), com home virando painel de obras/saldos/pendências em vez de criação rápida de orçamento. **Fundador decidiu manter o plano original: prestador solo** (ex. pintor), home continua orientada a criar orçamento rápido. Motivo prático: pivotar pra coordenador tensiona com "gestão de equipe fora do MVP" (ver "Fora de escopo" no fim deste arquivo) — um painel de obras/saldos de vários trabalhadores puxa naturalmente pra multi-usuário. Uso pessoal do fundador informa prioridade de features, não redefine o público.

**Resolvido (24/08/2026): 1 app × 5 — mantém 5.** `docs/ANALISE_CONCORRENCIA_E_ESCOPO.md` inicialmente recomendou colapsar os 5 apps da família em módulos de um único app; o fundador corrigiu o raciocínio e o documento foi revisado (Parte 2). Analogia certa não é Adobe, é **Autodesk** (AutoCAD/Revit/Navisworks): produtos focados para papéis/momentos distintos da mesma obra, que interoperam por dado compartilhado e se vendem como pacote — não um binário fundido. "Juntar no final" = **conta/login único sobre o Core** (modelo AEC Collection), não fusão de código. `PLANO_DE_NEGOCIO_INICIAL.md` §11 e `APP_FACTORY_CORE.md` §13 (família de 5 apps) **confirmados, não precisam de revisão**.

Três consequências práticas dessa decisão:
1. **Escopo do App #1 travado**: orçamento, medição, PDF, envio, status, recibo de pagamento. Qualquer coisa fora disso (diário de obra, catálogo completo de materiais, agenda) é candidato a outro app da família, não a uma aba nova aqui — reforça o princípio "não recriar infraestrutura em cada app" e a regra de fronteira App #1 × App #5 (calculadoras: Orçamentos só calcula o que vira item de orçamento).
2. **Ordem #2→#5 deixa de ser fixa por opinião.** O plano original tinha Materiais como #2; o sinal de uso real do fundador (gente que só quer diário de obra, não orçamento) é candidato a furar a fila. Decisão fica pra fase ★ Extração do Core do roadmap, com dado de uso — não travada agora por herança do documento original.
3. **Usuário-alvo permanece prestador solo** (decisão acima) — não muda com a confirmação da família de 5 apps.

### Segunda rodada da Fase 1.5 — tema único claro, sem dark mode (23/08/2026)

Fundador reportou o tema escuro "confuso" — investigação confirmou causa técnica real, não só gosto: o Material 3 gera o esquema escuro 100% automaticamente a partir da seed âmbar (`ColorScheme.fromSeed`), sem nenhum ajuste manual de contraste (só os tokens `success`/`warning` eram tunados à mão, e só no claro). Seeds saturadas em laranja/âmbar tendem a gerar esquemas escuros "sujos" quando gerados automaticamente.

**Decisão:** remover o tema escuro em vez de auditá-lo/corrigi-lo. Justificativa: o público do app trabalha ao sol/poeira no canteiro — uso noturno/indoor é atípico para este produto específico — então o ganho de manter dark mode não paga o custo de mantê-lo (mais uma superfície pra testar/manter, e nenhum ajuste manual já existia). `AppTheme.dark()`, `ThemeMode`/`themeModeProvider`, a seção "Aparência" em Configurações e a persistência de preferência de tema em `app_settings` foram removidos; `AppSemanticColors`/`AppSemanticPalette` mantêm só as variantes claras. `MaterialApp.router` usa só `theme: AppTheme.light()`, sem `darkTheme`/`themeMode`.

Isso também respondeu a segunda pergunta do fundador na mesma rodada ("o app está muito genérico?") — não, não era intenção: a cor âmbar (revisão de tema abaixo) já foi uma correção deliberada de genericidade uma vez. O que a família **compartilha por design** é a arquitetura do tema (seed → `ColorScheme.fromSeed`, tokens semânticos) e o sistema de ícone/monograma — não a personalidade visual específica de cada app, que deve continuar distintiva. Uma rodada de tipografia/iconografia mais autoral (via skill `frontend-design`) fica como próximo passo em aberto, não decidido ainda.

### Revisão de tema (23/08/2026) — âmbar de segurança

Pesquisa de mercado na Play Store (busca "orçamento obra whatsapp") mostrou dezenas de concorrentes diretos (Orça Na Mão, Profissa, ConstruCalc, Orçamento PRO, ORÇA AÍ, Prummo, ConstruFácil, Orça Rápido Whatsapp, entre outros) — a maioria usa azul corporativo genérico, a mesma cor que o Obrion usava (`0xFF1565C0`). Isso não é uma escolha de marca, é o "olhar padrão de app de utilidade", e não ajuda em nada a facilidade de aprendizado do público (baixa familiaridade digital, uso ao sol/poeira no canteiro, referência diária é o WhatsApp).

**Decisão:** trocar a seed do Material 3 (`lib/theme/app_colors.dart`, `obrionSeed`) para um **âmbar de segurança** (`0xFFC2680A`). Justificativa: é a cor do próprio canteiro (capacete, colete, cone, faixa zebrada) — reconhecível sem exigir aprendizado novo — e de alto contraste para leitura ao sol. Como o app deriva toda a paleta (`ColorScheme.fromSeed`) de um único valor, a troca é cirúrgica: nenhuma tela ou widget referencia cor fora de `app_colors.dart`/`app_theme.dart`. Tokens semânticos (`success`/`warning`) mantidos como estão — já são acessíveis e não têm relação com a marca.

Confirmado com o fundador (23/08/2026): a **arquitetura** do tema (uma seed → `ColorScheme.fromSeed`, tokens semânticos, convenções de componente) é o que vira padrão reutilizável entre os apps da família — não a cor em si. Cada app continua com sua própria cor de destaque, escolhida pelo mesmo método (grounded no ofício daquele app), conforme "Identidade visual da família" abaixo. Formalizado como módulo Core em `docs/APP_FACTORY_CORE.md` §8.

## Identidade visual da família

Mesma forma-base de ícone e estilo de monograma em todos os apps; muda cor de destaque e monograma de 2 letras: Obrion Orçamentos (**Or**), Materiais (**Ma**), Diário (**Di**), Medições (**Me**), Calculadora (**Ca**). Login único dá acesso a todos os apps instalados da família. Cross-promotion só em momentos de baixa fricção (ex.: tela de sucesso pós-PDF), nunca interrompendo tarefa.

⚠️ **`applicationId` (Android) e bundle identifier (iOS) são imutáveis após a primeira publicação.** Errar isso significa perder o app e a base de usuários — por isso a convenção da família está fixada agora, antes do primeiro build, e nunca deve ser alterada em nenhum app já publicado.

**Convenção definitiva (decidida em 21/08/2026):** `br.com.ractech.obrion.<app>`, sem acentos, tudo minúsculo. Usar o **mesmo identificador em Android e iOS** (Flutter permite configurar diferente por plataforma, mas não há motivo para isso aqui — divergir só cria confusão).

| App | applicationId / bundle id |
|---|---|
| Obrion Orçamentos (#1) | `br.com.ractech.obrion.orcamentos` |
| Obrion Materiais (#2) | `br.com.ractech.obrion.materiais` |
| Obrion Diário (#3) | `br.com.ractech.obrion.diario` |
| Obrion Medições (#4) | `br.com.ractech.obrion.medicoes` |
| Obrion Calculadora (#5) | `br.com.ractech.obrion.calculadora` |

Ao criar o projeto Flutter do App #1 (Fase 0), definir `br.com.ractech.obrion.orcamentos` em `android/app/build.gradle` (`applicationId`) e no Bundle Identifier do Xcode/`ios/Runner.xcodeproj` — mesmo que o build iOS só saia depois, fixar o valor agora evita divergência futura.

✅ Busca de "Obrion" na Google Play e App Store feita em 21/08/2026 — sem conflito encontrado. Ainda pendente, fora do controle de código: busca formal de anterioridade no INPI, e registro da conta de desenvolvedor Google Play / Apple Developer em nome da RACTECH.

## Convenção de prompt para pedir um módulo novo

```
Contexto: Use o OBRION CORE (APP_FACTORY_CORE.md) e as regras de APP_FACTORY_RULES.md.
Tarefa: Construir o módulo <nome> do Obrion <Nome do App> (App #<N>).
Reaproveitar: <módulos do Core / componentes do Design System que já resolvem parte do problema>.
Criar apenas: <o que é genuinamente novo>.
```

Aplique esse raciocínio internamente mesmo quando o usuário pedir algo em linguagem informal — antes de codar, identifique o que já existe no Core/Design System vs. o que é genuinamente novo.

## Fora de escopo do MVP (não implementar sem pedido explícito)

Gestão de equipe, cronograma, estoque, fornecedores, financeiro completo, emissão fiscal, marketplace, IA complexa, chat, integração bancária, mapa, assinatura digital avançada, ERP, versão desktop.

---

# 3. docs/PLANO_DE_NEGOCIO_INICIAL.md

# Plano de Negócio Inicial — Obrion (RACTECH)

**Projeto:** Obrion — família de apps da RACTECH para o setor de construção civil
**Primeiro produto:** Obrion Orçamentos (App #1) — Orçamento + Medição de Obra
**Data:** 21 de agosto de 2026
**Status:** Rascunho inicial para validação interna, baseado em pesquisa de mercado própria

> **Nota sobre a marca:** o nome **Obrion** foi definido após checagem de disponibilidade (INPI/web) que não encontrou conflito no setor de construção civil/orçamento de obra no Brasil — nenhuma empresa, app ou domínio brasileiro do nicho usa esse nome. A checagem também identificou uma semelhança fonética relevante com "Château Haut-Brion" (vinho francês de prestígio) — risco jurídico avaliado como baixo por se tratar de classe totalmente distinta, mas recomenda-se busca formal de anterioridade no INPI antes do registro definitivo de marca, domínio e CNPJ (ver Seção 13). **Atualização de 21/08/2026:** busca de "Obrion" também na Google Play e na App Store não encontrou conflito.

---

## 1. Sumário Executivo

A RACTECH pretende entrar no mercado de aplicativos para construção civil não com um sistema completo de gestão de obras, mas com uma **infraestrutura reutilizável (o "Obrion Core") somada a uma sequência de pequenos produtos especializados sob a marca Obrion**, cada um resolvendo uma dor específica do profissional de obra.

O primeiro produto, **Obrion Orçamentos**, será um app de **orçamento e medição rápidos**, com a promessa central de: *"Faça a medição, monte o orçamento e envie para o cliente pelo WhatsApp em poucos minutos."* A pesquisa de mercado indica demanda comprovada por ferramentas digitais de construção (apps de cálculo com mais de 1 milhão de downloads), mas também concorrência alta em "calculadoras genéricas" — o que aponta para uma oportunidade de nicho em fluxos rápidos e simples de orçamento, e não em mais um "gestor de obras completo".

A estratégia central é: construir uma vez a base técnica (autenticação, banco de dados, analytics, anúncios, assinaturas, notificações, tema e design system) e reaproveitá-la em cada novo aplicativo, reduzindo drasticamente o custo e o tempo de desenvolvimento dos produtos seguintes.

---

## 2. Oportunidade de Mercado

A pesquisa de mercado (Google Play) identificou sinais claros de demanda:

| App concorrente | Downloads | Avaliações | Foco |
|---|---|---|---|
| ConstruCalc | 1.000.000+ | ~8.250 | Cálculo de materiais e estimativas |
| Cálculos na obra | 100.000+ | ~3.380 | Telhado, concreto, paredes, aço, revestimento, pintura, lajes |
| Orça Rápido | — | — | Orçamento, cálculo de materiais, diário de obra, PDF, WhatsApp |
| Canteiro Gestão | — | — | Materiais, etapas, despesas, fornecedores, cotação via WhatsApp |
| Prummo | — | — | Orçamento por voz; plano Plus a R$ 39,90/mês |
| Azulejista+ | — | — | Orçamento por voz (nicho) |

Foram identificadas também categorias adicionais com tração: apps de orçamento (10 mil+ downloads), apps de gestão de obra, apps de materiais, apps de diário de obra, apps de orçamento com PDF e WhatsApp, e apps especializados por ofício (ex.: pintura).

**Leitura da oportunidade:** existe demanda comprovada, mas o segmento de "calculadora de construção genérica" já é competitivo. O espaço mais aberto está em fluxos **rápidos, simples e especializados** — não em recriar mais um sistema de gestão completo.

Uma análise do setor (Sienge, jul./ago. de 2026) reforça que o WhatsApp se tornou o canal padrão do canteiro brasileiro — usado para fotos, avisos, andamento e decisões — mas sem funcionar como registro organizado. Os próprios concorrentes já vendem essa promessa ("pare de depender de papel, planilha e WhatsApp"), confirmando que o problema real não é falta de software, e sim **software complicado demais para quem está no canteiro**.

---

## 3. O Problema

O fluxo atual do profissional de obra (pedreiro, pintor, gesseiro, azulejista, eletricista, encanador, pequeno empreiteiro) é, tipicamente:

visita o cliente → mede (papel/celular) → volta para casa → calcula → monta orçamento → envia por WhatsApp → espera resposta.

Esse processo é lento, informal e depende de memória, papel, calculadora e planilhas soltas — com alto risco de erro e de perda de oportunidade comercial por demora na resposta ao cliente.

---

## 4. A Solução — Obrion Orçamentos (App #1)

**Proposta de valor:** permitir que o profissional faça uma medição, transforme essa medição em orçamento e envie ao cliente em poucos minutos — direto do celular, inclusive no canteiro.

Fluxo de uso proposto (5 telas):

1. **Novo orçamento** — cliente e tipo de serviço.
2. **Medição** — dimensões do ambiente, portas, janelas.
3. **Serviço** — cálculo automático de quantidade (ex.: m²) e valor.
4. **Orçamento** — material, mão de obra, prazo, forma de pagamento, observações.
5. **Enviar** — gerar PDF e enviar por WhatsApp.

O produto deliberadamente **não** tenta competir como "sistema completo de gestão de obras" — evita o espaço já disputado pelos concorrentes maiores e ataca a dor mais específica e mais frequente: transformar uma visita em orçamento enviado.

---

## 5. Público-Alvo

Prestadores de serviço individuais e pequenos empreiteiros:

- Pedreiro
- Pintor
- Gesseiro
- Azulejista
- Eletricista
- Encanador
- Pequeno empreiteiro

Perfil de uso: profissional que atende diretamente o cliente final, precisa responder rápido para fechar o serviço, e hoje resolve isso com papel, WhatsApp, calculadora e memória.

---

## 6. Diferencial Competitivo

| Dimensão | Concorrência típica | Nossa abordagem |
|---|---|---|
| Escopo | "Gestão completa de obra" (equipe, cronograma, financeiro, estoque) | Um fluxo único e rápido: medir → orçar → enviar |
| Tempo de uso | Múltiplas telas, curva de aprendizado | Promessa de "orçamento em 3 minutos" |
| IA | Alguns concorrentes já usam voz→orçamento (Prummo, Azulejista+) | IA entra só na V2+, como diferencial Premium, não como base do produto |
| Barreira de entrada | Login obrigatório em muitos apps | Uso sem conta no primeiro orçamento; conta oferecida depois, sem fricção |
| Reuso de base | Cada app do concorrente é um produto isolado | Nossa base técnica (Core) é compartilhada entre todos os apps futuros, reduzindo custo marginal de cada novo produto |

Estratégia explícita de **não nichar em "calculadora de construção"** (mercado já concorrido) e sim em **velocidade do ciclo comercial** (medição → orçamento → envio).

### Onde está o fosso real (revisão de 21/08/2026)

Velocidade e simplicidade **não são defensáveis** — qualquer concorrente copia um app simples em um trimestre, e os concorrentes citados já têm distribuição. O que de fato cria custo de troca:

1. **A lista de preços pessoal do profissional.** Depois de cadastrar os preços dele, mudar de app custa retrabalho. É o maior custo de troca disponível neste produto — e é barato de construir. Também é o que faz o segundo orçamento levar 30 segundos em vez de 3 minutos, atacando a retenção ao mesmo tempo.
2. **O histórico acumulado** de clientes e orçamentos.
3. **O login único da família Obrion**, que já consta do plano.

Por isso a lista de preços deixa de ser detalhe de implementação e entra como funcionalidade central do MVP (ver R4 e P1 em `ANALISE_E_MELHORIAS.md`).

Complementarmente, o **rodapé do PDF gratuito** ("Orçamento feito com Obrion — obrion.app") deve ser tratado como canal de aquisição projetado, com chamada real — não como marca d'água acidental. É o canal de distribuição mais barato que o projeto tem.

---

## 7. Modelo de Negócio (Monetização)

Modelo **Freemium com paywall por recurso, não por volume** (revisão de 21/08/2026 — ver `ANALISE_E_MELHORIAS.md`, R2 e R3).

**Gratuito**
- Clientes, medições e orçamentos **ilimitados**; lista de preços pessoal; fluxo completo medir → orçar → enviar; PDF com rodapé "Feito com Obrion"; **sem anúncios**.

**Pro — R$ 14,90/mês ou R$ 99,90/ano**
- Logo própria no PDF; PDF sem a marca do app; histórico; backup na nuvem; notificações; templates e condições de pagamento salvas; controle de pagamentos.

**Pro+ — R$ 24,90 a R$ 29,90/mês**
- Orçamento por voz (IA); análise de orçamento; controle financeiro; relatórios; acompanhamento de lucro; recursos avançados.

**Por que o paywall não é por volume.** A estratégia de aquisição deste plano (Seção 12) é boca a boca: o orçamento compartilhado no WhatsApp carrega a marca do app. Ou seja, **cada PDF gerado por um usuário gratuito é uma peça de marketing sem custo** — limitar a 5 orçamentos/mês seria limitar o próprio canal de aquisição. Além disso, um teto de volume bate exatamente quando o profissional está virando usuário habitual, que é o momento em que mais se quer retê-lo (o risco nº 2 desta Seção 12 é justamente baixa retenção).

O paywall proposto converte pelo que o **cliente do usuário vê** — a logo dele no orçamento, o documento sem marca de terceiro. Isso vende orgulho profissional, e não escassez artificial, que em app de utilidade produz desinstalação em vez de upgrade.

**Por que não há anúncios.** Com a base inicial esperada (centenas a poucos milhares de usuários), a receita de AdMob seria da ordem de dezenas de reais por mês — irrelevante frente ao custo: experiência pior para um público de baixa tolerância digital, um módulo inteiro no caminho crítico do desenvolvimento, complexidade adicional no formulário de Segurança de Dados da Play Store, e risco direto contra a retenção. "Sem anúncios" passa a ser diferencial explícito na ficha da loja. A decisão é reavaliável quando houver base que torne a receita não-trivial.

**Evidência de disposição a pagar:** o concorrente Prummo já pratica um plano Plus de R$ 39,90/mês com recursos de gestão e automação, indicando que o mercado aceita assinatura nessa faixa de preço para recursos avançados.

> Nota: os valores acima refletem a hipótese inicial do fundador com base na pesquisa de concorrência. Recomenda-se validar sensibilidade de preço com os primeiros usuários reais antes de travar o pricing definitivo (ver Seção 13).
>
> **Reality check de escala:** a R$ 14,90/mês, com taxa de conversão freemium típica de 1–3%, são necessários da ordem de 5.000 a 10.000 usuários ativos para uma receita de poucos milhares de reais por mês. Isso reforça que o objetivo do primeiro ciclo é **validação e retenção**, não receita — como já afirma a Seção 14.

---

## 8. Arquitetura e Tecnologia — Obrion Core

Em vez de reconstruir autenticação, banco de dados, analytics, anúncios, assinaturas, notificações, tema e componentes de UI a cada novo aplicativo, a RACTECH constrói uma base técnica única e reutilizável — o **Obrion Core** — documentada em detalhe em dois arquivos complementares a este plano:

- `APP_FACTORY_RULES.md` — arquitetura, stack, padrões de código, banco de dados, autenticação, monetização, analytics, design system, segurança, LGPD, publicação e testes.
- `APP_FACTORY_CORE.md` — catálogo dos módulos reutilizáveis do Core, para consulta direta por qualquer IA de programação usada no desenvolvimento.

Stack resumida: **Flutter** (front-end, Android primeiro), **Drift/SQLite** (banco local — fonte da verdade, para funcionar sem sinal no canteiro), **Supabase** (backend/BaaS: autenticação, PostgreSQL, storage — como destino de backup e sincronização, não como dependência de execução), **Firebase Analytics** (eventos de produto e funil), **Firebase Crashlytics** (relatório de falhas), **Firebase Remote Config** (limites e flags sem release na loja), **Google Play Billing** (assinaturas, com avaliação futura de RevenueCat) e **Firebase Cloud Messaging** (notificações). Sem AdMob (ver Seção 7).

Essa arquitetura tem dois efeitos diretos no negócio: (1) reduz o custo e o tempo de desenvolvimento de cada app subsequente, já que ~80% da infraestrutura já existe; e (2) permite que instruções para IA de programação sejam objetivas e reutilizáveis ("use o Core e construa o módulo X"), em vez de recomeçar do zero a cada produto.

---

## 9. Roadmap de Desenvolvimento

> **Revisão de 21/08/2026:** o roadmap original construía o Core completo (4 sprints de infraestrutura) antes de qualquer usuário — o que contradizia dois princípios do próprio projeto ("primeiro produto pequeno, depois plataforma" e "dado antes de opinião") e projetava abstrações para quatro apps que ainda não existem. A sequência abaixo inverte isso: **valor primeiro, infraestrutura conforme comprovadamente necessária**. A disciplina de camadas é mantida; o Core passa a ser **extraído** durante o App #2, não especulado antes do App #1. Ver R1 em `ANALISE_E_MELHORIAS.md`.

**Fase 0 — Fundação mínima** (1 sprint)
- Projeto Flutter, navegação, tokens de tema, os componentes de UI que o App #1 realmente usa, banco local (Drift), Crashlytics.

**Fase 1 — O fluxo que vale dinheiro** (3–4 sprints) — *tudo local: sem conta, sem nuvem, sem billing*
- Clientes (criar, editar, excluir, pesquisar).
- Medição (ambientes, dimensões, vãos, grandezas derivadas).
- Lista de preços pessoal (serviços, unidade, preço padrão do profissional).
- Orçamento (serviços, quantidade, unidade, preço, desconto, mão de obra, material, status).
- Geração de PDF (logo, dados do profissional, cliente, serviços, total, condições, validade).
- Compartilhamento (folha do sistema → WhatsApp/e-mail; PDF e imagem).

**Fase 1.5 — Polimento interno** (revisão de 23/08/2026, sem prazo fixo)
- UI/UX, features adicionais e uma tela de login/perfil (só interface, sem Supabase — ver `../CLAUDE.md`, decisão 5) construídas e testadas só pelo fundador, antes de qualquer instalação externa.
- Distribuição passa a ser por patch OTA (Shorebird) em vez de reinstalar um APK a cada mudança — ver `../CLAUDE.md`, decisão 6.

**★ Validação** — antes de qualquer nuvem ou monetização
- 3 a 5 profissionais do público-alvo usando o app de verdade. É aqui que se descobre se a medição confunde, se o orçamento contém o que o cliente final precisa para aceitar, e se o preço faz sentido.

**Fase 2 — Conta e nuvem** (1–2 sprints)
- Supabase, login anônimo vinculado a e-mail, sincronização, backup, gerenciamento de conta, política de privacidade.

**Fase 3 — Monetização** (1 sprint)
- Google Play Billing, tela Premium, ativação dos benefícios Pro (logo, PDF sem marca, histórico, backup, controle de pagamentos). Sem anúncios.

**Fase 4 — Publicação e leitura de dados**
- Publicação na Play Store. Sem adição imediata de novas funcionalidades — priorizar coleta e leitura de dados de uso antes de expandir escopo.

**★ Extração do Core** — ao construir o Obrion Materiais (App #2)
- Extrair para o Core o que comprovadamente repetiu entre os dois apps. O Core passa a ser um resultado medido, não uma hipótese.

**Ganho da inversão:** o produto chega na frente de usuários reais por volta da metade do caminho do plano original — e todo o resto passa a ser decidido com dado, conforme o princípio nº 4 do projeto.

**Fora do escopo do MVP (deliberadamente adiado):** equipe, cronograma, estoque, fornecedores, financeiro completo, emissão fiscal, marketplace, IA complexa, chat, integração bancária, mapa, assinatura digital avançada, ERP, versão desktop.

---

## 10. Métricas de Sucesso (KPIs)

**Funil de produto a instrumentar desde o dia 1:**

Instalou → Abriu → Começou orçamento → Criou orçamento → Gerou PDF → Compartilhou → Criou conta → Voltou → Assinou.

**Indicadores por categoria:**

- **Aquisição:** downloads, origem do tráfego, custo por instalação.
- **Produto:** usuários ativos, orçamentos criados, usuários recorrentes, tempo até o primeiro orçamento.
- **Monetização:** visualizações de anúncio, receita de anúncios, taxa de conversão para Premium, receita por usuário (ARPU).
- **Retenção:** D1, D7 e D30 — o indicador mais crítico do primeiro mês. Um usuário que cria um orçamento e nunca mais retorna sinaliza problema de proposta de valor; retorno semanal indica produto com tração real.

---

## 11. Visão de Portfólio — Próximos Produtos

A validação do Obrion Orçamentos é o gatilho para expandir o portfólio, sempre reaproveitando o Obrion Core:

| Ordem | Produto | Problema central | Reuso do Core |
|---|---|---|---|
| #2 | **Obrion Materiais** — controle de materiais / lista de compra | "O que preciso comprar para essa obra?" | Login, clientes, obras, banco, analytics, monetização, UI, PDF, notificações — quase sem desenvolvimento novo |
| #3 | **Obrion Diário** — diário de obra simplificado | Registro de ocorrências por voz, com fotos, localização, equipe e clima; geração de RDO em PDF | Idem acima + módulo de voz (compartilhado futuramente com Pro+ do Obrion Orçamentos) |
| #4 | **Obrion Medições** — controle de medição do empreiteiro | "Quanto executei e quanto tenho a receber?" (contrato, executado, recebido, saldo) | Idem acima; primeiro produto com apelo B2B mais forte |
| #5 | **Obrion Calculadora** — calculadoras especializadas de construção | Concreto, alvenaria, pintura, piso, telhado, aço — nichadas em vez de genéricas | Reaproveita Core; entra no mercado já validado, mas de forma segmentada |

Após alguns meses, esses produtos formam uma família de apps compartilhando usuário, login, perfil, assinatura, banco, analytics, notificações, componentes e design — reduzindo o custo marginal de cada novo lançamento.

---

## 12. Análise de Riscos

| Risco | Descrição | Mitigação |
|---|---|---|
| Concorrência em orçamento/gestão | Vários apps já oferecem orçamento + PDF + WhatsApp | Diferenciação por velocidade extrema ("3 minutos") e simplicidade de escopo, não por lista de features |
| Baixa retenção | Profissional cria 1 orçamento e não volta | **Mecanismos, não só medição:** (a) lista de preços pessoal — o 2º orçamento leva 30s em vez de 3min; (b) status do orçamento (enviado → aceito → recusado), que dá motivo para voltar e alimenta a notificação de acompanhamento; (c) duplicar orçamento anterior. Acompanhar D1/D7/D30 para calibrar — medir é diagnóstico, não tratamento |
| Adoção lenta por público pouco digitalizado | Público-alvo pode ter baixa familiaridade com apps | Fluxo de 5 telas, sem login obrigatório, linguagem simples, foco total em reduzir fricção |
| Dependência de canal único (Play Store/orgânico) | Custo de aquisição pode inviabilizar crescimento | Explorar indicação boca a boca (o próprio orçamento compartilhado via WhatsApp carrega a marca do app) antes de investir em mídia paga |
| Complexidade prematura | Tentação de adicionar features de gestão completa cedo demais | Lista explícita do que fica de fora do MVP (Seção 9); revisão de escopo só após dados de retenção |
| Monetização insuficiente com anúncios | Anúncio em excesso prejudica experiência e retenção | Política de anúncio comedida (nunca no meio de uma tarefa); foco maior em conversão Pro do que em receita de ad |

---

## 13. Investimento e Recursos Necessários

Este plano nasce de uma pesquisa de mercado e de uma decisão de escopo — os itens abaixo precisam de definição em uma próxima rodada de planejamento antes da execução:

- **Equipe:** quem desenvolve (interno, freelancer, ou desenvolvimento assistido por IA conduzido pelo próprio fundador), e quem valida/testa com usuários reais.
- **Orçamento de ferramentas:** custos de Supabase, Firebase, contas de desenvolvedor (Google Play), eventuais licenças de bibliotecas de PDF.
- **Orçamento de aquisição:** valor reservado (se houver) para testes de mídia paga após a validação orgânica inicial.
- **Prazo-alvo:** data desejada para a Fase 3 (publicação) — a definir com base na capacidade real de desenvolvimento.
- **Registro da marca Obrion:** busca formal de anterioridade no INPI (busca.inpi.gov.br/pePI), registro de domínio (obrion.com.br e obrion.app) e reserva dos perfis de redes sociais (@obrion) antes do lançamento público — a checagem informal feita nesta fase não substitui a confirmação oficial, especialmente pela semelhança fonética identificada com a marca internacional "Château Haut-Brion".

*(Campos deixados em aberto propositalmente — preencher antes de considerar este plano "fechado" para execução.)*

---

## 14. Meta Inicial e Critério de Validação

**Meta concreta do primeiro ciclo:** colocar o Obrion Orçamentos funcional na Play Store e medir, com dados reais, se as pessoas o utilizam — antes de qualquer expectativa de receita relevante.

**Definição de sucesso do MVP** (sugestão, a calibrar):
- Usuários conseguem completar o fluxo completo (medir → orçar → gerar PDF → compartilhar) sem suporte manual.
- Retenção D7 mostra parcela relevante de usuários voltando para criar um segundo orçamento.
- Ao menos uma fração dos usuários ativos considera pagar pelo plano Pro (sinal de disposição a pagar, mesmo antes de otimizar conversão).

Se esses sinais aparecerem, avança-se para o Obrion Materiais reaproveitando o Core. Se não aparecerem, o aprendizado (via analytics e conversas diretas com os usuários) direciona um pivô de nicho antes de investir mais desenvolvimento.

---

## 15. Próximos Passos

1. Fazer a busca formal de anterioridade da marca **Obrion** no INPI e, se confirmada a viabilidade, registrar domínio e perfis sociais. ✅ Busca do nome na Google Play e App Store já feita (21/08/2026), sem conflito. **O `applicationId`/bundle id já foi fixado** (21/08/2026): `br.com.ractech.obrion.<app>` — ver tabela completa em `APP_FACTORY_CORE.md` §13 e `../CLAUDE.md`. Ele é imutável após a primeira publicação.
2. **Validação de custo zero, em paralelo ao desenvolvimento** (não depois dele):
   - Protótipo em papel ou telas estáticas das 5 telas na frente de 3 pedreiros. Se a tela de medição confundir, isso se descobre hoje de graça, e não depois de meses de código.
   - **MVP de concierge:** o fundador faz manualmente, por WhatsApp, "medição → orçamento em PDF" para 3 profissionais. Em uma semana se aprende o que um orçamento precisa conter para o cliente final aceitar — conhecimento que nenhum dos documentos do projeto tem hoje.
   - Perguntar sobre preço antes de fixá-lo: os valores da Seção 7 são hipótese. Três conversas resolvem melhor que três meses de código.
3. Validar/ajustar os campos em aberto da Seção 13 (equipe, orçamento, prazo).
4. Iniciar a Fase 0 (fundação mínima) seguindo `../CLAUDE.md`, `APP_FACTORY_RULES.md` e `APP_FACTORY_CORE.md`.
5. Recrutar 3 a 5 profissionais do público-alvo para testes guiados ao fim da Fase 1 — antes de investir em nuvem e monetização.
6. Publicar o Obrion Orçamentos e acompanhar o funil/retenção por pelo menos 30 dias antes de decidir o próximo passo do portfólio.

> O princípio nº 4 do projeto é "dado antes de opinião". Hoje o plano inteiro é opinião bem estruturada — o que é normal nesta fase, desde que o primeiro dado venha antes do primeiro grande gasto de tempo.

---

## Documentos relacionados

- `../CLAUDE.md` — guia operacional para IA de programação: regras de engenharia, roadmap vigente e decisões tomadas.
- `ANALISE_E_MELHORIAS.md` — análise crítica deste plano: riscos, lacunas e correções que originaram a revisão de 21/08/2026.
- `APP_FACTORY_RULES.md` — regras técnicas, padrões e stack.
- `APP_FACTORY_CORE.md` — catálogo de módulos reutilizáveis do Core.

---

# 4. docs/APP_FACTORY_RULES.md

# APP_FACTORY_RULES.md

> Documento mestre de regras e padrões da **RACTECH**, empresa por trás da marca **Obrion** — a família de apps para profissionais da construção civil.
> Objetivo: ser a referência única que qualquer desenvolvedor (humano ou IA) consulta antes de tocar em código. Toda IA de programação usada no projeto deve ler este arquivo — e o `APP_FACTORY_CORE.md` — antes de gerar qualquer módulo novo.
>
> Versão: 0.3 — Data: 2026-08-21 (revisão pós-análise: roadmap resequenciado, paywall por recurso, AdMob adiado — ver `ANALISE_E_MELHORIAS.md`)
> Escopo: válido para o **Obrion Core** (infraestrutura técnica reutilizável, internamente chamada "App Factory Core") e para todos os apps construídos sobre ele — **Obrion Orçamentos** (App #1 — Orçamento + Medição) e os seguintes.
>
> Nomenclatura da linha: **Obrion** (marca-mãe) → Obrion Orçamentos, Obrion Materiais, Obrion Diário, Obrion Medições, Obrion Calculadora.

---

## 1. Princípios do projeto

1. **Não recriar infraestrutura em cada app.** Autenticação, banco, analytics, assinatura, notificações, tema e componentes de UI vivem no Core e são apenas *consumidos* pelos apps.
   > **Revisão v0.3:** o Core é **extraído**, não especulado. O App #1 é construído inteiro primeiro, em camadas limpas; o Core nasce da extração durante o App #2, com base no que comprovadamente repetiu. Abstração reutilizável não se projeta a partir de zero produtos — ver R1 em `ANALISE_E_MELHORIAS.md`.
2. **Primeiro produto pequeno, depois plataforma.** Nenhum app novo deve nascer como "sistema completo". Deve resolver uma dor específica em poucos minutos de uso. Isso vale também para a plataforma em si: nada de infraestrutura genérica antes de um produto validado.
3. **IA não é feature de lançamento.** Todo app nasce funcional sem IA. Recursos de IA (ex.: orçamento por voz) entram depois, como diferencial Premium, quando o produto já validou a dor principal.
4. **Dado antes de opinião.** Toda decisão de "o que construir a seguir" deve se apoiar em métricas de funil e retenção (D1/D7/D30), não em achismo interno.
5. **Fricção mínima de entrada.** Login nunca é obrigatório no primeiro uso. O usuário deve conseguir usar o valor central do app (ex.: criar um orçamento) antes de qualquer barreira de cadastro.
6. **Consistência de marca por tema, não por tela.** Cores, tipografia e espaçamento são centralizados em tokens de tema — nunca hardcoded em componentes de tela.

---

## 2. Arquitetura

```
OBRION
│
├── Core (Obrion Core)  ← extraído durante o App #2, não construído antes do App #1
│   ├── Authentication
│   ├── Database          (local Drift = fonte da verdade; Supabase = backup/sync)
│   ├── Analytics
│   ├── CrashReporting    (novo v0.3 — Crashlytics)
│   ├── RemoteConfig      (novo v0.3 — limites e flags sem release na loja)
│   ├── AppUpdate         (novo v0.3 — atualização forçada/recomendada)
│   ├── Review            (novo v0.3 — in_app_review no momento de sucesso)
│   ├── Connectivity      (novo v0.3 — estado da conexão para a UI local-first)
│   ├── Purchases
│   ├── Subscriptions
│   ├── Notifications
│   ├── Settings
│   ├── Theme
│   └── UI Components
│
├── Design System
│   ├── Buttons, Cards, Inputs, Dialogs
│   ├── Bottom Sheets, Navigation
│   └── Empty States, Loading States
│
├── User
│   ├── Profile
│   ├── Preferences
│   └── Subscription
│
└── App (camada específica de cada produto)
    └── Obrion Orçamentos (App #1: Orçamento + Medição)
        ├── Clientes
        ├── Obras
        ├── Medições
        ├── Orçamentos
        └── PDF
```

**Regra de dependência:** a camada `App` pode depender do `Core` e do `Design System`. O `Core` nunca depende de nada da camada `App`. Isso é o que garante que o Obrion Core seja reaproveitado em Obrion Materiais, Obrion Diário, Obrion Medições... sem refatoração.

Quando um novo app for criado, a IA deve:
1. Importar o Core existente sem modificá-lo (salvo bugfix ou extensão genérica aprovada).
2. Criar apenas a camada `App/<nome-do-app>` com os módulos específicos daquele produto.
3. Reaproveitar todos os componentes do Design System antes de criar um novo.

---

## 3. Stack tecnológica

| Camada | Tecnologia | Motivo |
|---|---|---|
| Front-end | **Flutter** | Um único código para Android e iOS; Android primeiro, iOS depois sem reescrever. |
| **Banco local** | **Drift / SQLite** | **Fonte da verdade.** O app precisa funcionar sem sinal no canteiro — toda leitura e escrita da UI é local e instantânea. |
| Backend / BaaS | **Supabase** | Autenticação, PostgreSQL, storage, RLS. **Destino de backup e sincronização, não dependência de execução** — nenhuma tela pode travar esperando rede. |
| Analytics | **Firebase Analytics** | Eventos de funil e produto (ver seção 7). |
| **Crash reporting** | **Firebase Crashlytics** | Para um dev solo, saber que o app quebrou vale mais que analytics. Sem isso, bugs são descobertos por avaliação 1 estrela. |
| **Feature flags** | **Firebase Remote Config** | Permite mudar regra de negócio (limites, flags) sem release na loja. Uma constante em Dart não é "um único lugar" — é uma atualização com dias de rollout. |
| ~~Anúncios~~ | ~~Google AdMob~~ | **Cortado do MVP** — ver seção 5. |
| Assinaturas | **Google Play Billing** (fase inicial) → avaliar **RevenueCat** quando o número de apps crescer | Simplicidade inicial; RevenueCat reduz retrabalho quando houver múltiplos apps/assinaturas. |
| Notificações | **Firebase Cloud Messaging (FCM)** | Lembretes transacionais (cobrança, vencimento, orçamento parado). |
| Geração de PDF | Biblioteca Flutter de PDF (ex.: `pdf` + `printing`) | Orçamento e RDO exportáveis. Também usada para exportar como **imagem** (PNG) — muitos clientes finais abrem imagem no WhatsApp e ignoram PDF. |
| Compartilhamento | `share_plus` (folha de compartilhamento do sistema) | Canal de entrega ao cliente final. **Atenção:** `wa.me/<telefone>?text=` pré-preenche texto mas **não anexa arquivo** — anexar o PDF exige a folha do sistema. |

### Convenção de idioma no código

- Identificadores (classes, métodos, campos, tabelas, eventos) **sempre em inglês**: `startAnonymousSession()`, `signUp()`, `signIn()`, `upgrade(plan)`, `trackEvent(name, params)`.
- Texto visível ao usuário **em português**, centralizado em arquivo de tradução desde o dia 1 (iOS e expansão estão no roadmap). Nunca string de UI hardcoded no widget.

### Dinheiro é `int` em centavos — nunca `double`

Ponto flutuante quebra soma de dinheiro (`0.1 + 0.2 != 0.3`). Num app cuja função é cotar preços, isso gera orçamento cujo total não bate com a soma dos itens — e a credibilidade do profissional com o cliente dele vai junto. Todo valor monetário é `int` em centavos, do banco à tela; formatação para R$ só na borda de apresentação; `quantidade × preço_unitário` arredonda ao centavo, meio para cima, com teste unitário. Medidas (m², m³) continuam `double`.

---

## 4. Banco de dados (schema inicial — Obrion Orçamentos)

```
users
 ├── profiles
 ├── clients
 ├── projects
 ├── measurements
 ├── budgets
 ├── budget_items
 ├── payments
 ├── services
 ├── materials
 ├── subscriptions
 └── app_settings
```

Diretrizes:
- Todo dado de negócio é vinculado a `user_id` com Row Level Security (RLS) no Supabase — cada usuário só enxerga seus próprios dados.
- Tabelas pensadas para reuso: `clients`, `projects`, `payments` e `subscriptions` devem servir sem alteração de schema para Obrion Materiais, Obrion Diário e Obrion Medições.
- `budgets` e `budget_items` são específicos do Obrion Orçamentos, mas seguem convenção de nomes que os próximos apps devem espelhar (`<entidade>` + `<entidade>_items` para itens de linha).
- **Todo registro carrega** `id` (UUID gerado no cliente), `updated_at` e `deleted_at` (exclusão lógica, para propagar remoção na sincronização).

### `measurements` — guardar geometria bruta, não "a área"

Cada ofício mede coisa diferente **do mesmo cômodo**: pintor cobra m² de parede menos vãos; azulejista, m² de chão; gesseiro, m² de teto; rodapé é metro linear; contrapiso é m³; eletricista conta pontos. Guardar um único campo `area` faz o app servir apenas para pintura — e o público-alvo tem sete ofícios.

O ambiente armazena **comprimento, largura, altura e a lista de vãos** (portas/janelas com dimensões). As grandezas são **derivadas** sob demanda:

```
area_piso      = comprimento × largura
area_teto      = comprimento × largura
perimetro      = 2 × (comprimento + largura)
area_parede    = perimetro × altura − Σ(vãos)
perimetro_util = perimetro − Σ(largura das portas)
volume         = area_piso × espessura
```

Cada item do orçamento escolhe **qual grandeza** consumir, conforme a unidade do serviço. Decisão de modelagem de ~1 dia agora; reescrita de semanas depois.

### `services` — a lista de preços pessoal (funcionalidade central, não detalhe)

A promessa é "orçamento em 3 minutos". Se a cada orçamento o profissional redigita o preço do m² de reboco, o segundo orçamento demora tanto quanto o primeiro — e não há motivo para voltar ao app. Com lista de preços salva: orçamento nº 1 leva 3 minutos (cadastra enquanto usa), orçamento nº 2 leva **30 segundos**.

Isso ataca de uma vez as três fragilidades do plano: a promessa de velocidade, a retenção D7/D30 e o fosso competitivo (os preços dele moram no app — é o maior custo de troca disponível).

```
service
├── name                "Reboco de parede"
├── unit                m² | m | un | ponto | diária | verba
├── default_price_cents int
├── includes_material   bool
└── default_note        texto reaproveitado no orçamento
```

Pré-carregar lista sugerida por ofício (pedreiro, pintor, gesseiro, azulejista, eletricista, encanador) com a unidade correta e **preço em branco**. **Nunca sugerir valores de preço** — preço é regional, e errar destrói credibilidade com este público.

### `budgets` — status como mecanismo de retenção

`status`: `rascunho → enviado → aceito → recusado`, atualizável em um toque. Dá motivo estrutural para reabrir o app ("o cliente respondeu?"), alimenta a notificação já prevista no Core ("orçamento aguardando resposta há 3 dias"), gera taxa de fechamento como dado de produto, e é a semente natural do "controle de pagamentos" vendido no plano Pro. Baixa retenção é o risco nº 2 do projeto, e medir D1/D7/D30 é medição — não mitigação.

---

## 5. Monetização

Modelo: **Freemium com paywall por recurso, não por volume** (revisão v0.3 — ver R2 em `ANALISE_E_MELHORIAS.md`).

**Racional da mudança:** a estratégia de aquisição declarada na Seção 12 do plano de negócio é boca a boca via PDF compartilhado no WhatsApp carregando a marca do app. Logo, **cada PDF gerado por um usuário Free é uma peça de marketing gratuita** — limitar o volume limita o próprio canal de aquisição. Além disso, um teto de 5 orçamentos/mês bate exatamente quando o usuário está virando habitual, que é o momento em que mais se quer retê-lo.

**Free**
- Clientes, medições e orçamentos **ilimitados**; lista de preços pessoal completa; fluxo completo medir → orçar → enviar; PDF com rodapé "Feito com Obrion"; **sem anúncios**.

**Pro** — ~R$ 14,90/mês ou R$ 99,90/ano
- Logo própria no PDF, PDF sem a marca do app, histórico e backup na nuvem, templates e condições de pagamento salvas, controle de pagamentos, notificações.

**Pro+** — ~R$ 24,90–29,90/mês
- IA por voz, análise de orçamento, controle financeiro, relatórios, acompanhamento de lucro, recursos avançados.

O paywall converte por **orgulho profissional** — o PDF é o que o cliente do usuário vê — e não por escassez artificial, que em app de utilidade gera desinstalação, não upgrade.

Se algum teto for necessário para controlar custo de infraestrutura, usar valor que o uso normal nunca encosta (~30 orçamentos/mês) e configurável por Remote Config, nunca 5.

**Anúncios: cortados do MVP** (revisão v0.3 — ver R3 na análise). Com base inicial de centenas a poucos milhares de usuários, a receita de AdMob é ruído (dezenas de reais/mês), enquanto o custo é real: pior experiência para um público de baixa tolerância digital, um módulo inteiro no caminho crítico, complexidade no formulário de Segurança de Dados da Play Store e risco direto contra a retenção — a métrica que este documento chama de mais crítica. "Sem anúncios" passa a ser diferencial explícito na ficha da loja. Reavaliar apenas quando houver base de usuários que torne a receita não-trivial.

---

## 6. Autenticação

- **Login nunca é a primeira tela.** Fluxo: `Começar agora → usuário cria 1 orçamento sem conta → convite para criar conta gratuita ("salvar em outro celular")`.
- Conta gratuita via Supabase Auth (e-mail/senha e, se possível, login social simplificado).
- **A identidade do usuário nunca muda.** Usar **login anônimo do Supabase**, depois vinculado a um e-mail — o `user_id` permanece o mesmo do primeiro segundo ao cadastro.

  Isso **elimina a rotina de migração de dados** descrita na v0.2: não existe "migrar dados locais para a conta", existe apenas vincular identidade. Consequências: o RLS funciona desde o início sem caminho especial para "dados sem dono", e o risco de perda de dados no momento mais sensível da vida do usuário desaparece. Uma rotina de migração de uso único, difícil de testar, era a forma mais provável de quebrar a promessa "nunca perdidos".

  **Ressalva:** login anônimo exige rede no primeiro uso. Se o primeiro uso for offline (plausível no canteiro), gerar o UUID localmente e criar o usuário remoto na primeira conexão **mantendo o mesmo id**.

---

## 7. Analytics — eventos mínimos obrigatórios

Todo app novo nasce instrumentado com, no mínimo:

```
app_open
signup
create_budget (início)
budget_created (conclusão)
budget_shared          → parâmetro obrigatório: channel (whatsapp|email|outro)
pdf_generated          → parâmetro obrigatório: format (pdf|imagem)
subscription_started
premium_screen_view
```

Acrescentados na v0.3 — cobrem degraus do funil que a lista original deixava invisíveis:

```
measurement_started / measurement_completed
    A medição é a tela mais complexa do app — o ponto de abandono mais
    provável, e hoje o funil não o enxerga.

upgrade_blocked(limit, origin)
    O evento de monetização mais valioso que existe: diz QUAL limite
    realmente empurra para o upgrade. Sem ele, o pricing é chute.

subscription_cancelled / subscription_renewed
    subscription_started sozinho mostra só a metade boa — não há visão de churn.

price_list_item_created
    Mede a adoção do fosso competitivo (lista de preços pessoal).

budget_duplicated
    Mede reuso — o principal sinal de retenção real.
```

`budget_shared` sem o parâmetro `channel` torna impossível validar a hipótese central de distribuição do projeto (boca a boca via WhatsApp). `ad_view` foi removido junto com o AdMob (seção 5).

Funil de referência a ser acompanhado desde o dia 1:

```
Instalou → Abriu → Começou orçamento → Criou orçamento →
Gerou PDF → Compartilhou → Criou conta → Voltou → Assinou
```

Métricas de acompanhamento contínuo: aquisição (downloads, origem, CPI), produto (usuários ativos, orçamentos criados, recorrência, tempo até 1º orçamento), monetização (views de anúncio, receita de anúncio, conversão Premium, ARPU) e retenção (D1, D7, D30).

---

## 8. Design System

Componentes obrigatórios do Core (não recriar por app):

```
AppButton, AppTextField, AppCard, AppDialog, AppBottomSheet,
AppHeader, AppEmptyState, AppLoading, AppError,
AppCurrencyInput, AppNumberInput, AppDatePicker,
AppPremiumBadge, AppAdContainer, AppSubscriptionCard
```

Regra para a IA: ao construir uma tela nova, primeiro verificar se o componente já existe no Design System. Só criar um componente novo se genuinamente não houver equivalente — e, nesse caso, adicioná-lo ao Core (não deixá-lo local ao app).

---

## 9. Tema

- Suporte a **Light** e **Dark** desde o primeiro dia.
- Cores centralizadas em tokens: `primary`, `secondary`, `background`, `surface`, `text`, `error`, `success`, `warning`.
- Nenhuma tela deve referenciar valores de cor "soltos" (hex direto). Sempre via token de tema — isso permite trocar a identidade visual de um app inteiro sem tocar nas telas.

---

## 10. Segurança e LGPD

- Row Level Security (RLS) ativo em todas as tabelas do Supabase — nenhum dado de um usuário acessível por outro.
- Dados pessoais de clientes (nome, telefone, endereço de obra) tratados como dados pessoais sob a LGPD: coleta mínima necessária, finalidade explícita, e opção de exclusão de conta com apagamento de dados.
- **Dado pessoal de terceiro (acrescentado na v0.3).** O app armazena dados de pessoas que **nunca aceitaram nada com a RACTECH**: os clientes do profissional. Juridicamente, o profissional é o **controlador** desses dados e a RACTECH é a **operadora**. Implicações práticas:
  - A política de privacidade precisa descrever explicitamente essa relação, não apenas a relação com o usuário do app.
  - A exclusão de conta precisa **cascatear** para os registros de clientes.
  - O PDF gerado contém dado pessoal de terceiro e circula por WhatsApp — cabe uma linha nos termos sobre a responsabilidade do usuário nesse envio.
- Política de privacidade e termos de uso publicados antes do lançamento na Play Store.
- Backups (recurso Pro) criptografados em trânsito e em repouso (padrão Supabase Storage).
- Nenhuma credencial ou chave de API deve ser versionada em texto puro no repositório — usar variáveis de ambiente/secrets.

---

## 11. Publicação (Play Store)

Checklist mínimo antes de publicar qualquer app da família Obrion:
- ⚠️ **`applicationId`/bundle id fixado antes do primeiro build** — ele é **imutável após a primeira publicação**, errar significa perder o app e a base de usuários. Convenção definitiva da família (decidida em 21/08/2026): `br.com.ractech.obrion.<app>` — `orcamentos`, `materiais`, `diario`, `medicoes`, `calculadora`. Mesmo valor em Android e iOS. Ver `../CLAUDE.md`, seção "Identidade visual da família", para a tabela completa.
- ✅ Busca do nome na **Google Play e App Store** feita em 21/08/2026, sem conflito encontrado.
- ✅ Busca formal de anterioridade no INPI feita em 23/08/2026: existe marca "Obrion" registrada, mas na classe farmacêutica — classe diferente da de software, o que reduz mas não elimina o risco de colidência. **Confirmar com advogado de PI antes da Fase 4** (ver detalhe em `ANALISE_E_MELHORIAS.md`, seção C2).
- Política de privacidade pública e vinculada na ficha da loja, cobrindo o dado pessoal de terceiro (seção 10).
- Formulário de Segurança de Dados preenchido corretamente.
- "Sem anúncios" destacado na descrição da ficha — é diferencial frente aos concorrentes (seção 5).
- Testes internos com pelo menos 3 usuários reais do público-alvo (pedreiro, pintor, pequeno empreiteiro) antes do lançamento público.
- Nome, ícone e descrição focados na dor específica do app (ex.: "Obrion Orçamentos — orçamento em 3 minutos"), não em "gestão completa de obras".
- Ícone segue a identidade visual compartilhada da família Obrion (mesma base gráfica, cor de destaque própria por app, monograma de duas letras — ver `APP_FACTORY_CORE.md` seção 13).

---

## 12. Testes

Focar no que erra silenciosamente e custa caro:

- **Testes unitários** para: derivação de grandezas da medição (seção 4), cálculo de orçamento (soma de itens, descontos) e **arredondamento monetário** (seção 3).
- **Golden test do PDF** — o teste de maior retorno do projeto. O PDF é o produto que chega ao cliente final; uma quebra de layout é uma quebra de reputação do usuário.
- **CI simples** (GitHub Actions) rodando `flutter analyze` + `flutter test` a cada push. Uma tarde de configuração — e sem ela, com um dev solo, "rodar regressão contra todos os apps" não acontece na prática.
- Teste manual de fluxo completo antes de cada release: criar cliente → medir → gerar orçamento → gerar PDF → compartilhar.
- Testes de regressão sempre que um módulo do Core for alterado, rodando contra **todos** os apps que o consomem (não só o mais recente).

---

## 13. Como a IA deve usar este documento

Ao pedir para a IA construir um novo módulo ou app, o prompt de referência é:

> "Use o OBRION CORE (ver `APP_FACTORY_CORE.md`) e as regras deste documento (`APP_FACTORY_RULES.md`) para construir o módulo X do Obrion <Nome do App>."

A IA **não** deve reinventar autenticação, tema, componentes de UI, monetização ou analytics — apenas consumir o que já existe no Core e implementar a lógica específica do novo módulo.

---

# 5. docs/APP_FACTORY_CORE.md

# APP_FACTORY_CORE.md

> Catálogo dos módulos reutilizáveis do **Obrion Core** (infraestrutura técnica compartilhada por toda a família de apps **Obrion**, da RACTECH).
> Este documento descreve **o que já existe (ou deve existir) pronto para reuso**, para que uma IA de programação nunca precise recriar do zero algo que já faz parte do Core. Ler em conjunto com `APP_FACTORY_RULES.md`.
>
> Estado (atualizado 23/08/2026): a maioria dos módulos abaixo já está implementada dentro do Obrion Orçamentos (`lib/`) — Theme, Database, Analytics, Notifications, Review, AppUpdate, User (perfil), Settings, boa parte do Authentication (login/cadastro só de interface) e Purchases (semente: controle de pagamentos). Ainda não existe um pacote `Core` separado: cada módulo vive como código específico do App #1. Este catálogo continua sendo o **alvo da extração** (ver nota abaixo) — o trabalho que falta é mover o que já funciona pra um pacote compartilhado durante o App #2, não implementar do zero.
>
> ⚠️ **Revisão de 21/08/2026 — o Core é extraído, não construído antes.** O App #1 (Obrion Orçamentos) é construído inteiro primeiro, em camadas limpas; este catálogo passa a ser o **alvo da extração** durante a construção do App #2, não uma fase prévia de desenvolvimento. Abstração reutilizável não se projeta a partir de zero produtos. Ver R1 em `ANALISE_E_MELHORIAS.md` e o roadmap revisado no plano de negócio.
>
> **Convenção de idioma (v0.3):** identificadores de código sempre em **inglês**; português apenas em texto visível ao usuário, centralizado em arquivo de tradução. Os nomes em português usados abaixo na versão original foram substituídos.
>
> Nomenclatura da linha: **Obrion** (marca-mãe) → Obrion Orçamentos (App #1), Obrion Materiais (App #2), Obrion Diário (App #3), Obrion Medições (App #4), Obrion Calculadora (App #5).

---

## Como ler este documento

Cada módulo abaixo tem: **responsabilidade**, **o que expõe para os apps** (interface conceitual) e **o que um app nunca deve fazer** (para evitar duplicação/vazamento de responsabilidade).

---

## 1. Authentication

**Responsabilidade:** cadastro, login, sessão, recuperação de senha, modo anônimo/local.

**Expõe para os apps:**
- Estado atual do usuário (anônimo, logado free, logado pro).
- `startAnonymousSession()` — permite uso sem conta, via **login anônimo do Supabase**.
- `signUp()` / `signIn()` — **vincula** a sessão anônima a um e-mail.
- Evento `onAuthStateChanged` para telas reagirem (ex.: mostrar/esconder convite de cadastro).

**Decisão-chave:** o `user_id` **nunca muda**, do primeiro segundo ao cadastro. Não existe "migrar dados locais para a conta" — existe apenas vincular identidade. Isso elimina uma rotina de uso único, difícil de testar, que rodaria no momento mais sensível da vida do usuário e era a forma mais provável de quebrar a promessa "dados nunca perdidos".

Se o primeiro uso for offline (plausível no canteiro), gerar o UUID localmente e criar o usuário remoto na primeira conexão, **mantendo o mesmo id**.

**O app nunca deve:** implementar sua própria tela de login do zero ou seu próprio fluxo de sessão.

---

## 2. Database

**Responsabilidade:** banco local como fonte da verdade, sincronização com Supabase, regras de segurança (RLS).

**Expõe para os apps:**
- Camada de repositório genérica (CRUD) para as tabelas comuns: `clients`, `projects`, `payments`, `subscriptions`, `app_settings`.
- Cliente Supabase já autenticado e configurado com RLS.
- Sincronização em segundo plano.

**Arquitetura: local-first, não "offline-first" genérico.** A v0.2 resolvia isso em uma linha ("fila de escrita local → sync quando houver rede"), mas sincronização bidirecional com resolução de conflito é um dos problemas mais difíceis de mobile. **Este produto não precisa do caso difícil:** um orçamento tem um único dono e, na prática, um único dispositivo escrevendo — sem escritores concorrentes, não há conflito real a resolver.

- **O banco local (Drift/SQLite) é a fonte da verdade.** Toda leitura e escrita da UI é local, instantânea, e funciona no subsolo sem sinal.
- O Supabase é **destino de backup e sincronização**, nunca dependência de execução. Nenhuma tela pode travar esperando rede.
- Sincronização por registro com `updated_at`; último a escrever vence. Sem CRDT, sem tela de resolução de conflito.
- Todo registro carrega `id` (UUID gerado no cliente), `updated_at` e `deleted_at` (exclusão lógica, para propagar remoção).

Isso reduz o problema de "meses de engenharia de sincronização" para "dias", sem que o usuário perceba qualquer diferença.

**O app nunca deve:** abrir conexão própria ao banco, falar com o Supabase direto de uma tela, ou duplicar lógica de sincronização.

---

## 3. Analytics

**Responsabilidade:** disparo padronizado de eventos para o Firebase Analytics.

**Expõe para os apps:**
- Função única `trackEvent(name, params)` com os eventos-base já definidos (`app_open`, `signup`, `pdf_generated`, `subscription_started`, etc. — ver `APP_FACTORY_RULES.md` seção 7).
- Cada app adiciona apenas seus eventos específicos (ex.: `budget_created`), seguindo a mesma convenção de nomes (`snake_case`, verbo no particípio para conclusão).
- Eventos com parâmetro obrigatório: `budget_shared(channel)` e `pdf_generated(format)`. Sem `channel`, é impossível validar a hipótese central de distribuição do projeto.

**O app nunca deve:** integrar o SDK do Firebase diretamente nas telas — sempre via essa camada única, para manter consistência entre apps.

---

## 4. ~~Ads (AdMob)~~ — cortado do MVP

**Status: fora de escopo** (decisão de 21/08/2026 — ver R3 em `ANALISE_E_MELHORIAS.md`). Não implementar.

Com a base inicial esperada, a receita de anúncio seria da ordem de dezenas de reais por mês, contra um custo real em retenção, experiência e complexidade regulatória na Play Store. "Sem anúncios" passa a ser diferencial da ficha da loja.

Se um dia voltar, valem as regras originais: componente `AppAdContainer` para banner, `showInterstitial(context)` com regras de frequência centralizadas (nunca no meio de uma tarefa do usuário), flag automática desativando anúncios para Pro/Pro+, e nenhuma chamada ao SDK do AdMob direto da tela.

---

## 5. Purchases / Subscriptions

**Responsabilidade:** integração com Google Play Billing (e futuramente RevenueCat), gestão de planos Free/Pro/Pro+.

**Expõe para os apps:**
- Estado atual do plano do usuário (`free`, `pro`, `pro_plus`).
- Componente `AppSubscriptionCard` e `AppPremiumBadge` para sinalizar recursos bloqueados.
- Função `upgrade(plan)` que abre o fluxo de compra nativo.

**Paywall por recurso, não por volume:** o que é pago é acabamento profissional — logo no PDF, PDF sem a marca do app, histórico, backup, controle de pagamentos. O fluxo central (medir → orçar → enviar) nunca é bloqueado, porque cada PDF gratuito circulando no WhatsApp é aquisição.

**O app nunca deve:** implementar sua própria lógica de checagem "sou premium?" — sempre consultar o estado central. E os limites/flags vêm de **Remote Config**, não de constante em Dart: uma constante compilada não é "um único lugar", é uma atualização na loja com dias de rollout.

---

## 6. Notifications (FCM)

**Responsabilidade:** notificações push locais e remotas.

**Expõe para os apps:**
- Função `scheduleNotification(type, data)` para lembretes (ex.: "cobrar João amanhã", "orçamento aguardando resposta há 3 dias").
- Templates de notificação padronizados por tipo (financeiro, engajamento, transacional).

**O app nunca deve:** implementar canais de notificação próprios fora do padrão do Core.

---

## 6b. Módulos acrescentados na revisão v0.3

Coisas que **todo** app da família vai precisar e que são caras de adicionar depois (ver T5 na análise):

| Módulo | Responsabilidade | Por que é necessário |
|---|---|---|
| **CrashReporting** | Firebase Crashlytics | Não constava de nenhum documento. Para um dev solo, saber que o app quebrou vale mais que analytics — sem isso, bugs são descobertos por avaliação 1 estrela na loja. |
| **RemoteConfig** | Limites do plano, flags de funcionalidade | O módulo Purchases promete mudar regra de negócio "em um único lugar". Uma constante em Dart não é um lugar único: é uma atualização na loja com dias de rollout. |
| **AppUpdate** | Atualização forçada / recomendada | Você vai publicar uma build quebrada em algum momento. Sem esse mecanismo, ela permanece instalada nos aparelhos. |
| **Review** | `in_app_review` no momento de sucesso (logo após compartilhar o PDF) | Forma mais barata de subir a nota na Play Store — e o plano depende de aquisição orgânica. |
| **Connectivity** | Estado da conexão | Necessário para a UI local-first ("salvo no aparelho" / "sincronizado"). |

Os dois primeiros são os mais urgentes.

---

## 7. Settings / App Settings

**Responsabilidade:** preferências do usuário e do app (tema, notificações ligadas/desligadas, unidade de medida, etc.).

**Expõe para os apps:**
- Tela `AppSettingsScreen` base, extensível por seções específicas de cada app.
- Persistência em `app_settings` (Supabase) + cache local.

---

## 8. Theme

**Responsabilidade:** tokens de cor, tipografia e espaçamento; suporte Light/Dark.

**O que é reutilizado entre apps (padrão da fábrica, 23/08/2026) — a arquitetura, não a cor:**
- **Uma seed color por app** (`lib/theme/app_colors.dart`, `obrionSeed`) alimenta `ColorScheme.fromSeed` do Material 3, que deriva toda a paleta (primary/secondary/tertiary/surface, tons claro e escuro) automaticamente. Trocar a identidade visual de um app = trocar **um único valor**, sem tocar em nenhuma tela — nenhum widget referencia cor fora de `app_colors.dart`/`app_theme.dart`.
- **Tokens semânticos** (`success`/`warning`, via `AppSemanticColors extends ThemeExtension`) cobrem o que o `ColorScheme` do Material 3 não modela nativamente. São neutros por natureza (verde/laranja de status), não carregam a marca — reutilizáveis tal como estão em qualquer app da família.
- **Convenções de componente** (`AppTheme._build`): card outlined sem elevação (raio 12), botão com altura mínima 48, input preenchido sem borda visível (raio 8), diálogo com ação destrutiva em vermelho do `colorScheme.error`. Isso é o "jeito Obrion" de qualquer tela, independente da cor de marca.

**O que é específico de cada app — a cor em si, e como escolhê-la:** cada app da família mantém sua própria cor de destaque (ver "Identidade visual da família" em `../CLAUDE.md`). A regra para escolher essa cor, não só para o Orçamentos: **a seed vem do universo visual do ofício daquele app, nunca de preferência estética solta.** Foi assim que o Orçamentos chegou no âmbar de segurança (capacete, colete, cone — o canteiro), em vez do azul corporativo genérico que a maioria dos concorrentes de orçamento de obra usa. Antes de fixar a seed de um novo app, perguntar: qual é o objeto/cor mais característico do ofício desse app, que o profissional já reconhece sem precisar aprender nada novo? Exemplos ilustrativos, a confirmar com a mesma pesquisa de mercado quando cada app for construído (não são decisão fechada): Materiais poderia puxar do concreto/aço do depósito; Diário poderia puxar do azul de planta baixa (aqui o azul faria sentido — é o único ofício da família onde essa cor tem lastro no próprio objeto de trabalho).

---

## 9. UI Components (Design System)

**Responsabilidade:** biblioteca de componentes visuais reutilizáveis.

**Catálogo atual:**

| Componente | Uso |
|---|---|
| `AppButton` | Ação primária/secundária padronizada |
| `AppTextField` | Campo de texto padrão |
| `AppCard` | Contêiner de conteúdo (ex.: card de orçamento, de cliente) |
| `AppDialog` | Confirmações e alertas |
| `AppBottomSheet` | Ações contextuais (ex.: opções de um item) |
| `AppHeader` | Cabeçalho de tela padronizado |
| `AppEmptyState` | Estado vazio (ex.: "nenhum orçamento ainda") |
| `AppLoading` | Indicador de carregamento |
| `AppError` | Estado de erro padronizado |
| `AppCurrencyInput` | Entrada de valores em R$ |
| `AppNumberInput` | Entrada numérica (medidas, quantidades) |
| `AppDatePicker` | Seleção de data |
| `AppPremiumBadge` | Selo de recurso Premium |
| `AppAdContainer` | Espaço reservado para anúncio |
| `AppSubscriptionCard` | Card de plano/assinatura |

**Regra de ouro:** antes de desenhar uma tela nova, a IA deve montá-la combinando estes componentes. Um componente novo só é criado quando genuinamente não há equivalente — e, quando criado, entra no Core (não fica isolado no app).

---

## 10. User (Profile / Preferences / Subscription)

**Responsabilidade:** dados do usuário como pessoa/profissional (nome, telefone, logo do negócio, tipo de serviço) — separado dos dados de negócio específicos do app (clientes, obras, orçamentos).

**Expõe para os apps:**
- Perfil do profissional, usado por exemplo no cabeçalho do PDF de orçamento (logo, nome, telefone).
- Preferências gerais (tema, notificações).
- Estado da assinatura (espelha o módulo Purchases/Subscriptions).

---

## 11. Módulos específicos do Obrion Orçamentos (App #1)

Estes módulos **não** fazem parte do Core — vivem em `App/ObrionOrcamentos` — mas seguem os padrões acima:

- **Clientes:** CRUD de clientes (nome, telefone, endereço da obra).
- **Obras/Projetos:** agrupamento de medições e orçamentos por obra/cliente.
- **Medições:** ambientes com **geometria bruta** (comprimento × largura × altura + lista de vãos). As grandezas — área de piso, área de teto, área de parede menos vãos, perímetro, perímetro útil, volume — são **derivadas**, nunca armazenadas como um único campo `area`. Cada ofício mede coisa diferente do mesmo cômodo (pintor: m² de parede; azulejista: m² de chão; rodapé: metro linear; contrapiso: m³), e um campo único faria o app servir só para pintura. Ver seção 4 de `APP_FACTORY_RULES.md`.
- **Lista de preços (`services`):** os preços do próprio profissional, salvos uma vez e reutilizados. **Funcionalidade central, não detalhe** — é o que faz o segundo orçamento levar 30 segundos em vez de 3 minutos, e é o maior custo de troca disponível ao produto. Pré-carregar sugestões por ofício com a unidade correta e **preço em branco**; nunca sugerir valores (preço é regional).
- **Orçamentos:** serviços, quantidade, unidade, preço, desconto, mão de obra, material, total, e **status** (`rascunho → enviado → aceito → recusado`) como mecanismo de retenção.
- **PDF:** geração do orçamento em PDF com dados do profissional (via módulo User), do cliente, itens, total, condições e validade. Também exportável como **imagem** (PNG da primeira página) — muitos clientes finais abrem imagem no WhatsApp e ignoram PDF. Coberto por **golden test**: o PDF é o que chega ao cliente final, e quebra de layout é quebra de reputação do usuário.

> **Nota sobre "enviar pelo WhatsApp":** `wa.me/<telefone>?text=` abre a conversa com texto pré-preenchido mas **não anexa arquivo**. Anexar o PDF exige a folha de compartilhamento do sistema (`share_plus`), onde o usuário escolhe o app e o contato. Considerar isso ao desenhar a tela final.

Ao construir o Obrion Materiais, Obrion Diário etc., reaproveitar diretamente os módulos **Clientes** e **Obras/Projetos** — ajustando apenas o que for específico de cada novo produto (ex.: lista de compras no Obrion Materiais, RDO por voz no Obrion Diário).

---

## 12. Convenção de prompt para novos módulos

Ao pedir a um assistente de IA para gerar um módulo novo, usar sempre este formato:

```
Contexto: Use o OBRION CORE (APP_FACTORY_CORE.md) e as regras
de APP_FACTORY_RULES.md.

Tarefa: Construir o módulo <nome> do Obrion <Nome do App> (App #<N>).

Reaproveitar: <lista de módulos do Core e componentes de Design System
que já resolvem parte do problema>.

Criar apenas: <o que é genuinamente novo>.
```

Isso reduz o consumo de tokens e o tempo de desenvolvimento, porque a IA não perde tempo reconstruindo o que já existe — e mantém todos os apps da família Obrion visualmente e estruturalmente consistentes.

---

## 13. Identidade visual da família Obrion

Cada app da linha compartilha a mesma linguagem visual (base do ícone, tipografia, forma) e se diferencia por cor de destaque e um monograma de duas letras — o mesmo princípio usado por suítes de apps de marca única (ex.: Adobe Creative Cloud: Ps, Ai, Pr).

| App | Monograma | Papel na família | `applicationId` / bundle id |
|---|---|---|---|
| Obrion Orçamentos | **Or** | Flagship / porta de entrada — App #1 | `br.com.ractech.obrion.orcamentos` |
| Obrion Materiais | **Ma** | App #2 | `br.com.ractech.obrion.materiais` |
| Obrion Diário | **Di** | App #3 | `br.com.ractech.obrion.diario` |
| Obrion Medições | **Me** | App #4 | `br.com.ractech.obrion.medicoes` |
| Obrion Calculadora | **Ca** | App #5 | `br.com.ractech.obrion.calculadora` |

⚠️ **`applicationId`/bundle id fixado em 21/08/2026, antes de qualquer build.** É imutável após a primeira publicação em cada loja — errar significa perder o app e a base de usuários. Mesmo identificador em Android e iOS, sem acentos, tudo minúsculo.

Regras:
- Ícone: mesma forma-base (quadrado arredondado) e mesmo estilo de monograma em todos os apps — muda apenas a cor de destaque e as duas letras.
- Dentro de cada app, um card discreto de cross-promotion (ex.: "Você também controla materiais? Conheça o Obrion Materiais") aparece em momentos de baixa fricção (ex.: tela de sucesso após gerar um PDF) — nunca interrompendo uma tarefa em andamento.
- Login único: uma conta Obrion (via módulo Authentication do Core) dá acesso a todos os apps da família instalados, reduzindo fricção ao migrar de um app para o outro.
- Antes de registrar definitivamente a marca (INPI, domínio, CNPJ), fazer a busca formal de anterioridade — a checagem informal já feita indicou o nome como o mais livre entre os candidatos testados, mas não substitui a confirmação oficial.

---

# 6. docs/ANALISE_E_MELHORIAS.md

# Análise Crítica e Melhorias — Obrion (RACTECH)

**Data:** 21 de agosto de 2026
**Base:** `APP_FACTORY_RULES.md` (v0.2), `APP_FACTORY_CORE.md`, `PLANO_DE_NEGOCIO_INICIAL.md`
**Objetivo:** apontar riscos, incoerências e lacunas antes de escrever a primeira linha de código — quando corrigir ainda é grátis.

> **Status:** as três decisões estratégicas (R1, R2, R3) foram tomadas em 21/08/2026 e **já estão aplicadas** aos quatro documentos do projeto. Este arquivo permanece como registro do raciocínio — o *porquê* de cada mudança, que os documentos revisados não têm espaço para carregar. Ver resumo no final.
>
> **Atualização de 23/08/2026:** o fundador decidiu inserir uma Fase 1.5 (polimento interno — UI/UX, features, tela de login só de interface) entre a Fase 1 e a ★ Validação, e adotar atualização OTA via Shorebird em vez de reinstalação manual a cada build. Isso adia o início da validação com usuários externos, mas não contradiz R1: a disciplina é a mesma (produto antes de infraestrutura), só o fundador optou por polir mais antes de mostrar a terceiros. Ver `../CLAUDE.md`, decisões 4–6.

---

## Veredito geral

O plano é **acima da média para um projeto em fase 0**. Pontos genuinamente fortes:

- Escopo negativo explícito (Seção 9 do plano de negócio, "fora do escopo do MVP") — isso é raro e é o que mais protege projetos de fundador solo.
- Login não-obrigatório como decisão de produto, não como detalhe técnico.
- Reconhecimento de que o problema real não é falta de software, e sim software complicado demais para o canteiro.
- Documentação pensada para ser consumida por IA — decisão coerente com a realidade de execução.

**O maior risco não é técnico nem competitivo: é sequenciamento.** O roadmap gasta 4 sprints construindo infraestrutura genérica antes de existir um único usuário, o que contradiz dois dos seis princípios do próprio documento. Detalhado em R1.

Os itens abaixo estão em ordem de impacto. **R** = risco estratégico, **P** = lacuna de produto, **T** = correção técnica.

---

# Riscos estratégicos

## R1 — Construir o Core antes do produto contradiz os próprios princípios

**O que está escrito:** Fase 0 = 4 sprints de Core (auth, banco, ads, billing, analytics, notificações, settings, tema, design system). Fase 1 = 5 sprints do app. Nove sprints antes de qualquer usuário tocar em qualquer coisa.

**O problema:** o `APP_FACTORY_RULES.md` §1 diz *"Primeiro produto pequeno, depois plataforma"* e *"Dado antes de opinião"*. O roadmap faz o oposto: constrói a plataforma primeiro, baseada em opinião sobre o que os apps #2–#5 vão precisar.

Abstração reutilizável não se projeta — se extrai. Um Core desenhado para cinco apps imaginários quase sempre não serve ao app #2 real, e você refatora assim mesmo. Os "~80% de reuso" do plano de negócio (§8) são uma hipótese, não um número medido.

Agrava: a Sprint 3 constrói **AdMob e Google Play Billing** — monetização — quando ainda não existe nada para monetizar. E a monetização é ativada de novo na Fase 2, Sprint 10. Isso é a mesma coisa construída em dois momentos separados por seis sprints.

**Recomendação:** manter a *disciplina de camadas* (que é o que realmente garante o reuso) e abandonar a *especulação de infraestrutura*.

- Fase 0 vira **uma** sprint: projeto Flutter, navegação, tokens de tema, os ~8 componentes que o App #1 realmente usa, camada de dados local, Crashlytics.
- Auth, nuvem, billing e ads só entram quando o fluxo que gera valor já funciona.
- O Core é **extraído** durante a construção do App #2, quando já se sabe o que de fato repetiu.

O custo de escrever o App #1 em camadas limpas e extrair depois é muito menor que o custo de manter infraestrutura para apps que talvez nunca existam. Roadmap alternativo completo no final deste documento.

**Contra-argumento honesto:** se a intenção é lançar os 5 apps rapidamente e em sequência, há valor real em padronizar antes. A ressalva é que isso só se paga *se o App #1 validar* — e ele ainda não validou. Construir o Core depois da validação preserva a opção; construir antes gasta o orçamento mais escasso do projeto (tempo do fundador) no cenário de maior incerteza.

---

## R2 — Os limites do plano Free estrangulam o próprio motor de crescimento

**O que está escrito:** Free = 3 clientes, 5 orçamentos/mês, PDF com marca do app.

**O problema:** o plano de negócio (§12, linha de risco "Dependência de canal único") define a estratégia de aquisição como *boca a boca — o orçamento compartilhado no WhatsApp carrega a marca do app*. Ou seja: **cada PDF gerado por um usuário Free é uma peça de marketing gratuita.** Limitar a 5/mês é limitar o próprio canal de aquisição.

Pior, os limites batem exatamente no momento errado do ciclo de vida:

- O público-alvo faz algo entre 5 e 20 orçamentos/mês. O usuário bate no teto justamente quando está virando usuário habitual — que é quando você *mais* quer retê-lo, não bloqueá-lo.
- "3 clientes" bloqueia o mecanismo de retenção (voltar e reusar um cliente salvo) para economizar linhas de banco que custam centavos.
- O risco nº 2 declarado no próprio plano é baixa retenção. Um limite duro é uma máquina de churn.

**Recomendação: mover o paywall de volume para acabamento profissional.**

O que um profissional realmente paga para ter é o que o *cliente dele* vê:

| Grátis (sem limite prático) | Pago |
|---|---|
| Clientes, medições e orçamentos ilimitados | **Logo próprio no PDF** |
| PDF com rodapé "Feito com Obrion" | **PDF sem a marca do app** |
| Fluxo completo medir → orçar → enviar | Histórico e backup na nuvem |
| Lista de preços pessoal | Templates, condições de pagamento salvas |
| | Controle de pagamentos |

Isso converte por **orgulho profissional** ("meu orçamento tem minha logo"), não por escassez artificial — e escassez artificial em app de utilidade gera desinstalação, não upgrade. E o PDF gratuito com marca continua trabalhando como aquisição.

**Se quiser manter algum limite** para não perder o gatilho de upgrade e controlar custo de Supabase: use um teto que o uso normal nunca encosta (ex.: 30 orçamentos/mês), não 5.

---

## R3 — AdMob provavelmente não se paga no MVP e custa caro em outras dimensões

Fazendo a conta que o plano deixou em aberto (Seção 13):

- Um app utilitário brasileiro dessa categoria gera na ordem de poucos reais por mil impressões. Com uma base inicial de centenas ou poucos milhares de usuários, a receita de anúncio é **ruído** — dezenas de reais por mês.
- Em troca disso você paga: uma tela pior para um público de baixa tolerância digital, um módulo inteiro no caminho crítico do desenvolvimento, complexidade no formulário de Segurança de Dados da Play Store, e risco direto contra a métrica que o próprio plano chama de mais crítica (retenção D1/D7/D30).

**Recomendação:** cortar AdMob do MVP inteiro. Deixe o app sem anúncios como diferencial explícito na ficha da loja ("sem anúncios") — o que também remove um módulo do Core do caminho crítico. Reavaliar quando houver base de usuários ativos que torne a receita não-trivial.

Reforça R1: sem ads, a Sprint 3 praticamente desaparece.

---

## R4 — A diferenciação declarada não é defensável; a defensável não está sendo construída

O plano (§6) diferencia por **velocidade e simplicidade**. Isso não é um fosso — qualquer concorrente copia um app simples em um trimestre, e os concorrentes citados já têm distribuição.

Os fossos que este produto *pode* ter:

1. **A lista de preços pessoal do profissional** — depois de cadastrar os preços dele, trocar de app custa retrabalho. É o maior custo de troca disponível aqui, e é barato de construir (ver P1).
2. **Histórico de clientes e orçamentos** — acumula com o tempo.
3. **Login único da família Obrion** — já está no plano, e é real.

Nenhum dos três está no caminho crítico do MVP hoje. O item 1 deveria estar.

**Recomendação:** tratar a lista de preços como funcionalidade central do MVP, não como detalhe. E tratar o rodapé do PDF como canal de aquisição projetado — com chamada real ("Orçamento feito com Obrion — obrion.app"), não apenas uma marca d'água.

---

# Lacunas de produto

## P1 — De onde vêm os preços? (a lacuna mais grave do MVP)

A tabela `services` aparece no schema (`APP_FACTORY_RULES.md` §4) e **não é descrita em nenhum dos três documentos**. Mas ela é o coração do produto.

A promessa é "orçamento em 3 minutos". Se a cada orçamento o profissional precisa digitar o preço do m² de reboco, o segundo orçamento demora tanto quanto o primeiro — e não há motivo para voltar ao app.

**Com lista de preços pessoal:**

- Orçamento nº 1: 3 minutos (cadastra os preços enquanto usa).
- Orçamento nº 2: **30 segundos** (escolhe o serviço, o preço já vem).

Isso ataca simultaneamente as três coisas mais frágeis do plano: a promessa de velocidade, a retenção D7/D30, e o fosso competitivo.

**Recomendação — modelo mínimo:**

```
service
├── nome              "Reboco de parede"
├── unidade           m² | m | un | ponto | diária | verba
├── preco_padrao      valor em centavos (int)
├── inclui_material   bool
└── observacao_padrao texto reaproveitado no orçamento
```

Pré-carregar uma lista sugerida por ofício (pedreiro, pintor, gesseiro...) com unidade correta e **preço em branco** — o profissional preenche o dele. Nunca sugerir preço: preço é regional, e errar isso destrói credibilidade com esse público.

---

## P2 — O modelo de medição, se mal desenhado, só serve para pintura

O `APP_FACTORY_CORE.md` §11 descreve Medições como *"ambientes, dimensões, portas, janelas, área calculada"* — no singular: **uma** área.

Mas cada ofício mede uma coisa diferente **do mesmo cômodo**:

| Ofício | O que ele cobra | Derivado de |
|---|---|---|
| Pintor | m² de parede menos vãos | perímetro × altura − vãos |
| Azulejista / piso | m² de chão | comprimento × largura |
| Gesseiro (forro) | m² de teto | comprimento × largura |
| Rodapé / moldura | metro linear | perímetro − vãos de porta |
| Concreto / contrapiso | m³ | área × espessura |
| Eletricista | pontos | contagem manual |

Se a medição guardar "a área" como um número só, o app funciona para pintor e quebra para todos os outros — e o público-alvo listado tem sete ofícios.

**Recomendação:** o ambiente guarda a **geometria bruta** (comprimento, largura, altura, lista de vãos com dimensões) e o app **deriva** as grandezas sob demanda:

```
area_piso     = comprimento × largura
area_teto     = comprimento × largura
perimetro     = 2 × (comprimento + largura)
area_parede   = perimetro × altura − Σ(vãos)
perimetro_util= perimetro − Σ(largura das portas)
volume        = area_piso × espessura
```

Cada item de orçamento escolhe **qual grandeza** consumir, conforme a unidade do serviço. Isso é uma decisão de modelagem de ~1 dia agora e uma reescrita de semanas depois.

---

## P3 — Não há mecanismo de retenção no MVP, só medição de retenção

O plano identifica baixa retenção como risco nº 2, e a mitigação declarada é *"acompanhar D1/D7/D30 e ajustar"*. **Medir não é mitigar.** O MVP não tem nenhum motivo estrutural para o profissional reabrir o app depois de enviar o orçamento.

Três mecanismos baratos, em ordem de custo/benefício:

1. **Lista de preços** (P1) — o segundo orçamento fica 6× mais rápido.
2. **Status do orçamento**: `rascunho → enviado → aceito → recusado`. Um toque para atualizar. Dá motivo para voltar ("o cliente respondeu?"), alimenta a notificação que o Core já prevê (*"orçamento aguardando resposta há 3 dias"*), gera os dados de taxa de fechamento — e é a semente natural do "controle de pagamentos" já vendido no plano Pro.
3. **Duplicar orçamento anterior** como ponto de partida. Uma linha de UI, alto uso real.

O item 2 é o que transforma o app de *ferramenta de uso único* em *lugar onde o trabalho mora*.

---

## P4 — "Enviar pelo WhatsApp" tem uma limitação técnica que precisa ser conhecida agora

A promessa central termina em "envie pelo WhatsApp". Realidade da plataforma:

- `wa.me/<telefone>?text=...` abre conversa com **texto pré-preenchido, sem anexo**. Não existe forma suportada de anexar arquivo por deep link.
- Anexar o PDF exige a **folha de compartilhamento do sistema** (`share_plus`), onde o usuário escolhe WhatsApp e o contato.

Isso funciona bem, mas não é o "manda direto pro João" que a redação atual sugere. Vale alinhar a expectativa no design da tela final.

**Melhoria concreta:** oferecer **"enviar como imagem"** além do PDF. Uma parcela relevante dos clientes finais abre imagem no WhatsApp sem pensar e ignora ou não consegue abrir PDF. Renderizar a primeira página em PNG é barato com a mesma biblioteca de impressão, e melhora diretamente a ponta do funil que gera boca a boca.

---

# Correções técnicas

## T1 — Dinheiro nunca pode ser `double` ⚠️

Não está escrito em lugar nenhum, e é o bug mais provável do projeto inteiro. Em ponto flutuante, `0.1 + 0.2 = 0.30000000000000004`. Em um app cuja função é **cotar preços**, isso vira orçamento com total que não bate com a soma dos itens — e a credibilidade do profissional com o cliente dele vai junto.

**Regra:** todo valor monetário é `int` em **centavos**, do banco à tela. Formatação para R$ só na borda de apresentação. Regra de arredondamento definida uma vez (quantidade × preço unitário → arredonda ao centavo, meio para cima) e coberta por teste unitário.

Medidas (m², m³) continuam `double` — ali a precisão de ponto flutuante é irrelevante.

## T2 — Usar autenticação anônima do Supabase elimina a migração de dados

**Como está:** modo local sem conta → usuário cadastra → *migrar* os dados locais para a conta.

Essa migração é uma rotina de uso único, difícil de testar, que roda no momento mais sensível da vida do usuário — e o documento promete "nunca perdidos".

**Como fazer:** o Supabase suporta login anônimo, que cria um usuário real com UUID real, depois **vinculado** a um e-mail. O `user_id` **nunca muda**. Consequências:

- Não existe migração — só uma vinculação de identidade.
- O RLS funciona desde o primeiro segundo, sem caminho especial para "dados sem dono".
- Zero risco de perda de dados no cadastro.

**Ressalva:** login anônimo exige rede no primeiro uso. Se o primeiro uso for offline (plausível no canteiro), gerar o UUID localmente e criar o usuário remoto na primeira conexão, mantendo o mesmo id. Definir isso agora evita retrabalho.

## T3 — Offline-first está especificado em uma linha, e é a parte mais difícil do projeto

O `APP_FACTORY_CORE.md` §2 resolve com *"fila de escrita local → sync quando houver rede"*. Sincronização bidirecional com resolução de conflito é um dos problemas mais difíceis de mobile — e é obrigatório aqui, porque o próprio documento diz que a conexão do canteiro é instável.

**A boa notícia:** este produto **não precisa** do caso difícil. Um orçamento tem um único dono e, na prática, um único dispositivo escrevendo. Sem múltiplos escritores concorrentes, não há conflito real a resolver.

**Recomendação — local-first, não offline-first genérico:**

- **O banco local é a fonte da verdade.** Toda leitura e escrita da UI é local, sempre instantânea, sempre funciona no subsolo sem sinal.
- O Supabase é **destino de backup e sincronização**, não dependência de execução.
- Sincronização por registro com `updated_at`, último a escrever vence. Sem CRDT, sem tela de resolução de conflito.
- Cada registro carrega `id` (UUID gerado no cliente), `updated_at`, `deleted_at` (exclusão lógica, para propagar remoção).

Isso reduz o problema de "meses de engenharia de sync" para "dias", sem perder nada que o usuário perceba.

**Bibliotecas:** `drift` (SQLite tipado, ativo, bom suporte Flutter) é a aposta segura para o banco local. Existe também PowerSync, feito especificamente para Supabase offline-first — vale avaliar, mas tem custo e prende a arquitetura. Confirmar o estado de manutenção dos pacotes na hora de decidir.

## T4 — Convenção de nomes está misturada e vai gerar código inconsistente

O `APP_FACTORY_CORE.md` especifica métodos em português (`iniciarModoAnonimo()`, `criarConta()`, `upgrade(plano)`, `trackEvent(nome, parametros)`) enquanto o banco é todo em inglês (`clients`, `budgets`, `budget_items`) e os componentes também (`AppButton`, `AppEmptyState`).

Num projeto explicitamente desenhado para ser construído por IA, ambiguidade de convenção custa exatamente o que o documento quer economizar: tokens, tempo e consistência. Cada geração de código vira uma microdecisão.

**Recomendação:**

- **Inglês** para todo identificador de código (classes, métodos, campos, tabelas, eventos).
- **Português** apenas em texto visível ao usuário — e centralizado em arquivo de tradução desde o dia 1, já que iOS e expansão estão no roadmap.
- Ajustar o catálogo do Core: `startAnonymousSession()`, `signUp()`, `signIn()`, `upgrade(plan)`.

## T5 — Módulos ausentes no catálogo do Core

Faltam coisas que **todo** app da família vai precisar, e que são caras de adicionar depois:

| Módulo | Por que é necessário |
|---|---|
| **Crashlytics / Sentry** | Não está em nenhum documento. Para um dev solo, saber que o app quebrou vale mais que analytics. Sem isso você descobre bugs por avaliação 1 estrela. |
| **Remote Config** | O `APP_FACTORY_CORE.md` §5 promete mudar regras de negócio "em um único lugar" — mas uma constante em Dart não é um lugar único, é uma atualização na loja com dias de rollout. Firebase Remote Config resolve isso e já está na stack. |
| **Atualização forçada/recomendada** | Você vai publicar uma build quebrada em algum momento. Sem esse mecanismo, ela fica instalada. |
| **Avaliação in-app** (`in_app_review`) | Disparada no momento de sucesso (logo após compartilhar o PDF). É a forma mais barata de subir a nota na Play Store — e o plano depende de aquisição orgânica. |
| **Estado de conectividade** | Necessário para a UI local-first ("salvo no aparelho", "sincronizado"). |

Os dois primeiros são os mais urgentes.

## T6 — Eventos de analytics têm buracos nos pontos que mais importam

O funil declarado é `Instalou → Abriu → Começou orçamento → Criou orçamento → Gerou PDF → Compartilhou → Criou conta → Voltou → Assinou`, mas a lista obrigatória de eventos não cobre alguns dos degraus.

**Faltando:**

| Evento | Por quê |
|---|---|
| `measurement_started` / `measurement_completed` | A medição é a tela mais complexa do app — o ponto de abandono mais provável, e hoje invisível no funil. |
| `upgrade_blocked` (com `limite` e `origem`) | **O evento de monetização mais valioso que existe.** Diz *qual* limite realmente empurra para o upgrade. Sem ele, o pricing é chute. |
| `subscription_cancelled` / `subscription_renewed` | `subscription_started` sozinho não mostra churn — mostra só a metade boa. |
| `price_list_item_created` | Mede a adoção do fosso competitivo (P1). |
| `budget_duplicated` | Mede reuso, principal sinal de retenção real. |

**Ajustes:** `budget_shared` precisa de parâmetro `canal` (whatsapp / email / outro) — sem ele não dá para saber se a hipótese central de distribuição está certa. `pdf_generated` precisa de `formato` (pdf / imagem), se P4 for adotado.

## T7 — Testes: o que está escrito não vai acontecer

*"Testes de regressão contra todos os apps que consomem o Core"* — sem CI definida e com um dev solo, isso não acontece na prática.

**Versão realista e suficiente:**

- Testes unitários no que erra silenciosamente e custa caro: derivação de medidas (P2), soma de orçamento com desconto, arredondamento monetário (T1).
- **Golden test do PDF** — o PDF é o produto entregue ao cliente final; uma quebra de layout é uma quebra de reputação do usuário. É o teste de maior retorno do projeto.
- CI simples (GitHub Actions) rodando `flutter analyze` + `flutter test` a cada push. Uma tarde de configuração.
- Teste manual do fluxo completo antes de cada release (já está escrito, está correto).

---

# Conformidade e marca

## C1 — LGPD: falta reconhecer o dado de terceiro

Os documentos tratam LGPD como "protegemos os dados do usuário". Mas o app armazena **dados pessoais de terceiros**: nome, telefone e endereço de obra dos *clientes* do profissional, que nunca aceitaram nada com a RACTECH.

Juridicamente, o profissional é o **controlador** desses dados e a RACTECH é a **operadora**. Implicações práticas:

- A política de privacidade precisa descrever explicitamente essa relação, não só a relação com o usuário.
- A exclusão de conta precisa **cascatear** para os registros de clientes.
- O PDF gerado contém dado pessoal de terceiro e circula por WhatsApp — vale uma linha nos termos sobre a responsabilidade do usuário nesse envio.

Não é bloqueador, mas precisa estar escrito antes de publicar.

## C2 — Verificações de marca que faltam na lista

Antes de fixar o nome:

- ✅ Busca de "Obrion" na **Google Play** e na App Store feita em 21/08/2026 — sem conflito encontrado. Conflito de nome de app impediria a listagem independentemente de marca registrada; sem conflito, o nome pode ser reservado com a criação do app/ficha da loja.
- ✅ **`applicationId`/bundle id fixado em 21/08/2026:** `br.com.ractech.obrion.<app>` — mesmo valor em Android e iOS, sem acentos. Tabela completa em `APP_FACTORY_CORE.md` §13. Ele é **imutável após a primeira publicação** — errar aqui significaria perder o app e os usuários; fixar antes do primeiro build elimina o risco.
- ✅ **Busca formal de anterioridade no INPI feita (23/08/2026)** pelo fundador: encontrada uma marca "Obrion" já registrada, mas na classe farmacêutica. Como o INPI registra por classe (Classificação de Nice) — farmacêutico costuma cair na classe 5, software/app costuma cair nas classes 9 e/ou 42 —, uma marca de classe diferente **não necessariamente** impede o registro do app na classe de software. **Não é garantia**: só um profissional (advogado de PI) confirma se há risco real de colidência/diluição entre as classes. Vale essa confirmação antes da Fase 4 (Play Store) — o app_id já é imutável após publicado, e trocar de nome depois de usuários instalados é bem mais caro que agora.
- `obrion.app` exige HTTPS obrigatório (domínio `.app` está na lista HSTS pré-carregada). Adiado — não é urgente antes da Fase 4.

---

# Roadmap alternativo proposto

Consequência de R1 + R3. Mesma disciplina de camadas, sequência invertida: **valor primeiro, infraestrutura conforme provada necessária.**

| Fase | Conteúdo | Resultado |
|---|---|---|
| **0 — Fundação mínima** (1 sprint) | Projeto Flutter, navegação, tokens de tema, os componentes que o App #1 usa de fato, banco local (Drift), Crashlytics | Esqueleto rodando |
| **1 — O fluxo que vale dinheiro** (3–4 sprints) | Clientes → Medição (P2) → Lista de preços (P1) → Orçamento → PDF → Compartilhar. **Tudo local, sem conta, sem nuvem.** | O app já cumpre a promessa inteira |
| **★ Validação** | 3–5 profissionais reais usando de verdade. Antes de qualquer nuvem ou monetização. | Aprendizado antes do gasto |
| **2 — Conta e nuvem** (1–2 sprints) | Supabase, login anônimo→e-mail (T2), sync push (T3), backup | Multi-dispositivo, dados seguros |
| **3 — Monetização** (1 sprint) | Play Billing, paywall por recurso (R2). Sem ads. | Receita |
| **4 — Publicar e medir** | Play Store, 30 dias lendo funil e retenção | Dado real |
| **★ Extração do Core** | Ao construir o App #2, extrair o que **comprovadamente** repetiu | Core real, não especulado |

Ganho principal: o produto chega na frente de usuários reais **por volta da metade do caminho** do plano atual — e todo o resto passa a ser decidido com dado.

---

# Validação que dá para fazer esta semana, de graça

O plano prevê recrutar 3–5 profissionais para teste (§11 das regras) — mas **depois** de nove sprints. O momento certo é agora, e não precisa de código:

1. **Protótipo em papel / telas estáticas** das 5 telas, na frente de 3 pedreiros. Se a tela de medição confundir, você descobre hoje de graça, e não depois da Sprint 6.
2. **MVP de concierge:** o fundador faz manualmente, por WhatsApp, "medição → orçamento em PDF" para 3 profissionais. Em uma semana você aprende o que um orçamento *precisa* conter para o cliente aceitar — que é exatamente o conhecimento que nenhum dos três documentos tem hoje.
3. **Perguntar o preço antes de fixá-lo:** os valores de R$14,90 / R$99,90 são hipótese do fundador (o próprio plano admite, §7). Três conversas resolvem melhor que três meses de código.

O princípio nº 4 do projeto é "Dado antes de opinião". Hoje o plano inteiro é opinião bem estruturada — o que é normal nesta fase, desde que o primeiro dado venha antes do primeiro grande gasto.

---

# Resumo priorizado

**Fazer antes da primeira linha de código:**

| # | Ação | Custo |
|---|---|---|
| T1 | Dinheiro em centavos (`int`), nunca `double` | Zero — é uma regra |
| P2 | Medição guarda geometria bruta e deriva grandezas | ~1 dia de modelagem |
| T4 | Convenção de nomes: código em inglês, UI em português | Zero — é uma regra |
| P1 | Lista de preços pessoal no escopo do MVP | ~2 dias |
| R1 | Resequenciar o roadmap | Decisão |

**Decisões do fundador — tomadas em 21/08/2026:**

| # | Decisão | Resultado |
|---|---|---|
| R1 | Core primeiro ou produto primeiro? | ✅ **Produto primeiro.** Core extraído durante o App #2. Roadmap revisado aplicado a `PLANO_DE_NEGOCIO_INICIAL.md` §9. |
| R2 | Free por volume ou por recurso? | ✅ **Por recurso.** Fluxo central ilimitado; paga-se por logo, PDF sem marca, histórico, backup, controle de pagamentos. |
| R3 | AdMob no MVP? | ✅ **Adiado.** Sem anúncios no MVP; vira diferencial na ficha da loja. |

Todas as três já foram propagadas para `../CLAUDE.md`, `APP_FACTORY_RULES.md` (v0.3), `APP_FACTORY_CORE.md` e `PLANO_DE_NEGOCIO_INICIAL.md`.

**Aplicar durante a construção:** T2 (auth anônima), T3 (local-first), T5 (Crashlytics + Remote Config), T6 (eventos), T7 (golden test do PDF), P3 (status do orçamento), P4 (envio como imagem), C1 (LGPD dado de terceiro). C2 (application id e busca na Play/App Store) já resolvido.

---

## Documentos relacionados

- `../CLAUDE.md` — guia operacional para IA (já atualizado com T1, T2, T3, T4, T5, T6, P1, P2)
- `APP_FACTORY_RULES.md` — regras técnicas e padrões
- `APP_FACTORY_CORE.md` — catálogo de módulos do Core
- `PLANO_DE_NEGOCIO_INICIAL.md` — contexto de negócio

---

# 7. docs/POSICIONAMENTO_E_FEATURES_APP1.md

# Posicionamento e Features — Obrion Orçamentos (App #1)

**Data:** 24 de agosto de 2026
**Base:** os 4 documentos do projeto (`PLANO_DE_NEGOCIO_INICIAL.md`, `APP_FACTORY_RULES.md` v0.3, `APP_FACTORY_CORE.md`, `ANALISE_E_MELHORIAS.md`) **+ leitura do código real** em `obrion-orcamentos/lib` (v0.1.4+4, Fase 1.5 em andamento).
**Pergunta que originou este documento:** *"o app é genérico por conta do plano de negócio?"*

> **Resposta curta: sim — mas o problema não está na engenharia, e a correção é barata.**
> O código está certo: a decisão de guardar geometria bruta (P2) deixou o app tecnicamente capaz de servir sete ofícios. O que ficou genérico foi a **experiência**: o app não sabe quem é o usuário. O onboarding não pergunta nada, o perfil guarda só nome/telefone/logo, e a lista de sugestões despeja 23 serviços de todos os ofícios misturados. Um pintor abre o app e vê "ponto elétrico" na lista dele.
>
> A correção é uma **camada fina de ofício** sobre o que já existe — dado e filtro, não arquitetura. Os serviços **já estão agrupados por ofício no código**, só que como comentário: o agrupamento não chega ao usuário.

---

# Parte 1 — O que mudou desde a versão anterior

Entre 21 e 24/08 o projeto avançou muito mais do que a documentação sugere à primeira vista. Resumo do delta:

| Frente | Estado em 21/08 | Estado hoje |
|---|---|---|
| Documentação | 3 documentos | 4 — nasceu o `ANALISE_E_MELHORIAS.md`, com R1–R4, P1–P4, T1–T7, C1–C2 |
| Roadmap | Core primeiro (9 sprints antes do 1º usuário) | **Invertido (R1):** produto primeiro; Core é **extraído** no App #2 |
| Paywall | Por volume (3 clientes, 5 orçamentos/mês) | **Por recurso (R2):** fluxo central ilimitado; paga-se por acabamento |
| AdMob | No MVP | **Cortado (R3)** — "sem anúncios" vira diferencial de loja |
| Banco | "offline-first" em uma linha | **Local-first (T3):** Drift/SQLite é a fonte da verdade; Supabase é backup |
| Autenticação | Migrar dados locais → conta | **Login anônimo (T2):** `user_id` nunca muda, migração deixa de existir |
| Dinheiro | Não especificado | **`int` em centavos (T1)** — bug mais provável do projeto, eliminado por regra |
| Medição | "área calculada" (singular) | **Geometria bruta + grandezas derivadas (P2)** |
| Lista de preços | Tabela no schema, sem descrição | **Funcionalidade central (P1)** — o fosso competitivo real |
| Retenção | Só medição de D1/D7/D30 | **Mecanismos (P3):** status do orçamento, duplicar, lembrete |
| Core | 10 módulos | +5 (Crashlytics, RemoteConfig, AppUpdate, Review, Connectivity — T5) |
| Marca | Checagem informal | Busca no INPI feita: existe "Obrion" na **classe farmacêutica** — classe diferente, risco reduzido mas não zero (C2) |
| Código | Inexistente | **Fases 0 e 1 concluídas.** Fluxo completo medir → orçar → PDF → compartilhar rodando, local, com Crashlytics, Analytics, in-app review e OTA via Shorebird |

E, em 23/08: Fase 1.5 (polimento interno antes de mostrar a terceiros), distribuição por OTA, e a seed âmbar de segurança escolhida a partir do universo visual do canteiro — decisão de tema que virou regra da fábrica.

**Leitura geral:** as três decisões estratégicas (R1, R2, R3) foram as certas, e a de maior valor foi R1. O projeto tem hoje um app funcionando onde o plano original ainda estaria na sprint 4 de infraestrutura.

---

# Parte 2 — O app é genérico? A evidência

Sim, e dá para demonstrar sem opinião. Cinco fatos do código e do plano:

**1. O app não sabe quem é o usuário.** O onboarding são 3 slides informativos, puláveis, que **não perguntam nada**. Não existe nenhum conceito de ofício/profissão em lugar nenhum: nem coluna, nem enum, nem campo de perfil, nem filtro de UI. A única ocorrência da palavra "ofício" no projeto está em prosa de documento e em **comentário** de código.

**2. O perfil profissional guarda nome, telefone e logo.** O módulo User do Core prevê "tipo de serviço" — não foi implementado.

**3. A lista de sugestões é um bloco único de 23 serviços de todos os ofícios.** O `CHANGELOG` diz "sugestões por ofício"; o `populateDefaultServices` insere tudo de uma vez. Os comentários agrupam por pedreiro/pintor/gesseiro/azulejista/eletricista/encanador — **o agrupamento existe no código e não chega ao usuário.** Um pintor recebe "ponto de tomada" e "assentamento de piso" na lista dele e precisa apagar o que não usa. É o oposto de "orçamento em 3 minutos".

**4. O posicionamento declarado é o do concorrente.** O plano diferencia por **velocidade e simplicidade** — e um dos concorrentes citados literalmente se chama **Orça Rápido**. "Rápido" não é posicionamento, é adjetivo que todo mundo usa. O próprio `ANALISE_E_MELHORIAS.md` já tinha admitido isso em R4, mas a Seção 12 do plano de negócio ainda lista "velocidade extrema" como mitigação do risco de concorrência (ver Parte 6).

**5. O plano de negócio é a origem.** A Seção 5 lista **sete ofícios sem nenhum primário**. Servir sete públicos ao mesmo tempo, no dia 1, com um fundador solo, produz necessariamente a interseção deles — que é exatamente o app neutro que existe hoje.

## A distinção que resolve a tensão

> **O código deve ser genérico. A experiência não pode ser.**

A decisão P2 (geometria bruta em vez de "a área") foi **acertada** e é o que torna a correção barata: o motor já serve qualquer ofício. Genericidade de motor é reuso; genericidade de experiência é falta de dono.

O que falta é a camada de cima — e ela é **dado e filtro, não arquitetura**.

---

# Parte 3 — A correção: camada de ofício

Uma pergunta no onboarding muda o app inteiro sem mudar uma linha da arquitetura:

```
Onboarding, tela 3 (hoje informativa, vira pergunta):

   "O que você faz?"   (múltipla escolha — muitos fazem 2 ou 3)

   ☐ Pedreiro   ☐ Pintor      ☐ Gesseiro
   ☐ Azulejista ☐ Eletricista ☐ Encanador
   ☐ Outro
```

Guardado no perfil (ou em `app_settings`), esse único dado passa a alimentar:

| O que muda | Antes | Depois |
|---|---|---|
| Sugestões de serviço | 23 itens de todos os ofícios | 5–7 itens do ofício dele, unidade correta, **preço em branco** |
| Grandeza padrão na medição | usuário escolhe toda vez | pintor → área de parede; azulejista → área de piso; gesseiro → teto |
| Campos visíveis | todos | esconde o que aquele ofício nunca usa |
| Vocabulário | neutro | o termo que ele usa |
| Ficha da Play Store | "app de orçamento" | prints e texto que falam com um ofício |

**Custo estimado: ~1 dia.** Os dados já existem (agrupados como comentário). É provavelmente o melhor retorno por hora disponível no projeto inteiro hoje.

E há um efeito colateral valioso: **a camada de ofício é também um controle de complexidade.** Toda funcionalidade nova brigará com o posicionamento "simples". Com perfil de ofício, você pode adicionar features sem que ninguém veja o app ficar mais complexo — porque cada um só vê o que serve ao ofício dele. É o que permite crescer sem virar a "gestão completa de obras" que o plano jurou não ser.

## E o passo mais desconfortável: escolher um ofício para lançar

Servir sete continua sendo possível (e o app já serve). Mas **falar com sete ao mesmo tempo é falar com ninguém** — na ficha da loja, no boca a boca e, principalmente, na ★ Validação.

Cinco profissionais de ofícios diferentes dão cinco opiniões que se contradizem. Cinco pintores dão um sinal.

**Hipótese recomendada: pintor.** O raciocínio, para ser contestado com dado e não aceito por autoridade:

- É o ofício onde a medição **mais** dói: área de parede é perímetro × altura − vãos, a conta mais chata de fazer no papel — e é exatamente a que o app já deriva.
- Alto volume de trabalhos residenciais pequenos → muitos orçamentos por mês → mais uso, mais PDFs circulando (que é o canal de aquisição do plano).
- O eletricista, em contraste, cobra por **ponto**: a medição quase não agrega para ele, e o app perde metade do valor.
- O azulejista tem um concorrente nichado (Azulejista+) — o que **prova que nicho por ofício funciona** neste mercado, e ao mesmo tempo mostra que aquele espaço tem dono.

Onde decidir isso sem código: no **MVP de concierge** que o plano já prevê (Próximos Passos #2). Fazer o orçamento manual por WhatsApp para 3 pintores responde em uma semana o que meses de código não respondem.

---

# Parte 4 — Ideias de funcionalidades

Ordenadas por retorno, e ancoradas no que **já existe** no código.

## Nível 1 — cabem na Fase 1.5 (agora), sem nuvem

| # | Feature | Por que importa | Âncora no que já existe |
|---|---|---|---|
| **1** | **Ofício no onboarding** | A correção da Parte 3. Maior retorno/hora do projeto. | Onboarding e `app_settings` já existem |
| **2** | **Sugestões segmentadas por ofício** | Fecha a lacuna entre o CHANGELOG e o código | Agrupamento já está lá, como comentário |
| **3** | **Medição → item de orçamento com quantidade preenchida** | É isto que faz "3 minutos" ser verdade. Se o usuário mede e depois digita a quantidade à mão, a medição virou trabalho extra | `measurement_math.dart` já deriva tudo; falta a ponte para `budget_items` (verificar se já existe) |
| **4** | **Reajuste de preços em massa (+X%)** | Material subiu → um botão atualiza a lista toda. Aprofunda o fosso (P1) e nenhum concorrente citado faz | `services.defaultPriceCents` |
| **5** | **Lembrete de validade + follow-up pronto** | `validUntil` já existe e não é usado. "O orçamento do João vence amanhã" + texto de cobrança pronto para o WhatsApp | `validUntil` + serviço de notificação já implementados |
| **6** | **Três opções no mesmo orçamento** (econômico / recomendado / completo) | Alavanca de **venda**, não de cadastro. Quem manda 3 opções fecha mais. Nenhum concorrente da lista faz | Agrupar `budget_items` por opção |
| **7** | **Assinatura do cliente na tela** | Transforma orçamento em mini-contrato e reduz o "mas você não falou esse preço". **Não confundir** com assinatura digital ICP-Brasil, que está fora de escopo | Captura de imagem → PDF já gerado |

**Observação sobre a #3:** é a diferença entre "app que calcula" e "app que economiza tempo". Vale conferir se a ponte medição→item já existe; se não existir, é a primeira coisa a fazer depois do ofício.

## Nível 2 — Fase 1.5 tardia ou Fase 2

| # | Feature | Por que importa |
|---|---|---|
| **8** | **Medição por voz** | Diferenciação real. Os concorrentes fazem *voz → orçamento* (Prummo, Azulejista+). Ninguém ataca o momento físico da dor: **as duas mãos estão na trena**, o celular está no bolso e a mão está suja. "Sala, cinco por quatro, pé-direito dois e oitenta" enquanto mede é outro produto. Cuidado: é o único item desta lista que depende de IA — mantém a regra de não ser feature de lançamento |
| **9** | **Custo → margem** ("neste orçamento você ganha R$ 340") | Hoje o app diz quanto **cobrar**, não quanto ele **ganha**. Um `costCents` em `services` já resolve o essencial. É a semente natural do "acompanhamento de lucro" do Pro+ — e candidato forte a recurso pago |
| **10** | **Recibo pós-aceite** | O ciclo não acaba no orçamento aceito. Mesmo motor de PDF, casa com a tabela `payments` que **já está construída** |

## Nível 3 — depende da nuvem (Fase 2+), maior alavanca estratégica

| # | Feature | Por que importa |
|---|---|---|
| **11** | **Link do orçamento com aceite do cliente** | Em vez de só um PDF, um link (`obrion.app/o/abc123`) onde o **cliente final** vê o orçamento e toca em "Aceitar" ou "Tenho uma dúvida". Três ganhos de uma vez: (a) o **status se atualiza sozinho** — resolve P3 muito melhor que o toque manual; (b) o profissional recebe notificação e tem motivo real para reabrir o app; (c) a página carrega "Feito com Obrion" para alguém que **não é usuário** — é o laço viral que o plano quer e hoje depende de o cliente reparar num rodapé de PDF |

Se eu tivesse que apontar uma única funcionalidade para depois da validação, seria a **#11**. Ela transforma o canal de aquisição de "esperança" em mecanismo.

---

# Parte 5 — O que **não** fazer

| Ideia tentadora | Por que não |
|---|---|
| **Medição por AR / foto do cômodo** | Confiabilidade ruim nos Android baratos deste público, e uma medida errada não é bug: é o profissional cobrando errado. Destrói a confiança que o app inteiro depende |
| **Calculadoras genéricas dentro do App #1** | É o **App #5** da própria família. Sem uma regra de fronteira, os dois apps se canibalizam |
| **Voz → orçamento inteiro** | Prummo e Azulejista+ já ocupam. A voz na **medição** (#8) é o espaço livre |
| **Qualquer item da "gestão completa"** | Equipe, cronograma, estoque, fornecedores — a lista de escopo negativo do plano (§9) é um dos maiores acertos do projeto. Ela só protege se for consultada |

---

# Parte 6 — Inconsistências que sobraram nos documentos

A revisão v0.3 foi aplicada bem, mas alguns trechos anteriores não foram varridos. Como estes documentos são consumidos por IA de programação, cada contradição vira uma microdecisão errada no código.

**Resíduos de AdMob (contradizem R3, que cortou anúncios):**

| Arquivo | Onde | O que diz |
|---|---|---|
| `PLANO_DE_NEGOCIO_INICIAL.md` | §1, Sumário | lista "anúncios" na base técnica |
| `PLANO_DE_NEGOCIO_INICIAL.md` | §8 | idem |
| `PLANO_DE_NEGOCIO_INICIAL.md` | §10, Métricas | "visualizações de anúncio, receita de anúncios" |
| `PLANO_DE_NEGOCIO_INICIAL.md` | §12, Riscos | linha inteira sobre "política de anúncio comedida" |
| `APP_FACTORY_RULES.md` | §7, fim | "views de anúncio, receita de anúncio" |
| `APP_FACTORY_RULES.md` | §8 | `AppAdContainer` na lista de componentes **obrigatórios** |
| `APP_FACTORY_CORE.md` | §9 | `AppAdContainer` no catálogo |

**Contradições internas:**

- **`PLANO` §12 vs §6.** A tabela de riscos ainda mitiga concorrência com *"velocidade extrema e simplicidade"* — exatamente o que a §6 do mesmo documento (revisão R4) declara **não defensável**. Deveria apontar para a lista de preços, o histórico e o login único.
- **`PLANO` §1 vs §9.** O sumário ainda diz "construir uma vez a base técnica e reaproveitá-la"; a §9 diz o contrário (Core **extraído** no App #2). Quem ler só o sumário entende o roadmap antigo.
- **`RULES` §9 vs `CORE` §8.** A §9 do RULES ainda descreve o modelo antigo de tokens (`primary`, `secondary`, `background`…), enquanto o CORE §8 e o código real usam **seed color + `ColorScheme.fromSeed` do Material 3 + `AppSemanticColors`**. Documentos em conflito sobre tema.
- **Versão do `RULES`.** Cabeçalho diz v0.3 / 21-08, mas o conteúdo foi alterado em 23/08 (resultado do INPI). Vale v0.4.

**Regras que o código não cumpre (decidir: corrigir o código ou a regra):**

| Regra | Realidade |
|---|---|
| "Sugestões por ofício" | Lista única genérica de 23 serviços |
| "Texto de UI centralizado em arquivo de tradução desde o dia 1" | Strings hardcoded nos widgets |
| "`budget_shared` com `channel` **obrigatório**" | `share_plus` não informa o app escolhido — a regra é **inimplementável como escrita**. Ou se aceita `channel=system_sheet`, ou se cria uma folha própria com os canais principais |
| "Golden test do PDF — o teste de maior retorno" | Descartado (inviável em headless), substituído por testes de conteúdo. O RULES §12 precisa registrar o substituto, senão a regra vira letra morta |
| "Controle de pagamentos" vendido como **Pro** (§7) | `payments` já existe e é gratuito. Decidir na Fase 3 — tirar do Free depois é pior que nunca ter dado |

---

# Parte 7 — Uma tensão estratégica que vale nomear

A família Obrion é dividida por **função**: Orçamentos, Materiais, Diário, Medições, Calculadora. Mas a cabeça do usuário não é dividida assim. Um pintor não pensa "preciso de um app de diário" — ele pensa "preciso resolver meu trabalho".

A analogia da Adobe funciona porque Photoshop e Illustrator são **tarefas diferentes, muitas vezes de pessoas diferentes, em momentos diferentes**. Aqui é o mesmo profissional, no mesmo celular, na mesma obra, no mesmo dia. Cinco ícones para uma pessoa só é uma aposta diferente da que a analogia sugere — e o risco é terminar com **cinco apps medianos e genéricos em vez de um app específico e muito bom**.

Isso **não** é um argumento para abandonar a estratégia de família: ela tem ganhos reais (superfície de busca na loja, apps menores, custo marginal baixo, login único). É um argumento para duas coisas:

1. **Não decidir isso agora por opinião.** O App #1 vai gerar o dado: se os usuários pedirem "e a lista de material?" dentro do Orçamentos, o Materiais talvez deva nascer como **módulo**, não como app separado. O princípio nº 4 do projeto ("dado antes de opinião") se aplica à própria arquitetura do portfólio.
2. **Definir agora a fronteira entre App #1 e App #5.** Orçamentos vai naturalmente ganhando calculadoras; Calculadora é um app inteiro sobre isso. Sem regra escrita, um canibaliza o outro. Sugestão de regra: *o Orçamentos só calcula o que vira item de orçamento; a Calculadora calcula quantidade de material para comprar.*

---

# Próximos passos sugeridos

**Nesta semana, sem código:**

1. Rodar o **MVP de concierge** com 3 pintores (já previsto no plano) — e sair dele com o ofício de lançamento decidido por evidência.

**Na Fase 1.5, em ordem:**

2. Ofício no onboarding (#1) + sugestões segmentadas (#2) — ~1 dia, muda a percepção do app inteiro.
3. Verificar/construir a ponte medição → item de orçamento (#3).
4. Reajuste em massa (#4) e lembrete de validade (#5) — baratos, alimentam retenção e fosso.

**Antes da ★ Validação:**

5. Varrer as inconsistências da Parte 6 — principalmente os resíduos de AdMob e o conflito de tema entre `RULES` §9 e `CORE` §8, que são os que mais confundem IA gerando código.
6. Decidir a regra de fronteira App #1 × App #5 (Parte 7).

**Guardar para depois do dado:**

7. Três opções no orçamento (#6), margem (#9), medição por voz (#8).
8. Link com aceite do cliente (#11) — a maior alavanca, mas depende da Fase 2.

---

## Documentos relacionados

- `PLANO_DE_NEGOCIO_INICIAL.md` — contexto de negócio e roadmap vigente
- `ANALISE_E_MELHORIAS.md` — análise crítica que originou a revisão v0.3
- `APP_FACTORY_RULES.md` — regras técnicas e padrões
- `APP_FACTORY_CORE.md` — catálogo de módulos do Core
- `../CLAUDE.md` — guia operacional e decisões 1–6

---

# 8. docs/ANALISE_CONCORRENCIA_E_ESCOPO.md

# Análise de Concorrência e Decisão de Escopo — Obrion

**Data:** 24 de agosto de 2026
**Base:** capturas de tela de dois concorrentes diretos, testados pelo próprio fundador + código real do Obrion (v0.1.4+4)
**Origem:** o fundador apontou que "genérico" não significava falta de nicho por ofício, e sim **distância de UI/UX e de escopo em relação à concorrência** — e levantou a hipótese de que os concorrentes são mais completos porque o plano de negócio deles é **tudo em um app só**.

> **Conclusão principal:** os dois concorrentes analisados são all-in-one, e um deles (**Azulejista+**) tem nome de ofício com produto completo — ou seja, **o nicho está no nome e no posicionamento, não na fronteira do app.** Isso confirma a hipótese do fundador sobre *por que* eles parecem mais completos.
>
> **Sobre a estratégia de 5 apps:** a primeira versão deste documento recomendava colapsar tudo em um app. **Essa recomendação foi revista** (ver Parte 2) depois que o fundador esclareceu que a separação é uma **estratégia de produção com convergência planejada** — construir o #1, reaproveitar a base para erguer os seguintes rapidamente, e **juntar tudo no final** — e não a arquitetura final do produto. Com isso, a estratégia se sustenta; o que muda é o que precisa ser decidido hoje para que ela funcione.
>
> **Correção de uma recomendação anterior:** eu havia sugerido validar com 3 pintores antes de construir. O fundador coordena obras com pintor, pedreiro, caldeireiro, soldador e ajudantes, e faz orçamentos — **ele é o usuário**. A recomendação de validação externa cai; o que substitui está na Parte 6.

---

# Parte 1 — Teardown dos concorrentes

## Concorrente A (interface verde-petróleo)

**Estrutura:** navegação em 5 abas — Início · Orçamentos · **[+]** · Agenda · Mais.

| O que faz | Detalhe observado |
|---|---|
| **Orçamento por voz** | O topo da revisão tem um bloco recolhível "**O QUE DISSE**" — a transcrição do áudio. O fluxo é falar → IA monta → revisar |
| **Assistente em wizard** | 4 passos com barra de progresso: **ITENS → DETALHES → COBRANÇA → ENVIAR** |
| **Créditos** | Badge "Plus ativo" + contador "**0/2k**" no topo — monetização por consumo de IA, além da assinatura |
| **Fotos no orçamento** | "FOTOS (0/5)" |
| **Salvar itens** | "Salve itens para reutilizá-los / Gerenciar itens salvos" — a lista de preços deles |
| **Campos progressivos** | "CPF/CNPJ / Endereço" e "DETALHES DO TRABALHO" vêm **recolhidos e marcados Opcional** |
| **Importar contato** | Puxa cliente da agenda do telefone |
| **Agenda** | Aba própria, com "Próximos" e "Calendário" |
| **Escopo real** | O menu "Mais" revela: Pedidos, Clientes, **Despesas**, **Relatórios**, **Materiais**, **Modelos**, **Pontos**, Configurações, Ajuda |
| **Saída suave** | Botão "Salvar para mais tarde" em todos os passos |

**Posicionamento na tela vazia:** *"Responda primeiro. Ganhe o trabalho."* — vende **fechar o serviço**, não "fazer orçamento".

## Concorrente B — Azulejista+ v1.0.4

**Estrutura:** Início · Obras · **[🎤 microfone central]** · Clientes · Assistente. O microfone é o botão-herói, presente em **todas** as telas.

| O que faz | Detalhe observado |
|---|---|
| **Home = painel financeiro** | "Recebido este mês **R$ 4.375,00**", "Aguardando aprovação R$ 52.615,00", "Orçamentos a vencer: 0 em 7 dias", "Pendências de Recebimento" com barra de progresso, "Recebimentos Recentes · PIX" |
| **Orçamento por voz** | Card roxo: "Fale o orçamento e a IA cria automaticamente • **5 créditos**" |
| **Análise de margem por IA** | Card no orçamento: "Converse com a IA para validar sua margem, **descobrir custos ocultos**…" |
| **Catálogo unificado** | "Selecionar do catálogo" com chips **Ver todas / Serviços / Materiais** — serviço e material no mesmo lugar |
| **Recibo** | Botão "**Emitir Recibo**" direto no orçamento |
| **Lista de compras** | Botão "**Lista de Compras**" direto no orçamento — *é o App #2 do plano Obrion, como um botão* |
| **Dados de exemplo** | Cliente "Roberto Alves **[exemplo]**", catálogo com "Argamassa AC3 (50 kg) [exemplo] — R$ 42,00/saco" e "Assentamento de porcelanato [exemplo] — R$ 95,00/m²". O app **nunca aparece vazio** |
| **Ações no cliente** | Nova obra · WhatsApp · Ligar, direto na ficha |
| **Desconto** | Sem desconto / Valor fixo / **Percentual** |
| **Profissão no perfil** | Abaixo do nome aparece "**Pintor**" — e o onboarding tem um passo dedicado a isso |
| **PDF** | Logo, nº do orçamento, emissão e validade, dados dos dois lados, bloco PROJETO/OBRA com descrição, tabela completa, condições de pagamento, **duas linhas de assinatura** (profissional + contratante com CPF/CNPJ e data) e rodapé "Gerado com Azulejista+ • **Remova esta marca no plano Premium**" |
| **Onboarding** | 3 passos: **IDENTIDADE → PROFISSÃO → TELEFONE** ("Como se chama e qual é a sua empresa?" — nome, empresa, país) |

**Observação decisiva:** o app se chama **Azulejista+** e está sendo usado por um **pintor**, com empresa de pintura cadastrada, sem nenhum atrito. O nome de ofício **não** limitou o público — funcionou como isca de busca. Isso responde, sozinho, boa parte da pergunta sobre nicho.

---

# Parte 2 — Um app ou vários: a estratégia revisitada

A primeira versão desta análise recomendava colapsar os 5 apps em 1. O fundador corrigiu o raciocínio, e a correção procede: a separação por app não é a arquitetura final do produto — é uma **estratégia de produção**. Constrói-se o #1 pequeno e focado; a base técnica (Core) faz o #2 sair mais rápido que o #1; e, quando cada um já provou sua dor específica, **junta-se no final**. Isso é literalmente o que já estava escrito em `APP_FACTORY_RULES.md` §1 ("primeiro produto pequeno, depois plataforma") — a análise anterior perdeu esse fio.

**A analogia certa não é a Adobe — é a Autodesk**, e ela é mais forte exatamente na direção que o fundador apontou. AutoCAD (desenho 2D), Revit (modelagem BIM) e Navisworks (coordenação/detecção de conflito entre disciplinas) atendem **papéis diferentes dentro da mesma obra** — projetista, arquiteto, coordenador de obra — com fluxos de trabalho genuinamente distintos, não a mesma tarefa fatiada em telas. A Autodesk podia ter feito um "AutoCAD Tudo-em-Um". Não fez. Em vez disso, mantém produtos focados que **interoperam por formato de dado compartilhado** (IFC, DWG) e vende um pacote (AEC Collection) para quem usa vários ao mesmo tempo — sem forçar ninguém que só precisa de um a instalar o resto.

Isso é o modelo certo para "juntar no final": **não é fundir em um binário único**, é oferecer um pacote/conta única sobre produtos que continuam focados. É exatamente o que o Obrion Core (login único, dados compartilhados via Supabase na Fase 2) já foi desenhado para viabilizar.

## Onde a análise anterior errou

Eu vi as funções dos concorrentes (Lista de Compras, Recibo, painel financeiro) vivendo *dentro* do fluxo de orçamento deles e concluí que isso provava que deveriam viver dentro de *um* app Obrion também. Mas isso confunde duas coisas diferentes:

1. **Bloat dentro de um produto** — que é exatamente a queixa original de "genérico": o Concorrente A tem Pedidos, Clientes, Despesas, Relatórios, Materiais, Modelos, Pontos no menu "Mais". Isso não é foco, é acúmulo.
2. **Produtos distintos para pessoas/momentos distintos** — que é o que o fundador está descrevendo: o pedreiro que só quer passar orçamento e acompanhar não é a mesma pessoa (ou o mesmo momento) do "cara que quer um relatório diário". Forçar os dois dentro do mesmo app, mesmo com telas diferentes, é o mesmo erro do item 1 em escala menor.

O fato de um concorrente ter enfiado tudo num app só não é evidência de que essa é a arquitetura certa — pode muito bem ser a causa do problema que a queixa "genérico" está apontando.

## O que isso muda na prática

**App #1 (Orçamentos) fica mais estreito, não mais largo.** O escopo é: criar orçamento, medir, gerar PDF, enviar, acompanhar status (aceito/recusado/pago). Registrar recibo de pagamento continua fazendo sentido *dentro* dele, porque é o mesmo objeto de dado (este orçamento, foi pago?) — não é o mesmo tipo de decisão que "construir um app de diário".

**A ordem dos próximos apps deixa de ser fixa por opinião.** O plano original tinha Materiais como #2. Mas o fundador aponta um sinal real: existe gente que não quer orçamento nenhum, só quer relatório diário de obra. Se esse sinal for mais forte que o de Materiais, o Diário deveria furar a fila — a Fase ★ Extração do Core (que já existe no roadmap) é o ponto certo para essa decisão, com dado da experiência de coordenar obras, não com a ordem #1→#5 herdada do plano original.

**O Core precisa ser desenhado para o modelo Autodesk desde já**, mesmo construindo um app de cada vez: dados no formato que permite interoperar depois (cliente e obra como entidades compartilháveis, IDs estáveis) — sem isso, "juntar no final" vira reescrita, não integração.

## O que continua valendo da análise de concorrência

Nada do teardown muda: os padrões de UI/UX das Partes 3–5 (onboarding tardio, dados de exemplo, home como painel, campos recolhidos) continuam sendo o que falta no Obrion Orçamentos — só que agora claramente como melhorias do **App #1 focado**, não como justificativa para incorporar módulos de outros apps.

---

# Parte 3 — Onboarding: o fundador está certo, mas falta o meio-termo

**Observação do fundador:** todos os concorrentes pedem cadastro na primeira abertura — e-mail, nome da empresa, telefone. Ele acha que não é o caminho.

**Concordo, e o motivo é estrutural:** eles pedem porque **precisam** — a conta é o que sustenta a nuvem e o sistema de créditos desde o primeiro segundo. O Obrion é local-first: **não precisa**. Isso não é só uma escolha de UX, é uma vantagem que o concorrente não consegue copiar sem reescrever a arquitetura dele.

**Mas há um detalhe que não pode ser ignorado:** os três campos que eles pedem (nome, empresa, telefone) **não são para a conta — são para o PDF**. Sem eles, o primeiro orçamento sai sem cabeçalho, sem identidade, sem telefone de contato. Ou seja: pedir nada também quebra o produto.

## A saída: perguntar no momento da necessidade, não na porta

```
Abre o app  →  já dá pra criar orçamento (sem nada)
                        ↓
            toca em "Gerar PDF" pela 1ª vez
                        ↓
   "Como você quer aparecer no orçamento?"
   Nome · Empresa · Telefone · Logo (opcional)
                        ↓
              PDF sai pronto e com a cara dele
```

São os mesmos campos, no momento em que o valor é óbvio e o usuário já investiu esforço. A taxa de preenchimento sobe, e a pergunta parece **ajuda**, não pedágio. O cadastro de verdade (e-mail/senha) continua para depois, só quando ele quiser backup ou segundo aparelho — como já está na regra do projeto.

**Bônus:** "comece sem cadastro" e "funciona sem internet" viram duas linhas na ficha da Play Store que **nenhum dos dois concorrentes pode escrever**.

---

# Parte 4 — Onde está a brecha real (e ela já está construída)

Olhando as duas telas de criação de item dos concorrentes: em ambos, a quantidade é **digitada**. "50 m²". "619 m²". **Nenhum dos dois mede.** Eles assumem que o profissional já chegou com o número na mão.

O Obrion tem `measurement_math.dart` derivando área de piso, teto, **parede menos vãos**, perímetro e perímetro útil a partir da geometria bruta. Isso é a conta mais chata do orçamento — e é exatamente a que os concorrentes deixaram de fora.

**Isso reposiciona o produto:**

| | Concorrentes | Obrion |
|---|---|---|
| O que são | Apps de **orçamento** | App de **medição + orçamento** |
| Ponto de partida | "Quanto você vai cobrar?" | "Quanto tem aqui?" → "Quanto você vai cobrar?" |

A promessa deixa de ser "orçamento rápido" (adjetivo que o concorrente "Orça Rápido" já usa no nome) e passa a ser algo que só o Obrion entrega hoje: **medir no local e sair com o orçamento pronto**.

Outras brechas confirmadas: **funciona sem internet** (ambos dependem de nuvem), **sem cadastro para começar**, e **sem créditos** — os dois cobram consumo de IA por crédito, o que é atrito recorrente.

---

# Parte 5 — Gap de UI/UX: o que copiar, em ordem

Padrões que os dois concorrentes usam e que o Obrion não tem. Ordenados por impacto sobre a sensação de "app completo".

### Nível 1 — mudam a percepção imediatamente

| # | Padrão | O que é | Por quê |
|---|---|---|---|
| 1 | **Dados de exemplo com selo [exemplo]** | Cliente e itens de catálogo pré-carregados, marcados e apagáveis | O app **nunca abre vazio**. Resolve o cold start melhor que qualquer texto de estado vazio, e mostra o formato esperado. *Também resolve o impasse do "nunca sugerir preço": um preço marcado `[exemplo]` não é sugestão, é amostra.* |
| 2 | **Home como painel, não como estado vazio** | "Recebido este mês", "Aguardando aprovação", "A vencer em 7 dias", pendências com barra | Responde "como está meu negócio?" em vez de "crie um orçamento". É o que faz o app parecer um sistema. **A tabela `payments` já existe** — o dado está lá |
| 3 | **Campos opcionais recolhidos, com o motivo escrito ao lado** | "Adicionar endereço e mais detalhes (Opcional)" fechado por padrão. No campo de telefone do cliente, um aviso: *"Com telefone: envia por WhatsApp em um clique."* | Não é só esconder campo — é **explicar o ganho no momento da escolha**, pra quem não sabe por que preencheria algo opcional. Copy barata, sem tela nova |
| 4 | **Wizard com passos** | ITENS → DETALHES → COBRANÇA → ENVIAR, com progresso | O `budget_form_screen.dart` tem 29 KB — provavelmente um formulão único. Dividir reduz a sensação de esforço |
| 5 | **Importar contato do telefone** | Puxa nome e telefone da agenda | Elimina a digitação mais chata do fluxo |
| 6 | **Ações rápidas no cliente** | WhatsApp · Ligar · Nova obra na ficha | Transforma a ficha em ponto de ação, não de consulta |
| 7 | **Grade de atalhos na Home** | 6 ícones fixos: Novo cliente · Nova obra · Catálogo · Orçamentos · Recibos · Listas | Complementa o item 2 (home-painel): não é só mostrar número, é também tirar 1 toque de cada ação comum. Puro roteamento — Obrion já tem todas as telas de destino |
| 8 | **Descrição da obra no PDF** | Bloco "PROJETO/OBRA" com parágrafo livre acima da tabela de itens ("Assentamento de porcelanato retificado 90x90 em cozinha de alto padrão…"), separado da descrição de cada item | O PDF do Obrion hoje só tem descrição por item (`budget_pdf_content.dart`), nenhum resumo do trabalho como um todo. É barato (1 campo de texto no orçamento) e é exatamente o que sustenta a promessa de "medição + orçamento" da Parte 4 — dá o lugar certo pra registrar o que foi medido |

### Nível 2 — fecham o ciclo do trabalho

| # | Padrão | Observação |
|---|---|---|
| 9 | **Assinatura no PDF** | Duas linhas (profissional + contratante, com CPF/CNPJ e data). Vira mini-contrato. **Não confundir** com assinatura digital ICP-Brasil |
| 10 | **Emitir recibo** | Mesmo motor de PDF, casa com `payments` |
| 11 | **Lista de compras a partir dos itens** | O "App #2" como botão |
| 12 | **Fotos no orçamento** | Antes/depois, estado do local. Reduz discussão com o cliente |
| 13 | **Desconto percentual** | Hoje o Obrion só tem `discountCents` (valor fixo) |
| 14 | **Catálogo unificado serviços + materiais** | Chips "Ver todas / Serviços / Materiais". Hoje o Obrion só tem `services` |

### Nível 3 — depende de IA/nuvem

| # | Padrão | Observação |
|---|---|---|
| 15 | **Orçamento por voz** | Ambos têm. Deixou de ser diferencial e virou **tabela**. Mas o espaço livre continua sendo **voz na medição** (as duas mãos na trena), que nenhum dos dois ataca |
| 16 | **Análise de margem por IA** | "Descobrir custos ocultos" — vende insegurança real do profissional |
| 17 | **Alerta de valor fora do padrão** | Ninguém faz. Na captura do concorrente há um item de **619 m² de alvenaria em uma "Reforma Banheiro"**, aceito sem nenhum aviso, por R$ 52.615,00 — **confirmado em print real**, não é hipótese. Um "confere?" nesse momento evita orçamento errado indo pro cliente |

**Verificado direto no código (24/08/2026), pra não duplicar trabalho:** "notas internas do cliente" (campo livre visto no formulário de cliente do concorrente) **já existe** no Obrion — `clients.notes`, exposto em `client_form_screen.dart`. Não é gap, é só confirmação de algo que já foi feito.

---

# Parte 6 — Correções às recomendações anteriores

| O que eu disse antes | Correção |
|---|---|
| "Vá validar com 3 pintores antes de construir" | **Cai.** O fundador coordena obras com pintor, pedreiro, caldeireiro, soldador e ajudantes, e faz os orçamentos. Ele é o usuário. O que substitui: **usar o app nos próprios orçamentos reais desta semana** — dogfooding é validação legítima e mais rápida aqui |
| "Camada de ofício é a correção mais importante (~1 dia)" | **Continua valendo, mas desce de prioridade.** O concorrente já faz isso (passo PROFISSÃO no onboarding, "Pintor" no perfil) — é tabela, não diferencial. E como o fundador atua em vários ofícios, o valor maior está em **pré-carregar o catálogo certo** e **mostrar a profissão no PDF**, não em esconder campos |
| "Escolha um ofício para lançar (pintor)" | **Reformula.** O Azulejista+ prova o modelo certo: **nome de ofício, produto completo**. O nicho vai para o nome e para a ficha da loja; o produto atende todo mundo |
| "Cuidado com a fronteira App #1 × App #5" | **Continua valendo — e fica mais importante, não menos.** Com apps separados de verdade, essa fronteira precisa ser desenhada de propósito (ver Parte 2: dados compartilháveis, IDs estáveis de cliente/obra), em vez de deixada para "resolver depois" |
| "As 5 apps são visões do mesmo grafo" (Parte 7 do doc anterior) | **Reformula.** Não são visões do mesmo grafo — são **produtos distintos para dores/momentos distintos** (orçamento ≠ diário ≠ materiais). O que é compartilhado é a base técnica (Core) e, no final, o pacote/conta — não a tela nem o propósito de cada app |

---

# Parte 7 — O que decidir antes de codar

**1. Escopo do App #1, e o que "juntar no final" significa na prática.** Recomendação: manter os 5 apps como produtos focados (ver Parte 2) — não fundir em um binário. Três coisas precisam virar decisão explícita, não ficar implícitas:

- **Travar o escopo do #1** no que está listado na Parte 2 (orçamento, medição, PDF, envio, status, recibo de pagamento). Qualquer coisa fora disso — diário de obra, catálogo completo de materiais, agenda — é candidato a outro app, não a uma aba nova.
- **"Juntar no final" = pacote/conta única sobre o Core** (modelo AEC Collection: login único, dados compartilháveis), não fusão de código. `PLANO_DE_NEGOCIO_INICIAL.md` §11 e `APP_FACTORY_CORE.md` §13 já descrevem a família de cinco apps com login único — **não precisam de revisão**, a análise anterior é que estava desalinhada com eles.
- **A ordem #2→#5 deixa de ser fixa por opinião.** O plano original tinha Materiais como #2; o sinal do fundador (gente que só quer diário, não orçamento) é candidato real ao #2 e deve ser decidido com dado real de uso, na fase ★ Extração do Core do roadmap — não travado agora por herança do documento original.

**2. Qual usuário é o alvo — e isso importa mais do que parece.**

O fundador **coordena** obras e contrata pintor, pedreiro, caldeireiro, soldador, ajudantes. Isso é o perfil de **empreiteiro/coordenador**, não o de prestador solo. São dois produtos com a mesma base e **homes diferentes**:

| | Prestador solo (pintor) | Coordenador / empreiteiro |
|---|---|---|
| Pergunta central | "Fecho esse serviço?" | "Quanto executei, quanto recebi, quanto devo pagar?" |
| Home ideal | Criar orçamento rápido | Painel de obras, saldos e pendências |
| Papel do orçamento | O produto | Um documento entre vários |

O plano de negócio mira o primeiro; o fundador é o segundo. Não é contradição — mas define **qual home construir**, e a home é a tela que define o que o app "é". Vale escolher conscientemente em vez de deixar acontecer.

**3. Nome do app na loja.** Se o modelo Azulejista+ vale (nome de ofício + produto completo), "Obrion" sozinho não capta busca. Algo como **"Obrion — Orçamento de Obra"** no título da ficha, com os ofícios na descrição, resolve ASO sem quebrar a marca.

---

# Próximos passos sugeridos

1. **Confirmar o escopo travado do App #1 e qual home construir** (Parte 7.1 e 7.2). São as duas decisões que travam tudo o mais.
2. **Nível 1 da Parte 5**, em ordem: dados de exemplo → home-painel → campos recolhidos → wizard → importar contato. É o pacote que fecha o gap de percepção.
3. **Reposicionar a promessa** em torno de medição (Parte 4) — é a única coisa que os dois concorrentes não fazem e que já está construída.
4. **Onboarding no momento da necessidade** (Parte 3), em vez de cadastro na porta.
5. Só depois: voz, IA, margem, créditos.

---

## Documentos relacionados

- `POSICIONAMENTO_E_FEATURES_APP1.md` — análise anterior; ver Parte 6 acima para o que foi corrigido
- `PLANO_DE_NEGOCIO_INICIAL.md` — §11 (portfólio) já descreve a família de cinco; **não precisa de revisão**
- `APP_FACTORY_CORE.md` — §13 (identidade da família) idem, **não precisa de revisão**
- `ANALISE_E_MELHORIAS.md` — decisões R1–R3, que seguem válidas

---

# 9. docs/ROADMAP_UX_UI_E_FEATURES_APP1.md

# ROADMAP_UX_UI_E_FEATURES_APP1.md

# Obrion Orçamentos — Roadmap de UX/UI, Produto e Features

**Data:** 24/08/2026  
**Aplicativo:** Obrion Orçamentos — App #1  
**Objetivo deste documento:** servir como instrução operacional para a IA atualizar os documentos `.md` do projeto e orientar a evolução do produto sem perder o foco do App #1.

---

## 0. REGRA PRINCIPAL

O Obrion Orçamentos NÃO deve virar um ERP ou um sistema completo de gestão de obras.

O objetivo do App #1 é dominar o fluxo:

> **Cliente → Medição → Orçamento → Envio → Acompanhamento → Aprovação → Pagamento**

O produto deve ser percebido como uma ferramenta extremamente simples e profissional para transformar uma visita/medição em uma oportunidade comercial acompanhada até o recebimento.

### Princípio de produto

**"Do local ao orçamento."**

Promessa principal sugerida:

> **Meça no local. Monte o orçamento. Envie pelo WhatsApp.**

A diferenciação não deve depender apenas de "ser rápido" ou "ser simples", pois isso é copiável. O diferencial deve ser o conjunto:

- medição integrada;
- cálculo automático;
- funcionamento offline;
- início sem cadastro;
- lista de preços pessoal;
- histórico;
- envio por WhatsApp;
- acompanhamento do orçamento;
- experiência específica por profissão.

---

# 1. OBJETIVOS DESTA FASE

Antes de adicionar funcionalidades complexas, o projeto deve:

1. elevar significativamente a qualidade da UX/UI;
2. fazer o aplicativo parecer um produto completo e profissional;
3. reduzir fricção no primeiro uso;
4. deixar claro para cada profissional que o app foi feito para seu ofício;
5. tornar o fluxo de orçamento extremamente fácil;
6. aumentar a percepção de valor do PDF/Imagem enviado ao cliente;
7. criar motivos para o usuário retornar ao app;
8. preparar a base para monetização futura;
9. preservar a arquitetura local-first;
10. não antecipar features de IA/ERP antes da validação.

---

# 2. PRINCÍPIOS DE UX/UI

## 2.1. O usuário não deve aprender o aplicativo

A interface deve ensinar pelo uso.

Evitar:

- tutoriais longos;
- telas explicativas desnecessárias;
- excesso de campos;
- linguagem técnica;
- cadastro obrigatório na abertura.

Preferir:

- dados de exemplo;
- textos curtos;
- campos opcionais recolhidos;
- sugestões contextuais;
- ações claras;
- feedback imediato.

---

## 2.2. Não abrir o app vazio

No primeiro uso, apresentar dados de exemplo claramente marcados:

- Cliente exemplo;
- Orçamento exemplo;
- Serviços exemplo;
- valores explicitamente marcados como `[EXEMPLO]`.

O usuário deve poder excluir os dados de exemplo.

Objetivo:

> demonstrar imediatamente como o aplicativo funciona e reduzir a sensação de "app vazio".

---

## 2.3. Onboarding no momento da necessidade

Não exigir cadastro na primeira abertura.

Fluxo:

```text
Abrir app
    ↓
Criar orçamento imediatamente
    ↓
Gerar PDF pela primeira vez
    ↓
Pedir identidade profissional
    ↓
Nome
Empresa
Telefone
Logo opcional
    ↓
Gerar documento profissional
```

Conta/e-mail/senha deve continuar sendo associada a benefícios como backup, sincronização e uso em outro aparelho.

---

# 3. UX/UI — HOME

## Prioridade: P0

A Home deve deixar de ser apenas uma porta para "Novo orçamento".

Ela deve funcionar como um painel simples do negócio.

### Estrutura sugerida

```text
Bom dia, [Nome] 👋

RESUMO
R$ X em orçamentos
R$ X aguardando resposta
R$ X aprovados
R$ X recebidos

[ + Novo orçamento ]

PENDÊNCIAS
- João — R$ 5.800 — aguardando resposta
- Maria — R$ 3.200 — pagamento pendente

ATALHOS
[Clientes] [Orçamentos]
[Catálogo] [Recibos]
```

### Regras

- Não transformar a Home em dashboard complexo.
- Mostrar somente informações acionáveis.
- Priorizar pendências.
- Usar hierarquia visual clara.
- A ação principal deve continuar sendo `Novo orçamento`.

---

# 4. UX/UI — IDENTIDADE POR PROFISSÃO

## Prioridade: P0

O aplicativo possui estrutura genérica por baixo, mas a experiência deve ser contextualizada.

No onboarding/perfil:

> **Qual é o seu principal serviço?**

Opções iniciais:

- Pintor;
- Pedreiro;
- Eletricista;
- Encanador;
- Gesseiro;
- Azulejista;
- Empreiteiro;
- Outro.

## O ofício deve alterar:

- serviços sugeridos;
- unidades;
- exemplos;
- textos;
- atalhos;
- categorias;
- dados de exemplo.

### Regra importante

Não criar arquiteturas diferentes por profissão.

Usar:

> **mesma estrutura + dados/configuração específicos do ofício.**

---

# 5. CATÁLOGO / LISTA DE PREÇOS

## Prioridade: P0

A lista de preços é uma das funcionalidades estratégicas de retenção do produto.

Objetivo:

> o primeiro orçamento é rápido; o segundo deve ser ainda mais rápido.

### Estrutura

```text
MEUS SERVIÇOS

Pintura de parede
m² | R$ 18,00

Massa corrida
m² | R$ 12,00

Selador
m² | R$ 5,00
```

### Funcionalidades

- adicionar serviço;
- editar;
- excluir;
- categoria;
- unidade;
- preço;
- duplicar serviço;
- reajustar preços;
- filtrar por categoria.

### Sugestões

Pré-carregar serviços por profissão com:

- nome;
- unidade;
- preço vazio.

Nunca assumir preço regional como verdade.

---

# 6. UX/UI — FLUXO DE ORÇAMENTO

## Prioridade: P0

Substituir o formulário longo por um fluxo guiado.

### Wizard

```text
1. CLIENTE
2. MEDIÇÃO
3. SERVIÇOS
4. CONDIÇÕES
5. REVISÃO
6. ENVIO
```

### Etapa 1 — Cliente

- selecionar cliente existente;
- criar cliente;
- importar contato da agenda;
- telefone;
- endereço da obra.

Campos opcionais devem ficar recolhidos por padrão.

---

### Etapa 2 — Medição

Usar a geometria bruta já definida no projeto:

- comprimento;
- largura;
- altura;
- portas;
- janelas;
- outros vãos quando aplicável.

As grandezas devem continuar sendo derivadas:

- área de piso;
- área de teto;
- área de parede menos vãos;
- perímetro;
- perímetro útil;
- volume.

Não criar um único campo genérico `area`.

---

### Etapa 3 — Serviços

Permitir:

- adicionar serviço do catálogo;
- quantidade automática da medição;
- alterar quantidade;
- unidade;
- preço;
- mão de obra;
- material;
- desconto.

Mostrar total em tempo real.

---

### Etapa 4 — Condições

- prazo;
- validade;
- forma de pagamento;
- observações.

Campos opcionais devem permanecer compactos.

---

### Etapa 5 — Revisão

Mostrar:

- cliente;
- serviços;
- quantidades;
- valores;
- desconto;
- total;
- prazo;
- validade;
- pagamento.

A ação principal:

> **Gerar orçamento**

---

### Etapa 6 — Envio

Oferecer:

- PDF;
- imagem;
- compartilhar;
- WhatsApp.

Priorizar a experiência de compartilhamento.

---

# 7. IMPORTAÇÃO DE CONTATO

## Prioridade: P0/P1

Ao criar cliente:

```text
Adicionar cliente

[ Digitar manualmente ]

ou

[ Selecionar da agenda ]
```

Importar principalmente:

- nome;
- telefone.

Não pedir permissões antes de o recurso ser utilizado.

---

# 8. FICHA DO CLIENTE

## Prioridade: P0/P1

A ficha deve ser uma central de ação, não apenas consulta.

### Exemplo

```text
JOÃO DA SILVA

[WhatsApp] [Ligar]

OBRAS
- Reforma residencial

ORÇAMENTOS
- R$ 5.800 — Aguardando
- R$ 4.200 — Aceito

PAGAMENTOS
- R$ 2.000 recebido
- R$ 3.800 restante

[ Novo orçamento ]
```

Ações rápidas:

- WhatsApp;
- ligar;
- nova obra;
- novo orçamento;
- visualizar histórico.

---

# 9. STATUS DO ORÇAMENTO

## Prioridade: P0

Estados mínimos:

```text
RASCUNHO
↓
ENVIADO
↓
AGUARDANDO RESPOSTA
↓
ACEITO / RECUSADO
```

Não adicionar neste momento estados que puxem o produto para gestão de execução da obra.

---

# 10. FOLLOW-UP

## Prioridade: P1

O app deve ajudar o profissional a não perder oportunidades.

Exemplo:

```text
João da Silva
R$ 5.800
Enviado há 2 dias

[ Enviar lembrete ]
```

Mensagem inicial sugerida:

> Olá João, tudo bem? Passando para saber se conseguiu analisar o orçamento que enviei. Qualquer dúvida, estou à disposição.

### Futuramente

Lembretes automáticos:

- 2 dias;
- 5 dias;
- outros intervalos configuráveis.

Não enviar automaticamente sem consentimento explícito do usuário.

---

# 11. PAGAMENTOS DO ORÇAMENTO

## Prioridade: P1

Não transformar em financeiro completo.

Apenas acompanhar o que nasceu de um orçamento.

Exemplo:

```text
ORÇAMENTO
R$ 8.000

Entrada
R$ 2.000 ✅

Parcela 2
R$ 2.000

Parcela 3
R$ 2.000

Final
R$ 2.000

RECEBIDO
R$ 2.000

RESTANTE
R$ 6.000
```

Estados:

- não pago;
- parcial;
- pago.

---

# 12. RECIBO

## Prioridade: P1

Ao registrar pagamento:

```text
Pagamento registrado ✓

[ Gerar recibo ]
[ Enviar WhatsApp ]
```

O recibo deve usar os dados do profissional e do cliente já cadastrados.

---

# 13. DUPLICAR ORÇAMENTO

## Prioridade: P0

A duplicação já existe e deve receber uma UX melhor.

Opção:

> **Usar orçamento anterior**

Ao duplicar:

```text
O que deseja manter?

☑ Serviços
☑ Preços
☑ Condições
☐ Cliente
```

Objetivo:

> criar um novo orçamento com o mínimo de edição possível.

---

# 14. MODELOS DE ORÇAMENTO

## Prioridade: P1 / PRO

Permitir criar modelos:

```text
MEUS MODELOS

Pintura residencial
Pintura comercial
Reforma de banheiro
Instalação elétrica
```

Um modelo pode conter:

- serviços;
- preços;
- condições;
- observações;
- prazo padrão.

Ao criar orçamento:

```text
[ Começar do zero ]

[ Usar modelo ]
```

---

# 15. PDF / IMAGEM

## Prioridade: P0

O documento final é parte central do produto.

Ele deve parecer um orçamento profissional, não um relatório de aplicativo.

### Deve conter

- logo;
- nome profissional/empresa;
- telefone;
- cliente;
- obra;
- número do orçamento;
- data;
- validade;
- serviços;
- quantidades;
- valores;
- desconto;
- total;
- prazo;
- pagamento;
- observações.

### Exportações

- PDF;
- imagem/PNG.

### Compartilhamento

- WhatsApp;
- sistema de compartilhamento.

### Regra

O PDF deve ter testes de conteúdo/layout apropriados ao projeto. Uma quebra no documento final é considerada uma quebra de reputação do usuário.

---

# 16. UX/UI — MICROCOPY

Revisar todas as telas para:

- português natural do Brasil;
- frases curtas;
- linguagem de profissional de obra;
- evitar termos técnicos de software;
- explicar por que um campo opcional existe.

Exemplo ruim:

> "Endereço complementar"

Exemplo melhor:

> "Adicionar endereço da obra"

Exemplo:

> "Telefone — usado para enviar o orçamento pelo WhatsApp."

---

# 17. UX/UI — CAMPOS OPCIONAIS

Não mostrar grandes formulários.

Padrão:

```text
Informações adicionais (opcional) ▾
```

Ao abrir:

- endereço;
- CPF/CNPJ;
- e-mail;
- observações.

Objetivo:

> reduzir carga cognitiva sem esconder funcionalidades importantes.

---

# 18. UX/UI — ESTADOS VAZIOS

Todo estado vazio deve responder:

1. O que é esta tela?
2. Por que ela está vazia?
3. O que devo fazer agora?

Exemplo:

```text
Você ainda não possui clientes.

Cadastre seu primeiro cliente para criar
um orçamento mais rápido.

[ + Adicionar cliente ]
```

Não usar somente:

> "Nenhum cliente encontrado."

---

# 19. UX/UI — FEEDBACK

Toda ação importante deve ter feedback.

Exemplos:

- orçamento salvo ✓;
- PDF gerado ✓;
- pagamento registrado ✓;
- cliente criado ✓;
- orçamento duplicado ✓.

Evitar mensagens técnicas.

---

# 20. UX/UI — CONSISTÊNCIA VISUAL

Revisar:

- espaçamentos;
- tipografia;
- tamanhos de títulos;
- botões;
- cards;
- ícones;
- campos;
- estados;
- navegação;
- diálogos;
- bottom sheets;
- loading;
- erros;
- sucesso.

### Regra

Antes de criar componente novo:

> procurar componente existente no Core.

Se genuinamente novo:

> criar de forma reutilizável e registrar no Core quando aplicável.

---

# 21. UX/UI — ACESSIBILIDADE E USABILIDADE

Revisar:

- áreas de toque;
- contraste;
- tamanho de texto;
- foco;
- teclado;
- scroll;
- comportamento em telas pequenas;
- mensagens de erro;
- estados de loading;
- uso com uma mão.

O público inclui profissionais em campo, portanto a interface deve funcionar bem em situações de uso rápido.

---

# 22. FEATURE FUTURA — HISTÓRICO DE PREÇOS

## Prioridade: P2

Não sugerir preço externo.

Mostrar apenas dados do próprio usuário.

Exemplo:

```text
Pintura de parede

Seu histórico:
Média: R$ 19,80/m²
Menor: R$ 18,00
Maior: R$ 24,00
```

Objetivo:

> ajudar o profissional a entender sua própria precificação.

---

# 23. FEATURE FUTURA — MARGEM

## Prioridade: P2 / PRO+

Adicionar futuramente:

```text
Custo estimado: R$ 3.200
Preço de venda: R$ 5.000

Lucro estimado: R$ 1.800
Margem: 36%
```

Não implementar como financeiro completo.

---

# 24. FEATURE FUTURA — IA

## Prioridade: P3

IA não deve ser prioridade antes da validação do fluxo principal.

Primeira direção recomendada:

### Medição por voz

Exemplo:

> "Sala cinco por quatro, altura de três metros, duas portas de oitenta por dois e dez e uma janela de um e cinquenta por um e vinte."

Transformar em dados estruturados:

```text
Sala
5m × 4m
Altura: 3m
Portas: 2 × 0,80 × 2,10
Janela: 1 × 1,50 × 1,20
```

Depois calcular automaticamente.

Isso é mais alinhado ao diferencial do Obrion do que simplesmente copiar orçamento por voz dos concorrentes.

---

# 25. FEATURE FUTURA — FOTO DA MEDIÇÃO

## Prioridade: P3

Permitir adicionar fotos ao ambiente/medição.

Exemplo:

```text
SALA

Medição
5 × 4 × 3

Fotos
[ Foto 1 ] [ Foto 2 ]
```

Uso futuro:

- referência;
- comprovação;
- histórico;
- eventualmente inclusão opcional no orçamento.

Não transformar isso em Diário de Obra neste App #1.

---

# 26. MONETIZAÇÃO

A decisão atual permanece:

> **Free por recurso, não por volume.**

O fluxo central não deve ser artificialmente limitado.

## Free

Priorizar:

- clientes;
- medições;
- catálogo;
- orçamentos;
- PDF;
- imagem;
- compartilhamento;
- WhatsApp;
- status;
- duplicação;
- recibos básicos;
- funcionamento offline;
- sem anúncios no MVP.

## Pro

Possíveis recursos:

- logo/personalização avançada;
- PDF sem marca Obrion;
- modelos;
- histórico avançado;
- backup;
- sincronização;
- follow-up avançado;
- controle de pagamentos;
- personalização de condições;
- relatórios básicos.

## Pro+

Possíveis recursos:

- IA;
- medição por voz;
- orçamento por voz;
- análise de margem;
- lucro;
- inteligência baseada no histórico;
- automações.

Os recursos pagos devem ser definidos somente depois de observar quais funcionalidades geram valor real.

---

# 27. O QUE NÃO IMPLEMENTAR NO APP #1

Manter explicitamente fora do escopo:

- ERP;
- estoque;
- fornecedores;
- equipe;
- cronograma;
- diário de obra;
- chat interno;
- marketplace;
- integração bancária;
- emissão fiscal;
- mapa;
- assinatura digital avançada;
- versão desktop;
- gestão completa da execução da obra.

Se uma nova feature sugerida se aproximar desses itens, a IA deve parar e avaliar se ela pertence ao App #1 ou a outro produto da família.

---

# 28. ROADMAP DE IMPLEMENTAÇÃO

## FASE 1 — POLIMENTO UX/UI

### P0 — obrigatório

- [ ] Auditoria visual de todas as telas
- [ ] Home como painel
- [ ] Dados de exemplo
- [ ] Perfil por profissão
- [ ] Serviços filtrados por profissão
- [ ] Wizard de orçamento
- [ ] Campos opcionais recolhidos
- [ ] Microcopy
- [ ] Estados vazios
- [ ] Feedback de ações
- [ ] Revisão de navegação
- [ ] Revisão de componentes
- [ ] Revisão de espaçamento/tipografia
- [ ] Revisão de loading/erro/sucesso
- [ ] Importar contato
- [ ] Ações rápidas do cliente
- [ ] Melhorar duplicação
- [ ] PDF profissional
- [ ] Exportação em imagem
- [ ] Compartilhamento WhatsApp
- [ ] Revisão completa de responsividade

### Critério de saída

Um usuário deve conseguir:

> abrir → entender → criar cliente → medir → montar orçamento → gerar documento → compartilhar

sem tutorial manual.

---

# 29. FASE 2 — RETENÇÃO

## P1

- [ ] Status de orçamento
- [ ] Área "Aguardando resposta"
- [ ] Follow-up manual
- [ ] Histórico do cliente
- [ ] Histórico de orçamentos
- [ ] Controle simples de pagamentos
- [ ] Recibo
- [ ] Modelos de orçamento
- [ ] Melhorias no catálogo
- [ ] Reajuste de preços
- [ ] Notificações úteis

### Objetivo

Fazer o usuário retornar depois do primeiro orçamento.

---

# 30. FASE 3 — CONTA E NUVEM

## P1

Após validação:

- [ ] Conta anônima
- [ ] Login por e-mail
- [ ] Backup
- [ ] Sincronização
- [ ] Recuperação de dados
- [ ] Multi-dispositivo

Não adicionar nuvem apenas porque é tecnicamente possível.

A decisão deve ser orientada pelos dados de uso.

---

# 31. FASE 4 — MONETIZAÇÃO

## P1

- [ ] Paywall
- [ ] Play Billing
- [ ] Pro
- [ ] Pro+
- [ ] Analytics de conversão
- [ ] Experimentos de paywall
- [ ] Tela de assinatura
- [ ] Gerenciamento de assinatura

Sem anúncios no MVP.

---

# 32. FASE 5 — INTELIGÊNCIA

## P2/P3

- [ ] Medição por voz
- [ ] Orçamento por voz
- [ ] IA para estruturar descrição
- [ ] Histórico de preços
- [ ] Margem
- [ ] Lucro
- [ ] Insights
- [ ] Automação de follow-up

---

# 33. KPIs

Instrumentar:

```text
Instalou
↓
Abriu
↓
Começou orçamento
↓
Criou orçamento
↓
Gerou PDF
↓
Compartilhou
↓
Cliente respondeu
↓
Orçamento aceito
↓
Pagamento registrado
↓
Voltou
↓
Assinou
```

## Métricas principais

### Aquisição

- instalações;
- origem;
- custo por instalação.

### Ativação

- tempo até primeiro orçamento;
- % que cria primeiro orçamento;
- % que gera PDF;
- % que compartilha.

### Retenção

- D1;
- D7;
- D30;
- segundo orçamento;
- terceiro orçamento.

### Comercial

- % de orçamentos aceitos;
- valor total enviado;
- valor aprovado;
- valor recebido.

### Monetização

- conversão Free → Pro;
- conversão Pro → Pro+;
- ARPU;
- churn.

---

# 34. REGRA PARA A IA ATUALIZAR OS DOCUMENTOS

Ao implementar este roadmap, a IA deve atualizar os `.md` relacionados.

## Arquivos prioritários

### `PLANO_DE_NEGOCIO_INICIAL.md`

Atualizar:

- posicionamento;
- proposta de valor;
- diferenciais;
- público;
- estratégia de retenção;
- Free/Pro/Pro+;
- roadmap;
- KPIs;
- limites de escopo.

### `docs/POSICIONAMENTO_E_FEATURES_APP1.md`

Atualizar:

- posicionamento por profissão;
- diferenciação por medição;
- UX/UI;
- home;
- onboarding;
- catálogo;
- wizard;
- follow-up;
- PDF;
- roadmap de features.

### `docs/ANALISE_CONCORRENCIA_E_ESCOPO.md`

Atualizar somente quando uma decisão nova for resultado direto da análise de concorrência.

Não adicionar features apenas para "igualar" concorrentes.

### `docs/ANALISE_E_MELHORIAS.md`

Registrar:

- decisões;
- riscos;
- correções;
- mudanças estratégicas;
- conflitos encontrados entre documentação e código.

### `APP_FACTORY_CORE.md`

Registrar apenas componentes/módulos realmente reutilizáveis.

Não extrair para o Core prematuramente.

---

# 35. REGRA DE CONSISTÊNCIA DOS `.md`

Depois de qualquer alteração relevante:

1. procurar contradições entre documentos;
2. atualizar a versão/data quando aplicável;
3. remover decisões antigas que foram substituídas;
4. manter uma única decisão vigente;
5. não deixar roadmap antigo contradizendo roadmap novo;
6. não afirmar que uma feature existe se ela ainda não foi implementada;
7. separar claramente:
   - planejado;
   - em desenvolvimento;
   - implementado;
   - validado;
   - adiado;
   - descartado.

---

# 36. REGRA DE IMPLEMENTAÇÃO PARA A IA

Antes de programar uma feature:

1. verificar este roadmap;
2. verificar `CLAUDE.md`;
3. verificar `APP_FACTORY_RULES.md`;
4. verificar `APP_FACTORY_CORE.md`;
5. verificar o código existente;
6. reutilizar componentes existentes;
7. implementar a menor solução que resolva o problema;
8. testar;
9. atualizar documentação;
10. registrar decisão relevante.

Não criar uma arquitetura nova para uma feature que pode ser resolvida com dados/configuração.

---

# 37. REGRA DE PRIORIDADE

Quando houver conflito entre "mais features" e "melhor UX":

> **Escolher melhor UX.**

Quando houver conflito entre "feature concorrente" e "diferencial do Obrion":

> **Priorizar o diferencial do Obrion.**

Quando houver conflito entre "velocidade de desenvolvimento" e "produto bem acabado":

> **Priorizar acabamento nas telas e fluxo principal.**

Quando houver dúvida sobre escopo:

> **Perguntar: isso ajuda diretamente o profissional a sair do local com um orçamento profissional e acompanhar o resultado?**

Se não:

> provavelmente pertence a outro app.

---

# 38. VISÃO FINAL DO APP #1

O Obrion Orçamentos deve ser percebido como:

> **O aplicativo que o profissional abre quando recebe um cliente e precisa transformar uma visita em orçamento.**

Fluxo ideal:

```text
CLIENTE
  ↓
MEDIÇÃO
  ↓
CÁLCULO AUTOMÁTICO
  ↓
SERVIÇOS
  ↓
ORÇAMENTO
  ↓
PDF / IMAGEM
  ↓
WHATSAPP
  ↓
AGUARDANDO RESPOSTA
  ↓
ACEITO
  ↓
PAGAMENTO
  ↓
RECIBO
```

A evolução futura adiciona inteligência e automação sem alterar essa essência.

---

# 39. DECISÃO ESTRATÉGICA

O App #1 não precisa vencer os concorrentes por quantidade de funcionalidades.

Precisa vencer por:

> **experiência + medição + velocidade + contexto profissional + acompanhamento comercial.**

O produto deve parecer simples na superfície e poderoso quando necessário.

**Primeiro tornar o fluxo principal excelente. Depois adicionar inteligência.**

---

# 10. docs/PROGRESSO_ROADMAP_UX_UI.md

# Progresso — Roadmap UX/UI e Features (App #1)

**Fonte:** `docs/ROADMAP_UX_UI_E_FEATURES_APP1.md` (adicionado 24/08/2026).
**Como usar este arquivo:** é o checklist vivo desse roadmap — cada item vira `[x]` só quando implementado de verdade (código no `main`, `flutter analyze`/`flutter test` passando), com uma nota curta de onde/como. Se pegar este projeto numa sessão nova (IA diferente ou não), comece por aqui: mostra o que já saiu do papel e o que ainda falta, sem precisar reler o roadmap inteiro linha por linha. Atualize os checkboxes conforme for implementando — não deixe o roadmap fonte e este arquivo divergirem.

**Regra de ouro herdada do roadmap (seção 37):** UX melhor > mais features. Diferencial do Obrion (medição integrada) > copiar concorrente. Acabamento no fluxo principal > velocidade de desenvolvimento.

---

## FASE 1 — Polimento UX/UI (P0, seção 28 do roadmap)

| # | Item | Status | Nota |
|---|---|---|---|
| 1 | Auditoria visual de todas as telas | 🔶 Parcial (24/08/2026) | Passe restrito a **cor + espaçamento**: confirmado por grep que não há `Colors.*` (Material) hardcoded em nenhuma tela — só `PdfColors.*` legítimo nos geradores de PDF; e as 75 ocorrências de `SizedBox`/`EdgeInsets` com número solto em `budget_form_screen.dart`/`services_screen.dart`/`client_form_screen.dart`/`clients_screen.dart` trocadas por tokens `AppSpacing.*`. **Não** cobre navegação, componentes, tipografia nem responsividade (itens 11/12/13/21 continuam pendentes à parte). |
| 2 | Home como painel | ✅ Feito (24/08/2026) | `lib/screens/home_screen.dart` + `BudgetsRepository.loadHomeSummary()` — resumo (em orçamentos / aguardando / aprovados / recebidos) + lista de pendências (orçamentos "Enviado", tocável, leva direto pro orçamento). Grade de atalhos (Clientes/Catálogo/Recibos/Listas) **não** entrou — já é redundante com a barra inferior, decisão registrada no `CHANGELOG.md`. |
| 3 | Dados de exemplo | ✅ Feito | `lib/repositories/example_data_seeder.dart` — cliente + orçamento `[exemplo]`, ação "Ver um exemplo" nos estados vazios de Clientes/Orçamentos. |
| 4 | Perfil por profissão | ✅ Feito | Onboarding pergunta "O que você faz?" (múltipla escolha), editável em Ajustes → "Seus ofícios". `Trade` enum em `database/enums.dart`. |
| 5 | Serviços filtrados por profissão | ✅ Feito | `ServicesRepository.populateDefaultServices(trades:)` — "Sugestões" na Lista de Preços filtra pelo ofício do perfil. |
| 6 | Wizard de orçamento | ⏸️ Pendente — decisão deliberada | Avaliado e adiado de propósito (ver plano de lote de 24/08/2026): `budget_form_screen.dart` hoje tem ~1040 linhas, uma tela só, sem sub-widgets. Extrair com segurança é trabalho isolado, maior risco de regressão — não bundlar com outras mudanças. **Tensão a resolver:** este roadmap marca como P0 obrigatório; decisão anterior tratou como "fora deste lote". Quem continuar precisa decidir explicitamente se entra agora. |
| 7 | Campos opcionais recolhidos | ✅ Feito | Formulário de cliente: cabeçalho colapsável (seta garantida, controlado à mão) escondendo CPF/CNPJ, Rua, Número, Bairro, Complemento, Observações. |
| 8 | Microcopy | 🔶 Parcial (24/08/2026) | Telefone → "Com telefone, dá pra chamar o cliente no WhatsApp direto da ficha"; + as 4 mensagens de estado vazio reescritas (ver item 9). Ainda não houve revisão completa tela por tela contra a seção 16 do roadmap (rótulos de botão, validações, diálogos de confirmação). |
| 9 | Estados vazios | ✅ Feito (24/08/2026) | As 4 telas com `AppEmptyState` (`clients_screen.dart`, `services_screen.dart`, `client_detail_screen.dart`, `budgets_list_screen.dart`) reescritas contra as 3 perguntas da seção 18 ("o que é / por que vazio / o que fazer"). De quebra, corrigido um bug de microcopy em `services_screen.dart`: mostrava a mesma mensagem pra "sem serviço nenhum" e "busca sem resultado" — agora distingue, igual `clients_screen.dart` já fazia. |
| 10 | Feedback de ações | ✅ Feito | `AppSnackBar` em toda ação relevante (salvar, excluir, duplicar, etc.), ícone muda por tipo. |
| 11 | Revisão de navegação | ⏸️ Pendente | Sem passe formal. |
| 12 | Revisão de componentes | ⏸️ Pendente | Sem passe formal — mas nenhum componente novo foi criado fora do padrão `App*` do Design System nesta rodada. |
| 13 | Revisão de espaçamento/tipografia | ⏸️ Pendente | Sem passe formal. |
| 14 | Revisão de loading/erro/sucesso | ⏸️ Pendente | `AppLoading`/`AppError` existem e são usados consistentemente; não houve auditoria dedicada. |
| 15 | Importar contato | ⏸️ Pendente — **mudança nativa** | Precisa de `flutter_contacts` (ou similar) + permissão `READ_CONTACTS` no `AndroidManifest.xml` → só entra em vigor num release completo (não patch), exige reinstalação. Avaliado em 24/08/2026, não implementado ainda. |
| 16 | Ações rápidas do cliente | ✅ Feito | Botões "WhatsApp"/"Ligar" na ficha do cliente (`lib/utils/phone_actions.dart`), sem `canLaunchUrl` (evita precisar de `<queries>` no manifest — continua patchável). |
| 17 | Melhorar duplicação | ✅ Feito (24/08/2026), parcial | `BudgetsRepository.duplicate()` já existia mas estava **órfão** (nenhuma tela chamava desde que `budgets_screen.dart` foi removido) — corrigido: menu ⋮ no orçamento → "Duplicar orçamento". A UX refinada do roadmap ("O que deseja manter? ☑ Serviços ☑ Preços ☐ Cliente") **não** entrou — duplicar hoje sempre copia serviços/preços/condições pro mesmo cliente, como já era antes de virar órfão. |
| 18 | PDF profissional | ✅ Feito | Descrição da obra, assinatura (profissional + contratante com CPF/CNPJ), todos os campos da seção 15 do roadmap já presentes. |
| 19 | Exportação em imagem | ✅ Feito | `BudgetShareService.shareAsImage`. |
| 20 | Compartilhamento WhatsApp | ✅ Feito | Via `share_plus` (folha do sistema). |
| 21 | Revisão completa de responsividade | ⏸️ Pendente | Sem passe formal — só testado no aparelho do fundador. |

**Critério de saída da Fase 1 (seção 28):** *"abrir → entender → criar cliente → medir → montar orçamento → gerar documento → compartilhar, sem tutorial manual"* — o fluxo funciona ponta a ponta hoje, mas os itens `⏸️`/`🔶` acima (principalmente wizard e auditoria visual) são o que falta pra dizer que a Fase 1 está **fechada**, não só "funcional".

---

## FASE 2 — Retenção (P1, seção 29 do roadmap)

| # | Item | Status | Nota |
|---|---|---|---|
| 1 | Status de orçamento | ✅ Feito | `rascunho → enviado → aceito/recusado`, um toque. |
| 2 | Área "Aguardando resposta" | ✅ Feito | Home (pendências) + chip na lista de orçamentos. |
| 3 | Follow-up manual | ✅ Feito (24/08/2026) | Botão "Enviar lembrete" (WhatsApp com mensagem pré-pronta, `lib/utils/follow_up_message.dart`) na Home (pendências) e na aba Orçamentos, pra qualquer orçamento "Enviado" com telefone salvo. Nunca envia sozinho — só pré-preenche a conversa. |
| 4 | Histórico do cliente | ✅ Feito | `client_detail_screen.dart`. |
| 5 | Histórico de orçamentos | ✅ Feito | `BudgetsListScreen`. |
| 6 | Controle simples de pagamentos | ✅ Feito | `payments` + resumo Recebido/Pendente no orçamento. |
| 7 | Recibo | ✅ Feito | `ReceiptPdfGenerator`. |
| 8 | Modelos de orçamento | ⏸️ Pendente | Nada implementado — schema novo necessário (`templates`?). Marcado P1/PRO no roadmap. |
| 9 | Melhorias no catálogo | ✅ Feito (24/08/2026) | Reajuste em massa (já feito antes) + categoria/filtro por categoria (seção 5 do roadmap): `services.category` (schema v5→v6, opcional, texto livre — mesma regra de "nunca sugerir preço" aplicada aqui, sem lista fixa inventada), chips de filtro na Lista de Preços (`lib/utils/service_filter.dart`, lógica pura testada). "Duplicar serviço" (também citado na seção 5) não entrou — não avaliado ainda se vale o esforço. |
| 10 | Reajuste de preços | ✅ Feito | Ícone "Reajustar" na Lista de Preços, aceita percentual negativo. |
| 11 | Notificações úteis | ✅ Feito | Lembrete "aguardando resposta" (3 dias) + lembrete de validade (1 dia antes). |

---

## FASE 3 — Conta e Nuvem (P1, seção 30)

Não iniciada — aguardando ★ Validação, conforme roadmap vigente do `CLAUDE.md`. Nenhum item desta fase deve ser adiantado "porque é tecnicamente possível" (regra explícita do roadmap).

## FASE 4 — Monetização (P1, seção 31)

Não iniciada — mesma dependência da Fase 3.

## FASE 5 — Inteligência (P2/P3, seção 32)

Não iniciada — nenhum item de IA deve ser feature de lançamento (regra já em `CLAUDE.md`).

---

## Achados durante esta rodada (24/08/2026) que valem registrar

- **`BudgetsRepository.duplicate()` estava órfão** — mesma classe de bug já vista com `MeasurementsRepository.softDeleteMeasurement()`: método existe, testado, mas nenhuma tela chamava. Motivo provável: perdido quando `budgets_screen.dart` foi removido na unificação do histórico do cliente. Corrigido nesta rodada — mas vale conferir se não há mais nenhum método "órfão" no repositório (busca rápida: grep por métodos públicos do repositório vs. chamadas em `lib/screens/`).
- **Home "painel" exigiu uma consulta nova** (`loadHomeSummary`) que varre `budgets`/`budget_items`/`payments`/`clients` inteiros e agrega em memória — aceitável pro volume de um profissional solo, mas **não escala** se o app crescer pra uso com muitos orçamentos/ano. Se isso um dia virar perceptível (tela lenta pra abrir), é o primeiro lugar a otimizar (mover a agregação pra SQL).

---

## Pendências de consistência entre documentos (seção 35 do roadmap)

O roadmap pede uma varredura de contradições entre os `.md` sempre que uma mudança relevante acontece. **Isso não foi feito nesta rodada** — ficou de fora de propósito, pra não misturar "implementar melhorias de UX" com "reescrever 5 documentos de uma vez" no mesmo lote. Pendente, na ordem que o próprio roadmap sugere (seção 34):

- [ ] `PLANO_DE_NEGOCIO_INICIAL.md` — atualizar posicionamento/diferenciais pra refletir a home-painel e a promessa "medição + orçamento" (já defendida em `ANALISE_CONCORRENCIA_E_ESCOPO.md`, Parte 4).
- [ ] `docs/POSICIONAMENTO_E_FEATURES_APP1.md` — Parte 4 já lista vários destes itens como "ideias"; marcar os que saíram do papel (ver tabela acima) em vez de deixar como sugestão em aberto.
- [ ] Resíduos de AdMob em `PLANO_DE_NEGOCIO_INICIAL.md`/`APP_FACTORY_RULES.md`/`APP_FACTORY_CORE.md` — já identificados em `POSICIONAMENTO_E_FEATURES_APP1.md`, Parte 6, nunca corrigidos.
- [ ] Conflito de tema `APP_FACTORY_RULES.md` §9 (tokens antigos: `primary`/`secondary`/`background`) vs. `APP_FACTORY_CORE.md` §8 (seed color + `ColorScheme.fromSeed`, o que o código real usa) — mesmo achado, nunca corrigido.
- [ ] `APP_FACTORY_CORE.md` — registrar só o que comprovadamente virou padrão reutilizável (regra da seção 34 do roadmap); não adiantar módulos especulativos.

---

## Próximos passos sugeridos (ordem de retorno/esforço)

1. ~~Follow-up manual~~ ✅ feito 24/08/2026.
2. ~~Auditoria visual (cor+espaçamento) + microcopy + estados vazios~~ ✅ feito 24/08/2026 — escopo restrito a espaçamento/cor (item 1) e às 4 telas com `AppEmptyState` (itens 8/9); navegação, componentes, tipografia e responsividade continuam pendentes.
3. **Decidir o wizard** (Fase 1, item 6) — tensão real entre este roadmap (P0) e a decisão anterior de adiar; precisa de conversa com o fundador antes de começar, é a maior mudança estrutural pendente.
4. **Importar contato** (Fase 1, item 15) — só quando houver disposição pra um release completo (não patch) — bom candidato a agrupar com outras mudanças nativas se/quando surgirem.
5. ~~Categoria no catálogo~~ ✅ feito 24/08/2026 — `services.category` + chips de filtro na Lista de Preços.
6. **Revisão de navegação/componentes/tipografia/responsividade** (Fase 1, itens 11/12/13/21) — o que sobrou da "auditoria visual" original; nenhum achado concreto ainda, precisa de passe formal tela por tela.
7. Varredura de consistência dos documentos (seção acima) — baixo risco de código, mas trabalhoso; fazer numa sessão dedicada só a isso.

---

# 11. CHANGELOG.md

# Changelog

Formato baseado em [Keep a Changelog](https://keepachangelog.com/pt-BR/1.1.0/), versionamento em [SemVer](https://semver.org/lang/pt-BR/).

## [Unreleased]

### Added
- **Follow-up manual**: botão "Enviar lembrete" (WhatsApp com mensagem pré-pronta, `lib/utils/follow_up_message.dart`) em qualquer orçamento "Enviado" com telefone salvo — na Home (pendências) e na aba Orçamentos. Nunca envia sozinho, só pré-preenche a conversa (`PhoneActions.openWhatsApp` ganhou parâmetro `message`).
- **`docs/ROADMAP_UX_UI_E_FEATURES_APP1.md`** (trazido pelo fundador, 24/08/2026) — novo roadmap de UX/UI/features, ponto de partida pra elevar o app a nível profissional antes da ★ Validação. **`docs/PROGRESSO_ROADMAP_UX_UI.md`** é o checklist vivo dele, cruzado contra o código real — ver esse arquivo pra status detalhado por item.
- **Home virou painel** (`HomeScreen`, `BudgetsRepository.loadHomeSummary`): resumo financeiro (em orçamentos / aguardando resposta / aprovados / recebidos) + lista de pendências (orçamentos "Enviado", tocável, leva direto pro orçamento). Grade de atalhos do concorrente não entrou — decisão já registrada de que é redundante com a barra inferior.
- **Duplicar orçamento voltou a funcionar** — `BudgetsRepository.duplicate()` já existia e era testado, mas ficou órfão (nenhuma tela chamava) desde que `budgets_screen.dart` foi removido na unificação do histórico do cliente. Menu ⋮ no orçamento agora tem "Duplicar orçamento".
- `DOCUMENTACAO_COMPLETA.md` — todos os `.md` do projeto concatenados num arquivo só, pra leitura/repasse fácil (não é fonte de verdade, os originais continuam sendo).
- **Auditoria de espaçamento**: as 75 ocorrências de `SizedBox(height/width:)`/`EdgeInsets.all()` com número solto em `budget_form_screen.dart`, `services_screen.dart`, `client_form_screen.dart` e `clients_screen.dart` trocadas pelos tokens `AppSpacing.*` — sem mudança visual, fecha uma violação do princípio 6 do `CLAUDE.md` (cor/espaçamento sempre por token). Confirmado por grep que não há cor hardcoded (`Colors.*`) em nenhuma tela.
- **Estados vazios reescritos** contra a seção 18 do roadmap (o que é / por que está vazio / o que fazer agora) nas 4 telas com `AppEmptyState` — Clientes, Lista de Preços, ficha do cliente e Orçamentos. De quebra, corrigido bug de microcopy em `services_screen.dart`: mostrava a mesma mensagem pra "sem serviço nenhum" e "busca sem resultado".
- **Categoria na Lista de Preços**: `services.category` (schema v5→v6), campo opcional no formulário de serviço, chips "Todas"/<categoria> pra filtrar (combina com a busca por nome já existente). Texto livre, sem lista pré-definida — mesma regra de "nunca sugerir preço" aplicada à categoria.

### Fixed
- **4 básicos que a análise de concorrência deixou passar**: Ligar/WhatsApp direto da ficha do cliente (fecha uma promessa que a microcopy já fazia sem nunca ter sido construída); CPF/CNPJ do cliente ligado ao PDF e ao recibo (dado já capturado desde a rodada anterior, nunca usado em lugar nenhum); e-mail do cliente (`clients.email`, schema v4→v5); "Válido até" visível direto na tela do orçamento, não só dentro do sheet de Detalhes.
- **App travava (bloco cinza) ao escolher "Válido até" no orçamento** — `AppDatePicker` formata com `DateFormat(..., 'pt_BR')`, mas o app nunca chamava `initializeDateFormatting('pt_BR')` (só os testes chamavam, isolado — nunca propagou pro `main.dart` de verdade). Achado em teste manual real no aparelho. Corrigido: `main.dart` inicializa o locale no boot, e o app ganhou `flutter_localizations` + `locale: pt_BR` configurado (também corrige o calendário nativo aparecendo em inglês). Teste de regressão novo em `test/widgets/app_date_picker_test.dart`.
- **Botões pouco visíveis** (Desconto, Registrar pagamento, Emitir recibo no orçamento; reajuste de preços na Lista de Preços; "Usar medição" ao adicionar item) — trocados de `TextButton`/ícone solto pra botões com contorno/preenchimento visivelmente clicáveis, achado em teste manual.
- Removida a confirmação obrigatória ao adicionar item acima de R$ 10.000 — atrapalhava mais do que ajudava, removido a pedido do fundador.
- **Formulário de cliente ganhou campos estruturados de endereço** — CPF/CNPJ, Rua, Número e Bairro (`clients.document`/`street`/`streetNumber`/`neighborhood`, schema v3→v4), junto com um cabeçalho colapsável com seta garantida (trocado o `ExpansionTile` padrão por um controlado à mão, pra não depender do ícone default do widget).
- **Excluir medição não tinha nenhum caminho na UI** — `MeasurementsRepository.softDeleteMeasurement` existia no repositório, mas nenhuma tela chamava. Editar cliente/medição e gerenciar vãos já funcionavam. Adicionado menu (⋮ visível, não long-press, mesmo raciocínio de baixa familiaridade digital do resto do app) em cada item da linha do tempo do cliente com "Editar"/"Excluir", só pra medições — orçamento fica de fora desse menu (ciclo de vida próprio via status).
- **App travando em tela branca ao abrir** — causado pelo R8/minificação (religado em 23/08, nunca testado num aparelho real) removendo/renomeando algo que o Firebase precisa achar via reflexão em runtime; `Firebase.initializeApp()` travava antes de `runApp()` rodar, sem handler de erro do Flutter ativo ainda. `flutter analyze`/`flutter test` não pegam esse tipo de bug (rodam contra o Dart VM, não o APK minificado). Revertido `isMinifyEnabled`/`isShrinkResources` pra `false` em `android/app/build.gradle.kts`. Versão bumped pra `0.1.5+5`.
- `build-distribute.yml` (Firebase App Distribution) estava disparando a cada push no `main` desde antes da migração pro Shorebird OTA, sem ninguém notar — provável causa do fundador ter instalado um build fora do fluxo Shorebird por engano. Trocado pra disparo manual (`workflow_dispatch`).

### Added
- **Camada de ofício** (`docs/POSICIONAMENTO_E_FEATURES_APP1.md`, Parte 3): a 3ª tela do onboarding, antes só informativa, agora pergunta "O que você faz?" (múltipla escolha — pedreiro, pintor, gesseiro, azulejista, eletricista, encanador), pulável como as outras. Editável depois em Ajustes (nova seção "Seus ofícios", mesmo seletor de chips). Guardado em `app_settings` via `ProfileRepository` (`Trade` enum novo em `database/enums.dart`), sem migração de schema — mesmo padrão chave/valor do nome/telefone/logo. O botão "Sugestões" da Lista de Preços agora filtra os 23 serviços padrão pelo(s) ofício(s) do perfil — antes despejava tudo de uma vez mesmo pra quem só faz um; perfil sem ofício informado mantém o comportamento antigo (insere tudo).
- **Lote de polimento pós-análise de concorrência** (`docs/ANALISE_CONCORRENCIA_E_ESCOPO.md`, `docs/POSICIONAMENTO_E_FEATURES_APP1.md`), 11 melhorias em commits pequenos e verificáveis:
  - **Descrição da obra no PDF**: campo opcional (`budgets.jobDescription`, schema v2→v3) renderizado num bloco "Projeto / Obra" acima da tabela de itens.
  - **Assinatura no PDF**: duas linhas (profissional + contratante), sem CPF/CNPJ — transforma o orçamento num mini-contrato informal, não confundir com assinatura digital ICP-Brasil.
  - **Alerta de valor fora do padrão**: confirma antes de adicionar um item cujo total passe de R$ 10.000 — motivado por evidência real (619 m² aceito sem aviso num concorrente).
  - **Desconto percentual**: seletor Valor fixo/Percentual no orçamento; só `discountCents` é persistido, percentual é o modo de entrada.
  - **Reajuste de preços em massa**: ícone na Lista de Preços aplica um percentual (aceita negativo) a todos os serviços com preço já definido.
  - **Lembrete de validade**: `budgets.validUntil` (já existia, nunca esteve ligado a nada) agora agenda um lembrete local 1 dia antes de vencer.
  - **Campos opcionais recolhidos no formulário de cliente**: Endereço/Observações num `ExpansionTile` fechado por padrão, com microcopy explicando o ganho do telefone.
  - **Dados de exemplo `[exemplo]`**: ação "Ver um exemplo" nos estados vazios de Clientes/Orçamentos, cria 1 cliente + 1 orçamento de demonstração, soft-deletáveis como qualquer registro real.
  - **Ponte medição → item de orçamento**: botão "Usar medição" nos dois fluxos de adicionar item, preenche a quantidade a partir da grandeza derivada certa pra unidade do serviço. Achado: orçamentos nunca guardavam `projectId` (nenhuma tela passava esse valor) — a busca usa `clientId`.
  - **Emitir recibo**: motor de PDF reduzido (`ReceiptPdfGenerator`), botão na seção de pagamentos quando já houver valor recebido.
  - Grade de atalhos na Home foi avaliada e **descartada de propósito** — já existe uma decisão documentada contra atalhos redundantes com a barra inferior, e as ações do concorrente (Novo Cliente, Lista de Preços, Orçamentos) já são abas próprias aqui.

### Changed
- R8/minificação religada (`android/app/build.gradle.kts`, `isMinifyEnabled`/`isShrinkResources = true` + `proguard-rules.pro` novo, vazio de propósito) — motivo original de ter desligado (build local lento) não existe mais desde que os releases passaram a rodar na nuvem. Mudança nativa (Gradle): só entra em vigor num release completo, não num patch. Versão bumped pra `0.1.4+4`, primeira a usar o esquema `x.y.build+build`.

### Added
- Controle básico de pagamentos por orçamento (`lib/repositories/payments_repository.dart`, `payments` — semente do "controle de pagamentos" do plano Pro, ver CLAUDE.md monetização): registra pagamentos parciais (valor + observação opcional) na tela do orçamento, mostra "Recebido"/"Pendente" calculado (nunca guardado, sempre `total - soma dos pagamentos`, nunca negativo). **Primeira migração de schema de verdade do app** (`schemaVersion` 1→2, `onUpgrade` cria a tabela nova sem apagar nada do que já existe — instalações antigas, como o celular do fundador, não perdem dado). `BudgetsRepository.watchById` agora combina três streams (`Rx.combineLatest3`: orçamento + itens + pagamentos), aplicando a correção do bug de item que não atualizava a tela também pra pagamentos.
- Aba "Orçamentos" na barra de navegação (5ª aba): `BudgetsListScreen` mostra todos os orçamentos de todos os clientes numa lista só, numerados (posição estável na ordem de criação) com nome do cliente, data e status. Botão "+" pergunta pra qual cliente e abre um orçamento novo — mesmo padrão do "+" de Clientes. Fecha a lacuna deixada pela remoção do `budgets_screen.dart` (que só listava por cliente): agora dá pra ver o negócio inteiro, não só cliente por cliente.
- "Item avulso" ao adicionar item num orçamento (`budget_form_screen.dart`): descrição livre, com escolha de unidade — não depende mais de já ter algo cadastrado na Lista de Preços.
- Histórico do cliente (`lib/screens/client_detail_screen.dart`): medições e orçamentos juntos numa linha do tempo ordenada por data, em vez de dois menus separados ("Medições" e "Orçamentos") que a pessoa tinha que descobrir escondidos no bottom sheet do cliente. Tocar num cliente na aba Clientes abre esse histórico direto; um único botão "+" oferece "Novo orçamento"/"Nova medição"; editar/excluir cliente viraram o menu (⋮) da própria tela. Consulta única (`initState`), recarregada ao voltar de uma tela de detalhe — mesmo raciocínio do resumo da Home.
- Onboarding de 3 telas na primeira abertura (`lib/screens/onboarding_screen.dart`): "Meça e cote rápido" / "Funciona sem internet" / "Tudo num toque só" — pensado pro público de baixa familiaridade digital que o CLAUDE.md descreve. Sempre pulável ("Pular" em qualquer tela) e nunca mostrado de novo depois da primeira vez (`PreferencesRepository.getOnboardingSeen`/`markOnboardingSeen`) — segue o princípio 5 do CLAUDE.md: nunca vira uma segunda barreira de entrada antes do login. `MainShell` virou `ConsumerStatefulWidget` pra checar a flag antes de montar a barra de navegação.

### Removed
- `budgets_screen.dart` e `measurements_screen.dart` (listas separadas por cliente/obra) — substituídas pelo histórico unificado em `client_detail_screen.dart`, ficaram órfãs (nada mais navegava pra elas). Rota `/measurements/:projectId` removida do `app_router.dart` pelo mesmo motivo.
- **Tema escuro** (`AppTheme.dark()`, `ThemeModeNotifier`/`themeModeProvider`, seção "Aparência" em Configurações, `PreferencesRepository.getThemeMode`/`saveThemeMode`): o esquema escuro era 100% gerado automaticamente pela seed âmbar via `ColorScheme.fromSeed`, sem ajuste manual de contraste — causa técnica real por trás do relato do fundador de cores "confusas" no escuro. Como o público do app usa ao sol/no canteiro (uso noturno atípico pra este produto), a decisão foi remover em vez de auditar/corrigir. App usa só `theme: AppTheme.light()` agora; `AppSemanticColors`/`AppSemanticPalette` mantêm só as variantes claras.

### Fixed
- **Valores em R$ sem ponto de milhar** (`R$ 95115,00` em vez de `R$ 95.115,00`) na tela do orçamento e na Lista de Preços — `formatCents`/formatação inline usavam `toStringAsFixed(2).replaceAll('.', ',')`, que só troca o separador decimal, nunca insere o de milhar. `budget_pdf_content.dart` já formatava certo (com regex de milhar) só no PDF; centralizado num único helper `lib/utils/currency_format.dart` (`formatCurrencyBrl`), reaproveitado nos três lugares — acaba a duplicação e a divergência entre tela e PDF.
- **Fundo transparente no PDF** deixava "compartilhar como imagem" ilegível em apps com tema escuro (ex.: WhatsApp): a página nunca pintava um fundo branco explícito, então o PNG gerado (`Printing.raster`) saía com fundo transparente — no visualizador escuro do WhatsApp isso virava fundo preto atrás de texto preto, invisível (só o cabeçalho da tabela aparecia, por ter fundo cinza próprio). Corrigido com `pw.PageTheme.buildBackground` pintando branco antes de qualquer conteúdo.
- **Bug real de "adicionar item" não aparecer no orçamento**: `BudgetsRepository.watchById` usava `watchSingleOrNull()` só em cima da tabela `budgets` — o Drift só sabia observar essa tabela, nunca `budget_items`. Adicionar ou remover um item grava só em `budget_items`, então a tela nunca recebia aviso pra atualizar (o item entrava no banco certinho, só que invisível até fechar e reabrir o orçamento). Corrigido combinando as duas streams com `Rx.combineLatest2` (pacote `rxdart`, puro Dart, sem risco de build nativo). Teste de regressão adicionado em `budgets_repository_test.dart` — o teste anterior não pegava esse bug porque só verificava o estado *depois* de tudo pronto, nunca uma tela já aberta recebendo a atualização ao vivo.
- "Adicionar item" no orçamento também não tinha como funcionar com a Lista de Preços vazia — o "+" abria um sheet só com uma mensagem, sem nenhum botão de ação. Resolvido junto com o "Item avulso" acima, que fica sempre disponível independente do estado da Lista de Preços.
- Build de teste distribuída via Firebase trocada de `--debug` pra `--release` (`build-distribute.yml`) — builds de debug do Flutter rodam com JIT e asserções extras, deixando qualquer animação (inclusive o teclado abrindo) visivelmente mais lenta que num aparelho de verdade. Não muda nada de infraestrutura: o tipo de build "release" já usa a chave de assinatura de debug (Fase 1.5, sem assinatura de produção ainda).
- Criar um cliente novo (pelo CTA da Home ou pelo "+" da aba Clientes) agora leva direto pra tela de Orçamentos daquele cliente (`client_form_screen.dart`), em vez de só voltar pra tela anterior. A promessa da Home ("Comece um orçamento novo") não se completava de verdade: depois de criar o cliente a pessoa ficava parada, sem saber que "Orçamentos" existia escondido no menu do cliente. Editar um cliente existente continua só voltando, como antes.

### Added
- Lembrete local de "orçamento aguardando resposta" (`lib/notifications/notification_service.dart`, pacote `flutter_local_notifications`): agendado 3 dias após um orçamento virar "Enviado", cancelado se o status mudar antes disso ou o orçamento for excluído — vive dentro de `BudgetsRepository.updateStatus`/`softDelete`, não em cada tela que os chama, pra nenhum call site esquecer. Agendamento **inexato** (`AndroidScheduleMode.inexactAllowWhileIdle`) de propósito: evita pedir a permissão especial "Alarmes e lembretes" do Android 12+, que exige liberação manual nas configurações do aparelho — folga de algumas horas no lembrete é aceitável, a permissão extra não seria pro público deste app. **Mudança nativa** (novo plugin com Gradle/AndroidManifest alterados: `multiDex`, `coreLibraryDesugaring`, permissões `POST_NOTIFICATIONS`/`RECEIVE_BOOT_COMPLETED`, dois `<receiver>`) — build local **vai travar de novo** por causa disso (mesmo padrão do bottom nav bar); publicar via `shorebird release` (não `patch`) pela nuvem (`.github/workflows/`), não localmente. Versão bumped pra `0.1.0+3`.
- Resumo no topo da Home: "N clientes" e "N aguardando resposta" (mesma regra de 3+ dias em "Enviado" do chip de `budgets_screen.dart`), reaproveitando `ClientsRepository.countActive`/`BudgetsRepository.countAwaitingResponse` — consulta única no `initState`, não stream reativa, já que a Home não precisa atualizar o número em tempo real e abrir mais streams de banco vivos no tab sempre-montado (`main_shell.dart`) reintroduziu o mesmo "Timer is still pending" já corrigido antes; resolvido trocando para busca única.
- Avançar status do orçamento em um toque direto da lista (`budgets_screen.dart`), sem precisar abrir o orçamento — fechava a lacuna do "atualizável em um toque" descrito em CLAUDE.md como mecanismo central de retenção (`BudgetsRepository.updateStatus` já existia mas só era chamado de dentro do formulário). Chip de aviso "Aguardando há Xd" no card quando um orçamento fica 3+ dias parado em "Enviado" — sinal de retenção visível sem precisar de notificação do sistema (que exigiria um pacote novo com permissão nativa, fora de escopo por ora).
- Workflow `shorebird-patch.yml` (disparo manual no GitHub Actions) para publicar patches OTA na nuvem em vez da máquina local — o build local vinha travando repetidamente no meio do `bundleRelease` do Gradle por falta de RAM disponível. Precisa do secret `SHOREBIRD_TOKEN` cadastrado no repositório (gerado uma vez via `shorebird login:ci`, passo manual do fundador).
- Passada de polimento visual (skill `frontend-design`): `AppSnackBar` (`lib/widgets/app_snackbar.dart`) substitui os 10 `SnackBar(content: Text(...))` crus espalhados pelo app por um componente único do Design System — ícone muda de forma conforme o tipo (`check_circle`/sucesso, `delete_outline`/exclusão, `error_outline`/aviso) em vez de só cor, pra não depender só de cor pra passar o significado. `AppEmptyState` ganhou o ícone dentro de um círculo (mesma linguagem visual do card de conta em Configurações) e uma entrada suave (fade + scale); `HomeScreen` ganhou um ícone de destaque, hierarquia tipográfica mais forte (`headlineSmall`) e uma entrada suave (fade + slide) no primeiro build — a tela que todo mundo vê ao abrir o app. As duas animações respeitam `MediaQuery.disableAnimations` (reduzir movimento).
- Tela de login/cadastro (`lib/screens/login_screen.dart`) e card de conta no topo de Configurações — decisão 5 do CLAUDE.md: **só interface nesta fase**, sem Supabase nem conta real. "Entrar"/"Criar conta" apenas salvam o e-mail digitado localmente (`AccountRepository`, mesmo padrão chave/valor do `ProfileRepository`) para a tela deixar de mostrar "Visitante"; sem validação de senha contra servidor, sem sessão de verdade — prepara o terreno visual para a Fase 2, quando a Supabase entra sem trocar a UI. Segue o princípio "login nunca é a primeira tela": só é alcançável a partir de Configurações, nunca bloqueia o fluxo de orçamento. `AppTextField` ganhou suporte a `obscureText` para o campo de senha.
- Barra de navegação inferior persistente (`lib/screens/main_shell.dart`, Material 3 `NavigationBar` com `IndexedStack`): Início/Clientes/Preços/Ajustes viram abas de primeiro nível em vez de rotas empilhadas — troca de aba é instantânea e preserva o estado de cada uma (rolagem, busca em andamento). `HomeScreen` perdeu o ícone de configurações e os atalhos de Clientes/Lista de Preços da AppBar, redundantes com as novas abas; ficou só com o CTA principal "Novo Cliente". Rotas `settings`/`clients`/`services` removidas de `app_router.dart`/`app_routes.dart` (agora vivem dentro da shell); `/clients/new` e `/measurements/:projectId` continuam como telas empilhadas por cima da barra. **Cada aba só monta na primeira visita** (`_visited` em `main_shell.dart`) — montar as 4 de uma vez dispara streams do banco (Clientes/Preços) e chamadas de plataforma (`PackageInfo`/Shorebird em Ajustes) simultaneamente, o que violava o invariante do `flutter_test` de não deixar timer pendente após o teste.
- Versão e patch OTA na tela de Configurações ("Versão 0.1.0 (build 1) · patch N"), pra confirmar visualmente se uma atualização (reinstalação ou patch Shorebird) realmente chegou — a versão do app não muda com patch, só o número de patch muda.
- Shorebird OTA funcionando: primeiro release publicado (0.1.0+1). Causa da lentidão/travamento anterior era o Windows Defender escaneando os arquivos do build em tempo real — resolvido com exclusões (`.gradle`, `.shorebird`, `Pub\Cache`, pasta do projeto). Daqui pra frente, mudanças de código Dart vão por `shorebird patch android` sem reinstalar.
- Editar e excluir cliente (antes só criava); editar, excluir e gerenciar múltiplos vãos (porta/janela, tipo e dimensões customizáveis) em medições, antes só um vão fixo hardcoded sem UI.
- Compartilhar orçamento como imagem (PNG), além de PDF — escolha na hora de compartilhar (`BudgetShareService.shareAsImage`, via `printing`/`Printing.raster`).
- Verificação de atualização recomendada (`UpgradeAlert` do pacote `upgrader`, checa a própria ficha da Play Store): sem efeito antes da publicação, mas o mecanismo de segurança já fica pronto para quando um patch OTA (Shorebird) ou build quebrada saírem (módulo AppUpdate do Core, nunca implementado antes). Controlado por `showUpgradeAlertProvider` — desligado nos widget tests, já que a checagem faz uma chamada de rede real que fica pendente em ambiente de teste (deixava um processo `flutter_tester.exe` travado).
- Avaliação in-app (`lib/review/review_service.dart`, pacote `in_app_review`): pedida logo após compartilhar um orçamento com sucesso — momento de sucesso, canal de aquisição orgânica mais barato disponível (módulo Review do Core, catálogo do `APP_FACTORY_CORE.md`, nunca implementado antes).
- Eventos mínimos de Analytics (`lib/analytics/analytics_service.dart`, `trackEvent` único sobre o SDK): `app_open`, `measurement_started`/`measurement_completed`, `create_budget`/`budget_created`, `budget_duplicated`, `price_list_item_created`, `pdf_generated` (com `format`: pdf/imagem), `budget_shared`. SDK estava instalado desde a Fase 0 mas nenhum evento disparava. **Nota:** `budget_shared` não leva o parâmetro `channel` pedido no CLAUDE.md — a folha de compartilhamento do sistema (`share_plus`) não informa qual app o usuário escolheu.
- Testes de conteúdo do PDF (`test/pdf/budget_pdf_content_test.dart`): conferem se cliente, itens, subtotal/desconto/total e observações vão certos pro PDF. Extraído `lib/pdf/budget_pdf_content.dart` do gerador — separa "que texto vai no PDF" de "como isso é desenhado", testável sem depender de renderização. **Nota:** golden test visual de verdade (pixel a pixel) não é viável no `flutter test` comum — `Printing.raster` exige um host de plataforma real (device/emulador via `integration_test`), que trava indefinidamente num ambiente headless. Decisão registrada em `CLAUDE.md`.
- Confirmação antes de excluir cliente, serviço ou orçamento (`AppDialog.confirm` com estilo destrutivo em vermelho), em vez de exclusão direta ao toque.
- Validadores de formulário centralizados (`lib/utils/validators.dart`: campo obrigatório, telefone, número positivo), substituindo lambdas duplicadas em cada tela.
- Filtro por status (chips: Todos/Rascunho/Enviado/Aceito/Recusado) na listagem de orçamentos (`budgets_screen.dart`).
- Preferência de tema claro/escuro/sistema, persistida em `app_settings` (`lib/repositories/preferences_repository.dart`) e selecionável em Configurações; `main.dart` carrega a preferência salva no boot em vez de fixar `ThemeMode.system`.
- Logo do profissional no cabeçalho do PDF de orçamento: seletor de imagem em Configurações (`file_picker`), arquivo salvo em `ApplicationDocumentsDirectory`, campo `logoPath` em `ProfileRepository`/`ProfessionalProfile`, renderizado em `budget_pdf_generator.dart` (falha silenciosa se o arquivo não existir mais).

- Roadmap revisado (`CLAUDE.md`, `docs/PLANO_DE_NEGOCIO_INICIAL.md`, `docs/ANALISE_E_MELHORIAS.md`): nova Fase 1.5 de polimento interno (UI/UX, features, tela de login só de interface) entre a Fase 1 e a ★ Validação, testada só pelo fundador; adoção de atualização OTA via Shorebird no lugar de reinstalação manual a cada build.
- Setup inicial do Shorebird (OTA): CLI instalada e app inicializado (`shorebird.yaml` com `app_id`), permissão `INTERNET` adicionada ao `AndroidManifest.xml`. **Pausado** — o primeiro `shorebird release android` não completou nesta máquina (suspeita de Windows Defender interferindo no build do Gradle); retomar após ajustar exclusões do Defender. Ver nota em `CLAUDE.md`, decisão 6.

### Changed
- R8/minificação desligada temporariamente em `android/app/build.gradle.kts` (release) — religar antes da Fase 4 (Play Store).

- Rótulo visível ("Sugestões") no botão de carregar sugestões de serviço por ofício em `services_screen.dart` — antes era só um ícone na barra superior, sem texto, funcionalidade central do MVP fácil de nunca ser descoberta.
- Feedback de confirmação (snackbar) ao salvar cliente, medição e serviço, e ao excluir serviço/orçamento — antes a tela só voltava em silêncio, sem indicar que a ação deu certo.

### Fixed
- Cores de status/exclusão hardcoded (`Colors.red`, `Colors.green`) em `services_screen.dart` e `budgets_screen.dart` trocadas pelos tokens de tema (`colorScheme.error`, `context.semanticColors.success`) — violavam a regra de nunca hardcodar cor fora de `app_theme.dart`.
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

---

