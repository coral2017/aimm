import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/ble/ble_device_info.dart';
import '../../../../core/ble/ble_manager.dart';
import '../../../../core/ble/ble_service_interface.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../control/providers/mask_controller.dart';

class DeviceConnectionDialog extends StatefulWidget {
  const DeviceConnectionDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => const DeviceConnectionDialog(),
    );
  }

  @override
  State<DeviceConnectionDialog> createState() => _DeviceConnectionDialogState();
}

class _DeviceConnectionDialogState extends State<DeviceConnectionDialog> {
  final BleManager _bleManager = BleManager.instance;
  StreamSubscription? _scanSub;
  StreamSubscription? _stateSub;

  List<BleDeviceInfo> _devices = [];
  BleConnectionState _connectionState = BleConnectionState.disconnected;
  BleDeviceInfo? _connectingDevice;

  @override
  void initState() {
    super.initState();
    _connectionState = _bleManager.currentConnectionState;

    _scanSub = _bleManager.scanResultsStream.listen((results) {
      if (mounted) {
        setState(() {
          _devices = results;
        });
      }
    });

    _stateSub = _bleManager.connectionStateStream.listen((state) {
      if (mounted) {
        setState(() {
          _connectionState = state;
        });
        if (state == BleConnectionState.connected) {
          Navigator.of(context).pop();
        }
      }
    });

    // Automatically trigger scan upon opening
    _startScan();
  }

  void _startScan() {
    _devices.clear();
    _bleManager.startScan();
  }

  @override
  void dispose() {
    _scanSub?.cancel();
    _stateSub?.cancel();
    _bleManager.stopScan();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 32),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(minHeight: 260, maxHeight: 420),
        child: _buildContent(context),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    // State 1: Connecting to host
    if (_connectionState == BleConnectionState.connecting && _connectingDevice != null) {
      return _buildConnectingView(context, _connectingDevice!);
    }

    // State 2: Scanning & No devices yet
    if (_devices.isEmpty) {
      return _buildScanningView(context);
    }

    // State 3: Discovered Device List
    return _buildDeviceListView(context);
  }

  Widget _buildScanningView(BuildContext context) {
    final isScanning = _connectionState == BleConnectionState.scanning;

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 20),
        if (isScanning)
          const SizedBox(
            width: 36,
            height: 36,
            child: CircularProgressIndicator(
              strokeWidth: 3.0,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          )
        else
          const Icon(
            Icons.bluetooth_searching_rounded,
            size: 40,
            color: AppColors.primary,
          ),
        const SizedBox(height: 20),
        Text(
          isScanning ? context.tr('searching') : context.tr('disconnected'),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          context.tr('noDevicesFound'),
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 20),
        if (!isScanning)
          ElevatedButton.icon(
            onPressed: _startScan,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: Text(context.tr('rescan')),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
          ),
      ],
    );
  }

  Widget _buildConnectingView(BuildContext context, BleDeviceInfo device) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 12),
        const SizedBox(
          width: 36,
          height: 36,
          child: CircularProgressIndicator(
            strokeWidth: 3.0,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          context.tr('connectingDevice'),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          device.id,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () {
            _bleManager.disconnect();
            setState(() {
              _connectingDevice = null;
            });
            _startScan();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
          ),
          child: Text(context.tr('cancelConnection')),
        ),
      ],
    );
  }

  Widget _buildDeviceListView(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              context.tr('deviceManagement'),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            if (_connectionState == BleConnectionState.scanning)
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
              )
            else
              IconButton(
                icon: const Icon(Icons.refresh_rounded, size: 20, color: AppColors.primary),
                onPressed: _startScan,
              ),
          ],
        ),
        const SizedBox(height: 12),
        Flexible(
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: _devices.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (ctx, index) {
              final device = _devices[index];
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.capsuleBackground,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE8E4DC)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.bluetooth_rounded, color: AppColors.primary, size: 22),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            device.name,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            device.id,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                              fontFamily: 'monospace',
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _connectingDevice = device;
                        });
                        context.read<MaskController>().connect(device);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        minimumSize: const Size(60, 34),
                      ),
                      child: Text(
                        context.tr('connect'),
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
