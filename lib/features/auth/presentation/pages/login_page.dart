import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../presentation/routing/app_routes.dart';
import '../models/auth_state.dart';
import '../providers/auth_providers.dart';
import '../widgets/auth_button.dart';
import '../widgets/auth_error_card.dart';
import '../widgets/auth_header.dart';
import '../widgets/auth_loading_overlay.dart';
import '../widgets/auth_text_field.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _emailFocusNode.addListener(() => _handleFieldFocus(_emailFocusNode));
    _passwordFocusNode.addListener(() => _handleFieldFocus(_passwordFocusNode));
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    ref.listen<AuthState>(authControllerProvider, (previous, next) {
      if (previous?.errorMessage != next.errorMessage && next.hasError) {
        HapticFeedback.mediumImpact();
      }
    });

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
              Theme.of(context).scaffoldBackgroundColor,
              Theme.of(context).colorScheme.secondary.withValues(alpha: 0.06),
            ],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final keyboardInset = MediaQuery.of(context).viewInsets.bottom;
              final keyboardVisible = keyboardInset > 0;

              return AnimatedPadding(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                padding: EdgeInsets.fromLTRB(
                  20,
                  20,
                  20,
                  keyboardVisible ? 20 : 28,
                ),
                child: AuthLoadingOverlay(
                  isVisible: authState.isRestoring,
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics(),
                    ),
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight:
                            constraints.maxHeight - (keyboardVisible ? 40 : 48),
                      ),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 480),
                          child: Align(
                            alignment: keyboardVisible
                                ? Alignment.topCenter
                                : Alignment.center,
                            child: Card(
                              elevation: 0,
                              color: Theme.of(context).colorScheme.surface,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(32),
                                side: BorderSide(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .outlineVariant
                                      .withValues(alpha: 0.4),
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(28),
                                child: Form(
                                  key: _formKey,
                                  child: AutofillGroup(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const AuthHeader(),
                                        const SizedBox(height: 28),
                                        if (authState.hasError) ...[
                                          AuthErrorCard(
                                            message: authState.errorMessage!,
                                          ),
                                          const SizedBox(height: 20),
                                        ],
                                        AuthTextField(
                                          controller: _emailController,
                                          focusNode: _emailFocusNode,
                                          label: 'auth.email_label'.tr(),
                                          hintText: 'example@email.com',
                                          keyboardType:
                                              TextInputType.emailAddress,
                                          textInputAction: TextInputAction.next,
                                          autofillHints: const [
                                            AutofillHints.email,
                                          ],
                                          prefixIcon: const Icon(
                                            Icons.mail_outline_rounded,
                                          ),
                                          validator: _validateEmail,
                                          onSubmitted: (_) {
                                            _passwordFocusNode.requestFocus();
                                          },
                                        ),
                                        const SizedBox(height: 18),
                                        AuthTextField(
                                          controller: _passwordController,
                                          focusNode: _passwordFocusNode,
                                          label: 'auth.password_label'.tr(),
                                          hintText: 'auth.password_hint'.tr(),
                                          keyboardType:
                                              TextInputType.visiblePassword,
                                          textInputAction: TextInputAction.done,
                                          autofillHints: const [
                                            AutofillHints.password,
                                          ],
                                          prefixIcon: const Icon(
                                            Icons.lock_outline_rounded,
                                          ),
                                          obscureText: _obscurePassword,
                                          validator: _validatePassword,
                                          suffixIcon: IconButton(
                                            onPressed: () {
                                              setState(() {
                                                _obscurePassword =
                                                    !_obscurePassword;
                                              });
                                            },
                                            icon: Icon(
                                              _obscurePassword
                                                  ? Icons
                                                        .visibility_off_outlined
                                                  : Icons.visibility_outlined,
                                            ),
                                          ),
                                          onSubmitted: (_) => _submit(),
                                        ),
                                        const SizedBox(height: 28),
                                        AuthButton(
                                          label: 'auth.login'.tr(),
                                          isLoading: authState.isSubmitting,
                                          onPressed: _submit,
                                        ),
                                        const SizedBox(height: 12),
                                        Center(
                                          child: TextButton(
                                            onPressed: authState.isSubmitting
                                                ? null
                                                : () => context.go(
                                                    AppRoutes.register,
                                                  ),
                                            child: Text(
                                              'auth.create_account_cta'.tr(),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 18),
                                        Text(
                                          'auth.login_info'.tr(),
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                color: Theme.of(
                                                  context,
                                                ).colorScheme.onSurfaceVariant,
                                                height: 1.6,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  String? _validateEmail(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return 'auth.email_required'.tr();
    }

    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(trimmed)) {
      return 'auth.email_invalid'.tr();
    }

    return null;
  }

  String? _validatePassword(String? value) {
    if ((value ?? '').isEmpty) {
      return 'auth.password_required'.tr();
    }

    return null;
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    ref.read(authControllerProvider.notifier).clearError();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    await ref
        .read(authControllerProvider.notifier)
        .login(
          email: _emailController.text,
          password: _passwordController.text,
        );
  }

  void _handleFieldFocus(FocusNode focusNode) {
    if (!focusNode.hasFocus) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future<void>.delayed(const Duration(milliseconds: 280), () {
        if (!mounted || !focusNode.hasFocus || focusNode.context == null) {
          return;
        }

        Scrollable.ensureVisible(
          focusNode.context!,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          alignment: 0.18,
        );
      });
    });
  }
}
