/// Mensagem pronta pro follow-up de orçamento aguardando resposta — ver
/// docs/ROADMAP_UX_UI_E_FEATURES_APP1.md, seção 10. Só pré-preenche a
/// conversa do WhatsApp; quem decide mandar é sempre o usuário.
String followUpMessage(String clientName) {
  final firstName = clientName.trim().split(' ').first;
  return 'Olá $firstName, tudo bem? Passando para saber se conseguiu analisar '
      'o orçamento que enviei. Qualquer dúvida, estou à disposição.';
}
