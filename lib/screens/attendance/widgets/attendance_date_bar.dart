import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';
import '../../../models/course.dart';

class AttendanceDateBar extends StatelessWidget {
  final DateTime selectedDate;
  final Course? course;
  final ValueChanged<DateTime> onDateChanged;

  const AttendanceDateBar({
    super.key,
    required this.selectedDate,
    required this.course,
    required this.onDateChanged,
  });

  /// الانتقال إلى يوم الدوام التالي مباشرة متجاوزاً أيام العطل
  DateTime _getNextWorkingDay(DateTime from) {
    if (course == null || course!.workingDays.isEmpty) {
      return from.add(const Duration(days: 1));
    }
    var next = from.add(const Duration(days: 1));
    for (int i = 0; i < 7; i++) {
      if (course!.isWorkingDay(next)) return next;
      next = next.add(const Duration(days: 1));
    }
    return from.add(const Duration(days: 1));
  }

  /// الانتقال إلى يوم الدوام السابق مباشرة متجاوزاً أيام العطل
  DateTime _getPrevWorkingDay(DateTime from) {
    if (course == null || course!.workingDays.isEmpty) {
      return from.subtract(const Duration(days: 1));
    }
    var prev = from.subtract(const Duration(days: 1));
    for (int i = 0; i < 7; i++) {
      if (course!.isWorkingDay(prev)) return prev;
      prev = prev.subtract(const Duration(days: 1));
    }
    return from.subtract(const Duration(days: 1));
  }

  String _formatDate(DateTime d) {
    final dayStr = d.day.toString().padLeft(2, '0');
    final monthStr = d.month.toString().padLeft(2, '0');
    return '$dayStr-$monthStr-${d.year}';
  }

  String _getDayName(DateTime d) {
    return Course.dayNamesArabic[d.weekday] ?? '';
  }

  Future<void> _pickDate(BuildContext context) async {
    final now = DateTime.now();
    final firstDate = DateTime(now.year - 2, 1, 1);
    final lastDate = DateTime(now.year + 2, 12, 31);

    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: firstDate,
      lastDate: lastDate,
      locale: const Locale('ar'),
      // لا يسمح باختيار سوى أيام دوام الدورة المحددة فقط
      selectableDayPredicate: (date) {
        if (course == null || course!.workingDays.isEmpty) return true;
        return course!.isWorkingDay(date);
      },
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryTeal,
              onPrimary: Colors.white,
              onSurface: AppColors.textDark,
            ),
          ),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: child!,
          ),
        );
      },
    );

    if (picked != null) {
      onDateChanged(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWorkingDay = course?.isWorkingDay(selectedDate) ?? true;
    final dayName = _getDayName(selectedDate);
    final formattedDate = _formatDate(selectedDate);

    final isToday = selectedDate.year == DateTime.now().year &&
        selectedDate.month == DateTime.now().month &&
        selectedDate.day == DateTime.now().day;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isWorkingDay
              ? AppColors.primaryTeal.withValues(alpha: 0.25)
              : Colors.amber.shade300,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // Course Info & Working Days Header
          if (course != null) ...[
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: course!.isSummer
                        ? const Color(0xFFFEF3D6)
                        : const Color(0xFFD7F5F0),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        course!.isSummer ? Icons.wb_sunny_rounded : Icons.ac_unit_rounded,
                        size: 13,
                        color: course!.isSummer ? const Color(0xFFC89336) : const Color(0xFF00796B),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        course!.name,
                        style: GoogleFonts.cairo(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: course!.isSummer ? const Color(0xFFC89336) : const Color(0xFF00796B),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'أيام الدوام: ${course!.workingDaysArabic}',
                    style: GoogleFonts.cairo(
                      fontSize: 11,
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const Divider(height: 16),
          ],

          // Date Navigator Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Next Working Day Button (اليوم التالي في RTL)
              InkWell(
                onTap: () => onDateChanged(_getNextWorkingDay(selectedDate)),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.arrow_back_ios_new_rounded, size: 13, color: AppColors.primaryTeal),
                      const SizedBox(width: 4),
                      Text(
                        'اليوم التالي',
                        style: GoogleFonts.cairo(
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryTeal,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Current Selected Date (Clickable for Calendar)
              InkWell(
                onTap: () => _pickDate(context),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primaryTeal.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_month_rounded, size: 18, color: AppColors.primaryTeal),
                      const SizedBox(width: 6),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                dayName,
                                style: GoogleFonts.cairo(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryTeal,
                                ),
                              ),
                              if (isToday) ...[
                                const SizedBox(width: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFC89336),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    'اليوم',
                                    style: GoogleFonts.cairo(
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          Text(
                            formattedDate,
                            style: GoogleFonts.cairo(
                              fontSize: 11,
                              color: AppColors.textMuted,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Previous Working Day Button (اليوم السابق في RTL)
              InkWell(
                onTap: () => onDateChanged(_getPrevWorkingDay(selectedDate)),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Text(
                        'اليوم السابق',
                        style: GoogleFonts.cairo(
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryTeal,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_forward_ios_rounded, size: 13, color: AppColors.primaryTeal),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Working Day Verification Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isWorkingDay
                  ? const Color(0xFFD7F5F0)
                  : const Color(0xFFFFF3E0),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isWorkingDay ? Icons.check_circle_rounded : Icons.info_outline_rounded,
                  size: 13,
                  color: isWorkingDay ? const Color(0xFF00796B) : Colors.orange.shade800,
                ),
                const SizedBox(width: 5),
                Text(
                  isWorkingDay
                      ? 'يوم دوام رسمي مسجل بالدورة الحالية'
                      : 'تنبيه: هذا اليوم ليس ضمن أيام الدوام الرسمية لهذه الدورة',
                  style: GoogleFonts.cairo(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isWorkingDay ? const Color(0xFF00796B) : Colors.orange.shade900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
