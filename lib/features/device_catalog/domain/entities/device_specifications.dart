class DeviceSpecifications {
  const DeviceSpecifications({
    this.battery,
    this.camera,
    this.storage,
    this.ram,
    this.processor,
    this.performance,
    this.display,
    this.operatingSystem,
  });

  final String? battery;
  final String? camera;
  final String? storage;
  final String? ram;
  final String? processor;
  final String? performance;
  final String? display;
  final String? operatingSystem;

  bool get hasAnyValue =>
      (battery ?? '').trim().isNotEmpty ||
      (camera ?? '').trim().isNotEmpty ||
      (storage ?? '').trim().isNotEmpty ||
      (ram ?? '').trim().isNotEmpty ||
      (processor ?? '').trim().isNotEmpty ||
      (performance ?? '').trim().isNotEmpty ||
      (display ?? '').trim().isNotEmpty ||
      (operatingSystem ?? '').trim().isNotEmpty;
}
