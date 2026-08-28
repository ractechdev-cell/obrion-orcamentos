# Progresso — Design System Safety Industrial

**Fonte:** `docs/stitch_document_theme_generator/` — `safety_industrial/DESIGN.md`
(especificação) mais 15 telas de referência (`*/code.html` + `*/screen.png`).

**Como usar este arquivo:** checklist vivo da aplicação do design ao app.
Marque um item como feito só quando estiver no `main` com `flutter analyze`
e `flutter test` passando. Onde a implementação **divergir** do modelo de
propósito, registre o porquê — divergência sem motivo escrito vira dívida
que ninguém sabe se pode remover.

> **Regra herdada do `CLAUDE.md` (princípio 6):** cor, tipografia e
> espaçamento sempre por token de tema, nunca no widget.

---

## Fundação

| # | Item | Status | Nota |
|---|---|---|---|
| 1 | Paleta completa | ✅ Feito | `app_colors.dart` — as ~40 cores do `DESIGN.md`. |
| 2 | Token `safetyAmber` (#C2680A) | ✅ Feito (26/08) | Existia só como seed e nunca era usado. É a cor de CTA, FAB, marca e dinheiro; `primary` (#8F4A00) fica para ícone/texto sobre fundo claro. Misturar os dois era o que deixava o app mais "marrom" que os modelos. |
| 3 | Token `surfaceOutline` (#C4C7C5) | ✅ Feito (26/08) | A borda padrão do design (118 usos nos modelos). O tema usava `outlineVariant`, um bege quente. |
| 4 | Tokens `info` / `danger` | ✅ Feito (26/08) | "Enviado" (azul) e `error-red` #D32F2F, que o design distingue de `error` #BA1A1A. |
| 5 | **Tipografia Hanken Grotesk** | ✅ Feito (26/08) | Estava **100% ausente** — o tema tinha tamanhos e pesos certos mas renderizava em Roboto. Empacotada como asset (OFL 1.1, `assets/fonts/`), não pelo pacote `google_fonts`: o app é local-first e cairia no fallback justamente no canteiro sem sinal. |
| 6 | Escalas de espaçamento e raio | ✅ Feito | `app_spacing.dart`, `app_radius.dart`. |
| 7 | Estilos separados por componente | ✅ Feito (26/08) | `app_theme.dart` concentrava tudo em 275 linhas; agora só compõe, e cada família vive em `theme/components/` (`button`, `input`, `surface`, `chip`, `navigation`, `feedback`). |
| 8 | `ColorScheme` fixado à mão | ✅ Feito (26/08) | Era derivado por `fromSeed`, que gerava tons próximos porém diferentes dos do design. |

## Componentes (`lib/widgets/`)

| Componente | Status | Onde é usado |
|---|---|---|
| `AppStatusChip` | ✅ Feito | Estado do orçamento, "Enviado há Xd", contagem de orçamentos. Antes cada tela montava um `Container` com `BoxDecoration` próprio. |
| `AppMetricCard` | ✅ Feito | Painel da Home (variante destacada + par comum). |
| `AppAvatar` | ✅ Feito | Lista de clientes e pendências (iniciais). |
| `AppSearchField` | ✅ Feito | Clientes, Orçamentos, Lista de Preços. |
| `AppFilterChips` | ✅ Feito | Filtro de status e de categoria. |
| `AppSectionHeader` | ✅ Feito | "PENDÊNCIAS" com filete. |
| `AppSegmentedBar` | ✅ Feito | "Saúde do Negócio". |
| `AppTimelineTile` | ✅ Feito | Linha do tempo da ficha do cliente. |
| `AppWizardStepper` | ⏸️ Pendente | O wizard existe, mas usa indicador próprio; o design mostra barra de etapas no topo. |

## Telas

| Tela | Status | Nota |
|---|---|---|
| Home / painel | ✅ Feito | Marca, saudação, cartão de destaque, par de indicadores, saúde do negócio, pendências. |
| Lista de orçamentos | ✅ Feito | Busca, filtro por status, card com selo + valor + ação. |
| Lista de clientes | ✅ Feito | Avatar, selo "N orçamentos". |
| Lista de preços | ✅ Feito | Preço em âmbar à direita com unidade abaixo; chips de categoria. |
| Ficha do cliente | ✅ Feito | Linha do tempo com marcadores coloridos por desfecho. |
| Detalhe do orçamento | ⏸️ Pendente | O modelo tem card "Resumo Financeiro" e card "Pagamento" com selo de estado. É a tela do dinheiro — maior valor entre as pendentes. |
| Wizard de orçamento | ⏸️ Pendente | Existe e funciona; falta a barra de etapas e o acabamento dos modelos (`novo_or_amento_*`). |
| Novo/editar cliente | ⏸️ Pendente | Modelo agrupa em card "Informações Básicas" + "Adicionar Endereço" recolhido, com barra de ações fixa embaixo (Cancelar / Salvar). |
| Ajustes | ⏸️ Pendente | Modelo tem cards por seção (conta, perfil, ofícios, identidade) com ícone no título. |
| Nova medição | ⏸️ Pendente | Ver `nova_medi_o_obrion`. |
| Onboarding | ⏸️ Pendente | Ver `onboarding_obrion`. |
| Login | ⏸️ Pendente | Não há modelo correspondente; seguir o padrão das demais. |

## Divergências deliberadas dos modelos

Registradas para que ninguém "conserte" achando que é esquecimento:

- **Selo "+12% vs mês ant." não entrou** na Home. O app não guarda
  histórico mensal; exibir uma variação inventada daria ao profissional
  uma leitura falsa do próprio negócio. Pelo mesmo motivo o cartão diz
  "Recebidos", não "Recebidos este mês".
- **Fotos na linha do tempo não entraram.** O app não guarda foto de
  medição — é feature futura no roadmap de UX/UI.
- **Barra superior da Lista de Preços virou menu.** Título mais os botões
  "Reajustar" e "Sugestões" estouravam 26px em aparelho de 320dp.
- **Números dos orçamentos** continuam sendo a posição na ordem de
  criação, não `ORÇ-2023-0042` como no modelo — mudar isso mexeria em
  dado, não em estilo.

## Proteção contra estouro de layout

`test/widgets/screen_layout_test.dart` renderiza as telas de lista em
**320dp** (menor Android em uso) e **411dp**, com dado hostil de propósito:
nome de construtora longo, valor de sete dígitos, serviço sem preço. O
`flutter_test` já falha em `RenderFlex overflowed`, então basta renderizar.

Achou e derrubou dois estouros reais na primeira execução (barra da Lista
de Preços e `AppEmptyState`). **Ao criar tela nova, adicione-a nesse
teste.**

Duas armadilhas que custaram tempo e vale não repetir:
- `pumpAndSettle` **trava** em tela com `AppLoading` — o indicador gira
  para sempre. Use `pump` com duração fixa.
- `await` em stream do Drift **no corpo do teste** nunca completa (a zona
  de tempo é simulada). Pegue o dado do próprio seeder.

## Próximos passos sugeridos

1. **Detalhe do orçamento** — é a tela do dinheiro e a que o cliente final
   vê refletida no PDF; maior retorno entre as pendentes.
2. **Ajustes** e **Novo cliente** — formulários, onde o estilo novo de
   input (preenchido, barra de foco) mais aparece.
3. **Wizard** — barra de etapas (`AppWizardStepper`) e acabamento.
4. **Onboarding** e **Nova medição**.
5. Rever no aparelho, ao sol, antes da ★ Validação — nenhum teste
   substitui isso (ver a nota do R8 no `CLAUDE.md`).
