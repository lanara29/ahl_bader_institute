import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';
import '../../../models/teacher.dart';
import '../../../models/course.dart';
import '../../../models/teacher_attendance.dart';
import '../../../db/database_helper.dart';

class MonthlyAttendanceReportDialog extends StatefulWidget {
  final Course? course;
  final List<Teacher> teachers;

  const MonthlyAttendanceReportDialog({
    super.key,
    required this.course,
    required this.teachers,
  });

  static Future<void> show({
    required BuildContext context,
    required Course? course,
    required List<Teacher> teachers,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MonthlyAttendanceReportDialog(
        course: course,
        teachers: teachers,
      ),
    );
  }

  @override
  State<MonthlyAttendanceReportDialog> createState() =>
      _MonthlyAttendanceReportDialogState();
}

class _MonthlyAttendanceReportDialogState
    extends State<MonthlyAttendanceReportDialog> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  late int _selectedMonth;
  late int _selectedYear;
  bool _isLoading = true;
  List<TeacherAttendance> _monthAttendances = [];

  static const List<String> _arabicMonths = [
    'كانون الثاني (1)',
    'شباط (2)',
    'آذار (3)',
    'نيسان (4)',
    'أيار (5)',
    'حزيران (6)',
    'تموز (7)',
    'آب (8)',
    'أيلول (9)',
    'تشرين الأول (10)',
    'تشرين الثاني (11)',
    'كانون الأول (12)',
  ];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedMonth = now.month;
    _selectedYear = now.year;
    _loadMonthData();
  }

  Future<void> _loadMonthData() async {
    setState(() => _isLoading = true);
    if (widget.course?.id == null) {
      setState(() {
        _monthAttendances = [];
        _isLoading = false;
      });
      return;
    }

    final list = await _dbHelper.getAttendanceForMonth(
      courseId: widget.course!.id,
      year: _selectedYear,
      month: _selectedMonth,
    );

    if (mounted) {
      setState(() {
        _monthAttendances = list;
        _isLoading = false;
      });
    }
  }

  Map<String, dynamic> _computeTeacherStats(Teacher teacher) {
    final tIdStr = teacher.id.toString();
    int present = 0;
    int absent = 0;
    int late = 0;
    int excused = 0;

    for (final att in _monthAttendances) {
      final rec = att.records[tIdStr];
      if (rec != null) {
        if (rec.isPresent) present++;
        if (rec.isAbsent) absent++;
        if (rec.isLate) late++;
        if (rec.isExcused) excused++;
      }
    }

    final totalSessions = _monthAttendances.length;
    final attendedSessions = present + late; // Late counts as attendance with delay
    final rate = totalSessions > 0
        ? ((attendedSessions / totalSessions) * 100).round()
        : 100;

    return {
      'present': present,
      'absent': absent,
      'late': late,
      'excused': excused,
      'rate': rate,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          children: [
            // Handle Bar
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),

            // Dialog Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primaryTeal.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.assessment_rounded,
                          color: AppColors.primaryTeal,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'تقرير تفقد الآنسات الشهري',
                            style: GoogleFonts.cairo(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryTeal,
                            ),
                          ),
                          Text(
                            widget.course?.name ?? 'الدورة الحالية',
                            style: GoogleFonts.cairo(
                              fontSize: 11.5,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded, color: AppColors.textMuted),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // Month & Year Selector Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.date_range_rounded, size: 18, color: AppColors.primaryTeal),
                    const SizedBox(width: 8),
                    Text(
                      'الشهر:',
                      style: GoogleFonts.cairo(
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryTeal,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          value: _selectedMonth,
                          isDense: true,
                          style: GoogleFonts.cairo(
                            fontSize: 12.5,
                            color: AppColors.textDark,
                            fontWeight: FontWeight.bold,
                          ),
                          items: List.generate(12, (index) {
                            return DropdownMenuItem<int>(
                              value: index + 1,
                              child: Text(_arabicMonths[index]),
                            );
                          }),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => _selectedMonth = val);
                              _loadMonthData();
                            }
                          },
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.primaryTeal.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '$_selectedYear',
                        style: GoogleFonts.cairo(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryTeal,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Summary Info Badge
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFD7F5F0),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'إجمالي أيام الدوام المسجلة بالشهر:',
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF00796B),
                      ),
                    ),
                    Text(
                      '${_monthAttendances.length} يوم',
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF00796B),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),
            const Divider(height: 1),

            // Teachers List with Monthly Breakdown
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: AppColors.primaryTeal),
                    )
                  : widget.teachers.isEmpty
                      ? Center(
                          child: Text(
                            'لا يوجد آنسات مسجلات',
                            style: GoogleFonts.cairo(color: AppColors.textMuted),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: widget.teachers.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final teacher = widget.teachers[index];
                            final stats = _computeTeacherStats(teacher);
                            final int rate = stats['rate'];

                            Color rateColor = Colors.green.shade700;
                            if (rate < 75) rateColor = Colors.red.shade700;
                            else if (rate < 90) rateColor = Colors.orange.shade800;

                            return Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: Colors.grey.shade200),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.02),
                                    blurRadius: 5,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Teacher Name & Rate
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        teacher.name,
                                        style: GoogleFonts.cairo(
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.textDark,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: rateColor.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          'نسبة الالتزام: $rate%',
                                          style: GoogleFonts.cairo(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: rateColor,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 8),

                                  // Stats Chips
                                  Row(
                                    children: [
                                      _miniStatChip('حاضرة: ${stats['present']}', const Color(0xFF00796B), const Color(0xFFD7F5F0)),
                                      const SizedBox(width: 6),
                                      _miniStatChip('غائبة: ${stats['absent']}', Colors.red.shade700, const Color(0xFFFFEBEE)),
                                      const SizedBox(width: 6),
                                      _miniStatChip('متأخرة: ${stats['late']}', Colors.orange.shade800, const Color(0xFFFFF3E0)),
                                      const SizedBox(width: 6),
                                      _miniStatChip('إجازة: ${stats['excused']}', const Color(0xFF8B5CF6), const Color(0xFFF3E8FF)),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _miniStatChip(String text, Color textColor, Color bgColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(6),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: GoogleFonts.cairo(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ),
    );
  }
}
