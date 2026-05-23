import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class AddressFormSection extends StatelessWidget {
  const AddressFormSection({
    required this.controller,
    required this.focusNode,
    super.key,
  });

  final TextEditingController controller;
  final FocusNode focusNode;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'orders.shipping_address_title'.tr(),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
              ),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          maxLines: 4,
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(
            hintText: 'orders.shipping_address_hint'.tr(),
          ),
          validator: (value) {
            final text = value?.trim() ?? '';
            if (text.isEmpty) {
              return 'orders.shipping_address_required'.tr();
            }
            return null;
          },
        ),
      ],
    );
  }
}
