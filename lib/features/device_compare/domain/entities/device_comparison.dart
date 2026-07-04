import '../../../device_catalog/domain/entities/device.dart';
import 'device_compare_row.dart';

class DeviceComparison {
  const DeviceComparison({required this.devices, required this.rows});

  final List<Device> devices;
  final List<DeviceCompareRow> rows;
}
