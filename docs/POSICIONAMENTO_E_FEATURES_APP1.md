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
