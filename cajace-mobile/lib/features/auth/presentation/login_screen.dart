import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/cajace_button.dart';
import '../../../shared/widgets/cajace_input.dart';
import 'auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final FormState? form = _formKey.currentState;
    if (form == null || !form.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();

    await ref
        .read(authProvider.notifier)
        .login(_emailController.text.trim(), _passwordController.text);

    final AuthState authState = ref.read(authProvider);
    if (!mounted) {
      return;
    }

    if (authState.isAuthenticated) {
      context.go(AppStrings.dashboardRoute);
    }
  }

  @override
  Widget build(BuildContext context) {
    final AuthState authState = ref.watch(authProvider);
    final bool isLoading = authState.status == AuthStatus.loading;
    final bool obscurePassword = ref.watch(loginPasswordVisibilityProvider);
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppTheme.backgroundSecondary,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppTheme.backgroundPrimary,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: const <BoxShadow>[AppTheme.cardShadow],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            _LoginScreenStrings.brandLabel,
                            style: textTheme.labelLarge?.copyWith(
                              color: AppTheme.primary,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _LoginScreenStrings.brandTitle,
                            style:
                                textTheme.headlineMedium?.copyWith(fontSize: 26),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _LoginScreenStrings.brandSubtitle,
                            maxLines: 3,
                            style: textTheme.bodyMedium?.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 18),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: const <Widget>[
                              _LoginTag(label: _LoginScreenStrings.featureOneTitle),
                              _LoginTag(label: _LoginScreenStrings.featureTwoTitle),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                decoration: const BoxDecoration(
                  color: AppTheme.backgroundCard,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: AppTheme.shadow,
                      blurRadius: 12,
                      offset: Offset(0, -2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(32, 32, 32, 40),
                  child: Form(
                    key: _formKey,
                    child: AutofillGroup(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            _LoginScreenStrings.formLabel,
                            style: textTheme.labelLarge?.copyWith(
                              color: AppTheme.primary,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _LoginScreenStrings.formTitle,
                            style: textTheme.headlineLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _LoginScreenStrings.formSubtitle,
                            style: textTheme.bodyMedium?.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 28),
                          Text(
                            _LoginScreenStrings.emailLabel,
                            style: textTheme.labelLarge?.copyWith(
                              color: AppTheme.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Theme(
                            data: Theme.of(context).copyWith(
                              inputDecorationTheme: _formInputDecorationTheme,
                            ),
                            child: CajaceInput(
                              controller: _emailController,
                              label: _LoginScreenStrings.emailLabel,
                              hintText: _LoginScreenStrings.emailHint,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              prefixIcon: const Icon(
                                Icons.mail_outline,
                                color: AppTheme.textHint,
                              ),
                              autofillHints: const <String>[
                                AutofillHints.username,
                                AutofillHints.email,
                              ],
                              validator: (value) {
                                final String email = value?.trim() ?? '';
                                if (email.isEmpty) {
                                  return _LoginScreenStrings.emailRequiredError;
                                }

                                final RegExp emailRegex = RegExp(
                                  r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                                );

                                if (!emailRegex.hasMatch(email)) {
                                  return _LoginScreenStrings.emailInvalidError;
                                }

                                return null;
                              },
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: Text(
                                  _LoginScreenStrings.passwordLabel,
                                  style: textTheme.labelLarge?.copyWith(
                                    color: AppTheme.textSecondary,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: isLoading
                                    ? null
                                    : () => context.push(AppStrings.recoveryRoute),
                                style: TextButton.styleFrom(
                                  foregroundColor: AppTheme.primary,
                                  padding: EdgeInsets.zero,
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: Text(
                                  _LoginScreenStrings.recoverAccessLabel,
                                  style: textTheme.bodySmall?.copyWith(
                                    color: AppTheme.primary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Theme(
                            data: Theme.of(context).copyWith(
                              inputDecorationTheme: _formInputDecorationTheme,
                            ),
                            child: CajaceInput(
                              controller: _passwordController,
                              label: _LoginScreenStrings.passwordLabel,
                              hintText: _LoginScreenStrings.passwordHint,
                              obscureText: obscurePassword,
                              textInputAction: TextInputAction.done,
                              onSubmitted: (_) => _submit(),
                              prefixIcon: const Icon(
                                Icons.lock_outline,
                                color: AppTheme.textHint,
                              ),
                              suffixIcon: IconButton(
                                onPressed: () {
                                  ref
                                      .read(
                                        loginPasswordVisibilityProvider
                                            .notifier,
                                      )
                                      .state = !obscurePassword;
                                },
                                icon: Icon(
                                  obscurePassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: AppTheme.textHint,
                                ),
                              ),
                              autofillHints: const <String>[
                                AutofillHints.password,
                              ],
                              enableSuggestions: false,
                              validator: (value) {
                                final String password = value ?? '';
                                if (password.isEmpty) {
                                  return _LoginScreenStrings
                                      .passwordRequiredError;
                                }
                                if (password.length < 6) {
                                  return _LoginScreenStrings
                                      .passwordLengthError;
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(height: 28),
                          CajaceButton(
                            label: _LoginScreenStrings.submitButton,
                            isLoading: isLoading,
                            onPressed: isLoading ? null : _submit,
                          ),
                          if (authState.errorMessage != null) ...<Widget>[
                            const SizedBox(height: 16),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryLight,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  const Icon(
                                    Icons.error_outline,
                                    color: AppTheme.error,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      authState.errorMessage!,
                                      style: textTheme.bodyMedium?.copyWith(
                                        color: AppTheme.error,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          const SizedBox(height: 16),
                          Center(
                            child: Text(
                              _LoginScreenStrings.bottomCaption,
                              textAlign: TextAlign.center,
                              style: textTheme.bodySmall?.copyWith(
                                color: AppTheme.textHint,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecorationTheme get _formInputDecorationTheme {
    const OutlineInputBorder enabledBorder = OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
      borderSide: BorderSide(color: AppTheme.border, width: 1),
    );

    const OutlineInputBorder focusedBorder = OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
      borderSide: BorderSide(color: AppTheme.primary, width: 1.5),
    );

    const OutlineInputBorder errorBorder = OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
      borderSide: BorderSide(color: AppTheme.error, width: 1),
    );

    return const InputDecorationTheme(
      filled: true,
      fillColor: AppTheme.backgroundSecondary,
      hintStyle: TextStyle(
        color: AppTheme.textHint,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      labelStyle: TextStyle(
        color: AppTheme.textSecondary,
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
      errorStyle: TextStyle(
        color: AppTheme.error,
        fontSize: 12,
        fontWeight: FontWeight.w400,
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: enabledBorder,
      enabledBorder: enabledBorder,
      focusedBorder: focusedBorder,
      errorBorder: errorBorder,
      focusedErrorBorder: errorBorder,
    );
  }
}

class _LoginTag extends StatelessWidget {
  const _LoginTag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.primaryLight,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.primary,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

class _LoginScreenStrings {
  const _LoginScreenStrings._();

  static const String brandLabel = 'ACCESO INSTITUCIONAL';
  static const String brandTitle = 'Plataforma de acceso CAJACE';
  static const String brandSubtitle =
      'Accede a una experiencia mobile clara, segura y alineada con tu espacio de trabajo.';
  static const String featureOneTitle = 'Ingreso seguro';
  static const String featureTwoTitle = 'Sesion persistente';
  static const String formLabel = 'INICIO DE SESION';
  static const String formTitle = 'Bienvenido';
  static const String formSubtitle =
      'Ingresa con tu cuenta institucional para acceder al sistema.';
  static const String emailLabel = 'Correo electronico';
  static const String emailHint = 'nombre@cajace.com';
  static const String passwordLabel = 'Contrasena';
  static const String passwordHint = 'Ingresa tu contrasena';
  static const String recoverAccessLabel = 'Recuperar acceso';
  static const String submitButton = 'Ingresar';
  static const String bottomCaption =
      'Acceso restringido al personal autorizado';
  static const String emailRequiredError = 'Ingresa tu correo.';
  static const String emailInvalidError = 'Correo invalido.';
  static const String passwordRequiredError = 'Ingresa tu contrasena.';
  static const String passwordLengthError = 'Debe tener al menos 6 caracteres.';
}
