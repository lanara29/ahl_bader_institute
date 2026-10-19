import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../models/teacher.dart';
import '../db/database_helper.dart';
import 'home_screen.dart';
import 'students_screen.dart';
import 'add_teacher_screen.dart';

class TeachersScreen extends StatefulWidget {
  const TeachersScreen({super.key});

  @override
  State<TeachersScreen> createState() => _TeachersScreenState();
}

class _TeachersScreenState extends State<TeachersScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Teacher> _allTeachers = [];
  List<Teacher> _filteredTeachers = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTeachers();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // 100% Dynamic from Firebase Firestore
  Future<void> _loadTeachers() async {
    setState(() => _isLoading = true);
    final list = await _dbHelper.getTeachers();
    if (mounted) {
      setState(() {
        _allTeachers = list;
        _filteredTeachers = list;
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) {
      setState(() => _filteredTeachers = _allTeachers);
    } else {
      setState(() {
        _filteredTeachers = _allTeachers.where((t) {
          return t.name.toLowerCase().contains(query) ||
              t.phone.contains(query) ||
              t.ageRange.contains(query);
        }).toList();
      });
    }
  }

  void _showAddEditTeacherDialog([Teacher? teacher]) {
    final isEditing = teacher != null;
    final nameController = TextEditingController(text: teacher?.name ?? '');
    final ageRangeController = TextEditingController(text: teacher?.ageRange ?? '');
    final phoneController = TextEditingController(text: teacher?.phone ?? '');
    final joinDateController = TextEditingController(
      text: teacher?.joinDate ??
          '${DateTime.now().day.toString().padLeft(2, '0')}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().year}',
    );

    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            isEditing ? 'تعديل بيانات الآنسة' : 'إضافة آنسة جديدة',
            style: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: AppColors.primaryTeal),
          ),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _dialogTextField(nameController, 'اسم الآنسة *', 'مثال: الآنسة نورة محمد', isRequired: true),
                  const SizedBox(height: 12),
                  _dialogTextField(ageRangeController, 'عمر الطلاب', 'مثال: 8 - 14 سنة'),
                  const SizedBox(height: 12),
                  _dialogTextField(phoneController, 'رقم الهاتف *', 'مثال: 0551234567', isNumber: true, isRequired: true),
                  const SizedBox(height: 12),
                  _dialogTextField(joinDateController, 'تاريخ الانضمام', 'مثال: 01-09-2022'),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('إلغاء', style: GoogleFonts.cairo(color: AppColors.textMuted)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00796B),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;

                final newTeacher = Teacher(
                  id: teacher?.id,
                  name: nameController.text.trim(),
                  ageRange: ageRangeController.text.trim(),
                  phone: phoneController.text.trim(),
                  joinDate: joinDateController.text.trim(),
                );

                Navigator.pop(ctx);
                if (isEditing) {
                  await _dbHelper.updateTeacher(newTeacher);
                } else {
                  await _dbHelper.insertTeacher(newTeacher);
                }

                if (mounted) {
                  _loadTeachers();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(isEditing ? 'تم تعديل البيانات بنجاح' : 'تمت إضافة الآنسة بنجاح'),
                      backgroundColor: AppColors.primaryTeal,
                    ),
                  );
                }
              },
              child: Text(
                isEditing ? 'حفظ التعديلات' : 'إضافة',
                style: GoogleFonts.cairo(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dialogTextField(
    TextEditingController controller,
    String label,
    String hint, {
    bool isNumber = false,
    bool isRequired = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.phone : TextInputType.text,
      style: GoogleFonts.cairo(fontSize: 13, color: AppColors.textDark),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: GoogleFonts.cairo(fontSize: 12, color: AppColors.primaryTeal),
        hintStyle: GoogleFonts.cairo(fontSize: 12, color: AppColors.inputHint),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
      validator: isRequired
          ? (val) {
              if (val == null || val.trim().isEmpty) return 'هذا الحقل مطلوب';
              return null;
            }
          : null,
    );
  }

  void _confirmDeleteTeacher(Teacher teacher) {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'حذف الآنسة',
            style: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: Colors.red.shade700),
          ),
          content: Text(
            'هل أنت متأكد من حذف (${teacher.name})؟',
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
                if (teacher.id != null) {
                  await _dbHelper.deleteTeacher(teacher.id);
                }
                if (mounted) {
                  _loadTeachers();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تم حذف البيانات بنجاح')),
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
              // Header Section
              _buildHeaderSection(),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      const SizedBox(height: 12),

                      // Search Input Field
                      _buildSearchField(),

                      const SizedBox(height: 12),

                      // Controls Bar (Count on Right & Add Button on Left)
                      _buildControlsRow(),

                      const SizedBox(height: 12),

                      // Teachers List (Dynamic from Firebase)
                      Expanded(
                        child: _isLoading
                            ? const Center(
                                child: CircularProgressIndicator(color: AppColors.primaryTeal),
                              )
                            : _filteredTeachers.isEmpty
                                ? Center(
                                    child: Text(
                                      'لا يوجد آنسات مضافات حالياً',
                                      style: GoogleFonts.cairo(color: AppColors.textMuted, fontSize: 14),
                                    ),
                                  )
                                : RefreshIndicator(
                                    color: AppColors.primaryTeal,
                                    onRefresh: _loadTeachers,
                                    child: ListView.builder(
                                      physics: const BouncingScrollPhysics(),
                                      itemCount: _filteredTeachers.length,
                                      padding: const EdgeInsets.only(bottom: 20),
                                      itemBuilder: (ctx, index) {
                                        final teacher = _filteredTeachers[index];
                                        return _buildTeacherCard(teacher);
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
                    'الآنسات',
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

  Widget _buildSearchField() {
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
          hintText: 'ابحث عن آنسة أو رقم هاتف...',
          hintStyle: GoogleFonts.cairo(fontSize: 13, color: AppColors.inputHint),
          suffixIcon: const Icon(Icons.search, color: AppColors.inputHint, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        ),
      ),
    );
  }

  Widget _buildControlsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Left in RTL: Add Button
        ElevatedButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddTeacherScreen()),
            ).then((_) => _loadTeachers());
          },
          icon: const Icon(Icons.add, size: 18, color: Colors.white),
          label: Text(
            'إضافة آنسة',
            style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00897B),
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),

        // Right in RTL: Count
        Text(
          '${_filteredTeachers.length} آنسة',
          style: GoogleFonts.cairo(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryTeal,
          ),
        ),
      ],
    );
  }

  Widget _buildTeacherCard(Teacher teacher) {
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
                // Right Avatar Icon
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3E8FF),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.school_rounded,
                    color: Color(0xFF8B5CF6),
                    size: 22,
                  ),
                ),

                const SizedBox(width: 12),

                // Name & Age Range Badge
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        teacher.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.cairo(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryTeal,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (teacher.ageRange.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD7F5F0),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            'عمر الطلاب: ${teacher.ageRange}',
                            style: GoogleFonts.cairo(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF00796B),
                            ),
                          ),
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
                            builder: (_) => AddTeacherScreen(teacher: teacher),
                          ),
                        ).then((_) => _loadTeachers());
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
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () => _confirmDeleteTeacher(teacher),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFEBEE),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.delete_outline_rounded, size: 16, color: Colors.red.shade700),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Divider Line
          Divider(height: 1, color: Colors.grey.shade200),

          // Footer Row (Phone & Join Date)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.phone, size: 12, color: Color(0xFF00796B)),
                    const SizedBox(width: 4),
                    Text(
                      teacher.phone,
                      style: GoogleFonts.cairo(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF00796B),
                      ),
                    ),
                  ],
                ),

                Text(
                  'تاريخ الانضمام: ${teacher.joinDate}',
                  style: GoogleFonts.cairo(
                    fontSize: 10,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
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
              icon: Icons.groups_rounded,
              label: 'الطلاب',
              isActive: false,
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const StudentsScreen()),
                );
              },
            ),
            _bottomNavItem(
              index: 2,
              icon: Icons.school_rounded,
              label: 'الآنسات',
              isActive: true,
              onTap: () {},
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
