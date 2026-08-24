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
