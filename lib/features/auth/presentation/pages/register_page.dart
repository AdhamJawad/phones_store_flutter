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

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmationController = TextEditingController();
  final _nameFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _phoneFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _passwordConfirmationFocusNode = FocusNode();
  bool _obscurePassword = true;
  bool _obscurePasswordConfirmation = true;

  @override
  void initState() {
    super.initState();
    for (final focusNode in [
      _nameFocusNode,
      _emailFocusNode,
      _phoneFocusNode,
      _passwordFocusNode,
      _passwordConfirmationFocusNode,
    ]) {
      focusNode.addListener(() => _handleFieldFocus(focusNode));
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _passwordConfirmationController.dispose();
    _nameFocusNode.dispose();
    _emailFocusNode.dispose();
    _phoneFocusNode.dispose();
    _passwordFocusNode.dispose();
    _passwordConfirmationFocusNode.dispose();
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
      resizeToAvoidBottomInset: false,
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
                                        const AuthHeader(
                                          titleKey: 'auth.create_account',
                                          subtitleKey: 'auth.register_subtitle',
                                        ),
                                        const SizedBox(height: 28),
                                        if (authState.hasError) ...[
                                          AuthErrorCard(
                                            message: authState.errorMessage!,
                                          ),
                                          const SizedBox(height: 20),
                                        ],
                                        AuthTextField(
                                          controller: _nameController,
                                          focusNode: _nameFocusNode,
                                          label: 'auth.name_label'.tr(),
                                          hintText: 'auth.name_hint'.tr(),
                                          keyboardType: TextInputType.name,
                                          textInputAction: TextInputAction.next,
                                          autofillHints: const [
                                            AutofillHints.name,
                                          ],
                                          prefixIcon: const Icon(
                                            Icons.person_outline_rounded,
                                          ),
                                          validator: _validateName,
                                          onSubmitted: (_) {
                                            _emailFocusNode.requestFocus();
                                          },
                                        ),
                                        const SizedBox(height: 18),
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
                                            _phoneFocusNode.requestFocus();
                                          },
                                        ),
                                        const SizedBox(height: 18),
                                        AuthTextField(
                                          controller: _phoneController,
                                          focusNode: _phoneFocusNode,
                                          label: 'auth.phone_label'.tr(),
                                          hintText: 'auth.phone_hint'.tr(),
                                          keyboardType: TextInputType.phone,
                                          textInputAction: TextInputAction.next,
                                          autofillHints: const [
                                            AutofillHints.telephoneNumber,
                                          ],
                                          prefixIcon: const Icon(
                                            Icons.phone_outlined,
                                          ),
                                          onSubmitted: (_) {
                                            _passwordFocusNode.requestFocus();
                                          },
                                        ),
                                        const SizedBox(height: 18),
                                        AuthTextField(
                                          controller: _passwordController,
                                          focusNode: _passwordFocusNode,
                                          label: 'auth.password_label'.tr(),
                                          hintText:
                                              'auth.register_password_hint'
                                                  .tr(),
                                          keyboardType:
                                              TextInputType.visiblePassword,
                                          textInputAction: TextInputAction.next,
                                          autofillHints: const [
                                            AutofillHints.newPassword,
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
                                          onSubmitted: (_) {
                                            _passwordConfirmationFocusNode
                                                .requestFocus();
                                          },
                                        ),
                                        const SizedBox(height: 18),
                                        AuthTextField(
                                          controller:
                                              _passwordConfirmationController,
                                          focusNode:
                                              _passwordConfirmationFocusNode,
                                          label:
                                              'auth.password_confirmation_label'
                                                  .tr(),
                                          hintText:
                                              'auth.password_confirmation_hint'
                                                  .tr(),
                                          keyboardType:
                                              TextInputType.visiblePassword,
                                          textInputAction: TextInputAction.done,
                                          autofillHints: const [
                                            AutofillHints.newPassword,
                                          ],
                                          prefixIcon: const Icon(
                                            Icons.verified_user_outlined,
                                          ),
                                          obscureText:
                                              _obscurePasswordConfirmation,
                                          validator:
                                              _validatePasswordConfirmation,
                                          suffixIcon: IconButton(
                                            onPressed: () {
                                              setState(() {
                                                _obscurePasswordConfirmation =
                                                    !_obscurePasswordConfirmation;
                                              });
                                            },
                                            icon: Icon(
                                              _obscurePasswordConfirmation
                                                  ? Icons
                                                        .visibility_off_outlined
                                                  : Icons.visibility_outlined,
                                            ),
                                          ),
                                          onSubmitted: (_) => _submit(),
                                        ),
                                        const SizedBox(height: 28),
                                        AuthButton(
                                          label: 'auth.register'.tr(),
                                          isLoading: authState.isSubmitting,
                                          onPressed: _submit,
                                        ),
                                        const SizedBox(height: 12),
                                        Center(
                                          child: TextButton(
                                            onPressed: authState.isSubmitting
                                                ? null
                                                : () => context.go(
                                                    AppRoutes.login,
                                                  ),
                                            child: Text(
                                              'auth.have_account'.tr(),
                                            ),
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

  String? _validateName(String? value) {
    if ((value?.trim() ?? '').isEmpty) {
      return 'auth.name_required'.tr();
    }
    return null;
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
    final password = value ?? '';
    if (password.isEmpty) {
      return 'auth.password_required'.tr();
    }
    if (password.length < 8) {
      return 'auth.password_min_length'.tr();
    }
    return null;
  }

  String? _validatePasswordConfirmation(String? value) {
    if ((value ?? '').isEmpty) {
      return 'auth.password_confirmation_required'.tr();
    }
    if (value != _passwordController.text) {
      return 'auth.password_confirmation_mismatch'.tr();
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
        .register(
          name: _nameController.text,
          email: _emailController.text,
          phone: _phoneController.text,
          password: _passwordController.text,
          passwordConfirmation: _passwordConfirmationController.text,
        );
  }

  void _handleFieldFocus(FocusNode focusNode) {
    if (!focusNode.hasFocus) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !focusNode.hasFocus || focusNode.context == null) {
        return;
      }

      Scrollable.ensureVisible(
        focusNode.context!,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        alignment: 0.30,
      );
    });
  }
}
