import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../control/models/mask_mode.dart';
import '../../../control/presentation/widgets/beauty_hub_icons.dart';

class UserManualPage extends StatefulWidget {
  const UserManualPage({super.key});

  @override
  State<UserManualPage> createState() => _UserManualPageState();
}

class _UserManualPageState extends State<UserManualPage> {
  // 0: Face Modes, 1: Body Modes
  int _selectedModeTab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: AppColors.textPrimary,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          context.tr('userManualTitle'),
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Official Manual Subtitle Header Banner
            _buildOfficialHeader(context),
            const SizedBox(height: 20),

            // 1. FUNCTIONAL TREATMENT MODES / 运作模式与效能
            _buildSection1Modes(context),
            const SizedBox(height: 24),

            // 2. HARDWARE LAYOUT & COMPONENTS / 设备结构图解
            _buildSection2Hardware(context),
            const SizedBox(height: 24),

            // 3. LED INDICATOR STATUS / 指示灯状态说明
            _buildSection3LedStatus(context),
            const SizedBox(height: 24),

            // 4. APP INSTALLATION & OPERATION GUIDE / 专属 App 下载与操作步骤
            _buildSection4AppGuide(context),
            const SizedBox(height: 24),

            // 5. TROUBLESHOOTING & FAQ / 常见问题与排除
            _buildSection5Faq(context),
            const SizedBox(height: 24),

            // 6. SAFETY GUIDELINES & CONTRAINDICATIONS / 安全规范与禁忌症
            _buildSection6SafetyAndContraindications(context),
            const SizedBox(height: 36),
          ],
        ),
      ),
    );
  }

  /// Official Header Subtitle Card
  Widget _buildOfficialHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF161922),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withValues(alpha: 0.12),
            ),
            child: const Icon(
              Icons.menu_book_rounded,
              color: AppColors.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'AI Smart Mask (Face/Body) & Skin Sensor',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  context.tr('userManualOfficialSub'),
                  style: TextStyle(
                    color: AppColors.textPrimary.withValues(alpha: 0.65),
                    fontSize: 11,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Section Header Helper
  Widget _buildSectionHeader({
    required BuildContext context,
    required String title,
    required IconData icon,
  }) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ],
    );
  }

  // =========================================================================
  // Section 1: FUNCTIONAL TREATMENT MODES / 运作模式与效能
  // =========================================================================
  Widget _buildSection1Modes(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          context: context,
          title: context.tr('manualSec1Title'),
          icon: Icons.auto_awesome_rounded,
        ),
        const SizedBox(height: 12),

        // Tab Switcher between Face Modes and Body Modes
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF14171E),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.cardBorder.withValues(alpha: 0.4)),
          ),
          padding: const EdgeInsets.all(4),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedModeTab = 0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: _selectedModeTab == 0
                          ? AppColors.primary.withValues(alpha: 0.2)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: _selectedModeTab == 0
                          ? Border.all(color: AppColors.primary.withValues(alpha: 0.4))
                          : null,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      context.tr('manualFaceModesTitle'),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: _selectedModeTab == 0 ? FontWeight.w700 : FontWeight.w500,
                        color: _selectedModeTab == 0 ? AppColors.primary : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedModeTab = 1),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: _selectedModeTab == 1
                          ? AppColors.primary.withValues(alpha: 0.2)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: _selectedModeTab == 1
                          ? Border.all(color: AppColors.primary.withValues(alpha: 0.4))
                          : null,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      context.tr('manualBodyModesTitle'),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: _selectedModeTab == 1 ? FontWeight.w700 : FontWeight.w500,
                        color: _selectedModeTab == 1 ? AppColors.primary : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // List of Modes
        if (_selectedModeTab == 0) ..._buildFaceModeCards(context),
        if (_selectedModeTab == 1) ..._buildBodyModeCards(context),
      ],
    );
  }

  List<Widget> _buildFaceModeCards(BuildContext context) {
    final faceModes = [
      (
        mode: MaskModeType.rejuvenating,
        name: context.tr('manualRejuvName'),
        desc: context.tr('manualRejuvDesc'),
      ),
      (
        mode: MaskModeType.firming,
        name: context.tr('manualFirmingName'),
        desc: context.tr('manualFirmingDesc'),
      ),
      (
        mode: MaskModeType.lifting,
        name: context.tr('manualLiftingName'),
        desc: context.tr('manualLiftingDesc'),
      ),
      (
        mode: MaskModeType.intensiveCare,
        name: context.tr('manualIntensiveName'),
        desc: context.tr('manualIntensiveDesc'),
      ),
      (
        mode: MaskModeType.revitalizing,
        name: context.tr('manualRevitalName'),
        desc: context.tr('manualRevitalDesc'),
      ),
      (
        mode: MaskModeType.plumping,
        name: context.tr('manualElasticityName'),
        desc: context.tr('manualElasticityDesc'),
      ),
    ];

    return faceModes.map((item) {
      return Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.cardBorder.withValues(alpha: 0.35)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
              ),
              alignment: Alignment.center,
              child: BeautyHubIcon(
                mode: item.mode,
                color: AppColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.desc,
                    style: TextStyle(
                      color: AppColors.textPrimary.withValues(alpha: 0.75),
                      fontSize: 12,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  List<Widget> _buildBodyModeCards(BuildContext context) {
    final bodyModes = [
      (
        icon: Icons.accessibility_new_rounded,
        name: context.tr('manualStretchingName'),
        desc: context.tr('manualStretchingDesc'),
      ),
      (
        icon: Icons.bolt_rounded,
        name: context.tr('manualActivationName'),
        desc: context.tr('manualActivationDesc'),
      ),
      (
        icon: Icons.touch_app_rounded,
        name: context.tr('manualTappingName'),
        desc: context.tr('manualTappingDesc'),
      ),
      (
        icon: Icons.clean_hands_rounded,
        name: context.tr('manualEnhancementName'),
        desc: context.tr('manualEnhancementDesc'),
      ),
      (
        icon: Icons.waterfall_chart_rounded,
        name: context.tr('manualLymphaticName'),
        desc: context.tr('manualLymphaticDesc'),
      ),
      (
        icon: Icons.all_inclusive_rounded,
        name: context.tr('manualMultiTherapyName'),
        desc: context.tr('manualMultiTherapyDesc'),
      ),
    ];

    return bodyModes.map((item) {
      return Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.cardBorder.withValues(alpha: 0.35)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
              ),
              alignment: Alignment.center,
              child: Icon(
                item.icon,
                color: AppColors.primary,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.desc,
                    style: TextStyle(
                      color: AppColors.textPrimary.withValues(alpha: 0.75),
                      fontSize: 12,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  // =========================================================================
  // Section 2: HARDWARE LAYOUT & COMPONENTS / 设备结构图解
  // =========================================================================
  Widget _buildSection2Hardware(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          context: context,
          title: context.tr('manualSec2Title'),
          icon: Icons.developer_board_rounded,
        ),
        const SizedBox(height: 12),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.cardBorder.withValues(alpha: 0.35)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Visual Device Structure Diagram (1:1 with PDF, showing complete labels)
              _buildDeviceStructureDiagram(context),
              const SizedBox(height: 16),

              // Ultra-Compact Design Description
              Text(
                context.tr('manualHwDesignTitle'),
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                context.tr('manualHwDesignDesc'),
                style: TextStyle(
                  color: AppColors.textPrimary.withValues(alpha: 0.75),
                  fontSize: 12,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 14),

              // Power Operation Instructions
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF14171E),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.cardBorder.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.tr('manualHwPowerOpTitle'),
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildBulletPoint(
                      title: 'Power ON: ',
                      content: context.tr('manualHwPowerOn'),
                      bulletColor: const Color(0xFF3498DB),
                    ),
                    const SizedBox(height: 6),
                    _buildBulletPoint(
                      title: 'Power OFF: ',
                      content: context.tr('manualHwPowerOff'),
                      bulletColor: AppColors.textSecondary,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // =========================================================================
  // Section 3: LED INDICATOR STATUS / 指示灯状态说明
  // =========================================================================
  Widget _buildSection3LedStatus(BuildContext context) {
    final ledStates = [
      (
        dotColor: const Color(0xFFE05D52),
        title: context.tr('manualLedRedTitle'),
        desc: context.tr('manualLedRedDesc'),
        isFlashing: false,
      ),
      (
        dotColor: const Color(0xFF2ECC71),
        title: context.tr('manualLedGreenTitle'),
        desc: context.tr('manualLedGreenDesc'),
        isFlashing: false,
      ),
      (
        dotColor: const Color(0xFF3498DB),
        title: context.tr('manualLedRapidBlueTitle'),
        desc: context.tr('manualLedRapidBlueDesc'),
        isFlashing: true,
      ),
      (
        dotColor: const Color(0xFF3498DB),
        title: context.tr('manualLedSlowBlueTitle'),
        desc: context.tr('manualLedSlowBlueDesc'),
        isFlashing: true,
      ),
      (
        dotColor: const Color(0xFF5DADE2),
        title: context.tr('manualLedBleBlueTitle'),
        desc: context.tr('manualLedBleBlueDesc'),
        isFlashing: true,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          context: context,
          title: context.tr('manualSec3Title'),
          icon: Icons.light_mode_rounded,
        ),
        const SizedBox(height: 12),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.cardBorder.withValues(alpha: 0.35)),
          ),
          child: Column(
            children: ledStates.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isLast = index == ledStates.length - 1;

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // LED Glow Circle
                        Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: item.dotColor,
                            boxShadow: [
                              BoxShadow(
                                color: item.dotColor.withValues(alpha: 0.5),
                                blurRadius: 6,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 14),
                        // Title
                        SizedBox(
                          width: 130,
                          child: Text(
                            item.title,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        // Description
                        Expanded(
                          child: Text(
                            item.desc,
                            style: TextStyle(
                              color: AppColors.textPrimary.withValues(alpha: 0.75),
                              fontSize: 12,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!isLast) const Divider(color: Color(0xFF262830), height: 1),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // =========================================================================
  // Section 4: APP INSTALLATION & OPERATION GUIDE / 专属 App 下载与操作步骤
  // =========================================================================
  Widget _buildSection4AppGuide(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          context: context,
          title: context.tr('manualSec4Title'),
          icon: Icons.install_mobile_rounded,
        ),
        const SizedBox(height: 12),

        // App Store Download Banner
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF14171E),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.cloud_download_rounded, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.tr('manualAppDownloadTitle'),
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      context.tr('manualAppDownloadDesc'),
                      style: TextStyle(
                        color: AppColors.textPrimary.withValues(alpha: 0.7),
                        fontSize: 11,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // 4 Step Sequential Process Cards
        _buildStepItem(
          context: context,
          stepNumber: 1,
          title: context.tr('manualStep1Title'),
          description: context.tr('manualStep1Desc'),
          badgeText: 'Hardware Setup',
          isLast: false,
        ),
        _buildStepItem(
          context: context,
          stepNumber: 2,
          title: context.tr('manualStep2Title'),
          description: context.tr('manualStep2Desc'),
          badgeText: 'Connectivity',
          isLast: false,
        ),
        _buildStepItem(
          context: context,
          stepNumber: 3,
          title: context.tr('manualStep3Title'),
          description: context.tr('manualStep3Desc'),
          badgeText: 'Electrode Alignment',
          isHighlighted: true,
          isLast: false,
        ),
        _buildStepItem(
          context: context,
          stepNumber: 4,
          title: context.tr('manualStep4Title'),
          description: context.tr('manualStep4Desc'),
          badgeText: 'Treatment Cycle',
          isLast: true,
        ),
      ],
    );
  }

  Widget _buildStepItem({
    required BuildContext context,
    required int stepNumber,
    required String title,
    required String description,
    required String badgeText,
    bool isHighlighted = false,
    required bool isLast,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step Line & Badge
          Column(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isHighlighted
                      ? AppColors.primary
                      : const Color(0xFF1C1D21),
                  border: Border.all(
                    color: isHighlighted
                        ? AppColors.primary
                        : AppColors.primary.withValues(alpha: 0.5),
                    width: 1.5,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  '$stepNumber',
                  style: TextStyle(
                    color: isHighlighted ? Colors.black : AppColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: AppColors.primary.withValues(alpha: 0.25),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),

          // Content Card
          Expanded(
            child: Container(
              margin: EdgeInsets.only(bottom: isLast ? 0 : 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isHighlighted
                    ? AppColors.primary.withValues(alpha: 0.08)
                    : AppColors.cardBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isHighlighted
                      ? AppColors.primary.withValues(alpha: 0.45)
                      : AppColors.cardBorder.withValues(alpha: 0.35),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            color: isHighlighted ? AppColors.primary : AppColors.textPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF14171E),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          badgeText,
                          style: TextStyle(
                            color: AppColors.textSecondary.withValues(alpha: 0.9),
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: TextStyle(
                      color: AppColors.textPrimary.withValues(alpha: 0.75),
                      fontSize: 12,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // Section 5: TROUBLESHOOTING & FAQ / 常见问题与排除
  // =========================================================================
  Widget _buildSection5Faq(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          context: context,
          title: context.tr('manualSec5Title'),
          icon: Icons.quiz_rounded,
        ),
        const SizedBox(height: 12),

        _buildFaqTile(
          context: context,
          question: context.tr('manualFaqQ1'),
          answer: context.tr('manualFaqA1'),
        ),
        const SizedBox(height: 10),
        _buildFaqTile(
          context: context,
          question: context.tr('manualFaqQ2'),
          answer: context.tr('manualFaqA2'),
        ),
        const SizedBox(height: 10),
        _buildFaqTile(
          context: context,
          question: context.tr('manualFaqQ3'),
          answer: context.tr('manualFaqA3'),
        ),
      ],
    );
  }

  Widget _buildFaqTile({
    required BuildContext context,
    required String question,
    required String answer,
  }) {
    return Material(
      color: AppColors.cardBackground,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.cardBorder.withValues(alpha: 0.35)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
          childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
          collapsedIconColor: AppColors.primary,
          iconColor: AppColors.primary,
          title: Text(
            question,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF14171E),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                answer,
                style: TextStyle(
                  color: AppColors.textPrimary.withValues(alpha: 0.8),
                  fontSize: 12,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================================
  // Section 6: SAFETY GUIDELINES & CONTRAINDICATIONS / 安全规范与禁忌症
  // =========================================================================
  Widget _buildSection6SafetyAndContraindications(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          context: context,
          title: context.tr('manualSec6Title'),
          icon: Icons.shield_rounded,
        ),
        const SizedBox(height: 12),

        // 1. Operational Safety (Amber Warning Card)
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF221E18),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE5A95C).withValues(alpha: 0.35)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: Color(0xFFE5A95C), size: 20),
                  const SizedBox(width: 8),
                  Text(
                    context.tr('manualSafetyTitle'),
                    style: const TextStyle(
                      color: Color(0xFFE5A95C),
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _buildBulletPoint(
                content: context.tr('manualSafetyItem1'),
                bulletColor: const Color(0xFFE5A95C),
              ),
              const SizedBox(height: 6),
              _buildBulletPoint(
                content: context.tr('manualSafetyItem2'),
                bulletColor: const Color(0xFFE5A95C),
              ),
              const SizedBox(height: 6),
              _buildBulletPoint(
                content: context.tr('manualSafetyItem3'),
                bulletColor: const Color(0xFFE5A95C),
              ),
              const SizedBox(height: 6),
              _buildBulletPoint(
                content: context.tr('manualSafetyItem4'),
                bulletColor: const Color(0xFFE5A95C),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // 2. Contraindications (Red Prohibition Card)
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF241618),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE05D52).withValues(alpha: 0.35)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.block_rounded, color: Color(0xFFE05D52), size: 20),
                  const SizedBox(width: 8),
                  Text(
                    context.tr('manualContraTitle'),
                    style: const TextStyle(
                      color: Color(0xFFE05D52),
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _buildBulletPoint(
                content: context.tr('manualContraItem1'),
                bulletColor: const Color(0xFFE05D52),
              ),
              const SizedBox(height: 6),
              _buildBulletPoint(
                content: context.tr('manualContraItem2'),
                bulletColor: const Color(0xFFE05D52),
              ),
              const SizedBox(height: 6),
              _buildBulletPoint(
                content: context.tr('manualContraItem3'),
                bulletColor: const Color(0xFFE05D52),
              ),
              const SizedBox(height: 6),
              _buildBulletPoint(
                content: context.tr('manualContraItem4'),
                bulletColor: const Color(0xFFE05D52),
              ),
              const SizedBox(height: 6),
              _buildBulletPoint(
                content: context.tr('manualContraItem5'),
                bulletColor: const Color(0xFFE05D52),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBulletPoint({
    String? title,
    required String content,
    required Color bulletColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 6),
          width: 5,
          height: 5,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: bulletColor,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: TextStyle(
                color: AppColors.textPrimary.withValues(alpha: 0.8),
                fontSize: 12,
                height: 1.4,
              ),
              children: [
                if (title != null)
                  TextSpan(
                    text: title,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: bulletColor,
                    ),
                  ),
                TextSpan(text: content),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDeviceStructureDiagram(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 165,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF131720),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder.withValues(alpha: 0.3)),
      ),
      child: CustomPaint(
        painter: _DeviceDiagramPainter(
          typeCLabel: context.tr('manualDiagramTypeC'),
          powerLabel: context.tr('manualDiagramPower'),
          ledLabel: context.tr('manualDiagramLed'),
          dockingLabel: context.tr('manualDiagramDocking'),
        ),
      ),
    );
  }
}

class _DeviceDiagramPainter extends CustomPainter {
  final String typeCLabel;
  final String powerLabel;
  final String ledLabel;
  final String dockingLabel;

  _DeviceDiagramPainter({
    required this.typeCLabel,
    required this.powerLabel,
    required this.ledLabel,
    required this.dockingLabel,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height * 0.44;

    // Responsive width of the capsule device
    final dw = (size.width * 0.46).clamp(135.0, 185.0);
    const dh = 76.0;

    final left = cx - dw / 2;
    final right = cx + dw / 2;
    final top = cy - dh / 2;
    final bottom = cy + dh / 2;

    // 1. Device Main Body Fill & Stroke
    final bodyRRect = RRect.fromRectAndRadius(
      Rect.fromLTRB(left, top, right, bottom),
      const Radius.circular(26),
    );

    final bgPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF142429), Color(0xFF0F181D)],
      ).createShader(bodyRRect.outerRect);
    canvas.drawRRect(bodyRRect, bgPaint);

    final borderPaint = Paint()
      ..color = const Color(0xFF0E7A75)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4;
    canvas.drawRRect(bodyRRect, borderPaint);

    // 2. Left Type-C Port (protruding tab)
    const portW = 8.0;
    const portH = 22.0;
    final portRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(left - portW, cy - portH / 2, portW + 1, portH),
      const Radius.circular(3),
    );
    final portPaint = Paint()..color = const Color(0xFF0E7A75);
    canvas.drawRRect(portRect, portPaint);

    // Inner Type-C notch cutout
    final notchRect = Rect.fromLTWH(left - portW + 2, cy - 7, 2.8, 14);
    canvas.drawRect(notchRect, Paint()..color = const Color(0xFF0B1014));

    // 3. Right Power Button (protruding tab)
    const btnW = 7.0;
    const btnH = 22.0;
    final btnRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(right - 1, cy - btnH / 2, btnW + 1, btnH),
      const Radius.circular(3),
    );
    canvas.drawRRect(btnRect, portPaint);

    // 4. 3 Status LED Dots (Vertically stacked on the left side)
    final ledX = cx - dw * 0.31;
    const ledRadius = 3.6;
    final ledPaint = Paint()..color = const Color(0xFF38B2AC);
    final ledGlowPaint = Paint()
      ..color = const Color(0x6638B2AC)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    for (final dy in [-16.0, 0.0, 16.0]) {
      final center = Offset(ledX, cy + dy);
      canvas.drawCircle(center, ledRadius + 2, ledGlowPaint);
      canvas.drawCircle(center, ledRadius, ledPaint);
    }

    // 5. Center Magnetic Docking Capsule
    const mw = 44.0;
    const mh = 58.0;
    final dockX = cx + 4;
    final dockRRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(dockX, cy), width: mw, height: mh),
      const Radius.circular(18),
    );
    final dockBgPaint = Paint()..color = const Color(0xFF162A2E);
    canvas.drawRRect(dockRRect, dockBgPaint);
    final dockStrokePaint = Paint()
      ..color = const Color(0xFF0E7A75)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;
    canvas.drawRRect(dockRRect, dockStrokePaint);

    // Dual Gold Contacts
    final goldContactPaint = Paint()..color = const Color(0xFFD69F5B);
    final goldGlowPaint = Paint()
      ..color = const Color(0x55D69F5B)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    for (final dy in [-15.0, 15.0]) {
      final pinCenter = Offset(dockX, cy + dy);
      canvas.drawCircle(pinCenter, 3.8, goldGlowPaint);
      canvas.drawCircle(pinCenter, 3.2, goldContactPaint);
    }

    // Center Text: dockingLabel
    _drawText(
      canvas: canvas,
      text: dockingLabel,
      offset: Offset(dockX, cy),
      align: TextAlign.center,
      style: const TextStyle(
        color: Color(0xFF2DD4BF),
        fontSize: 9.5,
        fontWeight: FontWeight.w600,
        height: 1.15,
      ),
      isCentered: true,
    );

    // 6. Dashed Connecting Lines
    final dashPaint = Paint()
      ..color = const Color(0xFF64748B)
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke;

    // Left dashed line to Port
    final leftDashStartX = left - portW;
    final leftDashEndX = (left - portW - 22).clamp(8.0, left - portW);
    _drawDashedLine(canvas, Offset(leftDashStartX, cy), Offset(leftDashEndX, cy), dashPaint);

    // Right dashed line to Power Button
    final rightDashStartX = right + btnW;
    final rightDashEndX = (right + btnW + 22).clamp(right + btnW, size.width - 8.0);
    _drawDashedLine(canvas, Offset(rightDashStartX, cy), Offset(rightDashEndX, cy), dashPaint);

    // Bottom L-shaped dashed line for Status LED
    final ledBottomY = cy + 16.0;
    final ledLCornerY = (bottom + 14.0).clamp(bottom + 8, size.height - 18.0);
    _drawDashedLine(canvas, Offset(ledX, ledBottomY + 5), Offset(ledX, ledLCornerY), dashPaint);
    _drawDashedLine(canvas, Offset(ledX, ledLCornerY), Offset(cx - 14, ledLCornerY), dashPaint);

    // 7. Text Callout Labels
    // Left Label: Type-C 充电口
    final leftTextLimit = math.max(45.0, leftDashEndX - 6.0);
    _drawText(
      canvas: canvas,
      text: typeCLabel,
      offset: Offset(leftDashEndX - 4.0, cy),
      align: TextAlign.right,
      style: const TextStyle(
        color: Color(0xFFE2E8F0),
        fontSize: 11.0,
        fontWeight: FontWeight.w700,
        height: 1.25,
      ),
      anchorRight: true,
      maxWidth: leftTextLimit,
    );

    // Right Label: 电源开关
    final rightTextLimit = math.max(45.0, size.width - (rightDashEndX + 6.0));
    _drawText(
      canvas: canvas,
      text: powerLabel,
      offset: Offset(rightDashEndX + 4.0, cy),
      align: TextAlign.left,
      style: const TextStyle(
        color: Color(0xFFE2E8F0),
        fontSize: 11.0,
        fontWeight: FontWeight.w700,
        height: 1.25,
      ),
      anchorRight: false,
      maxWidth: rightTextLimit,
    );

    // Bottom Label: 状态指示灯
    _drawText(
      canvas: canvas,
      text: ledLabel,
      offset: Offset(cx - 10, ledLCornerY),
      align: TextAlign.left,
      style: const TextStyle(
        color: Color(0xFFCBD5E1),
        fontSize: 10.5,
        fontWeight: FontWeight.w600,
      ),
      anchorRight: false,
      maxWidth: size.width - cx,
      centerYOffset: true,
    );
  }

  void _drawDashedLine(Canvas canvas, Offset p1, Offset p2, Paint paint, {double dash = 4.0, double space = 3.0}) {
    final dx = p2.dx - p1.dx;
    final dy = p2.dy - p1.dy;
    final count = (math.sqrt(dx * dx + dy * dy) / (dash + space)).floor();
    for (int i = 0; i < count; i++) {
      final t1 = (i * (dash + space)) / math.sqrt(dx * dx + dy * dy);
      final t2 = ((i * (dash + space)) + dash) / math.sqrt(dx * dx + dy * dy);
      canvas.drawLine(
        Offset(p1.dx + dx * t1, p1.dy + dy * t1),
        Offset(p1.dx + dx * t2, p1.dy + dy * t2),
        paint,
      );
    }
  }

  void _drawText({
    required Canvas canvas,
    required String text,
    required Offset offset,
    required TextAlign align,
    required TextStyle style,
    TextStyle? subStyle,
    bool isCentered = false,
    bool anchorRight = false,
    bool centerYOffset = true,
    double maxWidth = 120.0,
  }) {
    final lines = text.split('\n');
    InlineSpan span;
    if (lines.length > 1 && subStyle != null) {
      span = TextSpan(
        children: [
          TextSpan(text: '${lines[0]}\n', style: style),
          TextSpan(text: lines.sublist(1).join('\n'), style: subStyle),
        ],
      );
    } else {
      span = TextSpan(text: text, style: style);
    }

    final tp = TextPainter(
      text: span,
      textAlign: align,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: maxWidth);

    double x = offset.dx;
    double y = offset.dy;

    if (isCentered) {
      x -= tp.width / 2;
      y -= tp.height / 2;
    } else if (anchorRight) {
      x -= tp.width;
      if (centerYOffset) y -= tp.height / 2;
    } else {
      if (centerYOffset) y -= tp.height / 2;
    }

    tp.paint(canvas, Offset(x, y));
  }

  @override
  bool shouldRepaint(covariant _DeviceDiagramPainter oldDelegate) {
    return oldDelegate.typeCLabel != typeCLabel ||
        oldDelegate.powerLabel != powerLabel ||
        oldDelegate.ledLabel != ledLabel ||
        oldDelegate.dockingLabel != dockingLabel;
  }
}

