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
| 3 | **Campos opcionais recolhidos** | "Adicionar endereço e mais detalhes (Opcional)" fechado por padrão | É **o** truque que deixa os concorrentes completos e simples ao mesmo tempo. Permite crescer sem parecer complexo |
| 4 | **Wizard com passos** | ITENS → DETALHES → COBRANÇA → ENVIAR, com progresso | O `budget_form_screen.dart` tem 29 KB — provavelmente um formulão único. Dividir reduz a sensação de esforço |
| 5 | **Importar contato do telefone** | Puxa nome e telefone da agenda | Elimina a digitação mais chata do fluxo |
| 6 | **Ações rápidas no cliente** | WhatsApp · Ligar · Nova obra na ficha | Transforma a ficha em ponto de ação, não de consulta |

### Nível 2 — fecham o ciclo do trabalho

| # | Padrão | Observação |
|---|---|---|
| 7 | **Assinatura no PDF** | Duas linhas (profissional + contratante, com CPF/CNPJ e data). Vira mini-contrato. **Não confundir** com assinatura digital ICP-Brasil |
| 8 | **Emitir recibo** | Mesmo motor de PDF, casa com `payments` |
| 9 | **Lista de compras a partir dos itens** | O "App #2" como botão |
| 10 | **Fotos no orçamento** | Antes/depois, estado do local. Reduz discussão com o cliente |
| 11 | **Desconto percentual** | Hoje o Obrion só tem `discountCents` (valor fixo) |
| 12 | **Catálogo unificado serviços + materiais** | Chips "Ver todas / Serviços / Materiais". Hoje o Obrion só tem `services` |

### Nível 3 — depende de IA/nuvem

| # | Padrão | Observação |
|---|---|---|
| 13 | **Orçamento por voz** | Ambos têm. Deixou de ser diferencial e virou **tabela**. Mas o espaço livre continua sendo **voz na medição** (as duas mãos na trena), que nenhum dos dois ataca |
| 14 | **Análise de margem por IA** | "Descobrir custos ocultos" — vende insegurança real do profissional |
| 15 | **Alerta de valor fora do padrão** | Ninguém faz. Na captura do concorrente há um item de **619 m² de alvenaria em uma "Reforma Banheiro"**, aceito sem nenhum aviso. Um "confere?" nesse momento evita orçamento errado indo pro cliente |

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
