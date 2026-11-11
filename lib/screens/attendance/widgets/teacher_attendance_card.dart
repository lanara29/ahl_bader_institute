import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';
import '../../../models/teacher.dart';
import '../../../models/teacher_attendance.dart';

class TeacherAttendanceCard extends StatelessWidget {
  final Teacher teacher;
  final TeacherAttendanceRecord record;
  final ValueChanged<String> onStatusChanged;
  final ValueChanged<String> onNoteChanged;

  const TeacherAttendanceCard({
    super.key,
    required this.teacher,
    required this.record,
    required this.onStatusChanged,
    required this.onNoteChanged,
  });

  void _showNoteDialog(BuildContext context) {
    final noteController = TextEditingController(text: record.note);

    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: Row(
            children: [
              const Icon(Icons.edit_note_rounded, color: AppColors.primaryTeal),
              const SizedBox(width: 8),
              Text(
                'ملاحظة للآنسة ${teacher.name}',
                style: GoogleFonts.cairo(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryTeal,
                ),
              ),
            ],
          ),
          content: TextField(
            controller: noteController,
            maxLines: 3,
            style: GoogleFonts.cairo(fontSize: 13),
            decoration: InputDecoration(
              hintText: 'اكتب سبب الغياب، التأخير، أو تفاصيل الإجازة...',
              hintStyle: GoogleFonts.cairo(fontSize: 12, color: AppColors.inputHint),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
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
              onPressed: () {
                onNoteChanged(noteController.text.trim());
                Navigator.pop(ctx);
              },
              child: Text(
                'حفظ الملاحظة',
                style: GoogleFonts.cairo(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusButton({
    required String label,
    required String statusKey,
    required Color activeColor,
    required Color activeBg,
    required IconData icon,
  }) {
    final isSelected = record.status == statusKey;

    return Expanded(
      child: InkWell(
        onTap: () => onStatusChanged(statusKey),
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 7),
          decoration: BoxDecoration(
            color: isSelected ? activeColor : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? activeColor : Colors.grey.shade300,
              width: isSelected ? 1.5 : 1.0,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: activeColor.withValues(alpha: 0.25),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 15,
                color: isSelected ? Colors.white : Colors.grey.shade600,
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: GoogleFonts.cairo(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  color: isSelected ? Colors.white : AppColors.textDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Color cardBorder;
    switch (record.status) {
      case 'present':
        cardBorder = const Color(0xFF00796B).withValues(alpha: 0.2);
        break;
      case 'absent':
        cardBorder = Colors.red.shade300;
        break;
      case 'late':
        cardBorder = Colors.orange.shade300;
        break;
      case 'excused':
        cardBorder = Colors.purple.shade300;
        break;
      default:
        cardBorder = Colors.grey.shade200;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cardBorder, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Teacher Header Info Row
          Row(
            children: [
              // Avatar
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.primaryTeal.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  teacher.name.isNotEmpty ? teacher.name[0] : 'آ',
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryTeal,
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Teacher Name & Age range
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      teacher.name,
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    if (teacher.ageRange.isNotEmpty)
                      Text(
                        'الفئة: ${teacher.ageRange}',
                        style: GoogleFonts.cairo(
                          fontSize: 11,
                          color: AppColors.textMuted,
                        ),
                      ),
                  ],
                ),
              ),

              // Note Button
              IconButton(
                onPressed: () => _showNoteDialog(context),
                icon: Icon(
                  record.note.isNotEmpty ? Icons.comment_rounded : Icons.add_comment_outlined,
                  size: 20,
                  color: record.note.isNotEmpty ? const Color(0xFFC89336) : Colors.grey.shade400,
                ),
                tooltip: 'إضافة ملاحظة',
              ),
            ],
          ),

          // Note Preview (if any)
          if (record.note.isNotEmpty) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3D6),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFC89336).withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.notes_rounded, size: 13, color: Color(0xFFC89336)),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      record.note,
                      style: GoogleFonts.cairo(
                        fontSize: 11,
                        color: const Color(0xFF8C5D00),
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 10),

          // 4 Status Buttons Row
          Row(
            children: [
              _statusButton(
                label: 'حاضرة',
                statusKey: 'present',
                activeColor: const Color(0xFF00796B),
                activeBg: const Color(0xFFD7F5F0),
                icon: Icons.check_circle_outline_rounded,
              ),
              const SizedBox(width: 6),
              _statusButton(
                label: 'غائبة',
                statusKey: 'absent',
                activeColor: Colors.red.shade700,
                activeBg: const Color(0xFFFFEBEE),
                icon: Icons.cancel_outlined,
              ),
              const SizedBox(width: 6),
              _statusButton(
                label: 'متأخرة',
                statusKey: 'late',
                activeColor: Colors.orange.shade800,
                activeBg: const Color(0xFFFFF3E0),
                icon: Icons.access_time_rounded,
              ),
              const SizedBox(width: 6),
              _statusButton(
                label: 'إجازة',
                statusKey: 'excused',
                activeColor: const Color(0xFF8B5CF6),
                activeBg: const Color(0xFFF3E8FF),
                icon: Icons.beach_access_outlined,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
