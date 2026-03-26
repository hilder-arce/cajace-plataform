import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/cajace_button.dart';
import '../../../shared/widgets/cajace_input.dart';
import '../data/auth_repository.dart';

class PasswordRecoveryScreen extends ConsumerStatefulWidget {
  const PasswordRecoveryScreen({super.key});

  @override
  ConsumerState<PasswordRecoveryScreen> createState() =>
      _PasswordRecoveryScreenState();
}

class _PasswordRecoveryScreenState
    extends ConsumerState<PasswordRecoveryScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final ValueNotifier<int> _step = ValueNotifier<int>(0);
  final ValueNotifier<bool> _isLoading = ValueNotifier<bool>(false);
  final ValueNotifier<String?> _message = ValueNotifier<String?>(null);

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _passwordController.dispose();
    _step.dispose();
    _isLoading.dispose();
    _message.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppTheme.backgroundSecondary,
      appBar: AppBar(title: const Text(_RecoveryStrings.title)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ValueListenableBuilder<int>(
            valueListenable: _step,
            builder: (context, step, _) {
              return ValueListenableBuilder<bool>(
                valueListenable: _isLoading,
                builder: (context, isLoading, __) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppTheme.backgroundPrimary,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: const <BoxShadow>[AppTheme.cardShadow],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              _RecoveryStrings.stepTitle(step),
                              style: textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _RecoveryStrings.stepSubtitle(step),
                              style: textTheme.bodyMedium?.copyWith(
                                    color: AppTheme.textSecondary,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildStepContent(step),
                      ValueListenableBuilder<String?>(
                        valueListenable: _message,
                        builder: (context, message, ___) {
                          if (message == null || message.isEmpty) {
                            return const SizedBox.shrink();
                          }

                          return Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryLight,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Text(
                                message,
                                style: textTheme.bodySmall?.copyWith(
                                      color: AppTheme.primary,
                                    ),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                      CajaceButton(
                        label: _RecoveryStrings.stepButton(step),
                        isLoading: isLoading,
                        onPressed: isLoading ? null : () => _submit(step),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildStepContent(int step) {
    switch (step) {
      case 0:
        return CajaceInput(
          controller: _emailController,
          label: _RecoveryStrings.emailLabel,
          hintText: _RecoveryStrings.emailHint,
          keyboardType: TextInputType.emailAddress,
          prefixIcon: const Icon(Icons.mail_outline, color: AppTheme.textHint),
        );
      case 1:
        return Column(
          children: <Widget>[
            CajaceInput(
              controller: _codeController,
              label: _RecoveryStrings.codeLabel,
              hintText: _RecoveryStrings.codeHint,
              keyboardType: TextInputType.number,
              prefixIcon: const Icon(
                Icons.verified_outlined,
                color: AppTheme.textHint,
              ),
            ),
            const SizedBox(height: 16),
            CajaceInput(
              controller: _passwordController,
              label: _RecoveryStrings.passwordLabel,
              hintText: _RecoveryStrings.passwordHint,
              obscureText: true,
              prefixIcon: const Icon(Icons.lock_outline, color: AppTheme.textHint),
            ),
          ],
        );
      default:
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.backgroundPrimary,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const <BoxShadow>[AppTheme.cardShadow],
          ),
          child: Column(
            children: <Widget>[
              const Icon(
                Icons.check_circle_outline,
                color: AppTheme.success,
                size: 40,
              ),
              const SizedBox(height: 12),
              Text(
                _RecoveryStrings.successTitle,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 6),
              Text(
                _RecoveryStrings.successSubtitle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
              ),
            ],
          ),
        );
    }
  }

  Future<void> _submit(int step) async {
    _isLoading.value = true;
    _message.value = null;

    try {
      final repository = ref.read(authRepositoryProvider);

      if (step == 0) {
        await repository.forgotPassword(_emailController.text.trim());
        _message.value = _RecoveryStrings.emailSentMessage;
        _step.value = 1;
      } else if (step == 1) {
        await repository.verifyResetCode(
          email: _emailController.text.trim(),
          code: _codeController.text.trim(),
        );
        await repository.resetPassword(
          email: _emailController.text.trim(),
          code: _codeController.text.trim(),
          password: _passwordController.text,
        );
        _step.value = 2;
      } else {
        if (mounted) {
          Navigator.of(context).pop();
        }
      }
    } catch (error) {
      _message.value = error.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading.value = false;
    }
  }
}

class _RecoveryStrings {
  const _RecoveryStrings._();

  static const String title = 'Recuperar acceso';
  static const String emailLabel = 'Correo institucional';
  static const String emailHint = 'nombre@cajace.com';
  static const String codeLabel = 'Codigo';
  static const String codeHint = 'Ingresa el codigo recibido';
  static const String passwordLabel = 'Nueva contrasena';
  static const String passwordHint = 'Define una nueva contrasena';
  static const String emailSentMessage =
      'Si el correo existe, recibiras un codigo de verificacion.';
  static const String successTitle = 'Acceso restablecido';
  static const String successSubtitle =
      'Tu contrasena fue actualizada. Ahora puedes volver a iniciar sesion.';

  static String stepTitle(int step) {
    switch (step) {
      case 0:
        return 'Confirma tu correo';
      case 1:
        return 'Valida y renueva tu acceso';
      default:
        return successTitle;
    }
  }

  static String stepSubtitle(int step) {
    switch (step) {
      case 0:
        return 'Te enviaremos un codigo temporal para continuar con la recuperacion.';
      case 1:
        return 'Ingresa el codigo recibido y define tu nueva contrasena.';
      default:
        return successSubtitle;
    }
  }

  static String stepButton(int step) {
    switch (step) {
      case 0:
        return 'Enviar codigo';
      case 1:
        return 'Restablecer acceso';
      default:
        return 'Volver';
    }
  }
}
