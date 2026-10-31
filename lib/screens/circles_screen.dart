import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../models/teacher.dart';
import '../models/student.dart';
import '../db/database_helper.dart';
import 'add_student_screen.dart';
import 'add_teacher_screen.dart';
import 'home_screen.dart';
import 'students_screen.dart';
import 'teachers_screen.dart';
import 'circles/widgets/circle_stats_row.dart';
import 'circles/widgets/circle_card.dart';
import 'circles/widgets/transfer_student_dialog.dart';
import 'circles/widgets/student_details_sheet.dart';
import 'circles/widgets/unassigned_students_banner.dart';

class CirclesScreen extends StatefulWidget {
  const CirclesScreen({super.key});

  @override
  State<CirclesScreen> createState() => _CirclesScreenState();
}

class _CirclesScreenState extends State<CirclesScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final TextEditingController _searchController = TextEditingController();

  List<Teacher> _allTeachers = [];
  List<Student> _allStudents = [];
  bool _isLoading = true;

  final Map<String, bool> _expandedCircles = {};
  bool _expandUnassigned = false;

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final teachers = await _dbHelper.getTeachers();
      final students = await _dbHelper.getAllStudents();
      if (mounted) {
        setState(() {
          _allTeachers = teachers;
          _allStudents = students;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ أثناء تحميل الحلقات: $e', style: GoogleFonts.cairo()),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    }
  }

  Map<String, List<Student>> _groupStudentsByTeacher() {
    final Map<String, List<Student>> grouped = {};
    for (final teacher in _allTeachers) {
      final key = (teacher.id ?? '').toString();
      grouped[key] = [];
    }
    for (final student in _allStudents) {
      final tId = (student.teacherId ?? '').toString();
      if (grouped.containsKey(tId)) {
        grouped[tId]!.add(student);
      }
    }
    return grouped;
  }

  List<Student> _getUnassignedStudents() {
    final validTeacherIds = _allTeachers.map((t) => (t.id ?? '').toString()).toSet();
    return _allStudents.where((s) {
      final tId = (s.teacherId ?? '').toString();
      return tId.isEmpty || tId == '0' || !validTeacherIds.contains(tId);
    }).toList();
  }

  List<Teacher> _getFilteredTeachers(Map<String, List<Student>> grouped) {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return _allTeachers;

    return _allTeachers.where((t) {
      final matchTeacher = t.name.toLowerCase().contains(query) ||
          t.phone.contains(query) ||
          t.ageRange.toLowerCase().contains(query);

      final tId = (t.id ?? '').toString();
      final studentsInCircle = grouped[tId] ?? [];
      final matchStudent = studentsInCircle.any((s) {
        final fullName = '${s.name} ${s.surname} ${s.fatherName}'.toLowerCase();
        return fullName.contains(query) || s.mobile.contains(query);
      });

      return matchTeacher || matchStudent;
    }).toList();
  }

  void _toggleAllCircles(bool expand) {
    setState(() {
      for (final teacher in _allTeachers) {
        _expandedCircles[(teacher.id ?? '').toString()] = expand;
      }
      _expandUnassigned = expand;
    });
  }

  void _openTransferDialog(Student student) {
    TransferStudentDialog.show(
      context: context,
      student: student,
      allTeachers: _allTeachers,
      onTransferred: _loadData,
    );
  }

  void _openDetailsSheet(Student student) {
    StudentDetailsSheet.show(
      context: context,
      student: student,
      onTransfer: () => _openTransferDialog(student),
      onEdit: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => AddStudentScreen(student: student)),
        ).then((_) => _loadData());
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final grouped = _groupStudentsByTeacher();
    final unassigned = _getUnassignedStudents();
    final filteredTeachers = _getFilteredTeachers(grouped);

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
                            CircleStatsRow(
                              totalTeachers: _allTeachers.length,
                              totalStudents: _allStudents.length,
                              assignedStudents: _allStudents.length - unassigned.length,
                              unassignedCount: unassigned.length,
                            ),
                            const SizedBox(height: 14),
                            _buildSearchBar(),
                            const SizedBox(height: 12),
                            UnassignedStudentsBanner(
                              unassigned: unassigned,
                              isExpanded: _expandUnassigned,
                              onToggle: () => setState(() => _expandUnassigned = !_expandUnassigned),
                              onAssign: _openTransferDialog,
                            ),
                            const SizedBox(height: 6),
                            if (filteredTeachers.isEmpty)
                              _buildEmptySearchState()
                            else
                              ...filteredTeachers.map((teacher) {
                                final tId = (teacher.id ?? '').toString();
                                final students = grouped[tId] ?? [];
                                final isExpanded = _expandedCircles[tId] ?? false;

                                return CircleCard(
                                  teacher: teacher,
                                  students: students,
                                  isExpanded: isExpanded,
                                  searchQuery: _searchController.text,
                                  onToggle: () => setState(() => _expandedCircles[tId] = !isExpanded),
                                  onShowDetails: _openDetailsSheet,
                                  onTransfer: _openTransferDialog,
                                  onEdit: (s) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (_) => AddStudentScreen(student: s)),
                                    ).then((_) => _loadData());
                                  },
                                  onAddStudent: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (_) => const AddStudentScreen()),
                                    ).then((_) => _loadData());
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
        icon: const Icon(Icons.person_add_rounded, color: Colors.white),
        label: Text(
          'إضافة آنسة / حلقة',
          style: GoogleFonts.cairo(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddTeacherScreen()),
          ).then((_) => _loadData());
        },
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
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
                  onPressed: () {
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    } else {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const HomeScreen()),
                      );
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'الحلقات القرآنية',
                    style: GoogleFonts.cairo(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  Text(
                    'توزيع ومتابعة طلاب الحلقات مع الآنسات',
                    style: GoogleFonts.cairo(fontSize: 11, color: const Color(0xFFE8C882)),
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.unfold_more_rounded, color: Colors.white),
                tooltip: 'توسيع الكل',
                onPressed: () => _toggleAllCircles(true),
              ),
              IconButton(
                icon: const Icon(Icons.unfold_less_rounded, color: Colors.white70),
                tooltip: 'طي الكل',
                onPressed: () => _toggleAllCircles(false),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
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
          hintText: 'ابحث عن حلقة، آنسة، أو طالب...',
          hintStyle: GoogleFonts.cairo(fontSize: 13, color: AppColors.inputHint),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          prefixIcon: const Icon(Icons.search, color: AppColors.primaryTeal, size: 20),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 18, color: AppColors.inputHint),
                  onPressed: () => _searchController.clear(),
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildEmptySearchState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.search_off_rounded, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(
              'لا توجد حلقة أو طالب مطابق لبحثك',
              style: GoogleFonts.cairo(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200, width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            _bottomNavItem(
              icon: Icons.home_rounded,
              label: 'الرئيسية',
              isActive: false,
              onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen())),
            ),
            _bottomNavItem(
              icon: Icons.menu_book_rounded,
              label: 'الحلقات',
              isActive: true,
              onTap: () {},
            ),
            _bottomNavItem(
              icon: Icons.groups_rounded,
              label: 'الطلاب',
              isActive: false,
              onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const StudentsScreen())),
            ),
            _bottomNavItem(
              icon: Icons.school_rounded,
              label: 'الآنسات',
              isActive: false,
              onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const TeachersScreen())),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bottomNavItem({
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
              Icon(icon, color: isActive ? AppColors.primaryTeal : AppColors.textMuted, size: 22),
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
