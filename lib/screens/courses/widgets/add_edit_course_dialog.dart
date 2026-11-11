import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';
import '../../../models/course.dart';
import '../../../db/database_helper.dart';

class AddEditCourseDialog {
  static Future<void> show({
    required BuildContext context,
    Course? course,
    required VoidCallback onSaved,
  }) async {
    final isEditing = course != null;
    final formKey = GlobalKey<FormState>();
    final dbHelper = DatabaseHelper();

    final nameController = TextEditingController(text: course?.name ?? '');
    final yearController = TextEditingController(
      text: course != null ? course.year.toString() : DateTime.now().year.toString(),
    );
    final feeController = TextEditingController(
      text: course != null
          ? (course.fee % 1 == 0 ? course.fee.toInt().toString() : course.fee.toString())
          : '',
    );
    final startDateController = TextEditingController(text: course?.startDate ?? '');
    final endDateController = TextEditingController(text: course?.endDate ?? '');
    final notesController = TextEditingController(text: course?.notes ?? '');

    String selectedSeason = course?.season ?? 'summer';
    bool isActive = course?.isActive ?? (isEditing ? false : true);
    bool isSaving = false;

    List<int> selectedWorkingDays = course?.workingDays != null
        ? List<int>.from(course!.workingDays)
        : (selectedSeason == 'winter'
            ? [DateTime.saturday]
            : [DateTime.saturday, DateTime.sunday, DateTime.tuesday]);

    // Helper to auto-fill suggested name when season or year changes
    void updateSuggestedName(StateSetter setState) {
      if (!isEditing && nameController.text.isEmpty) {
        final seasonName = selectedSeason == 'summer' ? 'الدورة الصيفية' : 'الدورة الشتوية';
        nameController.text = '$seasonName ${yearController.text.trim()}';
      }
    }

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
              titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              title: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: selectedSeason == 'summer'
                          ? const Color(0xFFFEF3D6)
                          : const Color(0xFFD7F5F0),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      selectedSeason == 'summer'
                          ? Icons.wb_sunny_rounded
                          : Icons.ac_unit_rounded,
                      color: selectedSeason == 'summer'
                          ? const Color(0xFFC89336)
                          : const Color(0xFF00796B),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      isEditing ? 'تعديل بيانات الدورة' : 'إضافة دورة جديدة',
                      style: GoogleFonts.cairo(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryTeal,
                      ),
                    ),
                  ),
                ],
              ),
              content: SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Season Selection (صيفية / شتوية)
                        Text(
                          'نوع الدورة *',
                          style: GoogleFonts.cairo(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryTeal,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Expanded(
                              child: _seasonChoice(
                                title: 'دورة صيفية',
                                icon: Icons.wb_sunny_rounded,
                                isSelected: selectedSeason == 'summer',
                                activeColor: const Color(0xFFC89336),
                                activeBg: const Color(0xFFFEF3D6),
                                onTap: () {
                                  setDialogState(() {
                                    selectedSeason = 'summer';
                                    if (!isEditing) {
                                      nameController.text = 'الدورة الصيفية ${yearController.text.trim()}';
                                      selectedWorkingDays = [DateTime.saturday, DateTime.sunday, DateTime.tuesday];
                                    }
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _seasonChoice(
                                title: 'دورة شتوية',
                                icon: Icons.ac_unit_rounded,
                                isSelected: selectedSeason == 'winter',
                                activeColor: const Color(0xFF00796B),
                                activeBg: const Color(0xFFD7F5F0),
                                onTap: () {
                                  setDialogState(() {
                                    selectedSeason = 'winter';
                                    if (!isEditing) {
                                      nameController.text = 'الدورة الشتوية ${yearController.text.trim()}';
                                      selectedWorkingDays = [DateTime.saturday];
                                    }
                                  });
                                },
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 14),

                        // Course Name
                        _textField(
                          controller: nameController,
                          label: 'اسم الدورة *',
                          hint: 'مثال: الدورة الصيفية 2026',
                          isRequired: true,
                        ),

                        const SizedBox(height: 12),

                        // Year & Mandatory Fee (المبلغ إجباري)
                        Row(
                          children: [
                            Expanded(
                              child: _textField(
                                controller: yearController,
                                label: 'السنة *',
                                hint: '2026',
                                isNumber: true,
                                isRequired: true,
                                onChanged: (val) {
                                  if (!isEditing) {
                                    final seasonName = selectedSeason == 'summer' ? 'الدورة الصيفية' : 'الدورة الشتوية';
                                    nameController.text = '$seasonName $val';
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _textField(
                                controller: feeController,
                                label: 'رسم الدورة (إجباري) *',
                                hint: 'المبلغ المطلوب',
                                isNumber: true,
                                isRequired: true,
                                prefixIcon: Icons.payments_rounded,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // Working Days (أيام دوام الدورة للتفقد)
                        Text(
                          'أيام دوام الدورة (أيام التفقد والحضور) *',
                          style: GoogleFonts.cairo(
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryTeal,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            DateTime.saturday,
                            DateTime.sunday,
                            DateTime.monday,
                            DateTime.tuesday,
                            DateTime.wednesday,
                            DateTime.thursday,
                            DateTime.friday,
                          ].map((dayInt) {
                            final dayName = Course.dayNamesArabic[dayInt] ?? '';
                            final isSelected = selectedWorkingDays.contains(dayInt);
                            return InkWell(
                              onTap: () {
                                setDialogState(() {
                                  if (isSelected) {
                                    if (selectedWorkingDays.length > 1) {
                                      selectedWorkingDays.remove(dayInt);
                                    }
                                  } else {
                                    selectedWorkingDays.add(dayInt);
                                  }
                                });
                              },
                              borderRadius: BorderRadius.circular(10),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: isSelected ? AppColors.primaryTeal : Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: isSelected ? AppColors.primaryTeal : Colors.grey.shade300,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (isSelected) ...[
                                      const Icon(Icons.check, size: 14, color: Colors.white),
                                      const SizedBox(width: 4),
                                    ],
                                    Text(
                                      dayName,
                                      style: GoogleFonts.cairo(
                                        fontSize: 11.5,
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                        color: isSelected ? Colors.white : AppColors.textDark,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),

                        const SizedBox(height: 12),

                        // Dates (Start / End)
                        Row(
                          children: [
                            Expanded(
                              child: _textField(
                                controller: startDateController,
                                label: 'تاريخ البدء',
                                hint: 'مثال: 01-06-2026',
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _textField(
                                controller: endDateController,
                                label: 'تاريخ الانتهاء',
                                hint: 'مثال: 01-09-2026',
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // Active Switch (تعيين كدورة نشطة)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: isActive
                                ? const Color(0xFFD7F5F0)
                                : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isActive
                                  ? const Color(0xFF00796B).withValues(alpha: 0.3)
                                  : Colors.grey.shade300,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'تعيين كدورة نشطة حالياً',
                                    style: GoogleFonts.cairo(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: isActive ? const Color(0xFF00796B) : AppColors.textDark,
                                    ),
                                  ),
                                  Text(
                                    'ستكون الدورة الافتراضية للتسجيل والحلقات',
                                    style: GoogleFonts.cairo(
                                      fontSize: 10.5,
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                              Switch(
                                value: isActive,
                                activeColor: const Color(0xFF00796B),
                                onChanged: (val) => setDialogState(() => isActive = val),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Notes
                        _textField(
                          controller: notesController,
                          label: 'ملاحظات إضافية',
                          hint: 'ملاحظات عن الدورة أو الفئات المستهدفة...',
                          maxLines: 2,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              actions: [
                TextButton(
                  onPressed: isSaving ? null : () => Navigator.pop(ctx),
                  child: Text(
                    'إلغاء',
                    style: GoogleFonts.cairo(color: AppColors.textMuted, fontWeight: FontWeight.bold),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryTeal,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  ),
                  onPressed: isSaving
                      ? null
                      : () async {
                          if (!formKey.currentState!.validate()) return;
                          setDialogState(() => isSaving = true);

                          try {
                            final parsedFee = double.tryParse(feeController.text.trim()) ?? 0.0;
                            final parsedYear = int.tryParse(yearController.text.trim()) ?? DateTime.now().year;

                            final courseModel = Course(
                              id: course?.id,
                              name: nameController.text.trim(),
                              season: selectedSeason,
                              year: parsedYear,
                              fee: parsedFee,
                              startDate: startDateController.text.trim(),
                              endDate: endDateController.text.trim(),
                              isActive: isActive,
                              notes: notesController.text.trim(),
                              workingDays: selectedWorkingDays,
                            );

                            if (isEditing) {
                              await dbHelper.updateCourse(courseModel);
                            } else {
                              await dbHelper.insertCourse(courseModel);
                            }

                            onSaved();
                            if (context.mounted) {
                              Navigator.pop(ctx);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    isEditing ? 'تم تعديل بيانات الدورة بنجاح!' : 'تم إضافة الدورة وتحديد الرسم بنجاح!',
                                    style: GoogleFonts.cairo(),
                                  ),
                                  backgroundColor: const Color(0xFF00796B),
                                ),
                              );
                            }
                          } catch (e) {
                            setDialogState(() => isSaving = false);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('حدث خطأ: $e', style: GoogleFonts.cairo()),
                                  backgroundColor: Colors.red.shade700,
                                ),
                              );
                            }
                          }
                        },
                  child: isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : Text(
                          isEditing ? 'حفظ التعديل' : 'إضافة الدورة',
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

  static Widget _seasonChoice({
    required String title,
    required IconData icon,
    required bool isSelected,
    required Color activeColor,
    required Color activeBg,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? activeBg : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? activeColor : Colors.grey.shade300,
            width: isSelected ? 1.8 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: isSelected ? activeColor : AppColors.textMuted),
            const SizedBox(width: 6),
            Text(
              title,
              style: GoogleFonts.cairo(
                fontSize: 12.5,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected ? activeColor : AppColors.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _textField({
    required TextEditingController controller,
    required String label,
    required String hint,
    bool isRequired = false,
    bool isNumber = false,
    IconData? prefixIcon,
    int maxLines = 1,
    ValueChanged<String>? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 12.5,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryTeal,
          ),
        ),
        const SizedBox(height: 5),
        TextFormField(
          controller: controller,
          keyboardType: isNumber ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
          maxLines: maxLines,
          onChanged: onChanged,
          style: GoogleFonts.cairo(fontSize: 13, color: AppColors.textDark),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.cairo(fontSize: 12, color: AppColors.inputHint),
            filled: true,
            fillColor: Colors.white,
            prefixIcon: prefixIcon != null ? Icon(prefixIcon, size: 18, color: AppColors.primaryTeal) : null,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primaryTeal, width: 1.5),
            ),
          ),
          validator: isRequired
              ? (val) {
                  if (val == null || val.trim().isEmpty) return 'هذا الحقل مطلوب';
                  if (isNumber && double.tryParse(val.trim()) == null) {
                    return 'يرجى إدخال رقم صحيح';
                  }
                  return null;
                }
              : null,
        ),
      ],
    );
  }
}
