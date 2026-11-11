import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../models/teacher.dart';
import '../../models/course.dart';
import '../../models/teacher_attendance.dart';
import '../../db/database_helper.dart';
import 'widgets/attendance_date_bar.dart';
import 'widgets/attendance_stats_summary.dart';
import 'widgets/teacher_attendance_card.dart';
import 'widgets/monthly_report_dialog.dart';

class TeacherAttendanceScreen extends StatefulWidget {
  final dynamic initialCourseId;

  const TeacherAttendanceScreen({super.key, this.initialCourseId});

  @override
  State<TeacherAttendanceScreen> createState() =>
      _TeacherAttendanceScreenState();
}

class _TeacherAttendanceScreenState extends State<TeacherAttendanceScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  List<Course> _courses = [];
  Course? _selectedCourse;
  List<Teacher> _allTeachers = [];
  List<Teacher> _filteredTeachers = [];

  late DateTime _selectedDate;
  bool _isLoading = true;
  bool _isSaving = false;
  bool _hasUnsavedChanges = false;

  final TextEditingController _searchController = TextEditingController();
  final Map<String, TeacherAttendanceRecord> _currentRecords = {};
  String _currentNotes = '';

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _searchController.addListener(_onSearchChanged);
    _initializeData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _initializeData() async {
    setState(() => _isLoading = true);

    final courses = await _dbHelper.getCourses();
    final teachers = await _dbHelper.getTeachers();

    final defaultCourse = Course(
      name: 'الدورة العامة',
      season: 'summer',
      year: DateTime.now().year,
      fee: 0.0,
      isActive: true,
    );

    Course? targetCourse;
    if (courses.isEmpty) {
      targetCourse = defaultCourse;
    } else if (widget.initialCourseId != null) {
      targetCourse = courses.firstWhere(
        (c) => c.id.toString() == widget.initialCourseId.toString(),
        orElse: () =>
            courses.firstWhere((c) => c.isActive, orElse: () => courses.first),
      );
    } else {
      // البحث عن الدورة النشطة
      targetCourse = courses.firstWhere(
        (c) => c.isActive,
        orElse: () => courses.first,
      );
    }

    _courses = courses;
    _selectedCourse = targetCourse;
    _allTeachers = teachers;
    _filteredTeachers = teachers;

    // إذا كان اليوم ليس يوم دوام في الدورة، نبحث عن أقرب يوم دوام حالي أو سابق
    if (_selectedCourse != null &&
        !_selectedCourse!.isWorkingDay(_selectedDate)) {
      _selectedDate = _findNearestWorkingDay(_selectedDate, _selectedCourse!);
    }

    await _loadAttendanceForDate(_selectedDate);

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  DateTime _findNearestWorkingDay(DateTime date, Course course) {
    if (course.workingDays.isEmpty) return date;
    // أولاً نبحث للخلف حتى 7 أيام
    var test = date;
    for (int i = 0; i < 7; i++) {
      if (course.isWorkingDay(test)) return test;
      test = test.subtract(const Duration(days: 1));
    }
    return date;
  }

  String _formatDate(DateTime d) {
    final y = d.year.toString();
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '$y-$m-$day';
  }

  Future<void> _loadAttendanceForDate(DateTime date) async {
    final courseId = _selectedCourse?.id;
    if (courseId != null) {
      final dateKey = _formatDate(date);
      final existing = await _dbHelper.getTeacherAttendance(dateKey, courseId);

      _currentRecords.clear();

      if (existing != null) {
        _currentRecords.addAll(existing.records);
        _currentNotes = existing.notes;
      }
    } else {
      _currentRecords.clear();
    }

    // إكمال سجلات أي آنسة لم تُحضر بعد (افتراضياً: حاضرة)
    for (final teacher in _allTeachers) {
      final tIdStr = teacher.id.toString();
      if (!_currentRecords.containsKey(tIdStr)) {
        _currentRecords[tIdStr] = TeacherAttendanceRecord(
          teacherId: teacher.id,
          teacherName: teacher.name,
          status: 'present',
        );
      }
    }

    _hasUnsavedChanges = false;
  }

  void _onDateChanged(DateTime newDate) async {
    if (_hasUnsavedChanges) {
      final shouldSwitch = await _showDiscardConfirmDialog();
      if (!shouldSwitch) return;
    }

    setState(() {
      _selectedDate = newDate;
      _isLoading = true;
    });

    await _loadAttendanceForDate(newDate);

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<bool> _showDiscardConfirmDialog() async {
    final res = await showDialog<bool>(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'تغيير اليوم',
            style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
          ),
          content: Text(
            'هناك تعديلات لم تحفظ بعد على تفقد هذا اليوم. هل تود المتابعة وتجاهل التعديلات؟',
            style: GoogleFonts.cairo(fontSize: 13),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(
                'البقاء والحفظ',
                style: GoogleFonts.cairo(color: AppColors.primaryTeal),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
              ),
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(
                'تجاهل والانتقال',
                style: GoogleFonts.cairo(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
    return res ?? false;
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredTeachers = _allTeachers;
      } else {
        _filteredTeachers = _allTeachers.where((t) {
          return t.name.toLowerCase().contains(query) ||
              t.ageRange.toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  void _markAllPresent() {
    setState(() {
      for (final teacher in _allTeachers) {
        final tIdStr = teacher.id.toString();
        final current = _currentRecords[tIdStr];
        _currentRecords[tIdStr] =
            (current ??
                    TeacherAttendanceRecord(
                      teacherId: teacher.id,
                      teacherName: teacher.name,
                      status: 'present',
                    ))
                .copyWith(status: 'present');
      }
      _hasUnsavedChanges = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'تم تحضير جميع الآنسات كـ حاضرات بنجاح! ⚡',
          style: GoogleFonts.cairo(),
        ),
        duration: const Duration(seconds: 1),
        backgroundColor: const Color(0xFF00796B),
      ),
    );
  }

  void _updateTeacherStatus(Teacher teacher, String newStatus) {
    setState(() {
      final tIdStr = teacher.id.toString();
      final current = _currentRecords[tIdStr];
      _currentRecords[tIdStr] =
          (current ??
                  TeacherAttendanceRecord(
                    teacherId: teacher.id,
                    teacherName: teacher.name,
                    status: newStatus,
                  ))
              .copyWith(status: newStatus);
      _hasUnsavedChanges = true;
    });
  }

  void _updateTeacherNote(Teacher teacher, String note) {
    setState(() {
      final tIdStr = teacher.id.toString();
      final current = _currentRecords[tIdStr];
      _currentRecords[tIdStr] =
          (current ??
                  TeacherAttendanceRecord(
                    teacherId: teacher.id,
                    teacherName: teacher.name,
                    status: 'present',
                  ))
              .copyWith(note: note);
      _hasUnsavedChanges = true;
    });
  }

  Future<void> _saveAttendance() async {
    if (_selectedCourse == null || _selectedCourse?.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'يرجى إنشاء وتفعيل دورة أولاً لحفظ الحضور',
            style: GoogleFonts.cairo(),
          ),
          backgroundColor: Colors.orange.shade800,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final dateKey = _formatDate(_selectedDate);
      final dayName = Course.dayNamesArabic[_selectedDate.weekday] ?? '';

      final attendance = TeacherAttendance(
        id: '${dateKey}_${_selectedCourse!.id}',
        date: dateKey,
        dayName: dayName,
        courseId: _selectedCourse!.id,
        courseName: _selectedCourse!.name,
        records: Map<String, TeacherAttendanceRecord>.from(_currentRecords),
        notes: _currentNotes,
      );

      await _dbHelper.saveTeacherAttendance(attendance);

      if (mounted) {
        setState(() {
          _isSaving = false;
          _hasUnsavedChanges = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'تم حفظ تفقد يوم ($dayName $dateKey) بنجاح! ✅',
              style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
            ),
            backgroundColor: AppColors.primaryTeal,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'حدث خطأ أثناء الحفظ: $e',
              style: GoogleFonts.cairo(),
            ),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final presentCount = _currentRecords.values
        .where((r) => r.isPresent)
        .length;
    final absentCount = _currentRecords.values.where((r) => r.isAbsent).length;
    final lateCount = _currentRecords.values.where((r) => r.isLate).length;
    final excusedCount = _currentRecords.values
        .where((r) => r.isExcused)
        .length;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.creamBackground,
        appBar: AppBar(
          backgroundColor: AppColors.primaryTeal,
          elevation: 0,
          title: Text(
            'تفقد الآنسات',
            style: GoogleFonts.cairo(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          actions: [
            // Monthly Report Action
            IconButton(
              icon: const Icon(
                Icons.assessment_rounded,
                color: Color(0xFFE8C882),
              ),
              tooltip: 'التقرير الشهري',
              onPressed: () {
                MonthlyAttendanceReportDialog.show(
                  context: context,
                  course: _selectedCourse,
                  teachers: _allTeachers,
                );
              },
            ),
          ],
        ),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primaryTeal),
              )
            : Column(
                children: [
                  // Smart Date Bar (Respecting Course Working Days)
                  AttendanceDateBar(
                    selectedDate: _selectedDate,
                    course: _selectedCourse,
                    onDateChanged: _onDateChanged,
                  ),

                  // Quick Stats Summary & Mark All Button
                  AttendanceStatsSummary(
                    presentCount: presentCount,
                    absentCount: absentCount,
                    lateCount: lateCount,
                    excusedCount: excusedCount,
                    totalCount: _allTeachers.length,
                    onMarkAllPresent: _markAllPresent,
                  ),

                  // Search Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: TextField(
                        controller: _searchController,
                        style: GoogleFonts.cairo(fontSize: 13),
                        decoration: InputDecoration(
                          hintText: 'بحث باسم الآنسة...',
                          hintStyle: GoogleFonts.cairo(
                            fontSize: 12,
                            color: AppColors.inputHint,
                          ),
                          prefixIcon: const Icon(
                            Icons.search_rounded,
                            color: AppColors.primaryTeal,
                            size: 20,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 10,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Teachers Attendance List
                  Expanded(
                    child: _filteredTeachers.isEmpty
                        ? Center(
                            child: Text(
                              'لا توجد آنسات مطابقة',
                              style: GoogleFonts.cairo(
                                color: AppColors.textMuted,
                              ),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.only(top: 4, bottom: 80),
                            itemCount: _filteredTeachers.length,
                            itemBuilder: (context, index) {
                              final teacher = _filteredTeachers[index];
                              final tIdStr = teacher.id.toString();
                              final record =
                                  _currentRecords[tIdStr] ??
                                  TeacherAttendanceRecord(
                                    teacherId: teacher.id,
                                    teacherName: teacher.name,
                                    status: 'present',
                                  );

                              return TeacherAttendanceCard(
                                teacher: teacher,
                                record: record,
                                onStatusChanged: (newStatus) =>
                                    _updateTeacherStatus(teacher, newStatus),
                                onNoteChanged: (note) =>
                                    _updateTeacherNote(teacher, note),
                              );
                            },
                          ),
                  ),
                ],
              ),

        // Bottom Persistent Save Bar
        bottomNavigationBar: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 10,
                offset: const Offset(0, -3),
              ),
            ],
          ),
          child: SafeArea(
            child: Row(
              children: [
                if (_hasUnsavedChanges) ...[
                  Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: Colors.orange,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'يوجد تعديلات غير محفوظة',
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange.shade800,
                    ),
                  ),
                  const Spacer(),
                ] else ...[
                  const Spacer(),
                ],
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryTeal,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  onPressed: _isSaving ? null : _saveAttendance,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.check_rounded, color: Colors.white),
                  label: Text(
                    _isSaving ? 'جارٍ الحفظ...' : 'حفظ تفقد اليوم',
                    style: GoogleFonts.cairo(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
