import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constants/app_colors.dart';
import '../../core/network/api_client.dart';
import 'create_report_dto.dart';
import 'reports_service.dart';

class ReportDialog {
  ReportDialog._();

  static Future<void> show({
    required int targetType,
    required int targetId,
  }) async {
    int selectedReason = 0;
    bool isSubmitting = false;

    await Get.dialog(
      StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            child: Container(
              width: 330,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.flag_outlined, color: AppColors.red),
                      SizedBox(width: 8),
                      Text(
                        'إبلاغ عن المحتوى',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'اختر سبب البلاغ ليتم مراجعته من الإدارة.',
                    style: TextStyle(
                      color: AppColors.muted,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 18),

                  _ReasonTile(
                    title: 'إساءة',
                    subtitle: 'ألفاظ أو محتوى غير لائق',
                    icon: Icons.warning_amber_rounded,
                    value: 0,
                    groupValue: selectedReason,
                    onChanged: (value) {
                      setState(() => selectedReason = value);
                    },
                  ),

                  const SizedBox(height: 10),

                  _ReasonTile(
                    title: 'معلومات مضللة',
                    subtitle: 'خبر أو معلومة كروية غير صحيحة',
                    icon: Icons.error_outline,
                    value: 1,
                    groupValue: selectedReason,
                    onChanged: (value) {
                      setState(() => selectedReason = value);
                    },
                  ),

                  const SizedBox(height: 10),

                  _ReasonTile(
                    title: 'إزعاج',
                    subtitle: 'محتوى متكرر أو مزعج',
                    icon: Icons.report_gmailerrorred_outlined,
                    value: 2,
                    groupValue: selectedReason,
                    onChanged: (value) {
                      setState(() => selectedReason = value);
                    },
                  ),

                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: isSubmitting ? null : () => Get.back(),
                          child: const Text('إلغاء'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton.icon(
                          onPressed: isSubmitting
                              ? null
                              : () async {
                                  try {
                                    setState(() => isSubmitting = true);

                                    final service = ReportsService(
                                      Get.find<ApiClient>(),
                                    );

                                    await service.createReport(
                                      CreateReportDto(
                                        targetType: targetType,
                                        targetId: targetId,
                                        reason: selectedReason,
                                      ),
                                    );

                                    Get.back();

                                    Get.snackbar(
                                      'تم الإرسال',
                                      'تم إرسال البلاغ بنجاح',
                                      snackPosition: SnackPosition.BOTTOM,
                                    );
                                  } catch (e) {
                                    setState(() => isSubmitting = false);

                                    Get.snackbar(
                                      'خطأ',
                                      e
                                          .toString()
                                          .replaceFirst('Exception: ', ''),
                                      snackPosition: SnackPosition.BOTTOM,
                                    );
                                  }
                                },
                          icon: isSubmitting
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.send_outlined, size: 18),
                          label: Text(isSubmitting ? 'جارٍ الإرسال' : 'إرسال'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ReasonTile extends StatelessWidget {
  const _ReasonTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final int value;
  final int groupValue;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final selected = value == groupValue;

    return InkWell(
      onTap: () => onChanged(value),
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.red.withValues(alpha: 0.08)
              : Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? AppColors.red : AppColors.border,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: selected ? AppColors.red : AppColors.muted,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color: selected ? AppColors.red : null,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Radio<int>(
              value: value,
              groupValue: groupValue,
              activeColor: AppColors.red,
              onChanged: (v) {
                if (v == null) return;
                onChanged(v);
              },
            ),
          ],
        ),
      ),
    );
  }
}