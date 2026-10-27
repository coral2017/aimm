import 'dart:async';
import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_colors.dart';
import '../../features/connection/presentation/device_connection_dialog.dart';

/// Level 1: Standardized Toast / HUD for fleeting system feedback
class AppToast {
  AppToast._();

  static OverlayEntry? _activeGoldenOverlay;
  static Timer? _activeGoldenTimer;

  /// Plan A: Bottom champagne gold floating capsule toast (pure text, no icon, high contrast)
  /// Uses OverlayEntry with shrink-wrap layout so there is ZERO outer border, ZERO theme shape interference,
  /// and only the standalone golden capsule is visible.
  static void showGoldenToast(
    BuildContext context,
    String message, {
    Duration duration = const Duration(milliseconds: 2000),
  }) {
    _dismissGoldenToast();
    ScaffoldMessenger.maybeOf(context)?.hideCurrentSnackBar();

    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) return;

    final entry = OverlayEntry(
      builder: (ctx) => _GoldenToastWidget(message: message),
    );

    _activeGoldenOverlay = entry;
    overlay.insert(entry);

    _activeGoldenTimer = Timer(duration, () {
      _dismissGoldenToast();
    });
  }

  static void _dismissGoldenToast() {
    _activeGoldenTimer?.cancel();
    _activeGoldenTimer = null;
    _activeGoldenOverlay?.remove();
    _activeGoldenOverlay = null;
  }

  /// Alias for backward compatibility, routed directly to showGoldenToast
  static void showCenterToast(
    BuildContext context,
    String message, {
    IconData? icon,
    Color? iconColor,
    Duration duration = const Duration(milliseconds: 2000),
  }) {
    showGoldenToast(context, message, duration: duration);
  }

  static void showSuccess(BuildContext context, String message) {
    _showToast(
      context,
      message: message,
      icon: Icons.check_circle_rounded,
      iconColor: AppColors.success,
      iconBgColor: const Color(0x2A34C759),
    );
  }

  static void showWarning(BuildContext context, String message) {
    _showToast(
      context,
      message: message,
      icon: Icons.warning_amber_rounded,
      iconColor: AppColors.warning,
      iconBgColor: const Color(0x2AFF9500),
    );
  }

  static void showError(BuildContext context, String message) {
    _showToast(
      context,
      message: message,
      icon: Icons.error_outline_rounded,
      iconColor: AppColors.error,
      iconBgColor: const Color(0x2AE53935),
    );
  }

  static void showInfo(BuildContext context, String message) {
    _showToast(
      context,
      message: message,
      icon: Icons.info_outline_rounded,
      iconColor: AppColors.primary,
      iconBgColor: const Color(0x2AE5A95C),
    );
  }

  static void _showToast(
    BuildContext context, {
    required String message,
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    Duration duration = const Duration(seconds: 2),
  }) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        elevation: 8,
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.cardBackground,
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: AppColors.cardBorder, width: 1.0),
        ),
        duration: duration,
        content: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: iconBgColor,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(icon, size: 18, color: iconColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GoldenToastWidget extends StatefulWidget {
  final String message;

  const _GoldenToastWidget({required this.message});

  @override
  State<_GoldenToastWidget> createState() => _GoldenToastWidgetState();
}

class _GoldenToastWidgetState extends State<_GoldenToastWidget> with SingleTickerProviderStateMixin {
  late final AnimationController _anim;
  late final Animation<double> _scale;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scale = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _anim, curve: Curves.easeOutCubic),
    );
    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _anim, curve: Curves.easeOut),
    );
    _anim.forward();
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: SafeArea(
        child: Align(
          alignment: const Alignment(0.0, 0.74),
          child: FadeTransition(
            opacity: _opacity,
            child: ScaleTransition(
              scale: _scale,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 320),
                  margin: const EdgeInsets.symmetric(horizontal: 32),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: const Color(0xFFFDE1B5).withValues(alpha: 0.7),
                      width: 1.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.45),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    widget.message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF0F131A),
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                      height: 1.3,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Level 3: Device Not Connected Guidance Dialog (Optional Modal)
class DeviceNotConnectedDialog extends StatelessWidget {
  const DeviceNotConnectedDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.65),
      builder: (ctx) => const DeviceNotConnectedDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 380),
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.cardBorder, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.45),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Glowing Bluetooth Beacon Avatar
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF3B82F6).withValues(alpha: 0.25),
                    const Color(0xFF1E3A5F).withValues(alpha: 0.08),
                  ],
                ),
                border: Border.all(
                  color: const Color(0xFF3B82F6).withValues(alpha: 0.4),
                  width: 1.5,
                ),
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.bluetooth_searching_rounded,
                size: 34,
                color: Color(0xFF60A5FA),
              ),
            ),
            const SizedBox(height: 20),

            // Dialog Title
            Text(
              context.tr('deviceNotConnectedTitle'),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 12),

            // Description / Guidance
            Text(
              context.tr('deviceNotConnectedDesc'),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 26),

            // Actions: Connect Now (Primary) & Later (Secondary)
            SizedBox(
              width: double.infinity,
              height: 48,
              child: Container(
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.25),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    DeviceConnectionDialog.show(context);
                  },
                  icon: const Icon(Icons.bluetooth_connected_rounded, size: 20, color: Color(0xFF0F131A)),
                  label: Text(
                    context.tr('connectNow'),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F131A),
                      letterSpacing: 0.3,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),

            SizedBox(
              width: double.infinity,
              height: 42,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.textSecondary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  context.tr('later'),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
