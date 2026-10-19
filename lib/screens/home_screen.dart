import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/app_theme.dart';
import '../db/database_helper.dart';
import 'login_screen.dart';
import 'teachers_screen.dart';
import 'add_student_screen.dart';
import 'students_screen.dart';
import 'search_student_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentBottomIndex = 0;
  int _totalStudents = 0;
  int _totalTeachers = 0;
  bool _isLoadingStats = true;

  final DatabaseHelper _dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  // 100% Dynamic count from Firebase Firestore
  Future<void> _loadStatistics() async {
    try {
      final teachers = await _dbHelper.getTeachers();
      final students = await _dbHelper.getAllStudents();
      if (mounted) {
        setState(() {
          _totalTeachers = teachers.length;
          _totalStudents = students.length;
          _isLoadingStats = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingStats = false);
      }
    }
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'تسجيل الخروج',
            style: GoogleFonts.cairo(
              fontWeight: FontWeight.bold,
              color: AppColors.primaryTeal,
            ),
          ),
          content: Text(
            'هل أنت متاكد من رغبتك في تسجيل الخروج؟',
            style: GoogleFonts.cairo(color: AppColors.textDark),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'إلغاء',
                style: GoogleFonts.cairo(color: AppColors.textMuted),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryTeal,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
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
                style: GoogleFonts.cairo(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
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
          child: RefreshIndicator(
            color: AppColors.primaryTeal,
            onRefresh: _loadStatistics,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              child: Column(
                children: [
                  // Top Gradient Header Section (Screenshot 1)
                  _buildHeaderSection(),

                  const SizedBox(height: 14),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Greeting Card: السلام عليكم ورحمة الله وبركاته
                        _buildGreetingCard(),

                        const SizedBox(height: 14),

                        // Statistics Cards Row (Dynamic from Firebase)
                        _buildStatisticsRow(),

                        const SizedBox(height: 20),

                        // Administrative Services Title
                        _buildSectionTitle('الخدمات الإدارية'),

                        const SizedBox(height: 12),

                        // Quick Services Grid (2x2)
                        _buildServicesGrid(),

                        const SizedBox(height: 16),

                        // Quranic Verse Card
                        _buildQuranVerseCard(),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),
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
      padding: const EdgeInsets.only(top: 48, bottom: 24, left: 18, right: 18),
      child: Column(
        children: [
          // Top Action Row (Title on Right, Notifications & Logout on Left)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Top Right: Title + Star
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
                    child: const Icon(
                      Icons.star_rounded,
                      color: Color(0xFFE8C882),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'الرئيسية',
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

              // Top Left: Logout Button
              _headerIconButton(
                icon: Icons.logout_rounded,
                onTap: _handleLogout,
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Central Logo Card
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: const Color(0xFFE8C882), width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 14,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: Image.asset(
                    'assets/images/logo.png',
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.mosque_rounded,
                      color: AppColors.primaryTeal,
                      size: 44,
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Title
          Text(
            'ساداتنا أهل بدر الكرام',
            style: GoogleFonts.cairo(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),

          // Subtitle
          Text(
            'نظام إدارة الجامع',
            style: GoogleFonts.cairo(
              fontSize: 13,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerIconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
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
        icon: Icon(icon, color: Colors.white, size: 19),
        onPressed: onTap,
      ),
    );
  }

  Widget _buildGreetingCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
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
          _goldDividerWithStar(),
          const SizedBox(height: 6),
          Text(
            'السلام عليكم ورحمة الله وبركاته',
            style: GoogleFonts.cairo(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryTeal,
            ),
          ),
          const SizedBox(height: 6),
          _goldDividerWithStar(),
        ],
      ),
    );
  }

  Widget _goldDividerWithStar() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            color: const Color(0xFFE8C882).withValues(alpha: 0.7),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Icon(
            Icons.star_rate_rounded,
            size: 13,
            color: Color(0xFFC89336),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            color: const Color(0xFFE8C882).withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildStatisticsRow() {
    return Row(
      children: [
        // Total Students (Right card in RTL)
        Expanded(
          child: _statCard(
            title: 'إجمالي الطلاب',
            count: _totalStudents.toString(),
            icon: Icons.groups_rounded,
            iconColor: AppColors.primaryTeal,
            countColor: AppColors.primaryTeal,
            borderColor: const Color(0xFFB2DFDB),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const StudentsScreen()),
              ).then((_) => _loadStatistics());
            },
          ),
        ),
        const SizedBox(width: 14),

        // Total Teachers (Left card in RTL)
        Expanded(
          child: _statCard(
            title: 'الآنسات',
            count: _totalTeachers.toString(),
            icon: Icons.school_rounded,
            iconColor: const Color(0xFFC89336),
            countColor: const Color(0xFFC89336),
            borderColor: const Color(0xFFFFE082),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TeachersScreen()),
              ).then((_) => _loadStatistics());
            },
          ),
        ),
      ],
    );
  }

  Widget _statCard({
    required String title,
    required String count,
    required IconData icon,
    required Color iconColor,
    required Color countColor,
    required Color borderColor,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: borderColor, width: 1.5),
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
            Icon(icon, size: 28, color: iconColor),
            const SizedBox(height: 6),
            _isLoadingStats
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primaryTeal,
                    ),
                  )
                : Text(
                    count,
                    style: GoogleFonts.cairo(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: countColor,
                    ),
                  ),
            const SizedBox(height: 2),
            Text(
              title,
              style: GoogleFonts.cairo(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 2,
          color: const Color(0xFFC89336),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.cairo(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryTeal,
          ),
        ),
      ],
    );
  }

  Widget _buildServicesGrid() {
    return Column(
      children: [
        Row(
          children: [
            // إضافة طالب (Top Right in RTL)
            Expanded(
              child: _serviceCard(
                title: 'إضافة طالب',
                icon: Icons.person_add_alt_1_rounded,
                bgColor: const Color(0xFFD7F5F0),
                iconColor: const Color(0xFF00796B),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AddStudentScreen()),
                  ).then((_) => _loadStatistics());
                },
              ),
            ),
            const SizedBox(width: 12),

            // قائمة الطلاب (Top Left in RTL)
            Expanded(
              child: _serviceCard(
                title: 'قائمة الطلاب',
                icon: Icons.format_list_bulleted_rounded,
                bgColor: const Color(0xFFFEF3D6),
                iconColor: const Color(0xFFC89336),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const StudentsScreen()),
                  ).then((_) => _loadStatistics());
                },
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        Row(
          children: [
            // الآنسات (Bottom Right in RTL)
            Expanded(
              child: _serviceCard(
                title: 'الآنسات',
                icon: Icons.school_rounded,
                bgColor: const Color(0xFFF3E8FF),
                iconColor: const Color(0xFF8B5CF6),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const TeachersScreen()),
                  ).then((_) => _loadStatistics());
                },
              ),
            ),
            const SizedBox(width: 12),

            // البحث عن طالب (Bottom Left in RTL)
            Expanded(
              child: _serviceCard(
                title: 'البحث عن طالب',
                icon: Icons.search_rounded,
                bgColor: const Color(0xFFDFF6F5),
                iconColor: const Color(0xFF00897B),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SearchStudentScreen(),
                    ),
                  ).then((_) => _loadStatistics());
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _serviceCard({
    required String title,
    required IconData icon,
    required Color bgColor,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.grey.shade200, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(14),
              ),
              alignment: Alignment.center,
              child: Icon(icon, color: iconColor, size: 26),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: GoogleFonts.cairo(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryTeal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuranVerseCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEA),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFFE082), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(
            Icons.star_rate_rounded,
            size: 14,
            color: Color(0xFFC89336),
          ),
          const SizedBox(height: 4),
          Text(
            'وَقُل رَّبِّ زِدْنِي عِلْمًا',
            style: GoogleFonts.cairo(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryTeal,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'سورة طه — الآية 114',
            style: GoogleFonts.cairo(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: const Color(0xFFC89336),
            ),
          ),
          const SizedBox(height: 4),
          const Icon(
            Icons.star_rate_rounded,
            size: 14,
            color: Color(0xFFC89336),
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
              isActive: _currentBottomIndex == 0,
              onTap: () => setState(() => _currentBottomIndex = 0),
            ),
            _bottomNavItem(
              index: 1,
              icon: Icons.groups_rounded,
              label: 'الطلاب',
              isActive: _currentBottomIndex == 1,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const StudentsScreen()),
                ).then((_) => _loadStatistics());
              },
            ),
            _bottomNavItem(
              index: 2,
              icon: Icons.school_rounded,
              label: 'الآنسات',
              isActive: _currentBottomIndex == 2,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TeachersScreen()),
                ).then((_) => _loadStatistics());
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
