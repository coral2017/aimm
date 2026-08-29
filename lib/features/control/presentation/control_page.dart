import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../connection/presentation/device_connection_dialog.dart';
import '../../report/presentation/analysis_report_page.dart';
import '../providers/mask_controller.dart';
import 'widgets/circular_mode_dial.dart';
import 'widgets/combination_mode_dialog.dart';
import 'widgets/high_intensity_dialog.dart';
import 'widgets/intensity_slider.dart';
import 'widgets/save_mode_dialog.dart';
import 'widgets/status_metric_card.dart';

class ControlPage extends StatelessWidget {
  const ControlPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),

              // Top Bar: App Title & Analysis Report Navigation Link (Figma 0:810)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // App Title
                    Text(
                      context.tr('appTitle'),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),

                    // Analysis Report Navigation Button
                    InkWell(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const AnalysisReportPage(),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              context.tr('analysisReport'),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(width: 3),
                            const Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 11,
                              color: AppColors.textSecondary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 6),

              // Card 1: Combined Top Status & 4-Metric Bar Card (Figma 0:810 / 18:591)
              StatusMetricCard(
                onAddDeviceTap: () => DeviceConnectionDialog.show(context),
              ),

              const SizedBox(height: 2),

              // Card 2: Center Circular Mode Dial (Beauty Hub) (Figma 0:810 / 18:591)
              CircularModeDial(
                onSaveTap: () => SaveModeDialog.show(context),
                onCombinationTap: () => CombinationModeDialog.show(context),
              ),

              const SizedBox(height: 2),

              // Card 3: Intensity Level Slider Card (Figma 0:811)
              IntensitySlider(
                onBlockedTap: () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(context.tr('mustStartBeforeAdjust')),
                      backgroundColor: AppColors.primary,
                      duration: const Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  );
                },
                onHighIntensityRequested: (targetGear) async {
                  final confirmed = await HighIntensityDialog.show(context);
                  if (confirmed == true && context.mounted) {
                    context.read<MaskController>().acknowledgeHighIntensity();
                    context.read<MaskController>().setGear(targetGear);
                  }
                },
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
