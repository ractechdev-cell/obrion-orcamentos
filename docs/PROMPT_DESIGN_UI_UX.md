# Prompt de Design UI/UX — Obrion Orçamentos

> **Objetivo**: Usar este prompt com uma IA de design para gerar as interfaces do Obrion Orçamentos — app Flutter de orçamento e medição para profissionais da construção civil.
>
> **Contexto**: App local-first (sem nuvem ainda), público = prestadores solo (pedreiro, pintor, eletricista, encanador, gesseiro, azulejista). O diferencial é **medição integrada + orçamento rápido + envio por WhatsApp**.

---

## 1. Identidade Visual

### Marca
- **Nome**: Obrion Orçamentos
- **Monograma**: **Or** (duas letras no ícone)
- **Promessa**: "Meça no local. Monte o orçamento. Envie pelo WhatsApp."

### Cores
- **Seed color**: âmbar de segurança `#C2680A` (capacete, colete, cone — o canteiro)
- **Material 3**: `ColorScheme.fromSeed(seedColor: Color(0xFFC2680A))`
- **Tema**: somente light (sem dark mode — público trabalha ao sol)
- **Tokens semânticos**: success (verde), warning (laranja), error (vermelho)
- **Cor de fundo**: branca/clara, superfícies com `surfaceContainerLow`
- **Contraste**: alto — leitura ao sol/poeira no canteiro

### Tipografia
- **Headline**: Bold, para títulos de tela
- **Title Medium**: SemiBold, para seções e cards
- **Body**: Regular, para texto corrido
- **Label Small**: Para badges, chips e textos auxiliares
- **Nunca hardcoded** — sempre via `Theme.of(context).textTheme`

### Ícones
- **Estilo**:Outlined (Material Icons)
- **Tamanho**: 20-24px em botões, 16px em badges
- **Cor**: herda do contexto (primary, onSurfaceVariant, error)

### Espaçamento
- **Sistema de tokens**: `AppSpacing.xs(4)`, `sm(8)`, `md(16)`, `lg(24)`, `xl(32)`
- **Nunca número solto** — sempre via token
- **Padding de tela**: 16px horizontal
- **Gap entre cards**: 8-12px

### Bordas e Elevação
- **Cards**: outlined (borda sutil), sem elevação, raio 12
- **Botões**: raio 8, altura mínima 48px (área de toque)
- **Inputs**: sem borda visível (preenchidos), raio 8
- **Bottom Sheets**: drag handle no topo, raio 28 no topo

---

## 2. Regras de Design

### Para o Público
- **Linguagem**: português natural do Brasil, frases curtas
- **Vocabulário**: de obra, não de software (" serviço" não "componente")
- **Toque**: áreas mínimas de 48x48px (uso com mão suja, ao sol)
- **Leitura**: contraste alto, fonte não menor que 14px
- **Orientação**: vertical, uma mão (thumb zone no fundo)

### Campos Opcionais
- Sempre recolhidos por padrão
- Label explica o benefício: "Telefone — usado pra enviar o orçamento pelo WhatsApp"
- Nunca grandes formulários — expandir sob demanda

### Estados
- **Vazio**: sempre com 3 informações (o que é / por que vazio / o que fazer)
- **Loading**: indicador centralizado (AppLoading)
- **Erro**: mensagem + botão "Tentar novamente" (AppError)
- **Sucesso**: snackbar com ícone (AppSnackBar)

### Navegação
- **Bottom Navigation Bar**: 5 abas (Início, Orçamentos, Clientes, Preços, Ajustes)
- **Empilhamento**: telas de criação/edição sobem por cima da barra
- **Voltar**: sempre seta no AppBar, nunca gesto apenas

---

## 3. Telas do App

### 3.1. Onboarding (3 slides)

**Quando**: Primeira abertura do app
**Objetivo**: Mostrar o valor sem cadastro

**Slide 1 — "Meça e cote rápido"**
- Ícone: tape measure / ruler
- Texto: "Meça o cômodo, monte o orçamento com seus preços e mande pro cliente em poucos minutos."
- Fundo: ilustração simples de medição

**Slide 2 — "Funciona sem internet"**
- Ícone: offline shield / phone
- Texto: "Tudo salvo no celular. Sem cadastro pra começar, sem precisar de internet."
- Fundo: ilustração de sinal off

**Slide 3 — "O que você faz?"**
- Título: "O que você faz?"
- Subtitle: "Pode marcar mais de um. Isso ajusta as sugestões da sua lista de preços — dá pra mudar depois em Ajustes."
- Multi-select com chips: Pedreiro, Pintor, Gesseiro, Azulejista, Eletricista, Encanador
- Botão: "Começar"
- Opção: "Pular" no canto superior direito

---

### 3.2. Home (Painel do Negócio)

**Quando**: Aba "Início" — primeira tela ao abrir
**Objetivo**: Resumir o negócio em 3 segundos

**Estrutura**:
```
┌─────────────────────────────┐
│  Obrion Orçamentos     [⚙️] │  ← AppBar
├─────────────────────────────┤
│  Bom dia, [Nome] 👋         │  ← Saudação (opcional)
│                             │
│  ┌──────────┬──────────┐   │
│  │ R$ 5.800 │ R$ 3.200 │   │  ← Cards de resumo
│  │ em orçam.│ aguardando│   │     (grid 2x2)
│  ├──────────┼──────────┤   │
│  │ R$ 12.400│ R$ 8.000 │   │
│  │ aprovados│ recebidos │   │
│  └──────────┴──────────┘   │
│                             │
│  [ + Novo Cliente ]         │  ← CTA principal
│                             │
│  PENDÊNCIAS                 │  ← Seção (só se houver)
│  ┌─────────────────────────┐│
│  │ João   R$ 5.800  3d    ││  ← Card tocável
│  │ [Enviar lembrete]       ││
│  ├─────────────────────────┤│
│  │ Maria  R$ 3.200  5d    ││
│  │ [Enviar lembrete]       ││
│  └─────────────────────────┘│
└─────────────────────────────┘
```

**Regras**:
- Cards de resumo: ícone + valor + label, cores por status (primary, warning, success)
- Pendências: só aparecem se houver orçamentos "Enviado" há 3+ dias
- "Enviar lembrete": pré-preenche WhatsApp com mensagem amigável
- Animação sutil de entrada (fade + slide), respeitando `disableAnimations`

---

### 3.3. Clientes (Lista)

**Quando**: Aba "Clientes"
**Objetivo**: Gerenciar clientes rapidamente

**Estrutura**:
```
┌─────────────────────────────┐
│  Clientes                   │
├─────────────────────────────┤
│  🔍 Buscar cliente          │  ← Search bar
│  Nome, telefone ou endereço │
├─────────────────────────────┤
│  ┌─────────────────────────┐│
│  │ [JS] João da Silva      ││  ← Card com avatar
│  │     (11) 99999-9999     ││     inicial + nome + telefone
│  │     2 orçamentos        ││
│  ├─────────────────────────┤│
│  │ [MA] Maria Alves        ││
│  │     (11) 88888-8888     ││
│  │     1 orçamento         ││
│  └─────────────────────────┘│
│                             │
│              [ + ] FAB      │  ← Criar novo cliente
└─────────────────────────────┘
```

**Estado vazio**:
```
┌─────────────────────────────┐
│                             │
│      👤 (ícone grande)      │
│                             │
│  Você ainda não tem nenhum  │
│  cliente cadastrado.        │
│                             │
│  Cadastre o primeiro pra    │
│  criar um orçamento mais    │
│  rápido.                    │
│                             │
│  [ + Cadastrar cliente ]    │
│                             │
│  [ Ver um exemplo ]         │  ← link secundário
└─────────────────────────────┘
```

---

### 3.4. Ficha do Cliente (Detalhe)

**Quando**: Tocar num cliente na lista
**Objetivo**: Central de ação, não só consulta

**Estrutura**:
```
┌─────────────────────────────┐
│  ← João da Silva    [⋮]    │  ← AppBar com menu
├─────────────────────────────┤
│  [WhatsApp] [Ligar]         │  ← Ações rápidas
├─────────────────────────────┤
│  LINHA DO TEMPO             │
│                             │
│  📐 Medição - Sala          │  ← ícone + título
│     12,00 m² de piso       │    + subtítulo
│     26/08/2026              │
│                             │
│  💰 Orçamento - R$ 5.800    │
│     Enviado há 3 dias       │
│     26/08/2026              │
├─────────────────────────────┤
│              [ + ] FAB      │  ← "Novo orçamento" ou
└─────────────────────────────┘     "Nova medição"
```

**Menu ⋮**:
- Editar cliente
- Excluir cliente (com confirmação destrutiva)

**Estado vazio**:
```
┌─────────────────────────────┐
│                             │
│      📋 (ícone grande)      │
│                             │
│  Este cliente ainda não tem │
│  medição nem orçamento.     │
│                             │
│  Crie o primeiro orçamento  │
│  pra começar o histórico.   │
│                             │
│  [ Criar orçamento ]        │
└─────────────────────────────┘
```

---

### 3.5. Formulário de Cliente

**Quando**: Criar/editar cliente
**Objetivo**: Cadastro rápido com campos opcionais escondidos

**Estrutura**:
```
┌─────────────────────────────┐
│  ← Novo cliente             │
├─────────────────────────────┤
│                             │
│  Nome *                     │  ← AppTextField obrigatório
│                             │
│  Telefone                   │  ← AppTextField
│  Com telefone, dá pra       │    + helper text
│  chamar no WhatsApp         │
│                             │
│  E-mail (opcional)          │
│                             │
│  ▾ Adicionar endereço e     │  ← ExpansionTile colapsável
│    mais detalhes            │    (fechado por padrão)
│    Opcional                 │
│  ─────────────────────────  │
│  │ CPF/CNPJ (opcional)     │
│  │ Rua          Número     │  ← Row com flex
│  │ Bairro                  │
│  │ Complemento / referência│
│  │ Observações             │
│  ─────────────────────────  │
│                             │
│  [ Salvar cliente ]         │  ← AppButton primary
└─────────────────────────────┘
```

---

### 3.6. Lista de Preços (Serviços)

**Quando**: Aba "Preços"
**Objetivo**: Catálogo pessoal do profissional

**Estrutura**:
```
┌─────────────────────────────┐
│  Lista de Preços  [Reajustar]│
│                    [Sugestões]│
├─────────────────────────────┤
│  🔍 Buscar serviço          │
│  Ex: Reboco, pintura...     │
├─────────────────────────────┤
│  [Todas] [Pintura] [Elétrica]│  ← Chips de categoria
├─────────────────────────────┤
│  ┌─────────────────────────┐│
│  │ Pintura de parede       ││  ← Card de serviço
│  │ m² · R$ 18,00           ││
│  │ Pintura                  ││  ← categoria
│  ├─────────────────────────┤│
│  │ Massa corrida           ││
│  │ m² · R$ 12,00           ││
│  │ Pintura                  ││
│  └─────────────────────────┘│
│                             │
│              [ + ] FAB      │  ← Novo serviço
└─────────────────────────────┘
```

**Preço não definido**: Mostrar "Preço não definido" em texto secundário

**Estado vazio**:
```
┌─────────────────────────────┐
│      💰 (ícone grande)      │
│                             │
│  Você ainda não tem serviços│
│  na sua lista de preços.    │
│                             │
│  Carregue os sugeridos pro  │
│  seu ofício ou adicione o   │
│  seu, pra montar orçamentos │
│  em poucos toques.          │
│                             │
│  [ Carregar sugestões ]     │
│  [ Adicionar serviço ]      │
└─────────────────────────────┘
```

---

### 3.7. Wizard de Orçamento (4 etapas)

**Quando**: Criar novo orçamento (via Cliente ou aba Orçamentos)
**Objetivo**: Fluxo guiado, não formulário monolítico

**Indicador de Etapas** (topo):
```
  ①─────②─────③─────④
  Serv.  Conc.  Revisão Envio
```
- Bolinha preenchida = etapa atual ou concluída
- Linha conectando = etapa acessível
- Toque na bolinha = voltar pra etapa

---

#### Etapa 1: Serviços
```
┌─────────────────────────────┐
│  ← Novo orçamento           │  ← ✕ pra cancelar
├─────────────────────────────┤
│  ①──②──③──④               │  ← Indicador
├─────────────────────────────┤
│                             │
│      📋 (ícone grande)      │
│                             │
│  Adicione os serviços       │
│  Toque em + pra adicionar   │
│  serviços do catálogo ou    │
│  criar um item avulso       │
│                             │
│  ── ou lista de itens ──    │
│  ┌─────────────────────────┐│
│  │ Pintura de parede       ││
│  │ 50,00 m² × R$ 18,00    ││
│  │              R$ 900,00  ││
│  │                   [🗑️]  ││
│  └─────────────────────────┘│
├─────────────────────────────┤
│  2 itens     Desconto       │
│  Total: R$ 900,00  [ % ]   │  ← Rodapé fixo
│         [ + ]    [Próximo]  │
└─────────────────────────────┘
```

---

#### Etapa 2: Condições
```
┌─────────────────────────────┐
│  ← Novo orçamento           │
├─────────────────────────────┤
│  ①──②──③──④               │
├─────────────────────────────┤
│  Detalhes do orçamento      │
│  Tudo opcional. Preencha    │
│  só o que fizer sentido.    │
│                             │
│  Descrição da obra          │
│  ┌─────────────────────────┐│
│  │ O que vai ser feito na  ││
│  │ obra, resumido          ││
│  └─────────────────────────┘│
│                             │
│  Observações                │
│  ┌─────────────────────────┐│
│  │ Ex: pagamento em 2x,    ││
│  │ prazo de 15 dias        ││
│  └─────────────────────────┘│
│                             │
│  Válido até                 │
│  ┌─────────────────────────┐│
│  │ 📅 Selecionar data      ││
│  └─────────────────────────┘│
│                             │
│  [Voltar]          [Próximo]│
└─────────────────────────────┘
```

---

#### Etapa 3: Revisão
```
┌─────────────────────────────┐
│  ← Novo orçamento           │
├─────────────────────────────┤
│  ①──②──③──④               │
├─────────────────────────────┤
│  Revise seu orçamento       │
│                             │
│  ┌─────────────────────────┐│
│  │ 👤 João da Silva        ││  ← Card do cliente
│  │    (11) 99999-9999      ││
│  └─────────────────────────┘│
│                             │
│  Serviços (2)               │
│  ┌─────────────────────────┐│
│  │ Pintura de parede       ││
│  │ 50 m² × R$ 18,00       ││
│  │              R$ 900,00  ││
│  ├─────────────────────────┤│
│  │ Massa corrida           ││
│  │ 50 m² × R$ 12,00       ││
│  │              R$ 600,00  ││
│  └─────────────────────────┘│
│                             │
│  ┌─────────────────────────┐│
│  │ Subtotal    R$ 1.500,00 ││
│  │ Desconto    - R$ 150,00 ││
│  │ ─────────────────────── ││
│  │ Total       R$ 1.350,00 ││
│  └─────────────────────────┘│
│                             │
│  Válido até 26/09/2026      │
│                             │
│  [Voltar]   [Gerar orçamento]│
└─────────────────────────────┘
```

---

#### Etapa 4: Envio
```
┌─────────────────────────────┐
│  ← Novo orçamento           │
├─────────────────────────────┤
│  ①──②──③──④               │
├─────────────────────────────┤
│                             │
│      ✅ (ícone sucesso)     │
│                             │
│  Orçamento pronto!          │
│  Escolha como mandar pro    │
│  cliente.                   │
│                             │
│  [ 📄 Enviar como PDF ]     │
│  [ 🖼️ Enviar como imagem ]  │
│                             │
│  [Voltar]   [Depois eu envio]│
└─────────────────────────────┘
```

**Após enviar**:
```
┌─────────────────────────────┐
│      📧 (ícone enviado)     │
│                             │
│  Pronto! O orçamento foi    │
│  enviado.                   │
│  Acompanhe se o cliente     │
│  respondeu na aba Orçamentos│
│                             │
│  [ Concluir ]               │
└─────────────────────────────┘
```

---

### 3.8. Lista de Orçamentos

**Quando**: Aba "Orçamentos"
**Objetivo**: Visão geral de todos os orçamentos

**Estrutura**:
```
┌─────────────────────────────┐
│  Orçamentos                 │
├─────────────────────────────┤
│  [Todos] [Rascunho] [Enviado]│  ← Chips de filtro
│  [Aceito] [Recusado]        │
├─────────────────────────────┤
│  ┌─────────────────────────┐│
│  │ João da Silva           ││
│  │ R$ 5.800 · Enviado 3d  ││  ← Status badge
│  │ 26/08/2026              ││
│  │ [Enviar lembrete]       ││
│  ├─────────────────────────┤│
│  │ Maria Alves             ││
│  │ R$ 3.200 · Aceito       ││
│  │ 24/08/2026              ││
│  └─────────────────────────┘│
│                             │
│              [ + ] FAB      │  ← Novo orçamento
└─────────────────────────────┘
```

**Chips de status**:
- Rascunho: cinza
- Enviado: âmbar/warning
- Aceito: verde/success
- Recusado: vermelho/error

---

### 3.9. Orçamento (Edição/Detalhe)

**Quando**: Tocar num orçamento existente
**Objetivo**: Gerenciar orçamento já criado

**Estrutura**:
```
┌─────────────────────────────┐
│  ← Orçamento  [📤][✏️][+][⋮]│  ← AppBar com ações
├─────────────────────────────┤
│  ┌─────────────────────────┐│
│  │ Itens do orçamento      ││
│  │ (lista de cards)        ││
│  └─────────────────────────┘│
├─────────────────────────────┤
│  Subtotal      R$ 1.500,00 │
│  Desconto      - R$ 150,00 │
│  ──────────────────────────│
│  Total         R$ 1.350,00 │
│                             │
│  Recebido       R$ 0,00    │
│  [Registrar pagamento]      │
│  Pendente: R$ 1.350,00     │
│                             │
│  Válido até 26/09/2026      │
│  Status: Enviado            │
│  [Marcar como aceito]       │
└─────────────────────────────┘
```

**AppBar actions**:
- 📤 Compartilhar (PDF/Imagem)
- ✏️ Detalhes (editar descrição, observações, validade)
- + Adicionar item
- ⋮ Duplicar orçamento

---

### 3.10. Medições

**Quando**: Criar/editar medição (via ficha do cliente)
**Objetivo**: Registrar geometria bruta do cômodo

**Estrutura**:
```
┌─────────────────────────────┐
│  ← Nova medição             │
├─────────────────────────────┤
│  Nome do cômodo             │  ← Ex: "Sala"
│                             │
│  ┌────────┬────────┬───────┐│
│  │Comp.   │Larg.   │Altura ││  ← 3 campos numéricos
│  │ 5,00   │ 4,00   │ 2,80  ││    em Row
│  └────────┴────────┴───────┘│
│                             │
│  Vãos (portas e janelas)    │
│  Nenhum vão adicionado —    │  ← estado vazio inline
│  a parede será calculada    │
│  sem descontos.             │
│                             │
│  [ + Adicionar vão ]        │
│                             │
│  ── Grandezas derivadas ──  │  ← Preview automático
│  Piso: 20,00 m²            │
│  Teto: 20,00 m²            │
│  Parede: 44,80 m²          │
│  Perímetro: 18,00 m        │
│                             │
│  [ Salvar medição ]         │
└─────────────────────────────┘
```

**Dialog "Adicionar vão"**:
```
┌─────────────────────────────┐
│  Adicionar vão              │
├─────────────────────────────┤
│  [Porta] [Janela]           │  ← SegmentedButton
│                             │
│  Largura    Altura          │
│  ┌──────┐  ┌──────┐        │
│  │ 0,80 │  │ 2,10 │        │
│  └──────┘  └──────┘        │
│                             │
│  [Cancelar]    [Adicionar]  │
└─────────────────────────────┘
```

---

### 3.11. Configurações (Ajustes)

**Quando**: Aba "Ajustes"
**Objetivo**: Perfil profissional e preferências

**Estrutura**:
```
┌─────────────────────────────┐
│  Configurações              │
├─────────────────────────────┤
│  ┌─────────────────────────┐│
│  │ 👤 Visitante            ││  ← Card de conta
│  │ Dados salvos só neste   ││    (ou email se logado)
│  │ aparelho       [Entrar] ││
│  └─────────────────────────┘│
│                             │
│  Seu perfil profissional    │  ← Seção
│  Aparece no cabeçalho do    │
│  PDF enviado ao cliente.    │
│                             │
│  Seu nome ou da empresa     │
│  Telefone                   │
│                             │
│  Seus ofícios               │
│  Escolha seus ofícios. As   │
│  sugestões da Lista de      │
│  Preços vão mudar.          │
│  [Pedreiro] [Pintor] [...]  │
│                             │
│  Logo (opcional)            │
│  [Escolher] [Remover]       │
│                             │
│  [ Salvar ]                 │
│                             │
│  ──────────────────────────│
│  Versão 0.1.7 (build 7)    │
│  · patch 3                  │
└─────────────────────────────┘
```

---

### 3.12. Tela de Login (_Interface)

**Quando**: Acessível só via Configurações
**Objetivo**: Preparar terreno pra Fase 2 (Supabase)

**Estrutura**:
```
┌─────────────────────────────┐
│  ← Criar conta              │
├─────────────────────────────┤
│                             │
│  Crie sua conta             │
│                             │
│  Seus dados continuam       │
│  salvos aqui. A conta é pra │
│  quando você quiser         │
│  sincronizar entre aparelhos│
│                             │
│  E-mail                     │
│  ┌─────────────────────────┐│
│  │                         ││
│  └─────────────────────────┘│
│                             │
│  Senha                      │
│  ┌─────────────────────────┐│
│  │ ••••••••                ││
│  └─────────────────────────┘│
│                             │
│  [ Criar conta ]            │
│                             │
│  Já tenho conta — entrar    │  ← link secundário
└─────────────────────────────┘
```

---

## 4. Componentes do Design System

### Componentes Essenciais (já implementados)

| Componente | Uso | Estilo |
|------------|-----|--------|
| `AppButton` | Ações primárias/secundárias | Elevated/Outlined, altura 48px |
| `AppTextField` | Campos de texto | Preenchido, sem borda, raio 8 |
| `AppCard` | Contêiner de conteúdo | Outlined, raio 12, sem elevação |
| `AppDialog` | Confirmações e alertas | Title + message + ações |
| `AppBottomSheet` | Ações contextuais | Drag handle, ações em lista |
| `AppSnackBar` | Feedback de ações | Ícone + mensagem, 3s auto-dismiss |
| `AppEmptyState` | Estados vazios | Ícone + título + CTA |
| `AppLoading` | Carregamento | CircularProgressIndicator centralizado |
| `AppError` | Estados de erro | Mensagem + botão retry |
| `AppCurrencyInput` | Valores em R$ | Formatação automática |
| `AppNumberInput` | Medidas e quantidades | Teclado numérico |
| `AppDatePicker` | Seleção de data | Calendário nativo |
| `AppPremiumBadge` | Selo PRO | Badge dourado |

### Componentes Novos (sugeridos)

| Componente | Uso | Descrição |
|------------|-----|-----------|
| `AppStepIndicator` | Indicador de wizard | Bolinhas + linhas conectando etapas |
| `AppSummaryCard` | Cards de resumo na Home | Ícone + valor + label, com cor de status |
| `AppTimelineEntry` | Linha do tempo do cliente | Ícone + título + data + status |
| `AppStatusChip` | Badge de status | Chip colorido por status do orçamento |
| `AppClientCard` | Card de cliente na lista | Avatar + nome + telefone + ações |
| `AppServiceCard` | Card de serviço na lista | Nome + unidade + preço + categoria |
| `AppBudgetCard` | Card de orçamento na lista | Cliente + valor + status + data |
| `AppSectionHeader` | Cabeçalho de seção | Título + subtítulo + ação opcional |
| `AppExpandableHint` | Dica expansível | Texto + seta, expande ao toque |

---

## 5. Paleta de Cores (Detalhada)

```dart
// Seed
static const obrionSeed = Color(0xFFC2680A); // âmbar de segurança

// Material 3 derives:
// primary → âmbar escuro
// onPrimary → branco
// primaryContainer → âmbar claro
// secondary → tom complementar
// surface → branco/off-white
// background → branco

// Semantic tokens
static const success = Color(0xFF2E7D32); // verde escuro
static const warning = Color(0xFFED6C02); // laranja
static const error = Color(0xFFD32F2F);   // vermelho
```

---

## 6. Tipografia (Tokens)

```dart
// Headline
headlineSmall → 24sp, bold → Títulos de tela
headlineMedium → 28sp, bold → Títulos de destaque

// Title
titleLarge → 20sp, semiBold → Seções
titleMedium → 16sp, semiBold → Cards, itens

// Body
bodyLarge → 16sp, regular → Texto corrido
bodyMedium → 14sp, regular → Texto padrão
bodySmall → 12sp, regular → Subtítulos, hints

// Label
labelLarge → 14sp, medium → Botões
labelMedium → 12sp, medium → Chips, badges
labelSmall → 10sp, medium → Tags
```

---

## 7. Espaçamento (Tokens)

```dart
static const xs = 4.0;   // Gap mínimo
static const sm = 8.0;   // Entre itens
static const md = 16.0;  // Padding de tela
static const lg = 24.0;  // Entre seções
static const xl = 32.0;  // Espaço generoso
```

---

## 8. Regras de Layout

### Grid
- **Cards de resumo (Home)**: 2 colunas, gap 8px
- **Timeline (Cliente)**: 1 coluna, gap 8px
- **Lista de serviços**: 1 coluna, gap 8px

### Responsividade
- **Bottom sheets**: altura `min(60% da tela, 700px)` — clamp
- **Campos de texto**: largura 100% do container
- **Botões de ação**: sempre full-width ou em Row com Spacer
- **Textos longos**: `maxLines` + `overflow: TextOverflow.ellipsis`

### Teclado
- **Campos numéricos**: teclado numérico (`TextInputType.number`)
- **Campos de telefone**: teclado de telefone
- **Campos de email**: teclado de email
- **Auto-focus**: primeiro campo da tela

### Segurança de Toque
- **Área mínima**: 48x48px
- **Botões pequenos**: usar `VisualDensity.compact` + `tapTargetSize: MaterialTapTargetSize.shrinkWrap`
- **Espaçamento entre botões**: mínimo 8px

---

## 9. Animações

### Permitidas
- **Fade in**: opacity 0→1, 350ms, easeOut
- **Slide up**: translateY 12→0, 350ms, easeOut
- **Expansion**: height 0→auto, 200ms
- **Rotation**: seta expandir/recolher, 200ms

### Regra
- Respeitar `MediaQuery.disableAnimations`
- Nunca animação que atrapalhe a tarefa
- Loading nunca pulsa (só gira)

---

## 10. Acessibilidade

- **Contraste mínimo**: 4.5:1 (texto normal), 3:1 (texto grande)
- **Toque**: 48x48px mínimo
- **Fonte**: nunca menor que 10px
- **Ícones**: sempre com label/texto associado
- **Cores**: não usar cor como único indicador (sempre + ícone ou texto)

---

## 11. Referências de Design

### Apps modelo (construção civil)
- **Prummo**: FAB de microfone, wizard de orçamento, cards com status
- **Azulejista+**: Home como painel financeiro, dados de exemplo, assinatura no PDF
- **Orça PRO**: Catálogo unificado, desconto dinâmico, importar contato

### Padrões Flutter
- Material 3 como base
- Never importar widgets Material diretamente (sempre via Design System)
- Usar `Theme.of(context)` pra acessar tokens
- Nunca hardcodar cores, fontes ou espaçamentos

---

## 12. Checklist de Validação

Antes de aprovar qualquer tela:

- [ ] Usa componentes do Design System (não Material cru)?
- [ ] Cores vêm do tema (não hardcoded)?
- [ ] Espaçamento usa tokens (nunca número solto)?
- [ ] Tipografia usa estilos do tema?
- [ ] Botões têm área de toque mínima 48px?
- [ ] Estados vazios seguem as 3 perguntas?
- [ ] Loading/Erro/Sucesso estão cobertos?
- [ ] Texto é claro, curto, em português do Brasil?
- [ ] Campos opcionais estão recolhidos?
- [ ] Layout funciona em tela pequena (<360px)?
- [ ] Contraste é adequado pra leitura ao sol?
- [ ] Navegação é intuitive (seta voltar sempre visível)?
