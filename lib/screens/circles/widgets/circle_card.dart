import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';
import '../../../models/student.dart';
import '../../../models/teacher.dart';

class CircleCard extends StatelessWidget {
  final Teacher teacher;
  final List<Student> students;
  final bool isExpanded;
  final String searchQuery;
  final VoidCallback onToggle;
  final void Function(Student) onShowDetails;
  final void Function(Student) onTransfer;
  final void Function(Student) onEdit;
  final VoidCallback onAddStudent;

  const CircleCard({
    super.key,
    required this.teacher,
    required this.students,
    required this.isExpanded,
    required this.searchQuery,
    required this.onToggle,
    required this.onShowDetails,
    required this.onTransfer,
    required this.onEdit,
    required this.onAddStudent,
  });

  void _copyToClipboard(BuildContext context, String text, String label) {
    if (text.isEmpty) return;
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'تم نسخ $label: $text',
          style: GoogleFonts.cairo(color: Colors.white),
        ),
        backgroundColor: AppColors.primaryTeal,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final query = searchQuery.trim().toLowerCase();
    final displayStudents = query.isEmpty
        ? students
        : students.where((s) {
            final fullName = '${s.name} ${s.surname} ${s.fatherName}'.toLowerCase();
            return fullName.contains(query) || s.mobile.contains(query);
          }).toList();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isExpanded ? AppColors.primaryTeal.withValues(alpha: 0.4) : Colors.grey.shade200,
          width: isExpanded ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // Teacher / Circle Header
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(18),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD7F5F0),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.menu_book_rounded,
                      color: Color(0xFF00796B),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'حلقة الآنسة ${teacher.name}',
                          style: GoogleFonts.cairo(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryTeal,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            if (teacher.ageRange.isNotEmpty) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFEF3D6),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  teacher.ageRange,
                                  style: GoogleFonts.cairo(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFFC89336),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                            ],
                            if (teacher.phone.isNotEmpty)
                              InkWell(
                                onTap: () => _copyToClipboard(context, teacher.phone, 'رقم الآنسة'),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.phone_outlined, size: 12, color: AppColors.textMuted),
                                    const SizedBox(width: 3),
                                    Text(
                                      teacher.phone,
                                      style: GoogleFonts.cairo(
                                        fontSize: 11,
                                        color: AppColors.textMuted,
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
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: students.isEmpty
                              ? Colors.grey.shade100
                              : const Color(0xFFD7F5F0),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: students.isEmpty
                                ? Colors.grey.shade300
                                : const Color(0xFF00796B).withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          '${students.length} طالب',
                          style: GoogleFonts.cairo(
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                            color: students.isEmpty
                                ? AppColors.textMuted
                                : const Color(0xFF00796B),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(
                        isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                        color: AppColors.primaryTeal,
                        size: 22,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Students List inside Circle
          if (isExpanded) ...[
            const Divider(height: 1, thickness: 1, color: Color(0xFFEFEFEF)),
            if (students.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                child: Column(
                  children: [
                    Icon(Icons.person_outline_rounded, size: 36, color: Colors.grey.shade400),
                    const SizedBox(height: 8),
                    Text(
                      'لا يوجد طلاب مسجلون في هذه الحلقة حالياً',
                      style: GoogleFonts.cairo(
                        fontSize: 13,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.primaryTeal),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: onAddStudent,
                      icon: const Icon(Icons.add, size: 16, color: AppColors.primaryTeal),
                      label: Text(
                        'إضافة طالب للحلقة',
                        style: GoogleFonts.cairo(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryTeal,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else
              Container(
                color: const Color(0xFFFAFDFA),
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                child: Column(
                  children: displayStudents.asMap().entries.map((entry) {
                    final index = entry.key;
                    final student = entry.value;

                    return Container(
                      margin: const EdgeInsets.only(top: 8),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE6F2F4),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '${index + 1}',
                              style: GoogleFonts.cairo(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryTeal,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: InkWell(
                              onTap: () => onShowDetails(student),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${student.name} ${student.surname}',
                                    style: GoogleFonts.cairo(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textDark,
                                    ),
                                  ),
                                  Text(
                                    'الأب: ${student.fatherName.isEmpty ? '-' : student.fatherName}${student.grade.isNotEmpty ? ' • ${student.grade}' : ''}',
                                    style: GoogleFonts.cairo(
                                      fontSize: 11,
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (student.mobile.isNotEmpty || student.parentMobile.isNotEmpty)
                                IconButton(
                                  icon: const Icon(Icons.phone_outlined, size: 18, color: Color(0xFF00796B)),
                                  tooltip: 'نسخ رقم الهاتف',
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                  onPressed: () {
                                    final phone = student.mobile.isNotEmpty
                                        ? student.mobile
                                        : student.parentMobile;
                                    _copyToClipboard(context, phone, 'رقم الطالب / ولي الأمر');
                                  },
                                ),
                              IconButton(
                                icon: const Icon(Icons.swap_horiz_rounded, size: 20, color: Color(0xFFC89336)),
                                tooltip: 'نقل إلى حلقة أخرى',
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                onPressed: () => onTransfer(student),
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.primaryTeal),
                                tooltip: 'تعديل بيانات الطالب',
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                onPressed: () => onEdit(student),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
          ],
        ],
      ),
    );
  }
}
