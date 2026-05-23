import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class ListingConditionSelector extends StatelessWidget {
  const ListingConditionSelector({
    required this.value,
    required this.onChanged,
    super.key,
  });

  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final options = <({String value, String label})>[
      (value: 'new', label: 'products.condition_new'.tr()),
      (value: 'used', label: 'products.condition_used'.tr()),
    ];

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: options
          .map(
            (option) => ChoiceChip(
              label: Text(option.label),
              selected: option.value == value,
              onSelected: (_) => onChanged(option.value),
            ),
          )
          .toList(growable: false),
    );
  }
}
