/// Enums do schema local (Drift). Ver docs/APP_FACTORY_RULES.md §4 e
/// CLAUDE.md, "Lista de preços pessoal" / "Status do orçamento".
library;

/// Unidade de medida de um serviço da lista de preços (`services`).
enum ServiceUnit {
  squareMeter, // m²
  linearMeter, // m
  cubicMeter, // m³
  unit, // un
  point, // ponto (ex.: ponto elétrico)
  dailyRate, // diária
  lumpSum, // verba
}

/// Ciclo de vida do orçamento — mecanismo de retenção (CLAUDE.md, "Status
/// do orçamento"). Atualizável em um toque; nunca pular etapas via UI.
enum BudgetStatus {
  draft, // rascunho
  sent, // enviado
  accepted, // aceito
  declined, // recusado
}

/// Tipo de vão medido dentro de um ambiente (porta ou janela), usado para
/// derivar area_parede e perimetro_util — ver CLAUDE.md, "Medição guarda
/// geometria bruta".
enum OpeningType {
  door,
  window,
}
