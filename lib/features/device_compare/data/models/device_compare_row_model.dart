import '../../domain/entities/device_compare_row.dart';

class DeviceCompareRowModel extends DeviceCompareRow {
  const DeviceCompareRowModel({
    required super.key,
    required super.label,
    required super.values,
    required super.different,
  });

  factory DeviceCompareRowModel.fromJson(Map<String, dynamic> json) {
    return DeviceCompareRowModel(
      key: json['key'] as String? ?? '',
      label: json['label'] as String? ?? '',
      values:
          (json['values'] as List?)
              ?.map((value) => '$value')
              .toList(growable: false) ??
          const <String>[],
      different: json['different'] as bool? ?? false,
    );
  }
}
