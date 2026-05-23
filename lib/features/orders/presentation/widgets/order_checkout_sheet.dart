import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/errors/result.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../../../../presentation/routing/app_routes.dart';
import '../../../wallet/presentation/providers/wallet_providers.dart';
import '../../../products/domain/entities/product.dart';
import '../../../products/domain/entities/product_variant.dart';
import '../../domain/entities/create_order_input.dart';
import '../../domain/entities/order.dart';
import '../../domain/entities/order_payment_method.dart';
import '../providers/orders_providers.dart';
import 'address_form_section.dart';
import 'order_summary_card.dart';
import 'payment_method_selector.dart';
import 'wallet_payment_notice.dart';

class OrderCheckoutSheet extends ConsumerStatefulWidget {
  const OrderCheckoutSheet({
    required this.product,
    required this.initialPaymentMethods,
    super.key,
    this.selectedVariant,
  });

  final Product product;
  final ProductVariant? selectedVariant;
  final List<OrderPaymentMethod> initialPaymentMethods;

  @override
  ConsumerState<OrderCheckoutSheet> createState() => _OrderCheckoutSheetState();
}

class _OrderCheckoutSheetState extends ConsumerState<OrderCheckoutSheet> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _addressFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    final initialMethod = widget.initialPaymentMethods.first;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(createOrderControllerProvider.notifier).setPaymentMethod(
            initialMethod,
          );
    });
  }

  @override
  void dispose() {
    _addressController.dispose();
    _addressFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(createOrderControllerProvider);
    final controller = ref.read(createOrderControllerProvider.notifier);
    final walletSummary = ref.watch(walletSummaryProvider);
    final totalPrice =
        widget.product.price + (widget.selectedVariant?.priceModifier ?? 0);
    final isWalletSelected = state.paymentMethod == OrderPaymentMethod.wallet;
    final walletBalance = walletSummary.valueOrNull?.balance;
    final hasInsufficientWalletBalance =
        isWalletSelected && walletBalance != null && walletBalance < totalPrice;
    final canSubmit = !state.isSubmitting && !hasInsufficientWalletBalance;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.viewInsetsOf(context).bottom + 20,
        ),
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 46,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.outlineVariant,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  widget.product.isInventory
                      ? 'orders.checkout_inventory_title'.tr()
                      : 'orders.checkout_marketplace_title'.tr(),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.product.isInventory
                      ? 'orders.checkout_inventory_subtitle'.tr()
                      : 'orders.checkout_marketplace_subtitle'.tr(),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 18),
                OrderSummaryCard(
                  product: widget.product,
                  variant: widget.selectedVariant,
                  totalPrice: totalPrice,
                ),
                const SizedBox(height: 18),
                AddressFormSection(
                  controller: _addressController,
                  focusNode: _addressFocusNode,
                ),
                const SizedBox(height: 18),
                Text(
                  'orders.payment_method_title'.tr(),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: 10),
                PaymentMethodSelector(
                  methods: widget.initialPaymentMethods,
                  selectedMethod: state.paymentMethod,
                  onChanged: controller.setPaymentMethod,
                ),
                if (widget.initialPaymentMethods.contains(OrderPaymentMethod.wallet)) ...[
                  const SizedBox(height: 12),
                  WalletPaymentNotice(
                    walletSummary: walletSummary,
                    totalPrice: totalPrice,
                    active: isWalletSelected,
                  ),
                ],
                if (hasInsufficientWalletBalance) ...[
                  const SizedBox(height: 12),
                  Text(
                    'orders.wallet_insufficient_title'.tr(),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.error,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ],
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
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: canSubmit ? _submit : null,
                    child: state.isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2.2),
                          )
                        : Text('orders.submit_order'.tr()),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    _addressFocusNode.unfocus();
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final walletSummary = ref.read(walletSummaryProvider).valueOrNull;
    final totalPrice =
        widget.product.price + (widget.selectedVariant?.priceModifier ?? 0);
    final selectedMethod = ref.read(createOrderControllerProvider).paymentMethod;
    if (selectedMethod == OrderPaymentMethod.wallet &&
        walletSummary != null &&
        walletSummary.balance < totalPrice) {
      if (mounted) {
        AppFeedback.error(context, 'orders.wallet_insufficient_title'.tr());
      }
      return;
    }

    final result = await ref.read(createOrderControllerProvider.notifier).submit(
          CreateOrderInput(
            productId: widget.product.id,
            variantId: widget.selectedVariant?.id,
            shippingAddress: _addressController.text.trim(),
            paymentMethod: selectedMethod,
          ),
        );

    if (!mounted) {
      return;
    }

    switch (result) {
      case Success<Order>(:final data):
        Navigator.of(context).pop();
        context.go(AppRoutes.orderDetails(data.id));
      case Error<Order>():
        break;
    }
  }
}
