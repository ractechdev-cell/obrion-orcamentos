# CLAUDE.md

Guia para o Claude Code trabalhar neste repositório. Leia isto antes de gerar qualquer código.

## O projeto

**RACTECH** está construindo a **Obrion** — uma família de apps para profissionais da construção civil (pedreiro, pintor, gesseiro, azulejista, eletricista, encanador, pequeno empreiteiro), sobre uma base técnica única e reutilizável: o **Obrion Core**.

Primeiro produto: **Obrion Orçamentos** (App #1) — medir, montar orçamento e enviar ao cliente por WhatsApp em poucos minutos. Próximos da fila: Obrion Materiais (#2), Obrion Diário (#3), Obrion Medições (#4), Obrion Calculadora (#5).

**Estado atual: Fases 0 e 1 concluídas. Fase 1.5 em andamento — polimento interno (UI/UX, features, tela de login local) testado pelo próprio fundador. Ninguém externo instala o app ainda; ★ Validação (3–5 profissionais reais) só começa depois do polimento.**

Já feito: projeto Flutter (`applicationId` `br.com.ractech.obrion.orcamentos`), tema light/dark Material 3 (`lib/theme/`), navegação `go_router` (`lib/routing/`), banco local Drift/SQLite (`lib/database/`) com schema completo (`clients`, `projects`, `measurements`, `services`, `budgets`/`budget_items`, `app_settings`), DI com Riverpod, design system base (`lib/widgets/`), Crashlytics + Analytics inicializados no boot, e os módulos de negócio: **Clientes → Medições → Lista de Preços → Orçamentos** (criação, status rascunho→enviado→aceito/recusado, duplicação, soft delete) com geração de PDF e compartilhamento via `share_plus` (WhatsApp na ponta). Ver `CHANGELOG.md` para o histórico exato.

## Documentos-fonte (ler antes de gerar módulos)

- `docs/APP_FACTORY_CORE.md` — catálogo dos módulos reutilizáveis do Core (Authentication, Database, Analytics, Ads, Purchases/Subscriptions, Notifications, Settings, Theme, UI Components, User) e módulos específicos do Obrion Orçamentos.
- `docs/APP_FACTORY_RULES.md` — regras mestras: princípios, arquitetura, stack, schema de banco, monetização, autenticação, analytics, design system, tema, LGPD, publicação, testes.
- `docs/PLANO_DE_NEGOCIO_INICIAL.md` — contexto de negócio: mercado, problema, público-alvo, diferencial, roadmap, riscos, KPIs.
- `docs/ANALISE_E_MELHORIAS.md` — análise crítica do plano: riscos, lacunas e correções. **Onde este arquivo diverge dos três acima, ele explica o porquê e prevalece nos pontos técnicos já incorporados aqui.**

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

**Status da configuração (23/08/2026): pausada no meio.** CLI instalada, `shorebird login` feito, `shorebird init` rodou (`shorebird.yaml` com `app_id` já commitado, permissão `INTERNET` adicionada ao `AndroidManifest.xml`, R8/minificação desligada em `android/app/build.gradle.kts` — religar antes da Fase 4). **Falta:** o primeiro `shorebird release android` nunca terminou nesta máquina — travou duas vezes (~1h e ~40min) sem erro, com processos Gradle/Java ativos mas CPU praticamente parada; suspeita é o Windows Defender escaneando em tempo real os arquivos que o Gradle/Shorebird escrevem. Antes de retomar: rodar como Admin `Add-MpPreference -ExclusionPath` para `%USERPROFILE%\.gradle`, `%USERPROFILE%\.shorebird`, `%LOCALAPPDATA%\Pub\Cache` e a pasta do projeto (mais `-ExclusionProcess` para `java.exe`/`dart.exe`), depois repetir `shorebird release android --json`. Retomar isso só depois da rodada de UI/UX/features da Fase 1.5.

## Roadmap vigente

| Fase | Conteúdo | Estado |
|---|---|---|
| **0 — Fundação mínima** (1 sprint) | Projeto Flutter, navegação, tokens de tema, componentes que o App #1 usa de fato, banco local (Drift), Crashlytics | ✅ **concluída** |
| **1 — O fluxo que vale dinheiro** (3–4 sprints) | Clientes → Medição → Lista de preços → Orçamento → PDF → Compartilhar. **Tudo local: sem conta, sem nuvem, sem billing** | ✅ **concluída** — fluxo completo, PDF, compartilhamento (WhatsApp), duplicar/excluir |
| **1.5 — Polimento interno** (sem prazo fixo) | UI/UX, features adicionais, tela de login/perfil (só interface — decisão 5), correção de bugs. Testado só pelo fundador | 🔄 **em andamento** |
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
- **Golden test do PDF** — o teste de maior retorno do projeto. O PDF é o que chega ao cliente final; quebra de layout é quebra de reputação do usuário.
- **CI simples** (GitHub Actions) rodando `flutter analyze` + `flutter test` a cada push. Sem CI, "rodar regressão contra todos os apps" não acontece na prática.
- Teste manual de fluxo completo antes de cada release: criar cliente → medir → gerar orçamento → gerar PDF → compartilhar.
- Ao alterar um módulo do Core, rodar regressão contra **todos** os apps que o consomem, não só o mais recente.

### Revisão de tema (23/08/2026) — âmbar de segurança

Pesquisa de mercado na Play Store (busca "orçamento obra whatsapp") mostrou dezenas de concorrentes diretos (Orça Na Mão, Profissa, ConstruCalc, Orçamento PRO, ORÇA AÍ, Prummo, ConstruFácil, Orça Rápido Whatsapp, entre outros) — a maioria usa azul corporativo genérico, a mesma cor que o Obrion usava (`0xFF1565C0`). Isso não é uma escolha de marca, é o "olhar padrão de app de utilidade", e não ajuda em nada a facilidade de aprendizado do público (baixa familiaridade digital, uso ao sol/poeira no canteiro, referência diária é o WhatsApp).

**Decisão:** trocar a seed do Material 3 (`lib/theme/app_colors.dart`, `obrionSeed`) para um **âmbar de segurança** (`0xFFC2680A`). Justificativa: é a cor do próprio canteiro (capacete, colete, cone, faixa zebrada) — reconhecível sem exigir aprendizado novo — e de alto contraste para leitura ao sol. Como o app deriva toda a paleta (`ColorScheme.fromSeed`) de um único valor, a troca é cirúrgica: nenhuma tela ou widget referencia cor fora de `app_colors.dart`/`app_theme.dart`. Tokens semânticos (`success`/`warning`) mantidos como estão — já são acessíveis e não têm relação com a marca.

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
