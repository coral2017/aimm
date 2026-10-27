import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/storage/ble_tx_log_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_feedback.dart';

class BleTxLogDialog extends StatefulWidget {
  const BleTxLogDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (_) => const BleTxLogDialog(),
    );
  }

  @override
  State<BleTxLogDialog> createState() => _BleTxLogDialogState();
}

class _BleTxLogDialogState extends State<BleTxLogDialog> {
  List<BleTxLogItem> _logs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    setState(() => _isLoading = true);
    final list = await BleTxLogService.instance.getTodayLogs();
    if (mounted) {
      setState(() {
        _logs = list;
        _isLoading = false;
      });
    }
  }

  Future<void> _copyAll() async {
    if (_logs.isEmpty) return;
    final text = await BleTxLogService.instance.exportFormattedText();
    await Clipboard.setData(ClipboardData(text: text));
    if (mounted) {
      AppToast.showSuccess(context, context.tr('logsCopied'));
    }
  }

  Future<void> _clearLogs() async {
    await BleTxLogService.instance.clearLogs();
    await _loadLogs();
  }

  @override
  Widget build(BuildContext context) {

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: AppColors.cardBackground,
      titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      actionsPadding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.receipt_long_rounded, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              context.tr('bleTxLog'),
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          if (!_isLoading && _logs.isNotEmpty)
            Text(
              '${_logs.length}条',
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        height: 380,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _logs.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.inbox_outlined, size: 48, color: AppColors.textMuted.withValues(alpha: 0.5)),
                        const SizedBox(height: 10),
                        Text(
                          context.tr('noLogsToday'),
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                        ),
                      ],
                    ),
                  )
                : Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E), // 极客黑色控制台风格，易读且便于辨识
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      itemCount: _logs.length,
                      separatorBuilder: (_, __) => const Divider(color: Color(0xFF333333), height: 8),
                      itemBuilder: (context, index) {
                        final item = _logs[index];
                        final timeStr =
                            '${item.timestamp.hour.toString().padLeft(2, '0')}:${item.timestamp.minute.toString().padLeft(2, '0')}:${item.timestamp.second.toString().padLeft(2, '0')}';
                        final modeHex = '0x${item.mode.toRadixString(16).padLeft(2, '0').toUpperCase()}';
                        final gearHex = '0x${item.gear.toRadixString(16).padLeft(2, '0').toUpperCase()}';

                        return SelectableText.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: '#${(index + 1).toString().padLeft(2, '0')} [$timeStr] ',
                                style: const TextStyle(color: Color(0xFF888888), fontSize: 11, fontFamily: 'monospace'),
                              ),
                              TextSpan(
                                text: 'M:$modeHex G:${item.gear}($gearHex) ',
                                style: const TextStyle(color: Color(0xFF4CAF50), fontSize: 11, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
                              ),
                              TextSpan(
                                text: item.isOpen ? 'ON ' : 'OFF ',
                                style: TextStyle(
                                  color: item.isOpen ? const Color(0xFF64B5F6) : const Color(0xFFE57373),
                                  fontSize: 11,
                                  fontFamily: 'monospace',
                                ),
                              ),
                              TextSpan(
                                text: '\n${item.hexString}',
                                style: const TextStyle(color: Color(0xFFEEEEEE), fontSize: 11, fontFamily: 'monospace'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
      ),
      actions: [
        if (_logs.isNotEmpty)
          TextButton(
            onPressed: _clearLogs,
            style: TextButton.styleFrom(foregroundColor: AppColors.textSecondary),
            child: Text(context.tr('clearLogs')),
          ),
        const Spacer(),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(context.tr('cancel')),
        ),
        ElevatedButton.icon(
          onPressed: _logs.isEmpty ? null : _copyAll,
          icon: const Icon(Icons.copy_rounded, size: 16),
          label: Text(context.tr('copyAllLogs')),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ],
    );
  }
}
