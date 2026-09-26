import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../control/providers/mask_controller.dart';

class ConnectedDeviceDialog extends StatelessWidget {
  const ConnectedDeviceDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => const ConnectedDeviceDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<MaskController>();
    final device = controller.activeDevice ?? controller.boundDevice;
    final isConnected = controller.isConnected;
    final isAutoReconnecting = controller.isAutoReconnecting;

    if (device == null) {
      return const SizedBox.shrink();
    }

    // Status styling & label
    Color statusColor;
    Color statusBg;
    String statusText;
    IconData statusIcon;

    if (isConnected) {
      statusColor = const Color(0xFF2E7D32);
      statusBg = const Color(0xFFEBF7EE);
      statusText = context.tr('connected');
      statusIcon = Icons.bluetooth_connected_rounded;
    } else if (isAutoReconnecting) {
      statusColor = const Color(0xFFE65100);
      statusBg = const Color(0xFFFFF3E0);
      statusText = context.tr('reconnecting');
      statusIcon = Icons.bluetooth_searching_rounded;
    } else {
      statusColor = AppColors.textSecondary;
      statusBg = const Color(0xFFEEEEEE);
      statusText = context.tr('offline');
      statusIcon = Icons.bluetooth_disabled_rounded;
    }

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Title & Close
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        statusIcon,
                        color: statusColor,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          device.name,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: statusBg,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            statusText,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: statusColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Device Info Table
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.capsuleBackground,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _buildInfoRow(
                    label: 'UUID / MAC',
                    value: device.id,
                    isMono: true,
                  ),
                  const Divider(height: 16, color: Color(0xFFE5E0D6)),
                  _buildInfoRow(
                    label: context.tr('battery'),
                    value: controller.batteryLabel,
                    icon: Icons.battery_charging_full_rounded,
                  ),
                  const Divider(height: 16, color: Color(0xFFE5E0D6)),
                  _buildInfoRow(
                    label: context.tr('intensityLevel'),
                    value: isConnected ? '${controller.currentGear} 档' : '--',
                  ),
                  const Divider(height: 16, color: Color(0xFFE5E0D6)),
                  _buildInfoRow(
                    label: context.tr('timeRemaining'),
                    value: controller.formattedTime,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Action: Retry Connect (shown when disconnected)
            if (!isConnected) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    controller.triggerAutoReconnect();
                  },
                  icon: isAutoReconnecting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.refresh_rounded, size: 18),
                  label: Text(context.tr('retryConnect')),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],

            // Action: Unbind Device Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      backgroundColor: Colors.white,
                      title: Text(
                        context.tr('unbindConfirmTitle'),
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
                      ),
                      content: Text(
                        context.tr('unbindConfirmDesc'),
                        style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.4),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(false),
                          child: Text(
                            context.tr('cancel'),
                            style: const TextStyle(color: AppColors.textSecondary),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.of(ctx).pop(true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFD32F2F),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            elevation: 0,
                          ),
                          child: Text(context.tr('confirm')),
                        ),
                      ],
                    ),
                  );

                  if (confirmed == true) {
                    await controller.unbindCurrentDevice();
                    if (context.mounted) {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(context.tr('deviceUnbound')),
                          backgroundColor: AppColors.textPrimary,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  }
                },
                icon: const Icon(Icons.link_off_rounded, size: 18),
                label: Text(context.tr('unbindDevice')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFAF2F2),
                  foregroundColor: const Color(0xFFD32F2F),
                  elevation: 0,
                  side: const BorderSide(color: Color(0xFFFFCDD2)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required String label,
    required String value,
    IconData? icon,
    bool isMono = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: AppColors.textPrimary),
              const SizedBox(width: 4),
            ],
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 160),
              child: Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  fontFamily: isMono ? 'monospace' : null,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
