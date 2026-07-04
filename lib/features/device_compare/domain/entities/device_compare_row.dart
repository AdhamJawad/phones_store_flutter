class DeviceCompareRow {
  const DeviceCompareRow({
    required this.key,
    required this.label,
    required this.values,
    required this.different,
  });

  final String key;
  final String label;
  final List<String> values;
  final bool different;
}
