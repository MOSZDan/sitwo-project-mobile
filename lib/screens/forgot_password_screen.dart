// lib/screens/forgot_password_screen.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import 'login_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _emailFocus = FocusNode();

  bool _loading = false;
  String? _serverMsg;
  String? _serverErr;

  // Cooldown anti-spam (opcional, mantenido)
  static const int _cooldownSeconds = 45;
  int _cooldownLeft = 0;
  Timer? _cooldownTimer;

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    _emailCtrl.dispose();
    _emailFocus.dispose();
    super.dispose();
  }

  String _apiUrl() =>
      '${AppConfig.baseUrl}${AppConfig.apiPrefix}/auth/password-reset/';

  String? _validateEmail(String? value) {
    final s = (value ?? '').trim();
    if (s.isEmpty) return 'Ingresa tu correo';
    final re = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!re.hasMatch(s)) return 'Correo inválido';
    return null;
  }

  void _startCooldown() {
    setState(() => _cooldownLeft = _cooldownSeconds);
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_cooldownLeft <= 1) {
        t.cancel();
        setState(() => _cooldownLeft = 0);
      } else {
        setState(() => _cooldownLeft -= 1);
      }
    });
  }

  Future<void> _submit() async {
    if (_loading || _cooldownLeft > 0) return;
    _serverErr = null;
    _serverMsg = null;

    if (!_formKey.currentState!.validate()) {
      _emailFocus.requestFocus();
      return;
    }

    FocusScope.of(context).unfocus();
    HapticFeedback.selectionClick();
    setState(() => _loading = true);

    try {
      final res = await http
          .post(
            Uri.parse(_apiUrl()),
            headers: AppConfig.defaultHeaders,
            body: jsonEncode({'email': _emailCtrl.text.trim()}),
          )
          .timeout(AppConfig.requestTimeout);

      final data = res.body.isNotEmpty ? jsonDecode(res.body) : {};
      if (res.statusCode == 200) {
        _serverMsg =
            (data['message'] as String?) ??
            'Si el correo existe, enviamos un enlace para restablecer tu contraseña.';
        if (mounted) _showSuccessNotice(_serverMsg!);
        _startCooldown();
      } else if (res.statusCode == 400) {
        _serverErr = (data['detail'] as String?) ?? 'Solicitud inválida.';
        _showSnack(_serverErr!, isError: true);
      } else {
        _serverErr = 'Error inesperado (${res.statusCode}).';
        _showSnack(_serverErr!, isError: true);
      }
    } on TimeoutException {
      _serverErr = 'Tiempo de espera agotado. Inténtalo nuevamente.';
      _showSnack(_serverErr!, isError: true);
    } catch (e) {
      _serverErr = 'Error de red: $e';
      _showSnack(_serverErr!, isError: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.red : null,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _showSuccessNotice(String message) async {
    if (!mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final theme = Theme.of(ctx);
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.mark_email_read_rounded,
                  size: 56,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: 12),
                Text(
                  'Correo enviado',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  style: theme.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text('Listo'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final canSubmit = !_loading && _cooldownLeft == 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recuperar contraseña'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Centrado vertical: el contenido ocupa al menos la altura visible
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 48, // compensa padding
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Header / icono
                      Icon(
                        Icons.lock_reset_rounded,
                        size: 72,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '¿Olvidaste tu contraseña?',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Ingresa tu correo y te enviaremos un enlace para restablecerla.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.textTheme.bodyMedium?.color?.withOpacity(
                            0.9,
                          ),
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 28),

                      // Form centrado
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 420),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              TextFormField(
                                controller: _emailCtrl,
                                focusNode: _emailFocus,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.done,
                                autofillHints: const [AutofillHints.email],
                                validator: _validateEmail,
                                decoration: const InputDecoration(
                                  labelText: 'Correo electrónico',
                                  hintText: 'tucorreo@dominio.com',
                                  border: OutlineInputBorder(),
                                ),
                                onFieldSubmitted: (_) => _submit(),
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                height: 48,
                                child: FilledButton(
                                  onPressed: canSubmit ? _submit : null,
                                  child: AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 200),
                                    transitionBuilder:
                                        (c, a) => FadeTransition(
                                          opacity: a,
                                          child: c,
                                        ),
                                    child:
                                        _loading
                                            ? const SizedBox(
                                              key: ValueKey('loading'),
                                              width: 22,
                                              height: 22,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                              ),
                                            )
                                            : Text(
                                              _cooldownLeft > 0
                                                  ? 'Reintentar en $_cooldownLeft s'
                                                  : 'Enviar enlace',
                                              key: const ValueKey('label'),
                                            ),
                                  ),
                                ),
                              ),
                              if (_serverMsg != null) ...[
                                const SizedBox(height: 12),
                                Text(
                                  _serverMsg!,
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.bodySmall,
                                ),
                              ],
                              if (_serverErr != null) ...[
                                const SizedBox(height: 12),
                                Text(
                                  _serverErr!,
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.error,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 28),

                      // Enlace a Login
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '¿Recordaste tu contraseña?',
                            style: theme.textTheme.bodyMedium,
                          ),
                          TextButton(
                            onPressed: () {
                              // si hay ruta previa, volvemos; si no, reemplazamos por Login
                              if (Navigator.of(context).canPop()) {
                                Navigator.of(context).pop();
                              } else {
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                    builder: (_) => const LoginScreen(),
                                  ),
                                );
                              }
                            },
                            child: const Text('Iniciar sesión'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
