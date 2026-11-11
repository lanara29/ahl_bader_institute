import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../models/course.dart';
import '../../models/student.dart';
import '../../db/database_helper.dart';
import '../students_screen.dart';
import 'widgets/add_edit_course_dialog.dart';
import 'widgets/course_card.dart';

class CoursesScreen extends StatefulWidget {
  const CoursesScreen({super.key});

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Course> _courses = [];
  List<Student> _allStudents = [];
  bool _isLoading = true;
  String _selectedFilter = 'all'; // 'all', 'summer', 'winter'

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final courses = await _dbHelper.getCourses();
      final students = await _dbHelper.getAllStudents();
      if (mounted) {
        setState(() {
          _courses = courses;
          _allStudents = students;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ أثناء تحميل الدورات: $e', style: GoogleFonts.cairo()),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    }
  }

  List<Course> _getFilteredCourses() {
    if (_selectedFilter == 'summer') {
      return _courses.where((c) => c.isSummer).toList();
    } else if (_selectedFilter == 'winter') {
      return _courses.where((c) => !c.isSummer).toList();
    }
    return _courses;
  }

  List<Student> _getStudentsForCourse(Course course) {
    return _allStudents.where((s) => s.courseId.toString() == course.id.toString()).toList();
  }

  void _handleSetActiveCourse(Course course) async {
    try {
      await _dbHelper.setActiveCourse(course.id);
      await _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم تعيين "${course.name}" كدورة نشطة للمعهد بنجاح', style: GoogleFonts.cairo()),
            backgroundColor: const Color(0xFF00897B),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل تعيين الدورة النشطة: $e', style: GoogleFonts.cairo()),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    }
  }

  void _confirmDeleteCourse(Course course) {
    final count = _getStudentsForCourse(course).length;

    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'حذف الدورة',
            style: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: Colors.red.shade700),
          ),
          content: Text(
            count > 0
                ? 'تحذير: هذه الدورة مسجل بها ($count) طالب. هل أنت متأكد من حذف دورة (${course.name})؟'
                : 'هل أنت متأكد من حذف دورة (${course.name})؟',
            style: GoogleFonts.cairo(color: AppColors.textDark),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('إلغاء', style: GoogleFonts.cairo(color: AppColors.textMuted)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () async {
                Navigator.pop(ctx);
                await _dbHelper.deleteCourse(course.id);
                _loadData();
              },
              child: Text(
                'تأكيد الحذف',
                style: GoogleFonts.cairo(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredCourses = _getFilteredCourses();
    final activeCourse = _courses.where((c) => c.isActive).firstOrNull;

    return Scaffold(
      backgroundColor: const Color(0xFFF3FAF9),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: SafeArea(
          child: Column(
            children: [
              _buildHeaderSection(),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: AppColors.primaryTeal))
                    : RefreshIndicator(
                        color: AppColors.primaryTeal,
                        onRefresh: _loadData,
                        child: ListView(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
                          children: [
                            // Active Course Banner
                            if (activeCourse != null)
                              _buildActiveCourseBanner(activeCourse)
                            else if (_courses.isNotEmpty)
                              _buildNoActiveCourseWarning(),

                            const SizedBox(height: 12),

                            // Filter Chips (All, Summer, Winter)
                            _buildFilterChips(),

                            const SizedBox(height: 14),

                            // Courses List
                            if (filteredCourses.isEmpty)
                              _buildEmptyState()
                            else
                              ...filteredCourses.map((course) {
                                return CourseCard(
                                  course: course,
                                  studentsInCourse: _getStudentsForCourse(course),
                                  onSetActive: () => _handleSetActiveCourse(course),
                                  onEdit: () {
                                    AddEditCourseDialog.show(
                                      context: context,
                                      course: course,
                                      onSaved: _loadData,
                                    );
                                  },
                                  onDelete: () => _confirmDeleteCourse(course),
                                  onViewStudents: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (_) => const StudentsScreen()),
                                    );
                                  },
                                );
                              }),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primaryTeal,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          'إضافة دورة جديدة',
          style: GoogleFonts.cairo(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        onPressed: () {
          AddEditCourseDialog.show(
            context: context,
            onSaved: _loadData,
          );
        },
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF005045), Color(0xFF00796B)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(26),
          bottomRight: Radius.circular(26),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'نظام الدورات',
                    style: GoogleFonts.cairo(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'فصل الدورات الصيفية والشتوية وسجلاتها',
                    style: GoogleFonts.cairo(
                      fontSize: 11,
                      color: const Color(0xFFE8C882),
                    ),
                  ),
                ],
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            tooltip: 'تحديث',
            onPressed: _loadData,
          ),
        ],
      ),
    );
  }

  Widget _buildActiveCourseBanner(Course active) {
    final feeStr = active.fee % 1 == 0 ? active.fee.toInt().toString() : active.fee.toString();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF00796B), Color(0xFF004D40)],
          begin: Alignment.centerRight,
          end: Alignment.centerLeft,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00796B).withValues(alpha: 0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE8C882), width: 1.2),
            ),
            child: Icon(
              active.isSummer ? Icons.wb_sunny_rounded : Icons.ac_unit_rounded,
              color: const Color(0xFFE8C882),
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'الدورة النشطة الحالية',
                      style: GoogleFonts.cairo(
                        fontSize: 11,
                        color: const Color(0xFFE8C882),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Text(
                  active.name,
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                Text(
                  'رسم التسجيل',
                  style: GoogleFonts.cairo(fontSize: 9.5, color: Colors.white70),
                ),
                Text(
                  feeStr,
                  style: GoogleFonts.cairo(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoActiveCourseWarning() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.orange.shade300),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded, color: Colors.orange.shade800),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'يرجى تحديد دورة نشطة من القائمة أدناه لتكون الدورة الافتراضية للتسجيل',
              style: GoogleFonts.cairo(fontSize: 12, color: Colors.orange.shade900),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Row(
      children: [
        _filterChip(label: 'جميع الدورات (${_courses.length})', value: 'all'),
        const SizedBox(width: 8),
        _filterChip(label: '☀️ الصيفية', value: 'summer'),
        const SizedBox(width: 8),
        _filterChip(label: '❄️ الشتوية', value: 'winter'),
      ],
    );
  }

  Widget _filterChip({required String label, required String value}) {
    final isSelected = _selectedFilter == value;
    return InkWell(
      onTap: () => setState(() => _selectedFilter = value),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryTeal : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppColors.primaryTeal : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.white : AppColors.textDark,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.calendar_month_outlined, size: 50, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(
              'لا توجد دورات مضافة حالياً',
              style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textMuted),
            ),
            const SizedBox(height: 8),
            Text(
              'اضغط على زر "إضافة دورة جديدة" للبدء بتسجيل الدورة الصيفية أو الشتوية',
              style: GoogleFonts.cairo(fontSize: 12, color: AppColors.textMuted),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
