import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../models/mask_mode.dart';
import '../../providers/mask_controller.dart';

class CombinationModeDialog extends StatelessWidget {
  const CombinationModeDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const CombinationModeDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<MaskController>();

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE0DDD5),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          const SizedBox(height: 18),

          // Title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.tr('combination'),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Text(
            context.tr('combinationModeDesc'),
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 20),

          // Combination Sequence Pipeline
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.capsuleBackground,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                _buildStageRow(
                  stageNum: '1',
                  modeName: context.tr('rejuvenating'),
                  duration: '4 min',
                  gear: '03',
                  icon: Icons.hub_outlined,
                ),
                const Divider(height: 16, color: Color(0xFFE5E0D6)),
                _buildStageRow(
                  stageNum: '2',
                  modeName: context.tr('firming'),
                  duration: '4 min',
                  gear: '05',
                  icon: Icons.lightbulb_outline,
                ),
                const Divider(height: 16, color: Color(0xFFE5E0D6)),
                _buildStageRow(
                  stageNum: '3',
                  modeName: context.tr('lifting'),
                  duration: '4 min',
                  gear: '04',
                  icon: Icons.waves,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Start Combination Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                controller.setMode(MaskModeType.rejuvenating);
                controller.setGear(3);
                if (!controller.isPowerOn) {
                  controller.togglePower();
                }
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(context.tr('start') + ': ' + context.tr('combination')),
                    backgroundColor: AppColors.primary,
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                context.tr('start'),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStageRow({
    required String stageNum,
    required String modeName,
    required String duration,
    required String gear,
    required IconData icon,
  }) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            stageNum,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Icon(icon, size: 20, color: AppColors.textPrimary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            modeName,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        Text(
          '$duration | Level $gear',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
