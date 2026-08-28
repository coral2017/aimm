class BleDeviceInfo {
  final String id;
  final String name;
  final int rssi;
  final bool isConnected;

  const BleDeviceInfo({
    required this.id,
    required this.name,
    this.rssi = -60,
    this.isConnected = false,
  });

  BleDeviceInfo copyWith({
    String? id,
    String? name,
    int? rssi,
    bool? isConnected,
  }) {
    return BleDeviceInfo(
      id: id ?? this.id,
      name: name ?? this.name,
      rssi: rssi ?? this.rssi,
      isConnected: isConnected ?? this.isConnected,
    );
  }
}
