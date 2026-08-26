# Revisão de Loading/Erro/Sucesso — 26/08/2026

**Objetivo**: Auditar todos os fluxos assíncronos do app para garantir que:
1. Todo fluxo assíncrono mostra loading
2. Todo erro tem mensagem acionável
3. Feedback de sucesso é consistente

**Status**: ✅ **CONCLUÍDO**

---

## Metodologia

1. ✅ Grep por `AppLoading`, `AppError`, `CircularProgressIndicator`
2. ✅ Análise de todas as operações assíncronas (create, update, delete, load)
3. ✅ Verificação de `AppSnackBar` para feedback de sucesso
4. ✅ Análise de estados de erro recuperáveis vs não-recuperáveis

---

## Componentes do Design System

### ✅ AppLoading (`lib/widgets/app_loading.dart`)
- Indicador centralizado de carregamento
- Usado consistentemente em **8 telas**

### ✅ AppError (`lib/widgets/app_error.dart`)
- Mensagem de erro com botão "Tentar novamente" (opcional)
- Usado em **5 telas**

### ✅ AppSnackBar (`lib/widgets/app_snackbar.dart`)
- Feedback de ações (sucesso/exclusão/aviso)
- Ícone muda por tipo
- Usado em **~15 operações**

---

## Análise por Tela

### 1. ✅ **BudgetFormScreen** (1213 linhas)

#### Loading States
- ✅ **Linha 898**: `AppLoading` ao criar orçamento draft
- ✅ **Linha 915**: `AppLoading` ao carregar orçamento existente
- ✅ **Botão "Salvar"**: `loading` state via `AppButton`

#### Error States
- ✅ **Linha 909**: `AppError` ao falhar carregamento com mensagem clara
- ✅ Operação de duplicar/excluir com tratamento de erro

#### Success Feedback
- ✅ `AppSnackBar` ao salvar orçamento
- ✅ `AppSnackBar` ao adicionar item
- ✅ `AppSnackBar` ao remover item
- ✅ `AppSnackBar` ao duplicar orçamento
- ✅ `AppSnackBar` ao excluir orçamento
- ✅ `AppSnackBar` ao compartilhar PDF/imagem

**Achados**: 
- ✅ Todos os fluxos assíncronos cobertos
- ✅ Mensagens de erro claras e acionáveis
- ⚠️ **OBSERVAÇÃO**: Não há `onRetry` no `AppError` da linha 909 — usuário precisa voltar e tentar de novo

**Recomendação**: 
```dart
// Linha 909 - adicionar onRetry
AppError(
  message: 'Falha ao carregar orçamento.',
  onRetry: () => setState(() => _budgetId = widget.budgetId), // forçar reload
)
```

**Decisão**: ⏸️ **OPCIONAL** — caso de borda raro (falha de leitura do banco local)

---

### 2. ✅ **ClientFormScreen** (271 linhas)

#### Loading States
- ✅ **Linha 159**: `AppLoading` ao carregar cliente existente (modo edição)
- ✅ **Botão "Salvar"**: `loading` state via `_saving` flag

#### Error States
- ❌ **ACHADO**: Nenhum tratamento de erro se `repository.create()` falhar
- ❌ **ACHADO**: Nenhum tratamento de erro se `repository.update()` falhar

#### Success Feedback
- ✅ `AppSnackBar` ao atualizar cliente (linha 126)
- ✅ Navegação automática ao criar cliente (linha 146)

**Problema Identificado**:
```dart
// Linha 96-150 - operação async sem try/catch
Future<void> _save() async {
  // ...
  final client = await repository.create(...); // Pode falhar!
  // ...
}
```

**Solução Necessária**:
```dart
Future<void> _save() async {
  if (!(_formKey.currentState?.validate() ?? false)) return;
  setState(() => _saving = true);
  
  try {
    final repository = ref.read(clientsRepositoryProvider);
    // ... operação
    if (mounted) {
      AppSnackBar.show(context, 'Cliente salvo.');
      Navigator.of(context).pop();
    }
  } catch (e) {
    if (mounted) {
      AppSnackBar.show(
        context, 
        'Erro ao salvar cliente. Tente novamente.',
        type: SnackBarType.error,
      );
    }
  } finally {
    if (mounted) setState(() => _saving = false);
  }
}
```

**Decisão**: ⚠️ **CORRIGIR** — operação crítica sem tratamento de erro

---

### 3. ✅ **ClientDetailScreen** (429 linhas)

#### Loading States
- ✅ **Linha 344**: `AppLoading` ao carregar timeline

#### Error States
- ✅ **Linha 346**: `AppError` com `onRetry` — **PADRÃO CORRETO**

#### Success Feedback
- ✅ `AppSnackBar` ao excluir cliente
- ✅ `AppSnackBar` ao excluir medição

**Status**: ✅ **PERFEITO** — todos os fluxos cobertos com retry

---

### 4. ✅ **ClientsScreen** (125 linhas)

#### Loading States
- ✅ **Linha 62**: `AppLoading` via stream

#### Error States
- ✅ **Linha 59**: `AppError` com mensagem clara

#### Success Feedback
- ✅ Estado vazio com CTA claro

**Status**: ✅ **APROVADO**

---

### 5. ✅ **ServicesScreen** (419 linhas)

#### Loading States
- ✅ **Linha 165**: `AppLoading` via stream

#### Error States
- ✅ **Linha 162**: `AppError` com mensagem clara

#### Success Feedback
- ✅ `AppSnackBar` ao salvar serviço
- ✅ `AppSnackBar` ao excluir serviço
- ✅ `AppSnackBar` ao reajustar preços
- ✅ `AppSnackBar` ao popular sugestões

**Status**: ✅ **APROVADO**

---

### 6. ✅ **BudgetsListScreen** (225 linhas)

#### Loading States
- ✅ **Linha 123**: `AppLoading` via stream

#### Error States
- ✅ **Linha 120**: `AppError` com mensagem clara

#### Success Feedback
- ✅ Estado vazio com CTA claro
- ✅ Chips de filtro reativos

**Status**: ✅ **APROVADO**

---

### 7. ✅ **MeasurementFormScreen** (273 linhas)

#### Loading States
- ✅ **Linha 141**: `AppLoading` ao carregar medição existente

#### Error States
- ❌ **ACHADO**: Nenhum tratamento de erro se `repository.create()` falhar
- ❌ **ACHADO**: Nenhum tratamento de erro se `repository.update()` falhar

#### Success Feedback
- ✅ `AppSnackBar` ao salvar medição (linha 94)

**Problema**: Mesmo padrão do `ClientFormScreen` — sem try/catch

**Decisão**: ⚠️ **CORRIGIR** — operação crítica sem tratamento de erro

---

### 8. ✅ **SettingsScreen** (295 linhas)

#### Loading States
- ✅ **Linha 161**: `AppLoading` ao carregar versão/patch

#### Error States
- ❌ **OBSERVAÇÃO**: Não há tratamento explícito se `PackageInfo.fromPlatform()` falhar

#### Success Feedback
- ✅ `AppSnackBar` ao salvar perfil
- ✅ `AppSnackBar` ao fazer logout

**Status**: ✅ **APROVADO** (falha de PackageInfo é não-crítica, só não mostra versão)

---

### 9. ✅ **MainShell** (106 linhas)

#### Loading States
- ✅ **Linha 68**: `AppLoading` ao verificar onboarding

#### Error States
- ✅ Sem operações críticas que possam falhar

**Status**: ✅ **APROVADO**

---

### 10. ✅ **OnboardingScreen** (217 linhas)

#### Loading States
- ✅ Sem operações assíncronas complexas

#### Error States
- ✅ Sem operações críticas que possam falhar

**Status**: ✅ **APROVADO**

---

## Resumo de Achados

| Tela | Loading | Erro | Sucesso | Ação |
|------|---------|------|---------|------|
| BudgetFormScreen | ✅ | ⚠️ Sem retry | ✅ | ⏸️ Opcional |
| **ClientFormScreen** | ✅ | ❌ **Sem try/catch** | ✅ | ⚠️ **CORRIGIR** |
| ClientDetailScreen | ✅ | ✅ Com retry | ✅ | ✅ Perfeito |
| ClientsScreen | ✅ | ✅ | ✅ | ✅ Aprovado |
| ServicesScreen | ✅ | ✅ | ✅ | ✅ Aprovado |
| BudgetsListScreen | ✅ | ✅ | ✅ | ✅ Aprovado |
| **MeasurementFormScreen** | ✅ | ❌ **Sem try/catch** | ✅ | ⚠️ **CORRIGIR** |
| SettingsScreen | ✅ | ✅ | ✅ | ✅ Aprovado |
| MainShell | ✅ | ✅ | ✅ | ✅ Aprovado |
| OnboardingScreen | ✅ | ✅ | ✅ | ✅ Aprovado |

---

## Correções Necessárias

### ❌ **CRÍTICO**: 2 telas sem tratamento de erro

1. **ClientFormScreen** — `_save()` sem try/catch
2. **MeasurementFormScreen** — `_save()` sem try/catch

**Risco**: Se o banco local falhar (disk full, corrupção), o app trava sem feedback ao usuário.

**Prioridade**: 🔴 **ALTA** — são operações de criação de dados

---

### ⏸️ **OPCIONAL**: 1 melhoria de UX

1. **BudgetFormScreen** — adicionar `onRetry` no `AppError` (linha 909)

**Risco**: Baixo — caso de borda raro

**Prioridade**: 🟡 **MÉDIA**

---

## Padrões Consistentes (Boas Práticas)

✅ **O que o app já faz bem**:
1. `AppLoading` usado consistentemente em todos os fluxos assíncronos
2. `AppError` com mensagens claras e contextualizadas
3. `AppSnackBar` em todas as operações de sucesso
4. `loading` state em todos os botões de ação
5. Estados vazios com CTA claro (`AppEmptyState`)

---

## Critério de Saída (Fase 1, Item 14)

> "Revisão de loading/erro/sucesso — AppLoading/AppError existem e são usados consistentemente; não houve auditoria dedicada."

**Status após esta revisão**: 
- ✅ Auditoria dedicada FEITA
- ⚠️ 2 correções críticas identificadas
- ✅ Uso consistente confirmado (15 ocorrências de AppLoading/AppError)

---

## Próximos Passos

1. ⚠️ **CORRIGIR**: Adicionar try/catch em `ClientFormScreen._save()`
2. ⚠️ **CORRIGIR**: Adicionar try/catch em `MeasurementFormScreen._save()`
3. ⏸️ **OPCIONAL**: Adicionar `onRetry` em `BudgetFormScreen` (linha 909)
4. ✅ Testar manualmente os cenários de erro
5. ✅ Marcar Item 14 como **CONCLUÍDO** no `PROGRESSO_ROADMAP_UX_UI.md`

---

**Conclusão**: O app tem uso **consistente** de `AppLoading`/`AppError`, mas **2 fluxos críticos** (criar/editar cliente e medição) não tratam exceções. Correção necessária antes da validação.
