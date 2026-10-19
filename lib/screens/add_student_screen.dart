import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../models/student.dart';
import '../models/teacher.dart';
import '../db/database_helper.dart';

class AddStudentScreen extends StatefulWidget {
  final Student? student;

  const AddStudentScreen({super.key, this.student});

  @override
  State<AddStudentScreen> createState() => _AddStudentScreenState();
}

class _AddStudentScreenState extends State<AddStudentScreen> {
  final _formKey = GlobalKey<FormState>();
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // Controllers for Personal Info
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _fatherNameController = TextEditingController();
  final TextEditingController _motherNameController = TextEditingController();
  final TextEditingController _fatherJobController = TextEditingController();
  final TextEditingController _motherJobController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  // Controllers for Contact Info
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _parentMobileController = TextEditingController();

  // Memorization / Grade Controller & Notes
  final TextEditingController _gradeController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  // Dropdown States
  String? _selectedSocialStatus;
  Teacher? _selectedTeacher;
  List<Teacher> _teachersList = [];
  bool _isLoadingTeachers = true;
  bool _isSaving = false;

  final List<String> _socialStatusOptions = [
    'عزباء',
    'أعزب / عزباء',
    'يتيم الأب',
    'يتيم الأم',
    'يتيم الأبوين',
    'مكفول',
    'أخرى',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.student != null) {
      final s = widget.student!;
      _nameController.text = s.name;
      _surnameController.text = s.surname;
      _fatherNameController.text = s.fatherName;
      _motherNameController.text = s.motherName;
      _fatherJobController.text = s.fatherJob;
      _motherJobController.text = s.motherJob;
      _addressController.text = s.address;
      _mobileController.text = s.mobile;
      _parentMobileController.text = s.parentMobile;
      _gradeController.text = s.grade;
      _notesController.text = s.notes;
      if (_socialStatusOptions.contains(s.socialStatus)) {
        _selectedSocialStatus = s.socialStatus;
      } else if (s.socialStatus.isNotEmpty) {
        _socialStatusOptions.add(s.socialStatus);
        _selectedSocialStatus = s.socialStatus;
      }
    }
    _loadTeachers();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _fatherNameController.dispose();
    _motherNameController.dispose();
    _fatherJobController.dispose();
    _motherJobController.dispose();
    _addressController.dispose();
    _mobileController.dispose();
    _parentMobileController.dispose();
    _gradeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  // Fetch teachers dynamically from Firebase Firestore
  Future<void> _loadTeachers() async {
    final list = await _dbHelper.getTeachers();
    if (mounted) {
      setState(() {
        _teachersList = list;
        if (widget.student != null) {
          try {
            _selectedTeacher = list.firstWhere(
              (t) => t.id == widget.student!.teacherId || t.name == widget.student!.teacherName,
            );
          } catch (_) {
            if (list.isNotEmpty) _selectedTeacher = list.first;
          }
        } else if (list.isNotEmpty) {
          _selectedTeacher = list.first;
        }
        _isLoadingTeachers = false;
      });
    }
  }

  void _handleSaveStudent() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final isEditing = widget.student != null;

      final student = Student(
        id: widget.student?.id,
        name: _nameController.text.trim(),
        surname: _surnameController.text.trim(),
        fatherName: _fatherNameController.text.trim(),
        motherName: _motherNameController.text.trim(),
        fatherJob: _fatherJobController.text.trim(),
        motherJob: _motherJobController.text.trim(),
        socialStatus: _selectedSocialStatus ?? '',
        address: _addressController.text.trim(),
        mobile: _mobileController.text.trim(),
        parentMobile: _parentMobileController.text.trim(),
        teacherId: _selectedTeacher?.id ?? '',
        teacherName: _selectedTeacher?.name ?? '',
        grade: _gradeController.text.trim(),
        joinDate: widget.student?.joinDate ??
            '${DateTime.now().day.toString().padLeft(2, '0')}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().year}',
        notes: _notesController.text.trim(),
      );

      if (isEditing) {
        await _dbHelper.updateStudent(student);
      } else {
        await _dbHelper.insertStudent(student);
      }

      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEditing ? 'تم تعديل بيانات الطالب بنجاح!' : 'تم حفظ بيانات الطالب بنجاح!'),
            backgroundColor: AppColors.primaryTeal,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ أثناء الحفظ: $e'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.student != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF3FAF9),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              // Top Header Bar (Screenshot 4 & 5)
              _buildHeaderSection(isEditing),

              // Scrollable Form Body
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Card 1: البيانات الشخصية
                        _buildPersonalDataCard(),

                        const SizedBox(height: 14),

                        // Card 2: بيانات التواصل
                        _buildContactDataCard(),

                        const SizedBox(height: 14),

                        // Card 3: بيانات الحفظ
                        _buildMemorizationDataCard(),

                        const SizedBox(height: 14),

                        // Card 4: ملاحظات
                        _buildNotesCard(),

                        const SizedBox(height: 18),

                        // Fixed Bottom Button: إضافة الطالب / حفظ التعديلات
                        SizedBox(
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _isSaving ? null : _handleSaveStudent,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF00897B),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 0,
                            ),
                            child: _isSaving
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                  )
                                : Text(
                                    isEditing ? 'حفظ التعديلات' : 'إضافة الطالب',
                                    style: GoogleFonts.cairo(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection(bool isEditing) {
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
            isEditing ? 'تعديل بيانات الطالب' : 'إضافة طالب جديد',
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

  // Card 1: البيانات الشخصية
  Widget _buildPersonalDataCard() {
    return _formCard(
      title: 'البيانات الشخصية',
      icon: Icons.person,
      iconColor: const Color(0xFF1976D2),
      children: [
        // Name & Surname
        Row(
          children: [
            Expanded(
              child: _buildFormField(
                controller: _nameController,
                label: 'الاسم *',
                hint: 'الاسم',
                isRequired: true,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildFormField(
                controller: _surnameController,
                label: 'الكنية',
                hint: 'الكنية / اللقب',
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Father & Mother
        Row(
          children: [
            Expanded(
              child: _buildFormField(
                controller: _fatherNameController,
                label: 'الأب',
                hint: 'اسم الأب',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildFormField(
                controller: _motherNameController,
                label: 'الأم',
                hint: 'اسم الأم',
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Father Job & Mother Job
        Row(
          children: [
            Expanded(
              child: _buildFormField(
                controller: _fatherJobController,
                label: 'عمل الأب',
                hint: 'مهنة الأب',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildFormField(
                controller: _motherJobController,
                label: 'عمل الأم',
                hint: 'مهنة الأم',
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Social Status Dropdown
        _buildLabel('الحالة الاجتماعية'),
        const SizedBox(height: 6),
        Container(
          height: 46,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300, width: 1),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedSocialStatus,
              hint: Text('اختر...', style: GoogleFonts.cairo(fontSize: 13, color: AppColors.inputHint)),
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primaryTeal),
              items: _socialStatusOptions.map((status) {
                return DropdownMenuItem(
                  value: status,
                  child: Text(status, style: GoogleFonts.cairo(fontSize: 13, color: AppColors.textDark)),
                );
              }).toList(),
              onChanged: (val) {
                setState(() => _selectedSocialStatus = val);
              },
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Address
        _buildFormField(
          controller: _addressController,
          label: 'العنوان',
          hint: 'الحي والشارع والمدينة',
        ),
      ],
    );
  }

  // Card 2: بيانات التواصل
  Widget _buildContactDataCard() {
    return _formCard(
      title: 'بيانات التواصل',
      icon: Icons.phone,
      iconColor: AppColors.primaryTeal,
      children: [
        _buildFormField(
          controller: _mobileController,
          label: 'الموبايل',
          hint: '05xxxxxxxx',
          isPhone: true,
        ),
        const SizedBox(height: 12),
        _buildFormField(
          controller: _parentMobileController,
          label: 'موبايل الأهل',
          hint: '05xxxxxxxx',
          isPhone: true,
        ),
      ],
    );
  }

  // Card 3: بيانات الحفظ
  Widget _buildMemorizationDataCard() {
    return _formCard(
      title: 'بيانات الحفظ',
      icon: Icons.menu_book,
      iconColor: const Color(0xFFC89336),
      children: [
        // Teacher Selection
        _buildLabel('الآنسة / المعلمة'),
        const SizedBox(height: 6),
        Container(
          height: 46,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300, width: 1),
          ),
          child: _isLoadingTeachers
              ? const Center(child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)))
              : DropdownButtonHideUnderline(
                  child: DropdownButton<Teacher>(
                    value: _selectedTeacher,
                    hint: Text('اختر...', style: GoogleFonts.cairo(fontSize: 13, color: AppColors.inputHint)),
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primaryTeal),
                    items: _teachersList.map((teacher) {
                      return DropdownMenuItem<Teacher>(
                        value: teacher,
                        child: Text(teacher.name, style: GoogleFonts.cairo(fontSize: 13, color: AppColors.textDark)),
                      );
                    }).toList(),
                    onChanged: (Teacher? val) {
                      setState(() => _selectedTeacher = val);
                    },
                  ),
                ),
        ),

        const SizedBox(height: 12),

        _buildFormField(
          controller: _gradeController,
          label: 'ما حفظه',
          hint: 'مثال: جزء عم وتبارك',
        ),
      ],
    );
  }

  // Card 4: ملاحظات
  Widget _buildNotesCard() {
    return _formCard(
      title: 'ملاحظات',
      icon: Icons.edit_note_rounded,
      iconColor: const Color(0xFF00897B),
      children: [
        TextFormField(
          controller: _notesController,
          maxLines: 3,
          style: GoogleFonts.cairo(fontSize: 13, color: AppColors.textDark),
          decoration: InputDecoration(
            hintText: 'أي ملاحظات إضافية...',
            hintStyle: GoogleFonts.cairo(fontSize: 13, color: AppColors.inputHint),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.all(12),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primaryTeal, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _formCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: iconColor),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.cairo(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryTeal,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.cairo(
        fontSize: 13,
        fontWeight: FontWeight.bold,
        color: AppColors.primaryTeal,
      ),
    );
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required String hint,
    bool isRequired = false,
    bool isPhone = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
          style: GoogleFonts.cairo(fontSize: 13, color: AppColors.textDark),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.cairo(fontSize: 13, color: AppColors.inputHint),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primaryTeal, width: 1.5),
            ),
          ),
          validator: isRequired
              ? (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'هذا الحقل مطلوب';
                  }
                  return null;
                }
              : null,
        ),
      ],
    );
  }
}
