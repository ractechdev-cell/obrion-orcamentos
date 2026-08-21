# Obrion Orçamentos

App de orçamento e medição rápidos para profissionais da construção civil (pedreiro, pintor, gesseiro, azulejista, eletricista, encanador, pequeno empreiteiro).

**Proposta de valor:** medir, montar o orçamento e enviar ao cliente pelo WhatsApp em poucos minutos — direto do celular, inclusive no canteiro.

Este é o App #1 da família **Obrion**, da RACTECH. Proprietário — todos os direitos reservados.

## Documentação

Leia nesta ordem antes de mexer no código:

1. [`CLAUDE.md`](./CLAUDE.md) — guia operacional para IA de programação: regras de engenharia, roadmap vigente, decisões tomadas.
2. [`docs/PLANO_DE_NEGOCIO_INICIAL.md`](./docs/PLANO_DE_NEGOCIO_INICIAL.md) — contexto de negócio, mercado, roadmap, KPIs.
3. [`docs/APP_FACTORY_RULES.md`](./docs/APP_FACTORY_RULES.md) — regras mestras: arquitetura, stack, banco, monetização, LGPD, testes.
4. [`docs/APP_FACTORY_CORE.md`](./docs/APP_FACTORY_CORE.md) — catálogo dos módulos reutilizáveis do Core (extraído a partir do App #2).
5. [`docs/ANALISE_E_MELHORIAS.md`](./docs/ANALISE_E_MELHORIAS.md) — análise crítica que originou a revisão de 21/08/2026 (roadmap invertido, paywall por recurso, AdMob adiado).

## Stack

Flutter · Drift/SQLite (banco local, fonte da verdade) · Supabase (backup/sync) · Firebase (Analytics, Crashlytics, Remote Config, Cloud Messaging) · Google Play Billing.

## Rodando o projeto

```bash
flutter pub get
flutter run
```

## Testes

```bash
flutter analyze
flutter test
```

## Identificadores

- `applicationId` / bundle id: `br.com.ractech.obrion.orcamentos`
- Repositório: parte da família Obrion — ver `docs/APP_FACTORY_CORE.md` para os identificadores dos demais apps.

## Versionamento

SemVer (`MAJOR.MINOR.PATCH`) em `pubspec.yaml`, com tags Git `vX.Y.Z`. Enquanto a versão for `0.x.y`, o produto está em desenvolvimento inicial — sem garantia de estabilidade de API/schema entre versões menores. Ver `CHANGELOG.md`.

## Commits

[Conventional Commits](https://www.conventionalcommits.org/): `feat:`, `fix:`, `chore:`, `docs:`, `refactor:`, `test:`, `ci:`.
