# APP_FACTORY_CORE.md

> Catálogo dos módulos reutilizáveis do **Obrion Core** (infraestrutura técnica compartilhada por toda a família de apps **Obrion**, da RACTECH).
> Este documento descreve **o que já existe (ou deve existir) pronto para reuso**, para que uma IA de programação nunca precise recriar do zero algo que já faz parte do Core. Ler em conjunto com `APP_FACTORY_RULES.md`.
>
> Estado: rascunho de especificação — ainda não implementado.
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
