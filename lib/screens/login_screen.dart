import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/account_repository_provider.dart';
import '../theme/app_spacing.dart';
import '../utils/validators.dart';
import '../widgets/app_button.dart';
import '../widgets/app_snackbar.dart';
import '../widgets/app_text_field.dart';

/// Tela de login/cadastro — **só interface nesta fase** (ver CLAUDE.md,
/// decisão 5): não existe Supabase nem conta real ainda, "Entrar" e
/// "Criar conta" apenas guardam o e-mail localmente para a tela de
/// Configurações deixar de mostrar "Visitante". Nunca é a primeira tela
/// do app (princípio 5) — só é alcançável a partir de Configurações, e
/// todo o fluxo de orçamento continua funcionando sem passar por aqui.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSignUp = false;
  bool _submitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _submitting = true);

    final repository = ref.read(accountRepositoryProvider);
    await repository.signIn(_emailController.text.trim());

    if (mounted) {
      AppSnackBar.show(
        context,
        'Conta salva neste aparelho. Sincronização em nuvem chega numa próxima fase.',
      );
      Navigator.of(context).pop(true);
    }
    if (mounted) setState(() => _submitting = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isSignUp ? 'Criar conta' : 'Entrar')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            Text(
              _isSignUp ? 'Crie sua conta' : 'Entre na sua conta',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Seus dados continuam salvos neste aparelho. A conta serve pra identificar '
              'seu perfil quando o backup em nuvem chegar.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: AppSpacing.lg),
            AppTextField(
              controller: _emailController,
              label: 'E-mail',
              keyboardType: TextInputType.emailAddress,
              validator: emailValidator,
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              controller: _passwordController,
              label: 'Senha',
              obscureText: true,
              validator: requiredValidator('a senha'),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppButton(
              label: _isSignUp ? 'Criar conta' : 'Entrar',
              loading: _submitting,
              onPressed: _submitting ? null : _submit,
            ),
            const SizedBox(height: AppSpacing.md),
            Center(
              child: TextButton(
                onPressed: _submitting ? null : () => setState(() => _isSignUp = !_isSignUp),
                child: Text(
                  _isSignUp ? 'Já tenho conta — entrar' : 'Não tenho conta — criar',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
