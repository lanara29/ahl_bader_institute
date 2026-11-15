import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';

class CircleStatsRow extends StatelessWidget {
  final int totalTeachers;
  final int totalStudents;
  final int assignedStudents;
  final int unassignedCount;

  const CircleStatsRow({
    super.key,
    required this.totalTeachers,
    required this.totalStudents,
    required this.assignedStudents,
    required this.unassignedCount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _statCard(
            title: 'الحلقات',
            value: '$totalTeachers',
            subtitle: 'آنسة معتمدة',
            icon: Icons.mosque_rounded,
            color: const Color(0xFF00796B),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: _statCard(
            title: 'إجمالي الطلاب',
            value: '$totalStudents',
            subtitle: '$assignedStudents موزعين',
            icon: Icons.groups_rounded,
            color: const Color(0xFFC89336),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: _statCard(
            title: 'متوسط الحلقة',
            value: totalTeachers == 0
                ? '0'
                : (totalStudents / totalTeachers).toStringAsFixed(1),
            subtitle: 'طالب / حلقة',
            icon: Icons.pie_chart_rounded,
            color: const Color(0xFF8B5CF6),
          ),
        ),
      ],
    );
  }

  Widget _statCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 14),
              const SizedBox(width: 3),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    title,
                    maxLines: 1,
                    style: GoogleFonts.cairo(
                      fontSize: 10.5,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: GoogleFonts.cairo(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              subtitle,
              maxLines: 1,
              style: GoogleFonts.cairo(
                fontSize: 9,
                color: AppColors.textMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
