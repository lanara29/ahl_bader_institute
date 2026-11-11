import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';

class AttendanceStatsSummary extends StatelessWidget {
  final int presentCount;
  final int absentCount;
  final int lateCount;
  final int excusedCount;
  final int totalCount;
  final VoidCallback onMarkAllPresent;

  const AttendanceStatsSummary({
    super.key,
    required this.presentCount,
    required this.absentCount,
    required this.lateCount,
    required this.excusedCount,
    required this.totalCount,
    required this.onMarkAllPresent,
  });

  Widget _statBadge({
    required String label,
    required int count,
    required Color color,
    required Color bgColor,
    required IconData icon,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 14, color: color),
                const SizedBox(width: 4),
                Text(
                  '$count',
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            Text(
              label,
              style: GoogleFonts.cairo(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Stat Badges Row
          Row(
            children: [
              _statBadge(
                label: 'حاضرة',
                count: presentCount,
                color: const Color(0xFF00796B),
                bgColor: const Color(0xFFD7F5F0),
                icon: Icons.check_circle_rounded,
              ),
              const SizedBox(width: 6),
              _statBadge(
                label: 'غائبة',
                count: absentCount,
                color: Colors.red.shade700,
                bgColor: const Color(0xFFFFEBEE),
                icon: Icons.cancel_rounded,
              ),
              const SizedBox(width: 6),
              _statBadge(
                label: 'متأخرة',
                count: lateCount,
                color: Colors.orange.shade800,
                bgColor: const Color(0xFFFFF3E0),
                icon: Icons.access_time_filled_rounded,
              ),
              const SizedBox(width: 6),
              _statBadge(
                label: 'إجازة',
                count: excusedCount,
                color: const Color(0xFF8B5CF6),
                bgColor: const Color(0xFFF3E8FF),
                icon: Icons.beach_access_rounded,
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Quick Action Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'إجمالي الآنسات: $totalCount',
                style: GoogleFonts.cairo(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              InkWell(
                onTap: onMarkAllPresent,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00796B),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.flash_on_rounded, size: 14, color: Colors.white),
                      const SizedBox(width: 4),
                      Text(
                        'تحضير الكل كـ حاضرات',
                        style: GoogleFonts.cairo(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
