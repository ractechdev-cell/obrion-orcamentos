# Regras específicas do R8/ProGuard pro Obrion Orçamentos.
#
# Vazio de propósito: Firebase (SDKs recentes) e os plugins Flutter usados
# aqui já trazem suas próprias regras de consumo (flutter_local_notifications
# v19+ inclusive, via GSON) — não vale adicionar regra "por garantia" sem um
# problema real pra apontar, isso só anula o ganho do R8 sem necessidade.
#
# Se algo quebrar em runtime numa build release depois de religar o R8
# (23/08/2026, ver comentário em build.gradle.kts), a regra específica pro
# que quebrou entra aqui — não uma regra genérica "-keep class **".
