import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../theme/app_theme.dart';
import '../../models/course.dart';
import '../../models/student.dart';
import '../../db/database_helper.dart';
import '../home_screen.dart';
import '../login_screen.dart';
import 'courses_screen.dart';
import 'widgets/add_edit_course_dialog.dart';

class SelectCourseScreen extends StatefulWidget {
  final bool isChangingCourse;

  const SelectCourseScreen({super.key, this.isChangingCourse = false});

  @override
  State<SelectCourseScreen> createState() => _SelectCourseScreenState();
}

class _SelectCourseScreenState extends State<SelectCourseScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Course> _courses = [];
  List<Student> _allStudents = [];
  bool _isLoading = true;
  String? _selectedCourseId;
  final Map<String, bool> _expandedCourses = {};

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
      final activeCourse = await _dbHelper.getActiveCourse();

      if (mounted) {
        setState(() {
          _courses = courses;
          _allStudents = students;
          _selectedCourseId = activeCourse?.id?.toString();
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

  int _getStudentCountForCourse(Course course) {
    return _allStudents.where((s) => s.matchesCourse(course)).length;
  }

  Future<void> _selectCourseAndProceed(Course course) async {
    try {
      await _dbHelper.setActiveCourse(course.id);

      if (!mounted) return;

      if (widget.isChangingCourse) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'تم تغيير الدورة الحالية إلى: ${course.name} بنجاح ✅',
              style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
            ),
            backgroundColor: const Color(0xFF00796B),
            duration: const Duration(seconds: 2),
          ),
        );
        Navigator.pop(context, true);
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل تحديد الدورة: $e', style: GoogleFonts.cairo()),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    }
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'تسجيل الخروج',
            style: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: AppColors.primaryTeal),
          ),
          content: Text(
            'هل أنت متأكد من رغبتك في تسجيل الخروج؟',
            style: GoogleFonts.cairo(color: AppColors.textDark),
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
              onPressed: () async {
                Navigator.pop(ctx);
                await FirebaseAuth.instance.signOut();
                if (mounted) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                }
              },
              child: Text(
                'تأكيد',
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
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF3FAF9),
        body: SafeArea(
          top: false,
          child: Column(
            children: [
              // Header Section
              _buildHeaderSection(),

              // Body Content
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: AppColors.primaryTeal),
                      )
                    : _courses.isEmpty
                        ? _buildEmptyState()
                        : _buildCoursesList(),
              ),

              // Bottom Management Toolbar
              _buildBottomToolbar(),
            ],
          ),
        ),
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
          colors: [
            Color(0xFF005045),
            Color(0xFF00796B),
          ],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      padding: const EdgeInsets.only(top: 48, bottom: 22, left: 18, right: 18),
      child: Column(
        children: [
          // Top Navigation Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Back Button (if changing) or Star Brand
              widget.isChangingCourse
                  ? IconButton(
                      icon: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 20),
                      onPressed: () => Navigator.pop(context),
                      tooltip: 'العودة للرئيسية',
                    )
                  : Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.star_rounded,
                            color: Color(0xFFE8C882),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'ساداتنا أهل بدر الكرام',
                          style: GoogleFonts.cairo(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),

              // Logout or Action
              if (!widget.isChangingCourse)
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
                  ),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    icon: const Icon(Icons.logout_rounded, color: Colors.white, size: 19),
                    onPressed: _handleLogout,
                    tooltip: 'تسجيل الخروج',
                  ),
                ),
            ],
          ),

          const SizedBox(height: 12),

          // Title & Description
          Text(
            widget.isChangingCourse ? 'تغيير الدورة الحالية' : 'اختر الدورة للمتابعة',
            style: GoogleFonts.cairo(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'ستظهر بيانات وإحصائيات الطلاب والحضور وفقاً للدورة التي تختارها',
            textAlign: TextAlign.center,
            style: GoogleFonts.cairo(
              fontSize: 12.5,
              color: const Color(0xFFE8C882),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoursesList() {
    return RefreshIndicator(
      color: AppColors.primaryTeal,
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        itemCount: _courses.length,
        itemBuilder: (context, index) {
          final course = _courses[index];
          final isSelected = _selectedCourseId == course.id.toString() || course.isActive;

          // إذا كانت الشاشة خارج الصفحة الرئيسية (عند تسجيل الدخول): يظهر الاسم والزر فقط
          if (!widget.isChangingCourse) {
            return _buildSimpleEntryCard(course, isSelected);
          }

          // إذا كانت الشاشة من داخل الصفحة الرئيسية (لتغيير الدورة): يظهر الكارد مع سهم التوسيع الجانبي
          return _buildExpandableCourseCard(course, isSelected);
        },
      ),
    );
  }

  /// الكارد البسيط للواجهة التي قبل الرئيسية: اسم الدورة + زر متابعة الدخول فقط
  Widget _buildSimpleEntryCard(Course course, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? const Color(0xFF00796B) : Colors.grey.shade200,
          width: isSelected ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isSelected
                ? const Color(0xFF00796B).withValues(alpha: 0.10)
                : Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row: أيقونة الموسم + اسم الدورة + شارة نشطة حالياً
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: course.isSummer ? const Color(0xFFFEF3D6) : const Color(0xFFD7F5F0),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  course.isSummer ? Icons.wb_sunny_rounded : Icons.ac_unit_rounded,
                  color: course.isSummer ? const Color(0xFFC89336) : const Color(0xFF00796B),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.name,
                      style: GoogleFonts.cairo(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryTeal,
                      ),
                    ),
                    Text(
                      '${course.isSummer ? "دورة صيفية" : "دورة شتوية"} - سنة ${course.year}',
                      style: GoogleFonts.cairo(fontSize: 11.5, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.shade600),
                  ),
                  child: Text(
                    'نشطة حالياً',
                    style: GoogleFonts.cairo(
                      fontSize: 10.5,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade800,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 14),

          // زر متابعة الدخول بهذه الدورة
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: isSelected ? const Color(0xFF00796B) : const Color(0xFF016574),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              onPressed: () => _selectCourseAndProceed(course),
              icon: const Icon(Icons.login_rounded, size: 18, color: Colors.white),
              label: Text(
                'متابعة الدخول بهذه الدورة',
                style: GoogleFonts.cairo(
                  fontSize: 13.5,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// الكارد من داخل الصفحة الرئيسية: اسم الدورة + سهم جانبي يفتح باقي التفاصيل
  Widget _buildExpandableCourseCard(Course course, bool isSelected) {
    final cKey = course.id.toString();
    final isExpanded = _expandedCourses[cKey] ?? false;
    final studentCount = _getStudentCountForCourse(course);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? const Color(0xFF00796B) : Colors.grey.shade200,
          width: isSelected ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isSelected
                ? const Color(0xFF00796B).withValues(alpha: 0.12)
                : Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: الأيقونة + اسم الدورة + سهم التوسيع الجانبي
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: course.isSummer ? const Color(0xFFFEF3D6) : const Color(0xFFD7F5F0),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  course.isSummer ? Icons.wb_sunny_rounded : Icons.ac_unit_rounded,
                  color: course.isSummer ? const Color(0xFFC89336) : const Color(0xFF00796B),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.name,
                      style: GoogleFonts.cairo(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryTeal,
                      ),
                    ),
                    Text(
                      '${course.isSummer ? "دورة صيفية" : "دورة شتوية"} - سنة ${course.year}',
                      style: GoogleFonts.cairo(fontSize: 11.5, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),

              // السهم الجانبي لفتح وإخفاء التفاصيل
              InkWell(
                onTap: () {
                  setState(() {
                    _expandedCourses[cKey] = !isExpanded;
                  });
                },
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3FAF9),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        isExpanded ? 'إخفاء' : 'تفاصيل',
                        style: GoogleFonts.cairo(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryTeal,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                        color: AppColors.primaryTeal,
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // تفاصيل الدورة الموسعة عند الضغط على السهم
          if (isExpanded) ...[
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),

            _detailRow(Icons.event_available_rounded, 'أيام الدوام', course.workingDaysArabic, const Color(0xFFC89336)),
            const SizedBox(height: 8),

            if (course.startDate.isNotEmpty || course.endDate.isNotEmpty) ...[
              _detailRow(Icons.calendar_month_outlined, 'المدة', '${course.startDate} ⬅️ ${course.endDate}', AppColors.primaryTeal),
              const SizedBox(height: 8),
            ],

            Row(
              children: [
                Expanded(
                  child: _detailRow(Icons.groups_rounded, 'الطلاب المسجلين', '$studentCount طالب', const Color(0xFF00796B), isBold: true),
                ),
                if (course.fee > 0)
                  Expanded(
                    child: _detailRow(Icons.payments_outlined, 'الرسم', '${course.fee % 1 == 0 ? course.fee.toInt() : course.fee} ل.س', const Color(0xFFC89336)),
                  ),
              ],
            ),

            if (course.notes.isNotEmpty) ...[
              const SizedBox(height: 8),
              _detailRow(Icons.notes_rounded, 'ملاحظات', course.notes, AppColors.textMuted),
            ],
          ],

          const SizedBox(height: 14),

          // زر التحديد والعودة للرئيسية
          SizedBox(
            width: double.infinity,
            height: 42,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: isSelected ? const Color(0xFF00796B) : const Color(0xFF016574),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              onPressed: () => _selectCourseAndProceed(course),
              icon: Icon(
                isSelected ? Icons.check_circle_outline_rounded : Icons.swap_horiz_rounded,
                size: 18,
                color: Colors.white,
              ),
              label: Text(
                isSelected ? 'هذه هي الدورة المحددة حالياً' : 'تحديد هذه الدورة والعودة',
                style: GoogleFonts.cairo(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value, Color color, {bool isBold = false}) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
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

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3D6),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(Icons.calendar_month_rounded, size: 40, color: Color(0xFFC89336)),
            ),
            const SizedBox(height: 16),
            Text(
              'لا توجد أي دورات مضافة بعد',
              style: GoogleFonts.cairo(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryTeal,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'قم بإنشاء الدورة الأولى للمعهد (صيفية أو شتوية) للبدء بتسجيل الطلاب والحلقات والتفقد.',
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(fontSize: 13, color: AppColors.textMuted),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryTeal,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              onPressed: () {
                AddEditCourseDialog.show(
                  context: context,
                  onSaved: _loadData,
                );
              },
              icon: const Icon(Icons.add, color: Colors.white),
              label: Text(
                'إضافة دورة جديدة الآن',
                style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomToolbar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, -3),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          // Add Course
          Expanded(
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.primaryTeal),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
              onPressed: () {
                AddEditCourseDialog.show(
                  context: context,
                  onSaved: _loadData,
                );
              },
              icon: const Icon(Icons.add_circle_outline, color: AppColors.primaryTeal, size: 18),
              label: Text(
                'إضافة دورة جديدة',
                style: GoogleFonts.cairo(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppColors.primaryTeal),
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Manage Courses (CoursesScreen)
          Expanded(
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00796B),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 10),
                elevation: 0,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CoursesScreen()),
                ).then((_) => _loadData());
              },
              icon: const Icon(Icons.settings_outlined, color: Colors.white, size: 18),
              label: Text(
                'إدارة كافة الدورات',
                style: GoogleFonts.cairo(fontSize: 12.5, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
