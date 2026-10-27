import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../../models/mask_mode.dart';
import '../../providers/mask_controller.dart';
import 'beauty_hub_icons.dart';

class SaveModeDialog extends StatefulWidget {
  const SaveModeDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (ctx) => const SaveModeDialog(),
    );
  }

  @override
  State<SaveModeDialog> createState() => _SaveModeDialogState();
}

class _SaveModeDialogState extends State<SaveModeDialog> {
  MaskModeType? _selectedMode;
  late int _selectedGear;

  @override
  void initState() {
    super.initState();
    final controller = context.read<MaskController>();
    if (controller.isCombinationActive) {
      _selectedMode = null; // 综合模式
    } else {
      _selectedMode = controller.selectedMode ?? MaskModeType.rejuvenating;
    }
    _selectedGear = controller.currentGear.clamp(1, MaskController.maxGear).toInt();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<MaskController>();

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: AppColors.cardBorder, width: 1.0),
      ),
      backgroundColor: AppColors.cardBackground,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Padding(
        padding: const EdgeInsets.all(22.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  context.tr('saveMode'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 20, color: AppColors.textSecondary),
                  onPressed: () => Navigator.of(context).pop(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // 栏位 1: 模式 (包含单项模式与综合模式)
            Text(
              context.tr('mode'),
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.capsuleBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<MaskModeType?>(
                  value: _selectedMode,
                  dropdownColor: AppColors.cardBackground,
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textPrimary),
                  items: [
                    DropdownMenuItem<MaskModeType?>(
                      value: null,
                      child: Row(
                        children: [
                          const Icon(Icons.layers_rounded, color: AppColors.primary, size: 20),
                          const SizedBox(width: 10),
                          Text(
                            context.tr('combination'),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ...MaskModeType.values.map((mode) {
                      return DropdownMenuItem<MaskModeType?>(
                        value: mode,
                        child: Row(
                          children: [
                            BeautyHubIcon(mode: mode, color: AppColors.primary, size: 20),
                            const SizedBox(width: 10),
                            Text(
                              context.tr(mode.l10nKey),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                  onChanged: (newMode) {
                    setState(() => _selectedMode = newMode);
                  },
                ),
              ),
            ),

            const SizedBox(height: 18),

            // 栏位 2: 档位
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  context.tr('gear'),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  context.tr('gearFormat').replaceAll('{gear}', '$_selectedGear'),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.capsuleBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline_rounded, color: AppColors.primary, size: 24),
                    onPressed: _selectedGear > 1
                        ? () => setState(() => _selectedGear--)
                        : null,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  Expanded(
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: AppColors.primary,
                        inactiveTrackColor: Colors.black12,
                        thumbColor: AppColors.primary,
                        trackHeight: 4,
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                      ),
                      child: Slider(
                        value: _selectedGear.toDouble(),
                        min: 1,
                        max: MaskController.maxGear.toDouble(),
                        divisions: MaskController.maxGear - 1,
                        onChanged: (val) {
                          setState(() => _selectedGear = val.round());
                        },
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.primary, size: 24),
                    onPressed: _selectedGear < MaskController.maxGear
                        ? () => setState(() => _selectedGear++)
                        : null,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 操作按钮
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textPrimary,
                      side: const BorderSide(color: Color(0xFFE5E0D6)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                    ),
                    child: Text(context.tr('cancel')),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_selectedMode == null) {
                        await controller.savePreset(
                          isCombination: true,
                          gear: _selectedGear,
                        );
                      } else {
                        await controller.savePreset(
                          mode: _selectedMode,
                          gear: _selectedGear,
                        );
                      }
                      if (context.mounted) {
                        Navigator.of(context).pop();
                        AppToast.showSuccess(context, context.tr('modeSavedSuccess'));
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                    ),
                    child: Text(context.tr('save')),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
