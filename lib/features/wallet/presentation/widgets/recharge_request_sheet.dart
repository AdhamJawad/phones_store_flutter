import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/result.dart';
import '../../domain/entities/recharge_request.dart';
import '../providers/wallet_providers.dart';
import 'recharge_method_selector.dart';

class RechargeRequestSheet extends ConsumerStatefulWidget {
  const RechargeRequestSheet({super.key});

  @override
  ConsumerState<RechargeRequestSheet> createState() =>
      _RechargeRequestSheetState();
}

class _RechargeRequestSheetState extends ConsumerState<RechargeRequestSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _amountFocusNode = FocusNode();

  @override
  void dispose() {
    _amountController.dispose();
    _amountFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(createRechargeRequestControllerProvider);
    final controller = ref.read(createRechargeRequestControllerProvider.notifier);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.viewInsetsOf(context).bottom + 20,
        ),
        child: SingleChildScrollView(
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
                  'wallet.recharge_sheet_title'.tr(),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'wallet.recharge_sheet_subtitle'.tr(),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 18),
                TextFormField(
                  controller: _amountController,
                  focusNode: _amountFocusNode,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: 'wallet.amount_label'.tr(),
                    hintText: 'wallet.amount_hint'.tr(),
                  ),
                  validator: (value) {
                    final amount = double.tryParse((value ?? '').trim());
                    if (amount == null || amount < 1) {
                      return 'wallet.amount_required'.tr();
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 18),
                Text(
                  'wallet.recharge_method_title'.tr(),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: 10),
                RechargeMethodSelector(
                  selectedMethod: state.method,
                  onChanged: controller.setMethod,
                ),
                const SizedBox(height: 10),
                Text(
                  'wallet.proof_upload_title'.tr(),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'wallet.proof_upload_hint'.tr(),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    OutlinedButton.icon(
                      onPressed: controller.pickProofImage,
                      icon: const Icon(Icons.upload_file_outlined),
                      label: Text('wallet.pick_proof'.tr()),
                    ),
                    if (state.proofFilePath != null)
                      OutlinedButton.icon(
                        onPressed: controller.clearProofImage,
                        icon: const Icon(Icons.delete_outline),
                        label: Text('wallet.remove_proof'.tr()),
                      ),
                  ],
                ),
                if (state.proofFilePath != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    state.proofFilePath!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
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
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: state.isSubmitting ? null : _submit,
                    child: state.isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2.2),
                          )
                        : Text('wallet.submit_recharge'.tr()),
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
    _amountFocusNode.unfocus();
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final amount = double.parse(_amountController.text.trim());
    final result = await ref
        .read(createRechargeRequestControllerProvider.notifier)
        .submit(amount: amount);

    if (!mounted) {
      return;
    }

    switch (result) {
      case Success<RechargeRequest>(:final data):
        ref
            .read(rechargeRequestsControllerProvider.notifier)
            .prependCreatedRequest(data);
        Navigator.of(context).pop();
      case Error<RechargeRequest>():
        break;
    }
  }
}
