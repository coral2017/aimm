import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../../../control/presentation/widgets/beauty_hub_icons.dart';
import '../../../control/providers/mask_controller.dart';

class SavedModesPage extends StatelessWidget {
  const SavedModesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<MaskController>();
    final presets = controller.savedPresets;
    final canAddCurrent =
        (controller.selectedMode != null || controller.isCombinationActive) &&
            !controller.isCurrentSaved;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          context.tr('savedModes'),
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          if (canAddCurrent)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: ElevatedButton(
                  onPressed: () async {
                    if (controller.isCombinationActive) {
                      await controller.savePreset(
                        isCombination: true,
                        gear: controller.currentGear,
                      );
                    } else if (controller.selectedMode != null) {
                      await controller.savePreset(
                        mode: controller.selectedMode!,
                        gear: controller.currentGear,
                      );
                    }
                    if (context.mounted) {
                      AppToast.showSuccess(context, context.tr('modeSavedSuccess'));
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF07C160), // 小程序标准绿色按钮
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    minimumSize: const Size(64, 32),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: Text(
                    context.tr('addSave'),
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: presets.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.bookmark_border_rounded,
                    size: 54,
                    color: AppColors.textSecondary.withValues(alpha: 0.4),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    context.tr('noSavedPresets'),
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              itemCount: presets.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (ctx, index) {
                final preset = presets[index];
                final isCurrentlyActive = preset.isCombination
                    ? (controller.isCombinationActive && controller.currentGear == preset.gear && controller.isRunning)
                    : (controller.selectedMode == preset.mode && controller.currentGear == preset.gear && controller.isRunning);

                return Material(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(14),
                  elevation: 0,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () {
                      controller.applyPresetAndStart(preset);
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isCurrentlyActive
                              ? AppColors.primary
                              : AppColors.cardBorder,
                          width: isCurrentlyActive ? 1.5 : 1.0,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(9),
                            decoration: BoxDecoration(
                              color: isCurrentlyActive
                                  ? AppColors.primary.withValues(alpha: 0.15)
                                  : AppColors.capsuleBackground,
                              shape: BoxShape.circle,
                            ),
                            child: preset.isCombination
                                ? Icon(
                                    Icons.layers_rounded,
                                    color: isCurrentlyActive
                                        ? AppColors.primaryDark
                                        : AppColors.primary,
                                    size: 20,
                                  )
                                : BeautyHubIcon(
                                    mode: preset.mode,
                                    color: isCurrentlyActive
                                        ? AppColors.primaryDark
                                        : AppColors.primary,
                                    size: 20,
                                  ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Row(
                              children: [
                                Text(
                                  context.tr(preset.displayTitleKey),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    context.tr('gearFormat').replaceAll('{gear}', '${preset.gear}'),
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primaryDark,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline_rounded,
                              size: 20,
                              color: AppColors.textSecondary,
                            ),
                            onPressed: () => controller.deletePreset(preset.id),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
