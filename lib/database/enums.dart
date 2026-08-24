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

/// Ofício do profissional, escolhido no onboarding (múltipla escolha) e
/// editável depois em Ajustes — ver docs/POSICIONAMENTO_E_FEATURES_APP1.md,
/// Parte 3 ("camada de ofício"). Guardado em `app_settings`
/// (`ProfileRepository`), não numa coluna própria — não é geometria nem
/// dinheiro, é preferência de perfil. Usado para filtrar as sugestões da
/// lista de preços por ofício, em vez do bloco único de 23 serviços.
enum Trade {
  mason, // pedreiro
  painter, // pintor
  plasterer, // gesseiro
  tiler, // azulejista
  electrician, // eletricista
  plumber, // encanador
}
