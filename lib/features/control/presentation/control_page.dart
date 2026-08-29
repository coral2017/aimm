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
import 'widgets/skin_metric_bars.dart';
import 'widgets/status_capsule_bar.dart';

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

              // Top Bar: App Title & Analysis Report Link
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // App Title
                    Text(
                      context.tr('appTitle'),
                      style: const TextStyle(
                        fontSize: 22,
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
                      borderRadius: BorderRadius.circular(20),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 12,
                              color: AppColors.textSecondary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Status Capsule Pill (Battery, Connection State, Remaining Time, Language)
              StatusCapsuleBar(
                onConnectionTap: () => DeviceConnectionDialog.show(context),
              ),

              const SizedBox(height: 4),

              // 4 Skin Metric Bars (Smoothness, Hydration, Youthfulness, Skin Tone)
              const SkinMetricBars(),

              const SizedBox(height: 4),

              // Center Circular Mode Dial (Beauty Hub)
              CircularModeDial(
                onSaveTap: () => SaveModeDialog.show(context),
                onCombinationTap: () => CombinationModeDialog.show(context),
              ),

              const SizedBox(height: 6),

              // Intensity Level Slider Card
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
