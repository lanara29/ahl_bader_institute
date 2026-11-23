import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';
import '../../../models/course.dart';
import '../../../models/student.dart';

class CourseCard extends StatefulWidget {
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
  State<CourseCard> createState() => _CourseCardState();
}

class _CourseCardState extends State<CourseCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final isSummer = widget.course.isSummer;
    final primaryColor = isSummer ? const Color(0xFFC89336) : const Color(0xFF00796B);
    final lightBg = isSummer ? const Color(0xFFFEF3D6) : const Color(0xFFD7F5F0);

    // Calculate total collected revenue for this course
    double totalCollected = 0.0;
    for (final s in widget.studentsInCourse) {
      totalCollected += s.paidAmount;
    }

    final formattedFee = widget.course.fee % 1 == 0
        ? widget.course.fee.toInt().toString()
        : widget.course.fee.toString();
    final formattedCollected = totalCollected % 1 == 0
        ? totalCollected.toInt().toString()
        : totalCollected.toStringAsFixed(0);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: widget.course.isActive ? const Color(0xFF00897B) : Colors.grey.shade200,
          width: widget.course.isActive ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: widget.course.isActive
                ? const Color(0xFF00897B).withValues(alpha: 0.09)
                : Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Row 1: Icon + Course Name + (Edit & Delete Buttons)
                Row(
                  children: [
                    // Season Icon
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: lightBg,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        isSummer ? Icons.wb_sunny_rounded : Icons.ac_unit_rounded,
                        color: primaryColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Course Name
                    Expanded(
                      child: Text(
                        widget.course.name,
                        style: GoogleFonts.cairo(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryTeal,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    // Action Buttons: Edit & Delete
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: widget.onEdit,
                          icon: const Icon(Icons.edit_outlined, size: 20, color: Color(0xFF00796B)),
                          tooltip: 'تعديل الدورة',
                          padding: const EdgeInsets.all(6),
                          constraints: const BoxConstraints(),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: widget.onDelete,
                          icon: Icon(Icons.delete_outline_rounded, size: 20, color: Colors.red.shade700),
                          tooltip: 'حذف الدورة',
                          padding: const EdgeInsets.all(6),
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Row 2: "نشطة حالياً" if active, or season/year subtitle + expand toggle
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (widget.course.isActive)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.green.shade600, width: 1),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 7,
                              height: 7,
                              decoration: BoxDecoration(
                                color: Colors.green.shade600,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'نشطة حالياً',
                              style: GoogleFonts.cairo(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade800,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      Text(
                        '${widget.course.seasonArabic} - سنة ${widget.course.year}',
                        style: GoogleFonts.cairo(
                          fontSize: 12,
                          color: AppColors.textMuted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                    // Expand / Collapse Indicator
                    Row(
                      children: [
                        Text(
                          _isExpanded ? 'إخفاء التفاصيل' : 'عرض التفاصيل',
                          style: GoogleFonts.cairo(
                            fontSize: 11.5,
                            color: AppColors.primaryTeal,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          _isExpanded
                              ? Icons.keyboard_arrow_up_rounded
                              : Icons.keyboard_arrow_down_rounded,
                          size: 20,
                          color: AppColors.primaryTeal,
                        ),
                      ],
                    ),
                  ],
                ),

                // Expanded Section: Details and actions
                if (_isExpanded) ...[
                  const SizedBox(height: 14),
                  const Divider(height: 1),
                  const SizedBox(height: 14),

                  // Working Days
                  _infoRow(
                    icon: Icons.event_available_rounded,
                    label: 'أيام الدوام والتفقد',
                    value: widget.course.workingDaysArabic,
                    iconColor: const Color(0xFFC89336),
                  ),
                  const SizedBox(height: 10),

                  // Dates (Start / End)
                  if (widget.course.startDate.isNotEmpty || widget.course.endDate.isNotEmpty) ...[
                    _infoRow(
                      icon: Icons.calendar_month_outlined,
                      label: 'فترة الدورة',
                      value: '${widget.course.startDate} ⬅️ ${widget.course.endDate}',
                      iconColor: AppColors.primaryTeal,
                    ),
                    const SizedBox(height: 10),
                  ],

                  // Enrolled Students and Fee
                  Row(
                    children: [
                      Expanded(
                        child: _infoRow(
                          icon: Icons.groups_rounded,
                          label: 'الطلاب المسجلين',
                          value: '${widget.studentsInCourse.length} طالب',
                          iconColor: const Color(0xFF00796B),
                          isBold: true,
                        ),
                      ),
                      if (widget.course.fee > 0)
                        Expanded(
                          child: _infoRow(
                            icon: Icons.payments_outlined,
                            label: 'الرسم المطلوب',
                            value: '$formattedFee ل.س',
                            iconColor: const Color(0xFFC89336),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Collected revenue (if any)
                  if (totalCollected > 0) ...[
                    _infoRow(
                      icon: Icons.account_balance_wallet_outlined,
                      label: 'المبالغ المحصّلة',
                      value: '$formattedCollected ل.س',
                      iconColor: Colors.green.shade700,
                    ),
                    const SizedBox(height: 10),
                  ],

                  // Notes (if any)
                  if (widget.course.notes.isNotEmpty) ...[
                    _infoRow(
                      icon: Icons.notes_rounded,
                      label: 'ملاحظات',
                      value: widget.course.notes,
                      iconColor: AppColors.textMuted,
                    ),
                    const SizedBox(height: 10),
                  ],

                  const SizedBox(height: 6),

                  // Bottom Action Buttons: Set as Active & View Students
                  Row(
                    children: [
                      if (!widget.course.isActive)
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF00796B),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 9),
                              elevation: 0,
                            ),
                            onPressed: widget.onSetActive,
                            icon: const Icon(Icons.check_circle_outline_rounded, size: 16, color: Colors.white),
                            label: Text(
                              'تعيين كدورة نشطة',
                              style: GoogleFonts.cairo(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      if (!widget.course.isActive) const SizedBox(width: 10),

                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.primaryTeal),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 9),
                          ),
                          onPressed: widget.onViewStudents,
                          icon: const Icon(Icons.visibility_outlined, size: 15, color: AppColors.primaryTeal),
                          label: Text(
                            'عرض الطلاب (${widget.studentsInCourse.length})',
                            style: GoogleFonts.cairo(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryTeal,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoRow({
    required IconData icon,
    required String label,
    required String value,
    required Color iconColor,
    bool isBold = false,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: iconColor),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: GoogleFonts.cairo(
            fontSize: 12,
            color: AppColors.textMuted,
            fontWeight: FontWeight.w600,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.cairo(
              fontSize: 12,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: AppColors.textDark,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
