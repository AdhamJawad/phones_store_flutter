import '../../../device_catalog/data/models/device_model.dart';
import '../../domain/entities/device_comparison.dart';
import 'device_compare_row_model.dart';

class DeviceComparisonModel extends DeviceComparison {
  const DeviceComparisonModel({required super.devices, required super.rows});

  factory DeviceComparisonModel.fromJson(Map<String, dynamic> json) {
    return DeviceComparisonModel(
      devices:
          (json['devices'] as List?)
              ?.whereType<Map>()
              .map(
                (item) => DeviceModel.fromJson(Map<String, dynamic>.from(item)),
              )
              .toList(growable: false) ??
          const <DeviceModel>[],
      rows:
          (json['rows'] as List?)
              ?.whereType<Map>()
              .map(
                (item) => DeviceCompareRowModel.fromJson(
                  Map<String, dynamic>.from(item),
                ),
              )
              .toList(growable: false) ??
          const <DeviceCompareRowModel>[],
    );
  }
}
