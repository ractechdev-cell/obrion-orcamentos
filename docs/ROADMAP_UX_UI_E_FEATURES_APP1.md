# ROADMAP_UX_UI_E_FEATURES_APP1.md

# Obrion Orçamentos — Roadmap de UX/UI, Produto e Features

**Data:** 24/08/2026  
**Aplicativo:** Obrion Orçamentos — App #1  
**Objetivo deste documento:** servir como instrução operacional para a IA atualizar os documentos `.md` do projeto e orientar a evolução do produto sem perder o foco do App #1.

---

## 0. REGRA PRINCIPAL

O Obrion Orçamentos NÃO deve virar um ERP ou um sistema completo de gestão de obras.

O objetivo do App #1 é dominar o fluxo:

> **Cliente → Medição → Orçamento → Envio → Acompanhamento → Aprovação → Pagamento**

O produto deve ser percebido como uma ferramenta extremamente simples e profissional para transformar uma visita/medição em uma oportunidade comercial acompanhada até o recebimento.

### Princípio de produto

**"Do local ao orçamento."**

Promessa principal sugerida:

> **Meça no local. Monte o orçamento. Envie pelo WhatsApp.**

A diferenciação não deve depender apenas de "ser rápido" ou "ser simples", pois isso é copiável. O diferencial deve ser o conjunto:

- medição integrada;
- cálculo automático;
- funcionamento offline;
- início sem cadastro;
- lista de preços pessoal;
- histórico;
- envio por WhatsApp;
- acompanhamento do orçamento;
- experiência específica por profissão.

---

# 1. OBJETIVOS DESTA FASE

Antes de adicionar funcionalidades complexas, o projeto deve:

1. elevar significativamente a qualidade da UX/UI;
2. fazer o aplicativo parecer um produto completo e profissional;
3. reduzir fricção no primeiro uso;
4. deixar claro para cada profissional que o app foi feito para seu ofício;
5. tornar o fluxo de orçamento extremamente fácil;
6. aumentar a percepção de valor do PDF/Imagem enviado ao cliente;
7. criar motivos para o usuário retornar ao app;
8. preparar a base para monetização futura;
9. preservar a arquitetura local-first;
10. não antecipar features de IA/ERP antes da validação.

---

# 2. PRINCÍPIOS DE UX/UI

## 2.1. O usuário não deve aprender o aplicativo

A interface deve ensinar pelo uso.

Evitar:

- tutoriais longos;
- telas explicativas desnecessárias;
- excesso de campos;
- linguagem técnica;
- cadastro obrigatório na abertura.

Preferir:

- dados de exemplo;
- textos curtos;
- campos opcionais recolhidos;
- sugestões contextuais;
- ações claras;
- feedback imediato.

---

## 2.2. Não abrir o app vazio

No primeiro uso, apresentar dados de exemplo claramente marcados:

- Cliente exemplo;
- Orçamento exemplo;
- Serviços exemplo;
- valores explicitamente marcados como `[EXEMPLO]`.

O usuário deve poder excluir os dados de exemplo.

Objetivo:

> demonstrar imediatamente como o aplicativo funciona e reduzir a sensação de "app vazio".

---

## 2.3. Onboarding no momento da necessidade

Não exigir cadastro na primeira abertura.

Fluxo:

```text
Abrir app
    ↓
Criar orçamento imediatamente
    ↓
Gerar PDF pela primeira vez
    ↓
Pedir identidade profissional
    ↓
Nome
Empresa
Telefone
Logo opcional
    ↓
Gerar documento profissional
```

Conta/e-mail/senha deve continuar sendo associada a benefícios como backup, sincronização e uso em outro aparelho.

---

# 3. UX/UI — HOME

## Prioridade: P0

A Home deve deixar de ser apenas uma porta para "Novo orçamento".

Ela deve funcionar como um painel simples do negócio.

### Estrutura sugerida

```text
Bom dia, [Nome] 👋

RESUMO
R$ X em orçamentos
R$ X aguardando resposta
R$ X aprovados
R$ X recebidos

[ + Novo orçamento ]

PENDÊNCIAS
- João — R$ 5.800 — aguardando resposta
- Maria — R$ 3.200 — pagamento pendente

ATALHOS
[Clientes] [Orçamentos]
[Catálogo] [Recibos]
```

### Regras

- Não transformar a Home em dashboard complexo.
- Mostrar somente informações acionáveis.
- Priorizar pendências.
- Usar hierarquia visual clara.
- A ação principal deve continuar sendo `Novo orçamento`.

---

# 4. UX/UI — IDENTIDADE POR PROFISSÃO

## Prioridade: P0

O aplicativo possui estrutura genérica por baixo, mas a experiência deve ser contextualizada.

No onboarding/perfil:

> **Qual é o seu principal serviço?**

Opções iniciais:

- Pintor;
- Pedreiro;
- Eletricista;
- Encanador;
- Gesseiro;
- Azulejista;
- Empreiteiro;
- Outro.

## O ofício deve alterar:

- serviços sugeridos;
- unidades;
- exemplos;
- textos;
- atalhos;
- categorias;
- dados de exemplo.

### Regra importante

Não criar arquiteturas diferentes por profissão.

Usar:

> **mesma estrutura + dados/configuração específicos do ofício.**

---

# 5. CATÁLOGO / LISTA DE PREÇOS

## Prioridade: P0

A lista de preços é uma das funcionalidades estratégicas de retenção do produto.

Objetivo:

> o primeiro orçamento é rápido; o segundo deve ser ainda mais rápido.

### Estrutura

```text
MEUS SERVIÇOS

Pintura de parede
m² | R$ 18,00

Massa corrida
m² | R$ 12,00

Selador
m² | R$ 5,00
```

### Funcionalidades

- adicionar serviço;
- editar;
- excluir;
- categoria;
- unidade;
- preço;
- duplicar serviço;
- reajustar preços;
- filtrar por categoria.

### Sugestões

Pré-carregar serviços por profissão com:

- nome;
- unidade;
- preço vazio.

Nunca assumir preço regional como verdade.

---

# 6. UX/UI — FLUXO DE ORÇAMENTO

## Prioridade: P0

Substituir o formulário longo por um fluxo guiado.

### Wizard

```text
1. CLIENTE
2. MEDIÇÃO
3. SERVIÇOS
4. CONDIÇÕES
5. REVISÃO
6. ENVIO
```

### Etapa 1 — Cliente

- selecionar cliente existente;
- criar cliente;
- importar contato da agenda;
- telefone;
- endereço da obra.

Campos opcionais devem ficar recolhidos por padrão.

---

### Etapa 2 — Medição

Usar a geometria bruta já definida no projeto:

- comprimento;
- largura;
- altura;
- portas;
- janelas;
- outros vãos quando aplicável.

As grandezas devem continuar sendo derivadas:

- área de piso;
- área de teto;
- área de parede menos vãos;
- perímetro;
- perímetro útil;
- volume.

Não criar um único campo genérico `area`.

---

### Etapa 3 — Serviços

Permitir:

- adicionar serviço do catálogo;
- quantidade automática da medição;
- alterar quantidade;
- unidade;
- preço;
- mão de obra;
- material;
- desconto.

Mostrar total em tempo real.

---

### Etapa 4 — Condições

- prazo;
- validade;
- forma de pagamento;
- observações.

Campos opcionais devem permanecer compactos.

---

### Etapa 5 — Revisão

Mostrar:

- cliente;
- serviços;
- quantidades;
- valores;
- desconto;
- total;
- prazo;
- validade;
- pagamento.

A ação principal:

> **Gerar orçamento**

---

### Etapa 6 — Envio

Oferecer:

- PDF;
- imagem;
- compartilhar;
- WhatsApp.

Priorizar a experiência de compartilhamento.

---

# 7. IMPORTAÇÃO DE CONTATO

## Prioridade: P0/P1

Ao criar cliente:

```text
Adicionar cliente

[ Digitar manualmente ]

ou

[ Selecionar da agenda ]
```

Importar principalmente:

- nome;
- telefone.

Não pedir permissões antes de o recurso ser utilizado.

---

# 8. FICHA DO CLIENTE

## Prioridade: P0/P1

A ficha deve ser uma central de ação, não apenas consulta.

### Exemplo

```text
JOÃO DA SILVA

[WhatsApp] [Ligar]

OBRAS
- Reforma residencial

ORÇAMENTOS
- R$ 5.800 — Aguardando
- R$ 4.200 — Aceito

PAGAMENTOS
- R$ 2.000 recebido
- R$ 3.800 restante

[ Novo orçamento ]
```

Ações rápidas:

- WhatsApp;
- ligar;
- nova obra;
- novo orçamento;
- visualizar histórico.

---

# 9. STATUS DO ORÇAMENTO

## Prioridade: P0

Estados mínimos:

```text
RASCUNHO
↓
ENVIADO
↓
AGUARDANDO RESPOSTA
↓
ACEITO / RECUSADO
```

Não adicionar neste momento estados que puxem o produto para gestão de execução da obra.

---

# 10. FOLLOW-UP

## Prioridade: P1

O app deve ajudar o profissional a não perder oportunidades.

Exemplo:

```text
João da Silva
R$ 5.800
Enviado há 2 dias

[ Enviar lembrete ]
```

Mensagem inicial sugerida:

> Olá João, tudo bem? Passando para saber se conseguiu analisar o orçamento que enviei. Qualquer dúvida, estou à disposição.

### Futuramente

Lembretes automáticos:

- 2 dias;
- 5 dias;
- outros intervalos configuráveis.

Não enviar automaticamente sem consentimento explícito do usuário.

---

# 11. PAGAMENTOS DO ORÇAMENTO

## Prioridade: P1

Não transformar em financeiro completo.

Apenas acompanhar o que nasceu de um orçamento.

Exemplo:

```text
ORÇAMENTO
R$ 8.000

Entrada
R$ 2.000 ✅

Parcela 2
R$ 2.000

Parcela 3
R$ 2.000

Final
R$ 2.000

RECEBIDO
R$ 2.000

RESTANTE
R$ 6.000
```

Estados:

- não pago;
- parcial;
- pago.

---

# 12. RECIBO

## Prioridade: P1

Ao registrar pagamento:

```text
Pagamento registrado ✓

[ Gerar recibo ]
[ Enviar WhatsApp ]
```

O recibo deve usar os dados do profissional e do cliente já cadastrados.

---

# 13. DUPLICAR ORÇAMENTO

## Prioridade: P0

A duplicação já existe e deve receber uma UX melhor.

Opção:

> **Usar orçamento anterior**

Ao duplicar:

```text
O que deseja manter?

☑ Serviços
☑ Preços
☑ Condições
☐ Cliente
```

Objetivo:

> criar um novo orçamento com o mínimo de edição possível.

---

# 14. MODELOS DE ORÇAMENTO

## Prioridade: P1 / PRO

Permitir criar modelos:

```text
MEUS MODELOS

Pintura residencial
Pintura comercial
Reforma de banheiro
Instalação elétrica
```

Um modelo pode conter:

- serviços;
- preços;
- condições;
- observações;
- prazo padrão.

Ao criar orçamento:

```text
[ Começar do zero ]

[ Usar modelo ]
```

---

# 15. PDF / IMAGEM

## Prioridade: P0

O documento final é parte central do produto.

Ele deve parecer um orçamento profissional, não um relatório de aplicativo.

### Deve conter

- logo;
- nome profissional/empresa;
- telefone;
- cliente;
- obra;
- número do orçamento;
- data;
- validade;
- serviços;
- quantidades;
- valores;
- desconto;
- total;
- prazo;
- pagamento;
- observações.

### Exportações

- PDF;
- imagem/PNG.

### Compartilhamento

- WhatsApp;
- sistema de compartilhamento.

### Regra

O PDF deve ter testes de conteúdo/layout apropriados ao projeto. Uma quebra no documento final é considerada uma quebra de reputação do usuário.

---

# 16. UX/UI — MICROCOPY

Revisar todas as telas para:

- português natural do Brasil;
- frases curtas;
- linguagem de profissional de obra;
- evitar termos técnicos de software;
- explicar por que um campo opcional existe.

Exemplo ruim:

> "Endereço complementar"

Exemplo melhor:

> "Adicionar endereço da obra"

Exemplo:

> "Telefone — usado para enviar o orçamento pelo WhatsApp."

---

# 17. UX/UI — CAMPOS OPCIONAIS

Não mostrar grandes formulários.

Padrão:

```text
Informações adicionais (opcional) ▾
```

Ao abrir:

- endereço;
- CPF/CNPJ;
- e-mail;
- observações.

Objetivo:

> reduzir carga cognitiva sem esconder funcionalidades importantes.

---

# 18. UX/UI — ESTADOS VAZIOS

Todo estado vazio deve responder:

1. O que é esta tela?
2. Por que ela está vazia?
3. O que devo fazer agora?

Exemplo:

```text
Você ainda não possui clientes.

Cadastre seu primeiro cliente para criar
um orçamento mais rápido.

[ + Adicionar cliente ]
```

Não usar somente:

> "Nenhum cliente encontrado."

---

# 19. UX/UI — FEEDBACK

Toda ação importante deve ter feedback.

Exemplos:

- orçamento salvo ✓;
- PDF gerado ✓;
- pagamento registrado ✓;
- cliente criado ✓;
- orçamento duplicado ✓.

Evitar mensagens técnicas.

---

# 20. UX/UI — CONSISTÊNCIA VISUAL

Revisar:

- espaçamentos;
- tipografia;
- tamanhos de títulos;
- botões;
- cards;
- ícones;
- campos;
- estados;
- navegação;
- diálogos;
- bottom sheets;
- loading;
- erros;
- sucesso.

### Regra

Antes de criar componente novo:

> procurar componente existente no Core.

Se genuinamente novo:

> criar de forma reutilizável e registrar no Core quando aplicável.

---

# 21. UX/UI — ACESSIBILIDADE E USABILIDADE

Revisar:

- áreas de toque;
- contraste;
- tamanho de texto;
- foco;
- teclado;
- scroll;
- comportamento em telas pequenas;
- mensagens de erro;
- estados de loading;
- uso com uma mão.

O público inclui profissionais em campo, portanto a interface deve funcionar bem em situações de uso rápido.

---

# 22. FEATURE FUTURA — HISTÓRICO DE PREÇOS

## Prioridade: P2

Não sugerir preço externo.

Mostrar apenas dados do próprio usuário.

Exemplo:

```text
Pintura de parede

Seu histórico:
Média: R$ 19,80/m²
Menor: R$ 18,00
Maior: R$ 24,00
```

Objetivo:

> ajudar o profissional a entender sua própria precificação.

---

# 23. FEATURE FUTURA — MARGEM

## Prioridade: P2 / PRO+

Adicionar futuramente:

```text
Custo estimado: R$ 3.200
Preço de venda: R$ 5.000

Lucro estimado: R$ 1.800
Margem: 36%
```

Não implementar como financeiro completo.

---

# 24. FEATURE FUTURA — IA

## Prioridade: P3

IA não deve ser prioridade antes da validação do fluxo principal.

Primeira direção recomendada:

### Medição por voz

Exemplo:

> "Sala cinco por quatro, altura de três metros, duas portas de oitenta por dois e dez e uma janela de um e cinquenta por um e vinte."

Transformar em dados estruturados:

```text
Sala
5m × 4m
Altura: 3m
Portas: 2 × 0,80 × 2,10
Janela: 1 × 1,50 × 1,20
```

Depois calcular automaticamente.

Isso é mais alinhado ao diferencial do Obrion do que simplesmente copiar orçamento por voz dos concorrentes.

---

# 25. FEATURE FUTURA — FOTO DA MEDIÇÃO

## Prioridade: P3

Permitir adicionar fotos ao ambiente/medição.

Exemplo:

```text
SALA

Medição
5 × 4 × 3

Fotos
[ Foto 1 ] [ Foto 2 ]
```

Uso futuro:

- referência;
- comprovação;
- histórico;
- eventualmente inclusão opcional no orçamento.

Não transformar isso em Diário de Obra neste App #1.

---

# 26. MONETIZAÇÃO

A decisão atual permanece:

> **Free por recurso, não por volume.**

O fluxo central não deve ser artificialmente limitado.

## Free

Priorizar:

- clientes;
- medições;
- catálogo;
- orçamentos;
- PDF;
- imagem;
- compartilhamento;
- WhatsApp;
- status;
- duplicação;
- recibos básicos;
- funcionamento offline;
- sem anúncios no MVP.

## Pro

Possíveis recursos:

- logo/personalização avançada;
- PDF sem marca Obrion;
- modelos;
- histórico avançado;
- backup;
- sincronização;
- follow-up avançado;
- controle de pagamentos;
- personalização de condições;
- relatórios básicos.

## Pro+

Possíveis recursos:

- IA;
- medição por voz;
- orçamento por voz;
- análise de margem;
- lucro;
- inteligência baseada no histórico;
- automações.

Os recursos pagos devem ser definidos somente depois de observar quais funcionalidades geram valor real.

---

# 27. O QUE NÃO IMPLEMENTAR NO APP #1

Manter explicitamente fora do escopo:

- ERP;
- estoque;
- fornecedores;
- equipe;
- cronograma;
- diário de obra;
- chat interno;
- marketplace;
- integração bancária;
- emissão fiscal;
- mapa;
- assinatura digital avançada;
- versão desktop;
- gestão completa da execução da obra.

Se uma nova feature sugerida se aproximar desses itens, a IA deve parar e avaliar se ela pertence ao App #1 ou a outro produto da família.

---

# 28. ROADMAP DE IMPLEMENTAÇÃO

## FASE 1 — POLIMENTO UX/UI

### P0 — obrigatório

- [ ] Auditoria visual de todas as telas
- [ ] Home como painel
- [ ] Dados de exemplo
- [ ] Perfil por profissão
- [ ] Serviços filtrados por profissão
- [ ] Wizard de orçamento
- [ ] Campos opcionais recolhidos
- [ ] Microcopy
- [ ] Estados vazios
- [ ] Feedback de ações
- [ ] Revisão de navegação
- [ ] Revisão de componentes
- [ ] Revisão de espaçamento/tipografia
- [ ] Revisão de loading/erro/sucesso
- [ ] Importar contato
- [ ] Ações rápidas do cliente
- [ ] Melhorar duplicação
- [ ] PDF profissional
- [ ] Exportação em imagem
- [ ] Compartilhamento WhatsApp
- [ ] Revisão completa de responsividade

### Critério de saída

Um usuário deve conseguir:

> abrir → entender → criar cliente → medir → montar orçamento → gerar documento → compartilhar

sem tutorial manual.

---

# 29. FASE 2 — RETENÇÃO

## P1

- [ ] Status de orçamento
- [ ] Área "Aguardando resposta"
- [ ] Follow-up manual
- [ ] Histórico do cliente
- [ ] Histórico de orçamentos
- [ ] Controle simples de pagamentos
- [ ] Recibo
- [ ] Modelos de orçamento
- [ ] Melhorias no catálogo
- [ ] Reajuste de preços
- [ ] Notificações úteis

### Objetivo

Fazer o usuário retornar depois do primeiro orçamento.

---

# 30. FASE 3 — CONTA E NUVEM

## P1

Após validação:

- [ ] Conta anônima
- [ ] Login por e-mail
- [ ] Backup
- [ ] Sincronização
- [ ] Recuperação de dados
- [ ] Multi-dispositivo

Não adicionar nuvem apenas porque é tecnicamente possível.

A decisão deve ser orientada pelos dados de uso.

---

# 31. FASE 4 — MONETIZAÇÃO

## P1

- [ ] Paywall
- [ ] Play Billing
- [ ] Pro
- [ ] Pro+
- [ ] Analytics de conversão
- [ ] Experimentos de paywall
- [ ] Tela de assinatura
- [ ] Gerenciamento de assinatura

Sem anúncios no MVP.

---

# 32. FASE 5 — INTELIGÊNCIA

## P2/P3

- [ ] Medição por voz
- [ ] Orçamento por voz
- [ ] IA para estruturar descrição
- [ ] Histórico de preços
- [ ] Margem
- [ ] Lucro
- [ ] Insights
- [ ] Automação de follow-up

---

# 33. KPIs

Instrumentar:

```text
Instalou
↓
Abriu
↓
Começou orçamento
↓
Criou orçamento
↓
Gerou PDF
↓
Compartilhou
↓
Cliente respondeu
↓
Orçamento aceito
↓
Pagamento registrado
↓
Voltou
↓
Assinou
```

## Métricas principais

### Aquisição

- instalações;
- origem;
- custo por instalação.

### Ativação

- tempo até primeiro orçamento;
- % que cria primeiro orçamento;
- % que gera PDF;
- % que compartilha.

### Retenção

- D1;
- D7;
- D30;
- segundo orçamento;
- terceiro orçamento.

### Comercial

- % de orçamentos aceitos;
- valor total enviado;
- valor aprovado;
- valor recebido.

### Monetização

- conversão Free → Pro;
- conversão Pro → Pro+;
- ARPU;
- churn.

---

# 34. REGRA PARA A IA ATUALIZAR OS DOCUMENTOS

Ao implementar este roadmap, a IA deve atualizar os `.md` relacionados.

## Arquivos prioritários

### `PLANO_DE_NEGOCIO_INICIAL.md`

Atualizar:

- posicionamento;
- proposta de valor;
- diferenciais;
- público;
- estratégia de retenção;
- Free/Pro/Pro+;
- roadmap;
- KPIs;
- limites de escopo.

### `docs/POSICIONAMENTO_E_FEATURES_APP1.md`

Atualizar:

- posicionamento por profissão;
- diferenciação por medição;
- UX/UI;
- home;
- onboarding;
- catálogo;
- wizard;
- follow-up;
- PDF;
- roadmap de features.

### `docs/ANALISE_CONCORRENCIA_E_ESCOPO.md`

Atualizar somente quando uma decisão nova for resultado direto da análise de concorrência.

Não adicionar features apenas para "igualar" concorrentes.

### `docs/ANALISE_E_MELHORIAS.md`

Registrar:

- decisões;
- riscos;
- correções;
- mudanças estratégicas;
- conflitos encontrados entre documentação e código.

### `APP_FACTORY_CORE.md`

Registrar apenas componentes/módulos realmente reutilizáveis.

Não extrair para o Core prematuramente.

---

# 35. REGRA DE CONSISTÊNCIA DOS `.md`

Depois de qualquer alteração relevante:

1. procurar contradições entre documentos;
2. atualizar a versão/data quando aplicável;
3. remover decisões antigas que foram substituídas;
4. manter uma única decisão vigente;
5. não deixar roadmap antigo contradizendo roadmap novo;
6. não afirmar que uma feature existe se ela ainda não foi implementada;
7. separar claramente:
   - planejado;
   - em desenvolvimento;
   - implementado;
   - validado;
   - adiado;
   - descartado.

---

# 36. REGRA DE IMPLEMENTAÇÃO PARA A IA

Antes de programar uma feature:

1. verificar este roadmap;
2. verificar `CLAUDE.md`;
3. verificar `APP_FACTORY_RULES.md`;
4. verificar `APP_FACTORY_CORE.md`;
5. verificar o código existente;
6. reutilizar componentes existentes;
7. implementar a menor solução que resolva o problema;
8. testar;
9. atualizar documentação;
10. registrar decisão relevante.

Não criar uma arquitetura nova para uma feature que pode ser resolvida com dados/configuração.

---

# 37. REGRA DE PRIORIDADE

Quando houver conflito entre "mais features" e "melhor UX":

> **Escolher melhor UX.**

Quando houver conflito entre "feature concorrente" e "diferencial do Obrion":

> **Priorizar o diferencial do Obrion.**

Quando houver conflito entre "velocidade de desenvolvimento" e "produto bem acabado":

> **Priorizar acabamento nas telas e fluxo principal.**

Quando houver dúvida sobre escopo:

> **Perguntar: isso ajuda diretamente o profissional a sair do local com um orçamento profissional e acompanhar o resultado?**

Se não:

> provavelmente pertence a outro app.

---

# 38. VISÃO FINAL DO APP #1

O Obrion Orçamentos deve ser percebido como:

> **O aplicativo que o profissional abre quando recebe um cliente e precisa transformar uma visita em orçamento.**

Fluxo ideal:

```text
CLIENTE
  ↓
MEDIÇÃO
  ↓
CÁLCULO AUTOMÁTICO
  ↓
SERVIÇOS
  ↓
ORÇAMENTO
  ↓
PDF / IMAGEM
  ↓
WHATSAPP
  ↓
AGUARDANDO RESPOSTA
  ↓
ACEITO
  ↓
PAGAMENTO
  ↓
RECIBO
```

A evolução futura adiciona inteligência e automação sem alterar essa essência.

---

# 39. DECISÃO ESTRATÉGICA

O App #1 não precisa vencer os concorrentes por quantidade de funcionalidades.

Precisa vencer por:

> **experiência + medição + velocidade + contexto profissional + acompanhamento comercial.**

O produto deve parecer simples na superfície e poderoso quando necessário.

**Primeiro tornar o fluxo principal excelente. Depois adicionar inteligência.**
