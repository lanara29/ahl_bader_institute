import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../models/student.dart';
import '../models/teacher.dart';
import '../db/database_helper.dart';
import 'add_student_screen.dart';
import 'teachers_screen.dart';
import 'home_screen.dart';
import 'circles_screen.dart';

class StudentsScreen extends StatefulWidget {
  const StudentsScreen({super.key});

  @override
  State<StudentsScreen> createState() => _StudentsScreenState();
}

class _StudentsScreenState extends State<StudentsScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Student> _allStudents = [];
  List<Student> _filteredStudents = [];
  List<Teacher> _teachers = [];
  String? _selectedTeacherName;

  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchController.addListener(_filterStudents);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // 100% Dynamic from Firebase Firestore
  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final studentsList = await _dbHelper.getAllStudents();
    final teachersList = await _dbHelper.getTeachers();

    if (mounted) {
      setState(() {
        _allStudents = studentsList;
        _teachers = teachersList;
        _isLoading = false;
        _filterStudents();
      });
    }
  }

  void _filterStudents() {
    final query = _searchController.text.trim().toLowerCase();

    setState(() {
      _filteredStudents = _allStudents.where((s) {
        final fullName = '${s.name} ${s.surname} ${s.fatherName}'.toLowerCase();
        final matchesQuery = query.isEmpty ||
            fullName.contains(query) ||
            s.mobile.contains(query) ||
            s.parentMobile.contains(query) ||
            s.fatherName.toLowerCase().contains(query);

        final matchesTeacher = _selectedTeacherName == null ||
            _selectedTeacherName == 'كل الأنسات' ||
            s.teacherName == _selectedTeacherName;

        return matchesQuery && matchesTeacher;
      }).toList();
    });
  }

  void _confirmDeleteStudent(Student student) {
    showDialog(
      context: context,
      builder: (dialogCtx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'حذف الطالب',
            style: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: Colors.red.shade700),
          ),
          content: Text(
            'هل أنت متاكد من حذف الطالب (${student.name} ${student.surname})؟',
            style: GoogleFonts.cairo(color: AppColors.textDark),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: Text('إلغاء', style: GoogleFonts.cairo(color: AppColors.textMuted)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () async {
                Navigator.pop(dialogCtx);
                if (student.id != null) {
                  await _dbHelper.deleteStudent(student.id);
                }
                if (mounted) {
                  _loadData();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تم حذف بيانات الطالب بنجاح')),
                  );
                }
              },
              child: Text('حذف', style: GoogleFonts.cairo(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3FAF9),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              // Top Header Section (Screenshot 3)
              _buildHeaderSection(),

              // Search & Filter & Action Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  children: [
                    // Search Bar
                    Container(
                      height: 46,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.grey.shade300, width: 1),
                      ),
                      child: TextField(
                        controller: _searchController,
                        style: GoogleFonts.cairo(fontSize: 13, color: AppColors.textDark),
                        decoration: InputDecoration(
                          hintText: 'ابحث بالاسم أو موبايل أو الأب...',
                          hintStyle: GoogleFonts.cairo(fontSize: 13, color: AppColors.inputHint),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          suffixIcon: const Icon(Icons.search, color: AppColors.inputHint, size: 20),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Filter Dropdown: كل الأنسات
                    Container(
                      height: 44,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300, width: 1),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedTeacherName ?? 'كل الأنسات',
                          isExpanded: true,
                          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primaryTeal),
                          style: GoogleFonts.cairo(fontSize: 13, color: AppColors.textDark),
                          onChanged: (val) {
                            setState(() {
                              _selectedTeacherName = val;
                              _filterStudents();
                            });
                          },
                          items: [
                            const DropdownMenuItem(
                              value: 'كل الأنسات',
                              child: Text('كل الأنسات'),
                            ),
                            ..._teachers.map((t) {
                              return DropdownMenuItem(
                                value: t.name,
                                child: Text(t.name),
                              );
                            }),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Actions Bar: Total Count (Right in RTL) & + إضافة طالب (Left in RTL)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Left in RTL: Button + إضافة طالب
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const AddStudentScreen()),
                            ).then((_) => _loadData());
                          },
                          icon: const Icon(Icons.add, color: Colors.white, size: 18),
                          label: Text(
                            'إضافة طالب',
                            style: GoogleFonts.cairo(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00897B),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          ),
                        ),

                        // Right in RTL: Count
                        Text(
                          '${_filteredStudents.length} طالب',
                          style: GoogleFonts.cairo(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryTeal,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Students List (Dynamic from Firebase)
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: AppColors.primaryTeal),
                      )
                    : _filteredStudents.isEmpty
                        ? Center(
                            child: Text(
                              'لا يوجد طلاب مسجلون حالياً',
                              style: GoogleFonts.cairo(color: AppColors.textMuted, fontSize: 14),
                            ),
                          )
                        : RefreshIndicator(
                            color: AppColors.primaryTeal,
                            onRefresh: _loadData,
                            child: ListView.builder(
                              physics: const BouncingScrollPhysics(),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                              itemCount: _filteredStudents.length,
                              itemBuilder: (ctx, index) {
                                final student = _filteredStudents[index];
                                return _buildStudentCard(student);
                              },
                            ),
                          ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF00796B),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      padding: const EdgeInsets.only(top: 48, bottom: 18, left: 18, right: 18),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Right: Star Badge + Title
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.star_rounded, color: Color(0xFFE8C882), size: 20),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'قائمة الطلاب',
                    style: GoogleFonts.cairo(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.1,
                    ),
                  ),
                  Text(
                    'ساداتنا أهل بدر الكرام',
                    style: GoogleFonts.cairo(
                      fontSize: 11,
                      color: const Color(0xFFE8C882),
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Left: Notification Bell Icon
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.25),
                width: 1,
              ),
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.notifications_rounded, color: Colors.white, size: 19),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('لا توجد إشعارات جديدة حالياً')),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentCard(Student student) {
    final firstLetter = student.name.isNotEmpty ? student.name.characters.first : 'ط';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200, width: 1),
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
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Right Avatar: First letter in light cyan box
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD7F5F0),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    firstLetter,
                    style: GoogleFonts.cairo(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF00796B),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Middle Details: Name, Father, Teacher, Badges
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${student.name} ${student.surname}',
                        style: GoogleFonts.cairo(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryTeal,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'الأب: ${student.fatherName.isEmpty ? '-' : student.fatherName} • الأنسة ${student.teacherName.isEmpty ? 'غير محدد' : student.teacherName}',
                        style: GoogleFonts.cairo(
                          fontSize: 11,
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Pill Badges: Phone & Memorization
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          if (student.mobile.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFD7F5F0),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.phone, size: 11, color: Color(0xFF00796B)),
                                  const SizedBox(width: 4),
                                  Text(
                                    student.mobile,
                                    style: GoogleFonts.cairo(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF00796B),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          if (student.grade.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEF3D6),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                student.grade,
                                style: GoogleFonts.cairo(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFFC89336),
                                ),
                              ),
                            ),
                          // Payment Status Badge
                          if (student.requiredFee > 0 || student.paidAmount > 0 || student.paymentStatus == 'exempt')
                            _buildPaymentBadge(student),
                        ],
                      ),
                    ],
                  ),
                ),

                // Left Action Buttons: Edit (Teal) & Delete (Red)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AddStudentScreen(student: student),
                          ),
                        ).then((_) => _loadData());
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: const Color(0xFFD7F5F0),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.edit_outlined, color: Color(0xFF00796B), size: 16),
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () => _confirmDeleteStudent(student),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFEBEE),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.delete_outline_rounded, color: Colors.red.shade700, size: 16),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Divider
          Divider(height: 1, color: Colors.grey.shade200),

          // Card Footer: Address, Parent Mobile, Join Date
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'العنوان: ${student.address.isEmpty ? '-' : student.address}',
                    style: GoogleFonts.cairo(fontSize: 10, color: AppColors.textMuted),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  'الأهل: ${student.parentMobile.isEmpty ? '-' : student.parentMobile}',
                  style: GoogleFonts.cairo(fontSize: 10, color: AppColors.textMuted),
                ),
                const SizedBox(width: 8),
                Text(
                  'الانضمام: ${student.joinDate}',
                  style: GoogleFonts.cairo(fontSize: 10, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentBadge(Student student) {
    Color bgColor;
    Color textColor;
    String text;

    final req = student.requiredFee % 1 == 0 ? student.requiredFee.toInt() : student.requiredFee;
    final paid = student.paidAmount % 1 == 0 ? student.paidAmount.toInt() : student.paidAmount;

    switch (student.paymentStatus) {
      case 'paid':
        bgColor = const Color(0xFFD7F5F0);
        textColor = const Color(0xFF00796B);
        text = 'مسدد ($paid)';
        break;
      case 'partial':
        bgColor = const Color(0xFFFFF3E0);
        textColor = Colors.orange.shade800;
        text = 'جزئي ($paid / $req)';
        break;
      case 'exempt':
        bgColor = const Color(0xFFF3E8FF);
        textColor = const Color(0xFF8B5CF6);
        text = 'معفى';
        break;
      case 'unpaid':
      default:
        bgColor = const Color(0xFFFFEBEE);
        textColor = Colors.red.shade700;
        text = student.requiredFee > 0 ? 'غير مسدد ($req)' : 'غير مسدد';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.payments_outlined, size: 11, color: textColor),
          const SizedBox(width: 4),
          Text(
            text,
            style: GoogleFonts.cairo(
              fontSize: 10.5,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            _bottomNavItem(
              index: 0,
              icon: Icons.home_rounded,
              label: 'الرئيسية',
              isActive: false,
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const HomeScreen()),
                );
              },
            ),
            _bottomNavItem(
              index: 1,
              icon: Icons.menu_book_rounded,
              label: 'الحلقات',
              isActive: false,
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const CirclesScreen()),
                );
              },
            ),
            _bottomNavItem(
              index: 2,
              icon: Icons.groups_rounded,
              label: 'الطلاب',
              isActive: true,
              onTap: () {},
            ),
            _bottomNavItem(
              index: 3,
              icon: Icons.school_rounded,
              label: 'الآنسات',
              isActive: false,
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const TeachersScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _bottomNavItem({
    required int index,
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: isActive ? AppColors.primaryTeal : Colors.transparent,
                width: 2.5,
              ),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isActive ? AppColors.primaryTeal : AppColors.textMuted,
                size: 22,
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: GoogleFonts.cairo(
                  fontSize: 11,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  color: isActive ? AppColors.primaryTeal : AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
