import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';
import '../../../models/student.dart';
import '../../../models/teacher.dart';
import '../../../db/database_helper.dart';

class TransferStudentDialog {
  static Future<void> show({
    required BuildContext context,
    required Student student,
    required List<Teacher> allTeachers,
    required VoidCallback onTransferred,
  }) async {
    final validTeachers = allTeachers
        .where((t) => (t.id ?? '').toString() != (student.teacherId ?? '').toString())
        .toList();

    if (validTeachers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'لا توجد آنسات أخريات لنقل الطالب إليهن',
            style: GoogleFonts.cairo(),
          ),
        ),
      );
      return;
    }

    Teacher? selectedTeacher;
    final dbHelper = DatabaseHelper();

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: AppColors.primaryTealLight,
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    child: const Icon(Icons.swap_horiz_rounded, color: AppColors.primaryTeal),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'نقل الطالب إلى حلقة أخرى',
                      style: GoogleFonts.cairo(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryTeal,
                      ),
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'الطالب: ${student.name} ${student.surname}',
                    style: GoogleFonts.cairo(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'الحلقة الحالية: الآنسة ${student.teacherName.isEmpty ? 'غير معينة' : student.teacherName}',
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'اختر الحلقة الجديدة:',
                    style: GoogleFonts.cairo(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryTeal,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<Teacher>(
                        value: selectedTeacher,
                        isExpanded: true,
                        hint: Text(
                          'اختر الآنسة...',
                          style: GoogleFonts.cairo(fontSize: 13, color: AppColors.inputHint),
                        ),
                        items: validTeachers.map((t) {
                          return DropdownMenuItem<Teacher>(
                            value: t,
                            child: Text(
                              'الآنسة ${t.name} (${t.ageRange})',
                              style: GoogleFonts.cairo(fontSize: 13),
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          setDialogState(() => selectedTeacher = val);
                        },
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text('إلغاء', style: GoogleFonts.cairo(color: AppColors.textMuted)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryTeal,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: selectedTeacher == null
                      ? null
                      : () async {
                          Navigator.pop(ctx);
                          try {
                            await dbHelper.updateStudentTeacher(
                              studentId: student.id,
                              teacherId: selectedTeacher!.id,
                              teacherName: selectedTeacher!.name,
                            );
                            onTransferred();
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'تم نقل الطالب بنجاح إلى حلقة الآنسة ${selectedTeacher!.name}',
                                    style: GoogleFonts.cairo(),
                                  ),
                                  backgroundColor: const Color(0xFF00897B),
                                ),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('فشل نقل الطالب: $e', style: GoogleFonts.cairo()),
                                  backgroundColor: Colors.red.shade700,
                                ),
                              );
                            }
                          }
                        },
                  child: Text(
                    'تأكيد النقل',
                    style: GoogleFonts.cairo(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
