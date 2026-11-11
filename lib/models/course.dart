class Course {
  final dynamic id;
  final String name;
  final String season; // 'summer' (صيفية) or 'winter' (شتوية)
  final int year;
  final double fee; // رسم الدورة - إجباري
  final String startDate;
  final String endDate;
  final bool isActive;
  final String notes;

  final List<int> workingDays; // Dart DateTime weekday: 6=السبت, 7=الأحد, 1=الإثنين, 2=الثلاثاء, 3=الأربعاء, 4=الخميس, 5=الجمعة

  static const Map<int, String> dayNamesArabic = {
    DateTime.saturday: 'السبت',
    DateTime.sunday: 'الأحد',
    DateTime.monday: 'الإثنين',
    DateTime.tuesday: 'الثلاثاء',
    DateTime.wednesday: 'الأربعاء',
    DateTime.thursday: 'الخميس',
    DateTime.friday: 'الجمعة',
  };

  Course({
    this.id,
    required this.name,
    required this.season,
    required this.year,
    required this.fee,
    this.startDate = '',
    this.endDate = '',
    this.isActive = false,
    this.notes = '',
    List<int>? workingDays,
  }) : workingDays = workingDays ??
            (season.toLowerCase() == 'winter' || season == 'شتوية'
                ? const [DateTime.saturday]
                : const [DateTime.saturday, DateTime.sunday, DateTime.tuesday]);

  bool get isSummer => season.toLowerCase() == 'summer' || season == 'صيفية';

  String get seasonArabic => isSummer ? 'دورة صيفية' : 'دورة شتوية';

  /// نص أيام الدوام بالعربية مثل: 'السبت، الأحد، الثلاثاء'
  String get workingDaysArabic {
    if (workingDays.isEmpty) return 'لم تحدد';
    // ترتيب الأيام حسب الأسبوع الشرعي بدءاً من السبت
    final order = [
      DateTime.saturday,
      DateTime.sunday,
      DateTime.monday,
      DateTime.tuesday,
      DateTime.wednesday,
      DateTime.thursday,
      DateTime.friday,
    ];
    final sorted = List<int>.from(workingDays)
      ..sort((a, b) => order.indexOf(a).compareTo(order.indexOf(b)));
    return sorted.map((d) => dayNamesArabic[d] ?? '').where((s) => s.isNotEmpty).join('، ');
  }

  /// هل هذا التاريخ هو يوم دوام في هذه الدورة؟
  bool isWorkingDay(DateTime date) {
    if (workingDays.isEmpty) return true; // لو لم تحدد نعتبر كل الأيام متاحة
    return workingDays.contains(date.weekday);
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'name': name,
      'season': season,
      'year': year,
      'fee': fee,
      'start_date': startDate,
      'end_date': endDate,
      'is_active': isActive,
      'notes': notes,
      'working_days': workingDays,
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }

  factory Course.fromMap(Map<String, dynamic> map, [String? docId]) {
    final rawDays = map['working_days'] as List<dynamic>?;
    final seasonVal = map['season'] as String? ?? 'summer';
    final defaultDays = (seasonVal.toLowerCase() == 'winter' || seasonVal == 'شتوية')
        ? const [DateTime.saturday]
        : const [DateTime.saturday, DateTime.sunday, DateTime.tuesday];

    final daysList = rawDays != null
        ? rawDays.map((e) => (e as num).toInt()).toList()
        : defaultDays;

    return Course(
      id: docId ?? map['id'],
      name: map['name'] as String? ?? '',
      season: seasonVal,
      year: (map['year'] as num?)?.toInt() ?? DateTime.now().year,
      fee: (map['fee'] as num?)?.toDouble() ?? 0.0,
      startDate: map['start_date'] as String? ?? '',
      endDate: map['end_date'] as String? ?? '',
      isActive: map['is_active'] as bool? ?? false,
      notes: map['notes'] as String? ?? '',
      workingDays: daysList,
    );
  }

  Course copyWith({
    dynamic id,
    String? name,
    String? season,
    int? year,
    double? fee,
    String? startDate,
    String? endDate,
    bool? isActive,
    String? notes,
    List<int>? workingDays,
  }) {
    return Course(
      id: id ?? this.id,
      name: name ?? this.name,
      season: season ?? this.season,
      year: year ?? this.year,
      fee: fee ?? this.fee,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
      notes: notes ?? this.notes,
      workingDays: workingDays ?? this.workingDays,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Course &&
          runtimeType == other.runtimeType &&
          ((id != null && other.id != null && id.toString() == other.id.toString()) ||
              (id == null && other.id == null && name == other.name));

  @override
  int get hashCode => id?.toString().hashCode ?? name.hashCode;
}
