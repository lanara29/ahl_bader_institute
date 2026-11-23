import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../models/course.dart';
import '../../models/teacher.dart';
import '../../models/student.dart';

class StudentFilterCriteria {
  final String? courseId;
  final String? teacherName;
  final String? paymentStatus; // 'all', 'paid', 'partial', 'unpaid', 'exempt', 'has_remaining'
  final String? grade;
  final String? socialStatus;

  const StudentFilterCriteria({
    this.courseId = 'all',
    this.teacherName = 'كل الأنسات',
    this.paymentStatus = 'all',
    this.grade = 'all',
    this.socialStatus = 'all',
  });

  bool get isDefault =>
      (courseId == null || courseId == 'all') &&
      (teacherName == null || teacherName == 'كل الأنسات') &&
      (paymentStatus == null || paymentStatus == 'all') &&
      (grade == null || grade == 'all') &&
      (socialStatus == null || socialStatus == 'all');

  int get activeFiltersCount {
    int count = 0;
    if (courseId != null && courseId != 'all') count++;
    if (teacherName != null && teacherName != 'كل الأنسات') count++;
    if (paymentStatus != null && paymentStatus != 'all') count++;
    if (grade != null && grade != 'all') count++;
    if (socialStatus != null && socialStatus != 'all') count++;
    return count;
  }

  bool matches(Student student) {
    if (courseId != null && courseId != 'all') {
      if (!student.matchesCourseIdOrName(courseId)) return false;
    }
    if (teacherName != null && teacherName != 'كل الأنسات') {
      if (student.teacherName != teacherName) return false;
    }
    if (paymentStatus != null && paymentStatus != 'all') {
      if (paymentStatus == 'has_remaining') {
        if (student.remainingFee <= 0) return false;
      } else if (student.paymentStatus != paymentStatus) {
        return false;
      }
    }
    if (grade != null && grade != 'all') {
      if (student.grade.trim() != grade!.trim()) return false;
    }
    if (socialStatus != null && socialStatus != 'all') {
      if (student.socialStatus.trim() != socialStatus!.trim()) return false;
    }
    return true;
  }

  StudentFilterCriteria copyWith({
    String? courseId,
    String? teacherName,
    String? paymentStatus,
    String? grade,
    String? socialStatus,
  }) {
    return StudentFilterCriteria(
      courseId: courseId ?? this.courseId,
      teacherName: teacherName ?? this.teacherName,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      grade: grade ?? this.grade,
      socialStatus: socialStatus ?? this.socialStatus,
    );
  }
}

class StudentFilterBottomSheet extends StatefulWidget {
  final StudentFilterCriteria initialCriteria;
  final List<Course> courses;
  final List<Teacher> teachers;
  final List<String> availableGrades;
  final List<String> availableSocialStatuses;
  final ValueChanged<StudentFilterCriteria> onApply;

  const StudentFilterBottomSheet({
    super.key,
    required this.initialCriteria,
    required this.courses,
    required this.teachers,
    required this.availableGrades,
    required this.availableSocialStatuses,
    required this.onApply,
  });

  static Future<void> show({
    required BuildContext context,
    required StudentFilterCriteria initialCriteria,
    required List<Course> courses,
    required List<Teacher> teachers,
    required List<String> availableGrades,
    required List<String> availableSocialStatuses,
    required ValueChanged<StudentFilterCriteria> onApply,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StudentFilterBottomSheet(
        initialCriteria: initialCriteria,
        courses: courses,
        teachers: teachers,
        availableGrades: availableGrades,
        availableSocialStatuses: availableSocialStatuses,
        onApply: onApply,
      ),
    );
  }

  @override
  State<StudentFilterBottomSheet> createState() => _StudentFilterBottomSheetState();
}

class _StudentFilterBottomSheetState extends State<StudentFilterBottomSheet> {
  late String _courseId;
  late String _teacherName;
  late String _paymentStatus;
  late String _grade;
  late String _socialStatus;

  @override
  void initState() {
    super.initState();
    _courseId = widget.initialCriteria.courseId ?? 'all';
    _teacherName = widget.initialCriteria.teacherName ?? 'كل الأنسات';
    _paymentStatus = widget.initialCriteria.paymentStatus ?? 'all';
    _grade = widget.initialCriteria.grade ?? 'all';
    _socialStatus = widget.initialCriteria.socialStatus ?? 'all';
  }

  void _resetFilters() {
    setState(() {
      _courseId = 'all';
      _teacherName = 'كل الأنسات';
      _paymentStatus = 'all';
      _grade = 'all';
      _socialStatus = 'all';
    });
  }

  void _applyFilters() {
    final criteria = StudentFilterCriteria(
      courseId: _courseId,
      teacherName: _teacherName,
      paymentStatus: _paymentStatus,
      grade: _grade,
      socialStatus: _socialStatus,
    );
    widget.onApply(criteria);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Drag handle
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 14),

            // Header Row
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
                          color: const Color(0xFFD7F5F0),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.tune_rounded, color: AppColors.primaryTeal, size: 20),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'تصفية الطلاب المتقدمة',
                        style: GoogleFonts.cairo(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryTeal,
                        ),
                      ),
                    ],
                  ),
                  TextButton.icon(
                    onPressed: _resetFilters,
                    icon: const Icon(Icons.refresh_rounded, size: 16, color: Colors.red),
                    label: Text(
                      'إعادة تعيين',
                      style: GoogleFonts.cairo(
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 20),

            // Filters body
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. الدورة
                    _sectionTitle('الدورة التعليمية', Icons.school_outlined),
                    const SizedBox(height: 8),
                    _buildCourseFilterChips(),

                    const SizedBox(height: 20),

                    // 2. حالة الدفع والرسوم
                    _sectionTitle('حالة الرسوم والدفع', Icons.payments_outlined),
                    const SizedBox(height: 8),
                    _buildPaymentStatusChips(),

                    const SizedBox(height: 20),

                    // 3. الآنسة / الحلقة
                    _sectionTitle('الآنسة المشرفة / الحلقة', Icons.person_outline_rounded),
                    const SizedBox(height: 8),
                    _buildTeacherDropdown(),

                    const SizedBox(height: 20),

                    // 4. مستوى الحفظ / الصف الدراسي
                    if (widget.availableGrades.isNotEmpty) ...[
                      _sectionTitle('المستوى القرآني / الصف', Icons.auto_stories_outlined),
                      const SizedBox(height: 8),
                      _buildGradeChips(),
                      const SizedBox(height: 20),
                    ],

                    // 5. الوضع الاجتماعي
                    if (widget.availableSocialStatuses.isNotEmpty) ...[
                      _sectionTitle('الوضع الاجتماعي / العائلي', Icons.diversity_1_outlined),
                      const SizedBox(height: 8),
                      _buildSocialStatusChips(),
                      const SizedBox(height: 20),
                    ],
                  ],
                ),
              ),
            ),

            // Bottom Action Bar
            Container(
              padding: const EdgeInsets.all(16),
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
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryTeal,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                      ),
                      onPressed: _applyFilters,
                      child: Text(
                        'تطبيق الفلترة',
                        style: GoogleFonts.cairo(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFFC89336)),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.cairo(
            fontSize: 13.5,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryTeal,
          ),
        ),
      ],
    );
  }

  Widget _buildCourseFilterChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _chipItem(
          label: 'جميع الدورات',
          isSelected: _courseId == 'all',
          onTap: () => setState(() => _courseId = 'all'),
        ),
        _chipItem(
          label: '⚠️ طلاب بدون دورة',
          isSelected: _courseId == 'unassigned',
          onTap: () => setState(() => _courseId = 'unassigned'),
        ),
        ...widget.courses.map((course) {
          final isSelected = _courseId == course.id.toString();
          return _chipItem(
            label: '${course.isSummer ? '☀️' : '❄️'} ${course.name}',
            isSelected: isSelected,
            onTap: () => setState(() => _courseId = course.id.toString()),
          );
        }),
      ],
    );
  }

  Widget _buildPaymentStatusChips() {
    final options = [
      {'key': 'all', 'label': 'الكل'},
      {'key': 'paid', 'label': 'خالص (مسدد)'},
      {'key': 'partial', 'label': 'دفعة جزئية'},
      {'key': 'unpaid', 'label': 'غير مسدد'},
      {'key': 'exempt', 'label': 'معفى من الرسوم'},
      {'key': 'has_remaining', 'label': 'عليه متبقي'},
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((opt) {
        final key = opt['key']!;
        final label = opt['label']!;
        final isSelected = _paymentStatus == key;
        return _chipItem(
          label: label,
          isSelected: isSelected,
          onTap: () => setState(() => _paymentStatus = key),
        );
      }).toList(),
    );
  }

  Widget _buildTeacherDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF3FAF9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _teacherName,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primaryTeal),
          style: GoogleFonts.cairo(fontSize: 13, color: AppColors.textDark),
          items: [
            const DropdownMenuItem(
              value: 'كل الأنسات',
              child: Text('كل الأنسات'),
            ),
            ...widget.teachers.map((t) {
              return DropdownMenuItem(
                value: t.name,
                child: Text(t.name),
              );
            }),
          ],
          onChanged: (val) {
            if (val != null) setState(() => _teacherName = val);
          },
        ),
      ),
    );
  }

  Widget _buildGradeChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _chipItem(
          label: 'جميع المستويات',
          isSelected: _grade == 'all',
          onTap: () => setState(() => _grade = 'all'),
        ),
        ...widget.availableGrades.map((g) {
          return _chipItem(
            label: g,
            isSelected: _grade == g,
            onTap: () => setState(() => _grade = g),
          );
        }),
      ],
    );
  }

  Widget _buildSocialStatusChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _chipItem(
          label: 'الكل',
          isSelected: _socialStatus == 'all',
          onTap: () => setState(() => _socialStatus = 'all'),
        ),
        ...widget.availableSocialStatuses.map((s) {
          return _chipItem(
            label: s,
            isSelected: _socialStatus == s,
            onTap: () => setState(() => _socialStatus = s),
          );
        }),
      ],
    );
  }

  Widget _chipItem({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryTeal : const Color(0xFFF3FAF9),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primaryTeal : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.textDark,
          ),
        ),
      ),
    );
  }
}
