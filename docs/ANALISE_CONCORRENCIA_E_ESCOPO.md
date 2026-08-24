# Análise de Concorrência e Decisão de Escopo — Obrion

**Data:** 24 de agosto de 2026
**Base:** capturas de tela de dois concorrentes diretos, testados pelo próprio fundador + código real do Obrion (v0.1.4+4)
**Origem:** o fundador apontou que "genérico" não significava falta de nicho por ofício, e sim **distância de UI/UX e de escopo em relação à concorrência** — e levantou a hipótese de que os concorrentes são mais completos porque o plano de negócio deles é **tudo em um app só**.

> **Conclusão principal: a hipótese está certa, e a recomendação é colapsar os 5 apps em um.**
> Os dois concorrentes analisados são all-in-one. Um deles (**Azulejista+**) tem nome de ofício e produto completo — ou seja, **o nicho está no nome e no posicionamento, não na fronteira do app.** Os "5 apps" do plano Obrion são cinco visões do mesmo grafo de dados (cliente → obra → orçamento → item → pagamento), e separá-los exige a nuvem, que ainda não existe.
>
> **Correção da recomendação anterior:** eu havia sugerido validar com 3 pintores antes de construir. O fundador coordena obras com pintor, pedreiro, caldeireiro, soldador e ajudantes, e faz orçamentos — **ele é o usuário**. A recomendação de validação externa cai; o que substitui está na Parte 6.

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

# Parte 2 — A pergunta central: "tudo em um app" é o motivo?

**Sim.** E a evidência é mais forte do que a intuição sugeria.

O plano Obrion prevê cinco apps. Olhando o que os concorrentes fazem com essas mesmas funções:

| Plano Obrion | Onde isso vive no concorrente |
|---|---|
| App #2 — **Materiais / lista de compra** | Um **botão** dentro do orçamento ("Lista de Compras") + aba "Materiais" no catálogo |
| App #3 — **Diário de obra** | Dentro de "Obras" / "Pedidos" |
| App #4 — **Medições do empreiteiro** (contrato × executado × recebido) | É a **home**: "Recebido este mês / Aguardando aprovação / Pendências de Recebimento" |
| App #5 — **Calculadora** | Um item do catálogo que vira linha do orçamento |

Nenhum deles é um produto separado na cabeça do usuário. **São visões do mesmo grafo de dados.**

## Por que separar sai caro (e não barato)

1. **Os dados são um só.** cliente → obra → orçamento → item → pagamento. Toda função nova consulta esse mesmo grafo. Cinco apps significam **cinco cópias** ou dependência de nuvem para compartilhar.
2. **A nuvem não existe.** O login único que justifica a família é da Fase 2. Hoje, cinco apps Obrion seriam cinco silos que não se falam. A promessa de "reuso" ainda não é executável.
3. **Custo fixo por app, para um fundador solo.** Cinco fichas de loja, cinco conjuntos de prints, cinco notas de avaliação, cinco pipelines de release, cinco formulários de Segurança de Dados. Isso é imposto recorrente, não custo único.
4. **A analogia da Adobe não se aplica.** Photoshop e Illustrator são tarefas diferentes, de pessoas diferentes, em momentos diferentes. Aqui é o mesmo profissional, no mesmo celular, na mesma obra, no mesmo dia.
5. **A assimetria decide.** Separar depois é barato (um módulo já é código isolado). Juntar depois é caro (migração de dados, usuários com dois apps, duas bases instaladas). **Na dúvida, comece junto.**

## O que sobrevive da estratégia de família

O **Obrion Core** continua fazendo sentido — só muda o momento da extração. Módulos dentro de um app são tão extraíveis quanto apps separados. E se um módulo provar, com dado, que merece instalação própria (o Diário é o candidato mais plausível, por ter uso diário no canteiro e público diferente), ele sai depois.

**Decisão recomendada:** Obrion vira **um app** com módulos. A família volta à mesa quando houver dado que a justifique.

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
| "Cuidado com a fronteira App #1 × App #5" | **Some**, se houver um app só |
| "As 5 apps são visões do mesmo grafo" (Parte 7 do doc anterior) | **Confirmado por evidência**, e vira decisão |

---

# Parte 7 — O que decidir antes de codar

**1. Um app ou cinco.** Recomendação: **um**. Se aceita, atualizar `PLANO_DE_NEGOCIO_INICIAL.md` §11 e `APP_FACTORY_CORE.md` §13, que hoje descrevem a família de cinco.

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

1. **Decidir um app × cinco apps** (Parte 2) e **qual home** (Parte 7.2). São as duas decisões que travam tudo o mais.
2. **Nível 1 da Parte 5**, em ordem: dados de exemplo → home-painel → campos recolhidos → wizard → importar contato. É o pacote que fecha o gap de percepção.
3. **Reposicionar a promessa** em torno de medição (Parte 4) — é a única coisa que os dois concorrentes não fazem e que já está construída.
4. **Onboarding no momento da necessidade** (Parte 3), em vez de cadastro na porta.
5. Só depois: voz, IA, margem, créditos.

---

## Documentos relacionados

- `POSICIONAMENTO_E_FEATURES_APP1.md` — análise anterior; ver Parte 6 acima para o que foi corrigido
- `PLANO_DE_NEGOCIO_INICIAL.md` — §11 (portfólio) precisa de revisão se a decisão for um app só
- `APP_FACTORY_CORE.md` — §13 (identidade da família) idem
- `ANALISE_E_MELHORIAS.md` — decisões R1–R3, que seguem válidas
