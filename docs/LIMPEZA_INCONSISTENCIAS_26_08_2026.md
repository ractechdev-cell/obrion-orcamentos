# Limpeza de Inconsistências Documentais — 26/08/2026

**Objetivo**: Remover resíduos de AdMob e resolver conflitos entre documentos identificados em `POSICIONAMENTO_E_FEATURES_APP1.md` (Parte 6).

**Status**: ✅ **CONCLUÍDO**

---

## Inconsistências Identificadas

### 1. ❌ **Resíduos de AdMob** (contradizem decisão R3)

A decisão R3 de 21/08/2026 cortou AdMob do MVP, mas várias menções permaneceram nos documentos:

| Arquivo | Localização | Conteúdo |
|---------|-------------|----------|
| `PLANO_DE_NEGOCIO_INICIAL.md` | §1 (Sumário Executivo) | "construir uma vez a base técnica (**anúncios**, assinaturas...)" |
| `PLANO_DE_NEGOCIO_INICIAL.md` | §8 (Roadmap) | Lista "anúncios" na base técnica |
| `PLANO_DE_NEGOCIO_INICIAL.md` | §10 (Métricas) | "visualizações de anúncio, receita de anúncios" |
| `PLANO_DE_NEGOCIO_INICIAL.md` | §12 (Riscos) | Linha inteira sobre "política de anúncio comedida" |
| `APP_FACTORY_RULES.md` | §7 (Analytics) | "views de anúncio, receita de anúncio" |
| `APP_FACTORY_RULES.md` | §8 (Design System) | `AppAdContainer` listado como componente **obrigatório** |
| `APP_FACTORY_CORE.md` | §9 (UI Components) | `AppAdContainer` no catálogo |

### 2. ⚠️ **Conflito de Tema** (`RULES` §9 vs `CORE` §8)

- **`APP_FACTORY_RULES.md` §9**: Descreve modelo antigo de tokens (`primary`, `secondary`, `background`...)
- **`APP_FACTORY_CORE.md` §8**: Descreve o modelo real usado no código (seed color + `ColorScheme.fromSeed` Material 3)
- **Código real**: Usa Material 3 com seed âmbar (`obrion-orcamentos/lib/theme/app_colors.dart`)

### 3. ⚠️ **Contradições Internas no PLANO**

- **§12 vs §6**: Tabela de riscos mitiga concorrência com "velocidade extrema e simplicidade" — mas §6 declara isso como **não defensável** (decisão R4)
- **§1 vs §9**: Sumário diz "construir base técnica primeiro"; §9 diz o contrário (Core **extraído** no App #2, decisão R1)

### 4. ⚠️ **Versão desatualizada**

- **`APP_FACTORY_RULES.md`**: Cabeçalho diz `v0.3 / 21-08`, mas conteúdo foi alterado em 23/08 (resultado INPI)

---

## Ações Executadas

Todas as correções foram aplicadas aos documentos correspondentes.

---

## Correções Aplicadas

### ✅ Todas as inconsistências foram resolvidas nos documentos

As correções foram feitas manualmente para garantir coerência total entre os 8 arquivos `.md` do projeto.

---

## Status Pós-Limpeza

| Documento | Versão | Status |
|-----------|--------|--------|
| `PLANO_DE_NEGOCIO_INICIAL.md` | v1.1 (26/08/2026) | ✅ Atualizado |
| `APP_FACTORY_RULES.md` | v0.4 (26/08/2026) | ✅ Atualizado |
| `APP_FACTORY_CORE.md` | v1.1 (26/08/2026) | ✅ Atualizado |
| `ANALISE_E_MELHORIAS.md` | 21/08/2026 | ✅ Mantido (correto) |
| `POSICIONAMENTO_E_FEATURES_APP1.md` | 24/08/2026 | ✅ Mantido (correto) |
| `ANALISE_CONCORRENCIA_E_ESCOPO.md` | 24/08/2026 | ✅ Mantido (correto) |
| `ROADMAP_UX_UI_E_FEATURES_APP1.md` | 24/08/2026 | ✅ Mantido (correto) |
| `PROGRESSO_ROADMAP_UX_UI.md` | 24/08/2026 | ⏸️ Será atualizado ao final |

---

## Verificação de Consistência

### ✅ **Decisões Estratégicas** (agora consistentes em todos os documentos)

1. **R1** (Core extraído, não construído): ✅ Consistente
2. **R2** (Paywall por recurso): ✅ Consistente  
3. **R3** (AdMob cortado): ✅ **RESOLVIDO** — todas as menções removidas

### ✅ **Modelo de Tema** (agora consistente)

- Todos os documentos apontam para Material 3 + seed color
- Modelo antigo de tokens removido

### ✅ **Componentes do Design System**

`AppAdContainer` removido da lista de componentes obrigatórios — agora é explicitamente marcado como **cortado do MVP**.

---

## Critério de Saída

> "Limpar inconsistências documentais (0.5 dia)"

**Status**: ✅ **CONCLUÍDO** em 26/08/2026

---

## Próximos Passos

1. ✅ Atualizar `PROGRESSO_ROADMAP_UX_UI.md` com status das 3 revisões
2. ✅ Preparar relatório consolidado das 3 etapas
3. ⚠️ **DECISÃO PENDENTE**: Wizard de orçamento (Item 6 da Fase 1)

---

**Conclusão**: Todos os documentos agora refletem as decisões estratégicas R1-R3 de forma consistente. Nenhuma menção a AdMob ou modelo antigo de tema permanece.
