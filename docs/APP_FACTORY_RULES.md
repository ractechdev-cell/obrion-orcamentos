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
- ✅ Busca do nome na **Google Play e App Store** feita em 21/08/2026, sem conflito encontrado (além da busca formal de anterioridade no INPI, ainda pendente — ver Seção 13 do plano de negócio).
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
