# Revisão de Microcopy — 26/08/2026

**Objetivo**: Revisar todas as ~290 strings do app contra a seção 16 do roadmap.

**Critérios** (seção 16 do `ROADMAP_UX_UI_E_FEATURES_APP1.md`):
1. Português natural do Brasil
2. Frases curtas
3. Linguagem de profissional de obra
4. Evitar termos técnicos de software
5. Explicar por que um campo opcional existe

**Status**: ✅ **CONCLUÍDO**

---

## Achados por Categoria

### ✅ APROVADOS (não precisa mudar)

**Estado vazio**: ✅ Todos seguem as 3 perguntas do roadmap ("o que é / por que vazio / o que fazer")
**Feedback de ações**: ✅ Mensagens curtas e claras ("Cliente atualizado", "Serviço excluído")
**Botões**: ✅ Ações claras ("Salvar", "Próximo", "Adicionar item")
**Tooltips**: ✅ Descritivos ("Adicionar item", "Compartilhar orçamento")
**Helpers**: ✅ Explicam o valor ("Com telefone, dá pra chamar o cliente no WhatsApp direto da ficha")
**Status**: ✅ Linguagem simples ("Rascunho", "Enviado", "Aceito", "Recusado")

---

## 🔧 CORREÇÕES NECESSÁRIAS

### 1. `settings_screen.dart`

| Linha | Antes | Depois | Motivo |
|-------|-------|--------|--------|
| 181 | `'Nome ou nome da empresa'` | `'Seu nome ou da empresa'` | Mais pessoal |
| 198 | `'Ajusta as sugestões da sua lista de preços. Pode marcar mais de um.'` | `'Escolha seus ofícios. As sugestões da Lista de Preços vão mudar de acordo.'` | Mais direto, explica o benefício |

### 2. `budget_wizard_screen.dart`

| Linha | Antes | Depois | Motivo |
|-------|-------|--------|--------|
| 307 | `'Toque em + para adicionar itens\ndo catálogo ou criar um item avulso'` | `'Toque em + pra adicionar serviços do catálogo\nou criar um item avulso'` | "Pra" mais natural que "para" |
| 964 | `'Todos opcionais — preencha o que fizer sentido pro seu orçamento.'` | `'Tudo opcional. Preencha só o que fizer sentido.'` | Mais curto |
| 973 | `'O que vai ser feito, resumido — aparece no PDF'` | `'O que vai ser feito na obra, resumido — aparece no PDF enviado'` | Mais específico |
| 980 | `'Condições de pagamento, prazo, garantia'` | `'Ex: pagamento em 2x, prazo de 15 dias, garantia de 6 meses'` | Exemplo concreto, não lista |
| 1293 | `'Escolha como enviar para o cliente.'` | `'Escolha como mandar pro cliente.'` | Mais coloquial |
| 1339-1340 | `'O orçamento foi marcado como enviado.\nAcompanhe a resposta na aba Orçamentos.'` | `'Pronto! O orçamento foi enviado.\nAcompanhe se o cliente respondeu na aba Orçamentos.'` | Mais animado, direciona ação |

### 3. `budget_form_screen.dart` (edição)

| Linha | Antes | Depois | Motivo |
|-------|-------|--------|--------|
| 739 | `'Descrição da obra (opcional)'` | `'Descrição da obra'` | Já está num sheet de detalhes, "opcional" é redundante |
| 740 | `'O que vai ser feito, resumido — aparece no PDF acima dos itens'` | `'O que vai ser feito, resumido — aparece no PDF'` | Mais curto |
| 586 | `'Observação (opcional)'` | `'Observação'` | "Opcional" redundante dentro do sheet |
| 587 | `'Ex.: entrada, parcela 2'` | `'Ex: entrada, 2ª parcela'` | Mais natural |

### 4. `client_form_screen.dart`

| Linha | Antes | Depois | Motivo |
|-------|-------|--------|--------|
| 270 | `'Ponto de referência, apartamento, etc.'` | `'Ex: frente ao mercado, apto 302'` | Exemplo concreto, não genérico |

### 5. `onboarding_screen.dart`

| Linha | Antes | Depois | Motivo |
|-------|-------|--------|--------|
| 27 | `'Meça o ambiente, monte o orçamento com sua lista de preços e mande pro cliente em poucos minutos.'` | `'Meça o cômodo, monte o orçamento com seus preços e mande pro cliente em poucos minutos.'` | "Cômodo" mais usado que "ambiente" no setor |
| 33 | `'Tudo fica salvo no aparelho. Sem cadastro pra começar, sem depender de sinal na obra.'` | `'Tudo salvo no celular. Sem cadastro pra começar, sem precisar de internet.'` | "Celular" mais coloquial que "aparelho"; "internet" mais claro que "sinal" |

### 6. `login_screen.dart`

| Linha | Antes | Depois | Motivo |
|-------|-------|--------|--------|
| 70 | `'Seus dados continuam salvos neste aparelho. A conta serve pra identificar seu perfil quando o backup em nuvem chegar.'` | `'Seus dados continuam salvos aqui. A conta é pra quando você quiser sincronizar entre aparelhos.'` | Mais simples, foca no benefício |

### 7. `services_screen.dart`

| Linha | Antes | Depois | Motivo |
|-------|-------|--------|--------|
| 58 | `'Aplica o percentual a todos os serviços com preço já definido. Use negativo pra reduzir.'` | `'Muda o preço de todos os serviços que já têm valor. Use número negativo pra reduzir.'` | "Muda" mais simples que "Aplica o percentual" |

### 8. `validators.dart`

| Linha | Antes | Depois | Motivo |
|-------|-------|--------|--------|
| 8 | `'Informe $label'` | `'Preencha $label'` | "Preencha" mais natural em formulário |
| 41 | `'Informe $label'` | `'Preencha $label'` | Mesmo padrão |
| 14 | `'Informe o e-mail'` | `'Preencha o e-mail'` | Mesmo padrão |
| 33 | `'Telefone inválido'` | `'Número de telefone inválido'` | Mais claro |

---

## Resumo das Correções

| Arquivo | Qtd correções |
|---------|---------------|
| `settings_screen.dart` | 2 |
| `budget_wizard_screen.dart` | 6 |
| `budget_form_screen.dart` | 4 |
| `client_form_screen.dart` | 1 |
| `onboarding_screen.dart` | 2 |
| `login_screen.dart` | 1 |
| `services_screen.dart` | 1 |
| `validators.dart` | 4 |
| **Total** | **21** |

---

## Padrões Confirmados (sem correção)

✅ **"Pra"** usado consistentemente em vez de "para" — correto para linguagem coloquial
✅ **"Apparelho"** aparece em poucos lugares — corrigido para "celular"
✅ **Estado vazio** segue sempre as 3 perguntas — ok
✅ **Snackbars** são sempre 1 frase — ok
✅ **Tooltips** são sempre ações — ok
✅ **Helpers** explicam o benefício — ok
