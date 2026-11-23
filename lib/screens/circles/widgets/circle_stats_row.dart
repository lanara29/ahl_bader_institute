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
        // Card 1: الحلقات القرآنية
        Expanded(
          child: _statCard(
            title: 'الحلقات القرآنية',
            value: '$totalTeachers',
            subtitle: 'آنسة مشرفة',
            icon: Icons.mosque_rounded,
            color: const Color(0xFF00796B),
          ),
        ),
        const SizedBox(width: 10),

        // Card 2: إجمالي الطلاب
        Expanded(
          child: _statCard(
            title: 'إجمالي الطلاب',
            value: '$totalStudents',
            subtitle: '$assignedStudents موزعين بالحلقات',
            icon: Icons.groups_rounded,
            color: const Color(0xFFC89336),
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
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.25), width: 1.2),
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
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.cairo(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.cairo(
              fontSize: 10,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
