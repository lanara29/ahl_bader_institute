import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';
import '../../../models/student.dart';

class StudentDetailsSheet {
  static void show({
    required BuildContext context,
    required Student student,
    required VoidCallback onTransfer,
    required VoidCallback onEdit,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: AppColors.primaryTealLight,
                    child: Text(
                      student.name.isNotEmpty ? student.name.characters.first : 'ط',
                      style: GoogleFonts.cairo(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryTeal,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${student.name} ${student.surname}',
                          style: GoogleFonts.cairo(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryTeal,
                          ),
                        ),
                        Text(
                          'الحلقة: الآنسة ${student.teacherName.isEmpty ? 'غير معينة' : student.teacherName}',
                          style: GoogleFonts.cairo(
                            fontSize: 13,
                            color: AppColors.goldAccent,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _detailRow(ctx, Icons.person_outline, 'اسم الأب', student.fatherName),
              _detailRow(ctx, Icons.face_3_outlined, 'اسم الأم', student.motherName),
              _detailRow(ctx, Icons.menu_book_rounded, 'الصف / المرحلة', student.grade),
              _detailRow(ctx, Icons.phone_android_rounded, 'هاتف الطالب', student.mobile, isPhone: true),
              _detailRow(ctx, Icons.phone_rounded, 'هاتف ولي الأمر', student.parentMobile, isPhone: true),
              _detailRow(ctx, Icons.location_on_outlined, 'العنوان', student.address),
              _detailRow(ctx, Icons.favorite_outline, 'الحالة الاجتماعية', student.socialStatus),
              if (student.notes.isNotEmpty)
                _detailRow(ctx, Icons.notes_rounded, 'ملاحظات', student.notes),
              // Payment Details
              if (student.requiredFee > 0 || student.paidAmount > 0 || student.paymentStatus == 'exempt') ...[
                const Divider(height: 20),
                _detailRow(ctx, Icons.payments_outlined, 'المبلغ المطلوب', '${student.requiredFee % 1 == 0 ? student.requiredFee.toInt() : student.requiredFee}'),
                _detailRow(ctx, Icons.check_circle_outline, 'المبلغ المدفوع', '${student.paidAmount % 1 == 0 ? student.paidAmount.toInt() : student.paidAmount}'),
                _detailRow(ctx, Icons.info_outline, 'حالة الدفع', student.paymentStatusArabic),
                if (student.remainingFee > 0)
                  _detailRow(ctx, Icons.hourglass_bottom_rounded, 'المتبقي', '${student.remainingFee % 1 == 0 ? student.remainingFee.toInt() : student.remainingFee}'),
                if (student.paymentNotes.isNotEmpty)
                  _detailRow(ctx, Icons.receipt_long_rounded, 'ملاحظات الدفع / الوصل', student.paymentNotes),
              ],
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryTeal,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () {
                        Navigator.pop(ctx);
                        onTransfer();
                      },
                      icon: const Icon(Icons.swap_horiz, color: Colors.white),
                      label: Text(
                        'نقل لحلقة أخرى',
                        style: GoogleFonts.cairo(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.primaryTeal),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () {
                        Navigator.pop(ctx);
                        onEdit();
                      },
                      icon: const Icon(Icons.edit_outlined, color: AppColors.primaryTeal),
                      label: Text(
                        'تعديل البيانات',
                        style: GoogleFonts.cairo(
                          color: AppColors.primaryTeal,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _detailRow(BuildContext context, IconData icon, String label, String value, {bool isPhone = false}) {
    if (value.trim().isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primaryTeal),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: GoogleFonts.cairo(
              fontSize: 13,
              color: AppColors.textMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.cairo(
                fontSize: 13,
                color: AppColors.textDark,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (isPhone)
            IconButton(
              icon: const Icon(Icons.copy_rounded, size: 16, color: AppColors.primaryTeal),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: value));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'تم نسخ $label: $value',
                      style: GoogleFonts.cairo(color: Colors.white),
                    ),
                    backgroundColor: AppColors.primaryTeal,
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              tooltip: 'نسخ الرقم',
            ),
        ],
      ),
    );
  }
}
