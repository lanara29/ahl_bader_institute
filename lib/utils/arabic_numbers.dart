/// مساعد لمعالجة الأرقام العربية (المشرقية) والتحويل الآمن للأرقام
class ArabicNumbers {
  static const List<String> arabicIndic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
  static const List<String> english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];

  /// تحويل الأرقام المشرقية (٠-٩) إلى أرقام إنجليزية قياسية (0-9)
  static String normalize(String input) {
    String result = input;
    for (int i = 0; i < 10; i++) {
      result = result.replaceAll(arabicIndic[i], english[i]);
    }
    return result;
  }

  /// تحليل آمن للأرقام العشرية مع دعم الأرقام العربية والإنجليزية
  static double? parseDouble(String? input) {
    if (input == null || input.trim().isEmpty) return null;
    final normalized = normalize(input.trim());
    return double.tryParse(normalized);
  }

  /// تحليل آمن للأرقام الصحيحة مع دعم الأرقام العربية والإنجليزية
  static int? parseInt(String? input) {
    if (input == null || input.trim().isEmpty) return null;
    final normalized = normalize(input.trim());
    return int.tryParse(normalized);
  }
}
