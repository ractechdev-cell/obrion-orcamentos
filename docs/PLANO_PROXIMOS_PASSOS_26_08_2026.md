# Plano Detalhado — Próximos Passos
**Data**: 26 de agosto de 2026  
**Versão atual**: 0.1.7+7  
**Estado**: Fase 1 quase completa (20/21), Fase 2 quase completa (10/11)

---

## 📊 Situação Atual

### Fase 1 — Polimento UX/UI
**20/21 itens ✅** — Único pendente: Importar contato (#15, mudança nativa)

### Fase 2 — Retenção
**10/11 itens ✅** — Único pendente: Modelos de orçamento (#8, P1/PRO)

### Documentação
**3/6 pendências** — Atualizar PLANO, POSICIONAMENTO, CORE

---

## 🎯 PLANO DETALHADO POR FASE

---

## FASE 1.5 — Fechamento da Fase 1 (esta semana)

### Tarefa 1: Importar Contato da Agenda
**Prioridade**: P0 (falta 1 pra fechar Fase 1)  
**Esforço**: 1-2 dias  
**Tipo**: Mudança nativa (exige release completo)

**O que fazer**:
1. Adicionar dependência `flutter_contacts` no `pubspec.yaml`
2. Adicionar permissão `READ_CONTACTS` no `AndroidManifest.xml`
3. Criar botão "Selecionar da agenda" no `ClientFormScreen` (já tem a estrutura)
4. Importar nome + telefone do contato selecionado
5. Pedir permissão no momento do uso (não na abertura do app)
6. Atualizar schema documentation se necessário

**Oportunidade**: Agrupar com outras mudanças nativas pendentes:
- `flutter_contacts` (READ_CONTACTS)
- Qualquer plugin que mexa em `android/` ou `ios/`

**Resultado esperado**: Cadastro de cliente em 2 toques (escolher contato → salvar)

**Risco**: Baixo — o fluxo já existe, só falta a integração com a agenda

---

### Tarefa 2: Atualizar Documentação Pendente
**Prioridade**: P1 (consistência dos docs)  
**Esforço**: 30-45 min  
**Tipo**: Documentação

**Arquivos a atualizar**:

#### 2a. `PLANO_DE_NEGOCIO_INICIAL.md`
- Atualizar Seção 6 (Diferenciais) para refletir:
  - Home como painel (não só "porta de entrada")
  - Promessa "medição + orçamento" (não só "orçamento rápido")
  - Lista de preços pessoal como fosso competitivo
- Atualizar Seção 8 (Roadmap) para marcar Fase 1 como concluída
- Remover referências a "velocidade extrema" como diferencial (já declarado não-defensável em R4)

#### 2b. `POSICIONAMENTO_E_FEATURES_APP1.md`
- Parte 4 (Features): marcar como "implementado" os itens que saíram do papel:
  - ✅ Home como painel
  - ✅ Wizard de orçamento
  - ✅ Dados de exemplo
  - ✅ Perfil por profissão
  - ✅ Campos opcionais recolhidos
  - ✅ Ações rápidas do cliente
  - ✅ Desconto percentual
  - ✅ Reajuste em massa
  - ✅ Lembrete de validade
  - ✅ Follow-up manual
  - ✅ Recibo pós-pagamento
  - ✅ Descrição da obra no PDF
  - ✅ Assinatura no PDF
- Manter como "futuro": Medição por voz, Margem, Link com aceite do cliente

#### 2c. `APP_FACTORY_CORE.md`
- Confirmar que só módulos comprovadamente reutilizados estão no catálogo
- Não adicionar módulos especulativos (regra da seção 34 do roadmap)

---

## FASE 2 — Melhorias de Retenção (próximas 2 semanas)

### Tarefa 3: Melhorar Duplicação de Orçamento
**Prioridade**: P1 (UX refinada, alto uso real)  
**Esforço**: 1 hora  
**Tipo**: Feature pequena

**O que fazer**:
Ao duplicar orçamento, mostrar bottom sheet:

```text
O que deseja manter?

☑ Serviços
☑ Preços  
☑ Condições
☐ Cliente (pra usar outro cliente)
```

**Onde implementar**: 
- Criar bottom sheet `_showDuplicateOptionsSheet` no `budget_form_screen.dart`
- `BudgetsRepository.duplicate()` já aceita parâmetros — verificar se suporta flags
- Se não suportar, adicionar parâmetros `keepClient`, `keepServices`, `keepConditions`

**Resultado esperado**: Duplicar 1 orçamento existente em vez de recriar do zero

---

### Tarefa 4: Melhorar UX da Duplicação de Serviço
**Prioridade**: P2 (catálogo mais fluido)  
**Esforço**: 30 min  
**Tipo**: Feature pequena

**O que fazer**:
Na Lista de Preços, adicionar opção "Duplicar" no menu ⋮ de cada serviço:

```text
[ ⋮ ] →
  Editar
  Duplicar    ← novo
  Excluir
```

**Onde implementar**:
- `services_screen.dart` — adicionar `PopupMenuItem` com valor `'duplicate'`
- `ServicesRepository` — adicionar método `duplicate(String serviceId)`
- Criar cópia com nome "Cópia de [nome original]"

**Resultado esperado**: Criar variação de serviço existente sem redesenhar

---

### Tarefa 5: Modelos de Orçamento (PRO)
**Prioridade**: P1/PRO (reuso de orçamentos similares)  
**Esforço**: 2-3 dias  
**Tipo**: Feature média com schema novo

**O que fazer**:

#### 5a. Schema
```dart
// Nova tabela no banco
budget_templates
├── id (UUID)
├── user_id
├── name (text)          "Pintura residencial"
├── description (text?)  "Descrição do modelo"
├── items_snapshot (text) JSON com os itens
├── conditions_snapshot (text?) JSON com condições
├── created_at
├── updated_at
├── deleted_at
```

#### 5b. Tela de Modelos
- Nova aba ou seção dentro de Orçamentos
- Lista de modelos salvos
- Botão "Criar modelo a partir deste orçamento" no orçamento existente
- Botão "Usar modelo" ao criar novo orçamento

#### 5c. Integração com Wizard
- Na Etapa 1 (Serviços) do wizard, adicionar opção "Começar de um modelo"
- Se escolher modelo, pré-popula itens e condições

#### 5c. Monetização
- Modelos = recurso PRO (paywall)
- Free: criar 1 modelo
- Ilimitado: Pro/Pro+

**Resultado esperado**: Orçamento recorrente em 30 segundos (escolher modelo → ajustar → enviar)

---

## FASE 3 — Conta e Nuvem (após ★ Validação)

### Tarefa 6: Supabase + Login Anônimo
**Prioridade**: P1 (só após validação)  
**Esforço**: 3-5 dias  
**Tipo**: Infraestrutura

**O que fazer**:
1. Configurar projeto Supabase (Auth + PostgreSQL + Storage)
2. Implementar login anônimo no primeiro uso (decisão T2 da análise)
3. Vincular e-mail posteriormente (decisão 5 do CLAUDE.md)
4. `user_id` nunca muda (do primeiro segundo ao cadastro)
5. RLS ativo em todas as tabelas

**Fluxo**:
```text
Primeiro uso → UUID local → Supabase cria user anônimo
     ↓
Usuário cadastra e-mail → vincula identidade (mesmo UUID)
     ↓
Backup automático → dados sincronizados
```

**Resultado esperado**: Dados seguros, multi-dispositivo, sem perda

---

### Tarefa 7: Sincronização Local ↔ Nuvem
**Prioridade**: P1 (só após T6)  
**Esforço**: 3-5 dias  
**Tipo**: Infraestrutura

**O que fazer**:
1. Sincronização por registro com `updated_at`
2. Último a escrever vence (sem CRDT)
3. Exclusão lógica (`deleted_at`) para propagar remoção
4. Background sync quando houver conexão
5. UI mostra status: "Salvo no aparelho" / "Sincronizado"

**Arquitetura**:
```text
Banco Local (Drift/SQLite) ←→ Sync Service ←→ Supabase
         ↑                      ↑                    ↑
    Fonte da verdade      Background         Backup/Destino
                         (quando houver rede)
```

**Resultado esperado**: Dados sempre seguros, funciona offline, sincroniza quando possível

---

## FASE 4 — Monetização (após Fase 3)

### Tarefa 8: Play Billing + Paywall
**Prioridade**: P1 (só após validação + nuvem)  
**Esforço**: 2-3 dias  
**Tipo**: Feature de monetização

**O que fazer**:
1. Integrar `google_play_billing`
2. Criar tela de assinatura (Pro/Pro+)
3. Paywall por recurso (não por volume — decisão R2)
4. Remote Config para limites/flags
5. Analytics de conversão (`upgrade_blocked`, `subscription_started`)

**Paywall**:
```text
Free                          Pro (~R$14,90/mês)
───────────────────────────── ─────────────────────
✅ Clientes ilimitados         ✅ Logo própria no PDF
✅ Medições ilimitadas         ✅ PDF sem marca do app
✅ Orçamentos ilimitados       ✅ Backup na nuvem
✅ Lista de preços completa    ✅ Modelos ilimitados
✅ PDF com rodapé "Feito       ✅ Controle de pagamentos
   com Obrion"                ✅ Histórico avançado
❌ Sem anúncios                ✅ Sem anúncios
```

**Resultado esperado**: Receita recorrente, sem atrito no fluxo principal

---

## FASE 5 — Inteligência (P2/P3, bem depois)

### Tarefa 9: Medição por Voz
**Prioridade**: P3 (IA não é feature de lançamento)  
**Esforço**: 5-7 dias  
**Tipo**: Feature de IA

**O que fazer**:
1. Speech-to-text para capturar medição verbal
2. Parser para extrair dimensões da fala
3. Preencher automaticamente os campos de medição
4. Funcionar offline (modelo local)

**Exemplo**:
```text
Usuário fala: "Sala cinco por quatro, altura de três metros,
duas portas de oitenta por dois e dez"

App entende:
- Cômodo: Sala
- Comprimento: 5m
- Largura: 4m
- Altura: 3m
- Portas: 2 (0,80 × 2,10)

Área de parede calculada automaticamente
```

**Resultado esperado**: Medição com as duas mãos na trena, celular no bolso

---

### Tarefa 10: Análise de Margem
**Prioridade**: P3 (Pro+)  
**Esforço**: 2-3 dias  
**Tipo**: Feature de IA/finanças

**O que fazer**:
1. Adicionar campo `costCents` em `services` (custo estimado)
2. Calcular margem automaticamente no orçamento
3. Mostrar: "Custo: R$ X | Preço: R$ Y | Lucro: R$ Z (W%)"
4. Alertar se margem estiver abaixo de um limite

**Resultado esperado**: Profissional sabe quanto realmente ganha em cada orçamento

---

## 📋 RESUMO VISUAL DO ROADMAP

```
FASE 1.5 (esta semana)
├── Importar contato ──────────── 1-2 dias
└── Atualizar documentação ────── 30 min

FASE 2 (próximas 2 semanas)
├── Melhorar duplicação orçamento  1 hora
├── Duplicar serviço ──────────── 30 min
└── Modelos de orçamento (PRO) ── 2-3 dias

★ VALIDAÇÃO ──────────────────── 3-5 profissionais reais

FASE 3 (após validação)
├── Supabase + login anônimo ─── 3-5 dias
└── Sincronização local ↔ nuvem  3-5 dias

FASE 4 (após Fase 3)
└── Play Billing + paywall ───── 2-3 dias

FASE 5 (P2/P3, bem depois)
├── Medição por voz ───────────── 5-7 dias
└── Análise de margem ─────────── 2-3 dias
```

---

## ⏱️ CRONOGRAMA ESTIMADO

| Semana | Tarefas | Esforço |
|--------|---------|---------|
| **Esta semana** | Importar contato + Docs | 1.5-2.5 dias |
| **Próxima semana** | Duplicação + Serviço + Modelos | 3-4 dias |
| **Semana 3** | ★ Validação (usar o app em orçamentos reais) | Contínuo |
| **Semana 4-5** | Fase 3 (Supabase + Sync) | 6-10 dias |
| **Semana 6** | Fase 4 (Monetização) | 2-3 dias |
| **Mês 3+** | Fase 5 (IA) | 7-10 dias |

---

## 🎯 MÉTRICAS DE SUCESSO

### Antes da ★ Validação
- [ ] Fase 1: 21/21 itens (importar contato)
- [ ] Fase 2: 11/11 itens (modelos de orçamento)
- [ ] Documentação: 6/6 pendências resolvidas

### Durante a ★ Validação
- [ ] 3-5 profissionais usando o app em orçamentos reais
- [ ] Funil: criar → medir → orçar → PDF → compartilhar
- [ ] Feedback qualitativo: o que funciona, o que incomoda

### Após a ★ Validação
- [ ] Dados de retenção: D1, D7, D30
- [ ] Decisão: implementar Fase 3 (nuvem) ou ajustar produto
- [ ] Número de orçamentos criados por usuário

---

## 💡 RECOMENDAÇÕES ESTRATÉGICAS

### 1. Não pular a ★ Validação
O app está pronto pra validar. Cada dia sem feedback real é um dia de retrabalho potencial. Use o app em 2-3 orçamentos reais esta semana.

### 2. Agrupar mudanças nativas
Importar contato é mudança nativa (plugin novo no Gradle). Se houver outra mudança nativa pendente, agrupar num mesmo release completo pra evitar múltiplas reinstalações.

### 3. Modelos = diferencial PRO
Modelos de orçamento são o maior "atalho" que o app pode oferecer. É também o recurso mais fácil de monetizar (já é PRO no roadmap). Implementar antes da validação pode ajudar a testar o paywall.

### 4. Sync = retenção
A sincronização local ↔ nuvem é o que transforma o app de "ferramenta" em "plataforma". Sem sync, o profissional perde dados se trocar de celular. Com sync, ele tem motivos reais pra criar conta.

### 5. IA = último
IA (medição por voz, análise de margem) é diferencial, não necessities. Implementar só depois que o fluxo principal estiver validado e monetizado.

---

**Conclusão**: O projeto está em excelente estado. Fase 1 está quase completa, Fase 2 também. O próximo marco é a ★ Validação — usar o app em orçamentos reais e colher feedback. Depois disso, Fase 3 (nuvem) e Fase 4 (monetização) seguem naturalmente.
