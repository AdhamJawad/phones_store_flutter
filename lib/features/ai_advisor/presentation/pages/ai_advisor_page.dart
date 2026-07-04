import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/app_back_button.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../presentation/routing/app_routes.dart';
import '../../../../presentation/theme/app_spacing.dart';
import '../../../products/presentation/widgets/product_card.dart';
import '../../../products/presentation/widgets/product_card_grid_delegate.dart';
import '../providers/ai_advisor_providers.dart';

class AiAdvisorPage extends ConsumerStatefulWidget {
  const AiAdvisorPage({super.key});

  @override
  ConsumerState<AiAdvisorPage> createState() => _AiAdvisorPageState();
}

class _AiAdvisorPageState extends ConsumerState<AiAdvisorPage> {
  late final TextEditingController _queryController;

  @override
  void initState() {
    super.initState();
    _queryController = TextEditingController();
  }

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(aiAdvisorControllerProvider);
    final controller = ref.read(aiAdvisorControllerProvider.notifier);

    if (_queryController.text != state.query) {
      _queryController.value = TextEditingValue(
        text: state.query,
        selection: TextSelection.collapsed(offset: state.query.length),
      );
    }

    final result = state.result;

    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: Text('ai_advisor.title'.tr()),
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.page,
                  AppSpacing.page,
                  AppSpacing.page,
                  16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _queryController,
                      minLines: 2,
                      maxLines: 4,
                      onChanged: controller.setQuery,
                      decoration: InputDecoration(
                        hintText: 'ai_advisor.subtitle'.tr(),
                        alignLabelWithHint: true,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: state.isSubmitting
                            ? null
                            : controller.submit,
                        icon: state.isSubmitting
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.2,
                                ),
                              )
                            : const Icon(Icons.auto_awesome_rounded),
                        label: Text('ai_advisor.submit'.tr()),
                      ),
                    ),
                    if (state.hasError) ...[
                      const SizedBox(height: 12),
                      Text(
                        state.errorMessage!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.error,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            if (result != null) ...[
              if (result.products.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: AppEmptyState(
                    title: 'ai_advisor.empty_title'.tr(),
                    message: 'ai_advisor.empty_message'.tr(),
                  ),
                )
              else ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.page,
                      4,
                      AppSpacing.page,
                      8,
                    ),
                    child: Text(
                      'ai_advisor.results_title'.tr(),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.page,
                    8,
                    AppSpacing.page,
                    24,
                  ),
                  sliver: SliverGrid(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final product = result.products[index];
                      final heroTag = 'ai-advisor-${product.id}-$index';
                      return ProductCard(
                        product: product,
                        heroTag: heroTag,
                        onTap: () => context.push(
                          AppRoutes.productDetails(
                            product.id,
                            heroTag: heroTag,
                          ),
                        ),
                      );
                    }, childCount: result.products.length),
                    gridDelegate: buildProductCardGridDelegate(context),
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
