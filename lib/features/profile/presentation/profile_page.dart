import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../connection/presentation/device_connection_dialog.dart';
import '../../control/providers/mask_controller.dart';
import 'subpages/history_report_page.dart';
import 'subpages/saved_modes_page.dart';
import 'subpages/user_manual_page.dart';
import 'widgets/report_trend_icon.dart';
import 'widgets/smart_device_icon.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                // User Info Card Header (Figma 0:300)
                _buildUserProfileHeader(context),

                const SizedBox(height: 24),

                // Menu Items List
                _buildMenuItem(
                  context: context,
                  customIcon: const ReportTrendIcon(
                    color: AppColors.primary,
                    size: 20,
                  ),
                  title: context.tr('historyReport'),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const HistoryReportPage()),
                    );
                  },
                ),

                _buildMenuItem(
                  context: context,
                  icon: Icons.favorite_border_rounded,
                  title: context.tr('savedModes'),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SavedModesPage()),
                    );
                  },
                ),

                _buildMenuItem(
                  context: context,
                  customIcon: const SmartDeviceIcon(
                    color: AppColors.primary,
                    size: 18,
                  ),
                  title: context.tr('deviceManagement'),
                  onTap: () => DeviceConnectionDialog.show(context),
                ),

                _buildMenuItem(
                  context: context,
                  icon: Icons.tune_rounded,
                  title: context.tr('accountSettings'),
                  onTap: () => _showSettingsBottomSheet(context),
                ),

                // _buildMenuItem(
                //   context: context,
                //   icon: Icons.receipt_long_rounded,
                //   title: context.tr('bleTxLog'),
                //   onTap: () => BleTxLogDialog.show(context),
                // ),

                _buildMenuItem(
                  context: context,
                  icon: Icons.help_outline_rounded,
                  title: context.tr('helpCenter'),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const UserManualPage()),
                    );
                  },
                ),

                _buildMenuItem(
                  context: context,
                  icon: Icons.info_outline_rounded,
                  title: context.tr('aboutUs'),
                  onTap: () => _showAboutUsDialog(context),
                ),

                // _buildMenuItem(
                //   context: context,
                //   icon: Icons.logout_rounded,
                //   title: context.tr('logout'),
                //   isDestructive: true,
                //   onTap: () {
                //     showDialog(
                //       context: context,
                //       builder: (ctx) => AlertDialog(
                //         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                //         title: Text(context.tr('logout')),
                //         content: const Text('Are you sure you want to log out?'),
                //         actions: [
                //           TextButton(
                //             onPressed: () => Navigator.of(ctx).pop(),
                //             child: Text(context.tr('cancel')),
                //           ),
                //           ElevatedButton(
                //             onPressed: () {
                //               controller.disconnect();
                //               Navigator.of(ctx).pop();
                //             },
                //             style: ElevatedButton.styleFrom(
                //               backgroundColor: AppColors.primary,
                //               foregroundColor: Colors.white,
                //             ),
                //             child: Text(context.tr('confirm')),
                //           ),
                //         ],
                //       ),
                //     );
                //   },
                // ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserProfileHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.cardBorder, width: 1.0),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Circular Avatar with Luxury Ring
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primaryLight, width: 2),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/images/avatar.jpg',
                width: 76,
                height: 76,
                cacheWidth: 300,
                cacheHeight: 300,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: const Color(0xFFE8DCCF),
                  child: const Center(
                    child: Icon(
                      Icons.face_retouching_natural_rounded,
                      size: 42,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(width: 16),

          // User Info Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr('skinConsultant'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
                // const SizedBox(height: 4),
                // Container(
                //   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                //   decoration: BoxDecoration(
                //     color: AppColors.primary.withValues(alpha: 0.12),
                //     borderRadius: BorderRadius.circular(6),
                //   ),
                //   child: Text(
                //     context.tr('premiumMember'),
                //     style: const TextStyle(
                //       fontSize: 11,
                //       fontWeight: FontWeight.w600,
                //       color: AppColors.primaryDark,
                //     ),
                //   ),
                // ),
                const SizedBox(height: 6),
                Text(
                  context.tr('deviceModel'),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    IconData? icon,
    Widget? customIcon,
    required String title,
    String? trailingText,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.cardBorder, width: 1.0),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                // Icon in soft circular container
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: isDestructive ? const Color(0xFFFFECEB) : AppColors.sliderButton,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: customIcon ?? Icon(
                    icon,
                    size: 19,
                    color: isDestructive ? AppColors.error : AppColors.primary,
                  ),
                ),

                const SizedBox(width: 14),

                // Title
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isDestructive ? AppColors.error : AppColors.textPrimary,
                    ),
                  ),
                ),

                // Trailing text if any (e.g. 'v1.0.0')
                if (trailingText != null) ...[
                  Text(
                    trailingText,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 8),
                ],

                // Arrow Right
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAboutUsDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: 280,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            decoration: BoxDecoration(
              color: const Color(0xFF181E28),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.35),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.55),
                  blurRadius: 28,
                  offset: const Offset(0, 10),
                ),
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  blurRadius: 20,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // App Logo with subtle gold border
                Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.4),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.2),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16.5),
                    child: Image.asset(
                      'assets/images/app.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // App Name: Smart Skin Sensor
                const Text(
                  'Smart Skin Sensor',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 8),

                // Version Chip: v1.0.0
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      width: 0.8,
                    ),
                  ),
                  child: const Text(
                    'v1.0.10',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Status: Latest Version
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFF52C41A),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      context.tr('latestVersion'),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSettingsBottomSheet(BuildContext context) {
    final controller = context.read<MaskController>();

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.tr('switchLanguage'),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.language, color: AppColors.primary),
              title: const Text('English (EN)'),
              trailing: controller.currentLocale.languageCode == 'en'
                  ? const Icon(Icons.check, color: AppColors.primary)
                  : null,
              onTap: () {
                controller.setLocale(const Locale('en'));
                Navigator.of(ctx).pop();
              },
            ),
            ListTile(
              leading: const Icon(Icons.language, color: AppColors.primary),
              title: const Text('简体中文 (中)'),
              trailing: controller.currentLocale.languageCode == 'zh' &&
                      controller.currentLocale.countryCode == 'CN'
                  ? const Icon(Icons.check, color: AppColors.primary)
                  : null,
              onTap: () {
                controller.setLocale(const Locale('zh', 'CN'));
                Navigator.of(ctx).pop();
              },
            ),
            ListTile(
              leading: const Icon(Icons.language, color: AppColors.primary),
              title: const Text('繁體中文 (繁)'),
              trailing: controller.currentLocale.languageCode == 'zh' &&
                      controller.currentLocale.countryCode == 'TW'
                  ? const Icon(Icons.check, color: AppColors.primary)
                  : null,
              onTap: () {
                controller.setLocale(const Locale('zh', 'TW'));
                Navigator.of(ctx).pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}
