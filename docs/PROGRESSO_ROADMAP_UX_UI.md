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
| 9 | Melhorias no catálogo | 🔶 Parcial | Reajuste em massa feito; categoria/filtro por categoria (seção 5 do roadmap) não existe — `services` não tem campo de categoria. |
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
5. **Categoria no catálogo** (Fase 2, item 9) — schema pequeno, complementa o reajuste em massa já feito.
6. **Revisão de navegação/componentes/tipografia/responsividade** (Fase 1, itens 11/12/13/21) — o que sobrou da "auditoria visual" original; nenhum achado concreto ainda, precisa de passe formal tela por tela.
7. Varredura de consistência dos documentos (seção acima) — baixo risco de código, mas trabalhoso; fazer numa sessão dedicada só a isso.
