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
