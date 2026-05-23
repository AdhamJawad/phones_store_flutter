import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/errors/result.dart';
import '../../../../core/widgets/app_skeleton.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_error_state.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../../../../presentation/routing/app_routes.dart';
import '../../../../presentation/theme/app_spacing.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../providers/profile_providers.dart';
import '../widgets/destructive_action_dialog.dart';
import '../widgets/profile_action_tile.dart';
import '../widgets/profile_details_card.dart';
import '../widgets/profile_info_card.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(profileControllerProvider);
    final controller = ref.read(profileControllerProvider.notifier);
    final authState = ref.watch(authControllerProvider);

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: controller.refresh,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.page,
                  AppSpacing.page,
                  AppSpacing.page,
                  8,
                ),
                child: Text(
                  'profile.title'.tr(),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.page,
                  0,
                  AppSpacing.page,
                  14,
                ),
                child: Text(
                  'profile.subtitle'.tr(),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ),
            ),
            if (state.isLoading && !state.hasData)
              const SliverPadding(
                padding: EdgeInsets.all(AppSpacing.page),
                sliver: SliverToBoxAdapter(
                  child: AppSkeleton(
                    child: AppSkeletonBox(
                      height: 180,
                      borderRadius: BorderRadius.all(Radius.circular(28)),
                    ),
                  ),
                ),
              )
            else if (state.hasError && !state.hasData)
              SliverFillRemaining(
                hasScrollBody: false,
                child: AppErrorState(
                  title: 'profile.error_title'.tr(),
                  message: _displayError(state.errorMessage),
                  actionLabel: 'common.retry'.tr(),
                  onRetry: controller.load,
                ),
              )
            else if (!state.hasData)
              SliverFillRemaining(
                hasScrollBody: false,
                child: AppEmptyState(
                  title: 'profile.empty_title'.tr(),
                  message: 'profile.empty_message'.tr(),
                  icon: Icons.person_outline_rounded,
                ),
              )
            else ...[
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.page,
                  0,
                  AppSpacing.page,
                  16,
                ),
                sliver: SliverToBoxAdapter(
                  child: ProfileInfoCard(profile: state.profile!),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.page,
                  0,
                  AppSpacing.page,
                  16,
                ),
                sliver: SliverToBoxAdapter(
                  child: ProfileDetailsCard(profile: state.profile!),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.page,
                  0,
                  AppSpacing.page,
                  24,
                ),
                sliver: SliverList.list(
                  children: [
                    ProfileActionTile(
                      icon: Icons.edit_outlined,
                      title: 'profile.edit_title'.tr(),
                      subtitle: 'profile.edit_subtitle'.tr(),
                      onTap: () => context.push(AppRoutes.profileEdit),
                    ),
                    const SizedBox(height: 12),
                    ProfileActionTile(
                      icon: Icons.notifications_none_rounded,
                      title: 'profile.notifications_title'.tr(),
                      subtitle: 'profile.notifications_subtitle'.tr(),
                      onTap: () => context.push(AppRoutes.notifications),
                    ),
                    const SizedBox(height: 12),
                    ProfileActionTile(
                      icon: Icons.storefront_outlined,
                      title: 'profile.seller_dashboard_title'.tr(),
                      subtitle: 'profile.seller_dashboard_subtitle'.tr(),
                      onTap: () => context.push(AppRoutes.sellerDashboard),
                    ),
                    const SizedBox(height: 12),
                    ProfileActionTile(
                      icon: Icons.logout_rounded,
                      title: 'profile.logout_title'.tr(),
                      subtitle: 'profile.logout_subtitle'.tr(),
                      onTap: () => _logout(context, ref),
                      trailing: authState.isSubmitting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : null,
                    ),
                    const SizedBox(height: 12),
                    ProfileActionTile(
                      icon: Icons.delete_outline_rounded,
                      title: 'profile.delete_title'.tr(),
                      subtitle: 'profile.delete_subtitle'.tr(),
                      onTap: () => _deleteAccount(context, ref),
                      destructive: true,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _displayError(String? value) {
    if (value == 'profile.load_error_fallback') {
      return 'profile.load_error_fallback'.tr();
    }
    return value ?? 'profile.load_error_fallback'.tr();
  }

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    final result = await ref.read(authControllerProvider.notifier).logout();
    if (!context.mounted) {
      return;
    }

    if (result case Error(:final failure)) {
      AppFeedback.error(context, failure.message);
    }
  }

  Future<void> _deleteAccount(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => DestructiveActionDialog(
        title: 'profile.delete_dialog_title'.tr(),
        message: 'profile.delete_dialog_message'.tr(),
        confirmLabel: 'profile.delete_confirm'.tr(),
      ),
    );

    if (confirmed != true || !context.mounted) {
      return;
    }

    final result = await ref.read(deleteAccountControllerProvider.notifier).submit();
    if (!context.mounted) {
      return;
    }

    switch (result) {
      case Success():
        AppFeedback.success(context, 'profile.delete_success'.tr());
        context.go(AppRoutes.home);
      case Error(:final failure):
        AppFeedback.error(
          context,
          failure.message.isEmpty
              ? 'profile.delete_error_fallback'.tr()
              : failure.message,
        );
    }
  }
}
