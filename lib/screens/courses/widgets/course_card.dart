import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';
import '../../../models/course.dart';
import '../../../models/student.dart';

class CourseCard extends StatelessWidget {
  final Course course;
  final List<Student> studentsInCourse;
  final VoidCallback onSetActive;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onViewStudents;

  const CourseCard({
    super.key,
    required this.course,
    required this.studentsInCourse,
    required this.onSetActive,
    required this.onEdit,
    required this.onDelete,
    required this.onViewStudents,
  });

  @override
  Widget build(BuildContext context) {
    final isSummer = course.isSummer;
    final primaryColor = isSummer ? const Color(0xFFC89336) : const Color(0xFF00796B);
    final lightBg = isSummer ? const Color(0xFFFEF3D6) : const Color(0xFFD7F5F0);

    // Calculate total collected revenue and total required for this course
    double totalCollected = 0.0;
    for (final s in studentsInCourse) {
      totalCollected += s.paidAmount;
    }

    final formattedFee = course.fee % 1 == 0 ? course.fee.toInt().toString() : course.fee.toString();
    final formattedCollected = totalCollected % 1 == 0 ? totalCollected.toInt().toString() : totalCollected.toStringAsFixed(0);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: course.isActive ? const Color(0xFF00897B) : Colors.grey.shade200,
          width: course.isActive ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: course.isActive
                ? const Color(0xFF00897B).withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header Row
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Season Icon Box
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: lightBg,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    isSummer ? Icons.wb_sunny_rounded : Icons.ac_unit_rounded,
                    color: primaryColor,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 12),

                // Title & Badges
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              course.name,
                              style: GoogleFonts.cairo(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryTeal,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (course.isActive) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8F5E9),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.green.shade600, width: 1),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: Colors.green.shade600,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'نشطة حالياً',
                                    style: GoogleFonts.cairo(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green.shade800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),

                      // Season & Year & Fee Badge
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: lightBg,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              course.seasonArabic,
                              style: GoogleFonts.cairo(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE0F2F1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.payments_outlined, size: 12, color: Color(0xFF00796B)),
                                const SizedBox(width: 4),
                                Text(
                                  'الرسم: $formattedFee',
                                  style: GoogleFonts.cairo(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF00796B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade300, width: 0.8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.event_repeat_rounded, size: 12, color: AppColors.primaryTeal),
                                const SizedBox(width: 4),
                                Text(
                                  'الدوام: ${course.workingDaysArabic}',
                                  style: GoogleFonts.cairo(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textDark,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Edit & Delete Actions
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      onTap: onEdit,
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: const Color(0xFFD7F5F0),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.edit_outlined, size: 16, color: Color(0xFF00796B)),
                      ),
                    ),
                    const SizedBox(width: 6),
                    InkWell(
                      onTap: onDelete,
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFEBEE),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.delete_outline_rounded, size: 16, color: Colors.red.shade700),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Stats Banner (Students count + Revenue collected)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFFAFCFA),
              border: Border.symmetric(
                horizontal: BorderSide(color: Colors.grey.shade200, width: 1),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const Icon(Icons.groups_rounded, size: 16, color: AppColors.primaryTeal),
                      const SizedBox(width: 6),
                      Text(
                        'الطلاب المسجلين: ',
                        style: GoogleFonts.cairo(fontSize: 11.5, color: AppColors.textMuted),
                      ),
                      Text(
                        '${studentsInCourse.length}',
                        style: GoogleFonts.cairo(
                          fontSize: 12.5,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryTeal,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      const Icon(Icons.account_balance_wallet_outlined, size: 16, color: Color(0xFFC89336)),
                      const SizedBox(width: 6),
                      Text(
                        'المحصّل: ',
                        style: GoogleFonts.cairo(fontSize: 11.5, color: AppColors.textMuted),
                      ),
                      Text(
                        formattedCollected,
                        style: GoogleFonts.cairo(
                          fontSize: 12.5,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFC89336),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Bottom Action Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Set as Active button (if not already active)
                if (!course.isActive)
                  TextButton.icon(
                    onPressed: onSetActive,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    ),
                    icon: const Icon(Icons.check_circle_outline_rounded, size: 16, color: Color(0xFF00897B)),
                    label: Text(
                      'تعيين كدورة نشطة للمعهد',
                      style: GoogleFonts.cairo(
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF00897B),
                      ),
                    ),
                  )
                else
                  Row(
                    children: [
                      const Icon(Icons.verified_rounded, size: 16, color: Colors.green),
                      const SizedBox(width: 4),
                      Text(
                        'هذه هي الدورة النشطة الحالية',
                        style: GoogleFonts.cairo(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade800,
                        ),
                      ),
                    ],
                  ),

                // View Students Button
                OutlinedButton.icon(
                  onPressed: onViewStudents,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.primaryTeal),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  ),
                  icon: const Icon(Icons.visibility_outlined, size: 14, color: AppColors.primaryTeal),
                  label: Text(
                    'عرض الطلاب',
                    style: GoogleFonts.cairo(
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryTeal,
                    ),
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
