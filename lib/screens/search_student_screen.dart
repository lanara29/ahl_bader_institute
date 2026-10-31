import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../models/student.dart';
import '../db/database_helper.dart';
import 'add_student_screen.dart';
import 'home_screen.dart';
import 'students_screen.dart';
import 'teachers_screen.dart';
import 'circles_screen.dart';

class SearchStudentScreen extends StatefulWidget {
  const SearchStudentScreen({super.key});

  @override
  State<SearchStudentScreen> createState() => _SearchStudentScreenState();
}

class _SearchStudentScreenState extends State<SearchStudentScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final TextEditingController _searchController = TextEditingController();

  List<Student> _allStudents = [];
  List<Student> _searchResults = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchController.addListener(_performSearch);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // 100% Dynamic from Firebase Firestore
  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final students = await _dbHelper.getAllStudents();

    if (mounted) {
      setState(() {
        _allStudents = students;
        _searchResults = students;
        _isLoading = false;
        _performSearch();
      });
    }
  }

  void _performSearch() {
    final query = _searchController.text.trim().toLowerCase();

    setState(() {
      if (query.isEmpty) {
        _searchResults = _allStudents;
      } else {
        _searchResults = _allStudents.where((s) {
          final fullName = '${s.name} ${s.surname} ${s.fatherName} ${s.motherName}'.toLowerCase();
          return fullName.contains(query) ||
              s.mobile.contains(query) ||
              s.parentMobile.contains(query) ||
              s.address.toLowerCase().contains(query) ||
              s.teacherName.toLowerCase().contains(query) ||
              s.grade.toLowerCase().contains(query);
        }).toList();
      }
    });
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
              // Top Header Bar (Screenshot 1)
              _buildHeaderSection(),

              // Search Bar & Results
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Search Input Field (Rounded with green border, search icon & X clear)
                      Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFF00897B), width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.02),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const SizedBox(width: 14),
                            // Search Icon (Right in RTL)
                            const Icon(Icons.search, color: Color(0xFF00796B), size: 22),
                            const SizedBox(width: 10),

                            // TextField
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                style: GoogleFonts.cairo(fontSize: 14, color: AppColors.textDark),
                                decoration: InputDecoration(
                                  hintText: 'ابحث بالاسم أو الهاتف أو الأب...',
                                  hintStyle: GoogleFonts.cairo(fontSize: 13, color: AppColors.inputHint),
                                  border: InputBorder.none,
                                  isDense: true,
                                ),
                              ),
                            ),

                            // Clear X Button (Left in RTL)
                            if (_searchController.text.isNotEmpty)
                              IconButton(
                                icon: const Icon(Icons.close_rounded, color: AppColors.textMuted, size: 18),
                                onPressed: () {
                                  _searchController.clear();
                                },
                              ),
                            const SizedBox(width: 6),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Results Count (e.g. "1 نتيجة")
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            '${_searchResults.length} نتيجة',
                            style: GoogleFonts.cairo(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF00796B),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // Search Results List (Dynamic from Firebase)
                      Expanded(
                        child: _isLoading
                            ? const Center(
                                child: CircularProgressIndicator(color: AppColors.primaryTeal),
                              )
                            : _searchResults.isEmpty
                                ? Center(
                                    child: Text(
                                      'لا توجد نتائج مطابقة للبحث',
                                      style: GoogleFonts.cairo(color: AppColors.textMuted, fontSize: 14),
                                    ),
                                  )
                                : RefreshIndicator(
                                    color: AppColors.primaryTeal,
                                    onRefresh: _loadData,
                                    child: ListView.builder(
                                      physics: const BouncingScrollPhysics(),
                                      itemCount: _searchResults.length,
                                      padding: const EdgeInsets.only(bottom: 20),
                                      itemBuilder: (ctx, index) {
                                        final student = _searchResults[index];
                                        return _buildResultCard(student);
                                      },
                                    ),
                                  ),
                      ),
                    ],
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
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      padding: const EdgeInsets.only(top: 48, bottom: 16, left: 16, right: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'البحث عن طالب',
            style: GoogleFonts.cairo(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 22),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard(Student student) {
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
                // Right Avatar: First Letter
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

                      // Pill Badges: Grade & Phone
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
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
                          // Payment Badge
                          if (student.requiredFee > 0 || student.paidAmount > 0 || student.paymentStatus == 'exempt')
                            _buildPaymentBadge(student),
                        ],
                      ),
                    ],
                  ),
                ),

                // Left Action Button: Edit (Teal) as in Screenshot 1
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
                    child: const Icon(Icons.edit_outlined, size: 16, color: Color(0xFF00796B)),
                  ),
                ),
              ],
            ),
          ),

          // Divider
          Divider(height: 1, color: Colors.grey.shade200),

          // Card Footer: Address & Parent Mobile
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
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const StudentsScreen()),
                );
              },
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
