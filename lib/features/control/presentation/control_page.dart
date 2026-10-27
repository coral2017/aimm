import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../../report/presentation/analysis_report_page.dart';
import '../providers/mask_controller.dart';
import '../../profile/presentation/subpages/saved_modes_page.dart';
import 'widgets/circular_mode_dial.dart';
import 'widgets/high_intensity_dialog.dart';
import 'widgets/intensity_slider.dart';
import 'widgets/status_metric_card.dart';

class ControlPage extends StatefulWidget {
  const ControlPage({super.key});

  @override
  State<ControlPage> createState() => _ControlPageState();
}

class _ControlPageState extends State<ControlPage> with WidgetsBindingObserver {
  StreamSubscription? _alertSub;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = context.read<MaskController>();
      _alertSub = controller.globalAlertStream.listen((alertKey) {
        if (!mounted) return;
        if (alertKey.contains('Complete')) {
          AppToast.showSuccess(context, context.tr(alertKey));
        } else {
          AppToast.showWarning(context, context.tr(alertKey));
        }
      });
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      context.read<MaskController>().onAppResumed();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _alertSub?.cancel();
    super.dispose();
  }

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
              const SizedBox(height: 6),

              // Top Bar: App Title & Analysis Report Navigation Link (Figma 0:810)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 2.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // App Title
                    Text(
                      context.tr('appTitle'),
                      style: const TextStyle(
                        fontSize: 19,
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

              const SizedBox(height: 2),

              // Card 1: Combined Top Status & 4-Metric Bar Card (Figma 0:810 / 18:591)
              const StatusMetricCard(),

              const SizedBox(height: 2),

              // Card 2: Center Circular Mode Dial (Beauty Hub) (Figma 0:810 / 18:591)
              CircularModeDial(
                onSaveTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SavedModesPage()),
                  );
                },
                onCombinationTap: () {
                  final controller = context.read<MaskController>();
                  if (!controller.isConnected) {
                    AppToast.showGoldenToast(
                      context,
                      context.tr('deviceNotConnected'),
                    );
                    return;
                  }
                  controller.switchToCombinationMode();
                },
              ),

              const SizedBox(height: 2),

              // Card 3: Intensity Level Slider Card (Figma 0:811)
              IntensitySlider(
                onNotConnectedTap: () {
                  AppToast.showGoldenToast(
                    context,
                    context.tr('deviceNotConnected'),
                  );
                },
                onBlockedTap: () {
                  AppToast.showGoldenToast(
                    context,
                    context.tr('mustStartBeforeAdjust'),
                  );
                },
                onHighIntensityRequested: (targetGear) async {
                  final confirmed = await HighIntensityDialog.show(context);
                  if (confirmed == true && context.mounted) {
                    context.read<MaskController>().setGear(targetGear);
                  }
                },
              ),

              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
