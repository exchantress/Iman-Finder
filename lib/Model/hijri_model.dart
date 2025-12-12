class HijriDate {
  final String gregorianDate;
  final String hijriDate;
  final String hijriMonth;
  final String hijriYear;
  final String weekdayEn;

  HijriDate({
    required this.gregorianDate,
    required this.hijriDate,
    required this.hijriMonth,
    required this.hijriYear,
    required this.weekdayEn,
  });

  factory HijriDate.fromJson(Map<String, dynamic> json) {
    return HijriDate(
      gregorianDate: json['gregorian']['date'],
      hijriDate: json['hijri']['day'],
      hijriMonth: json['hijri']['month']['en'],
      hijriYear: json['hijri']['year'],
      weekdayEn: json['gregorian']['weekday']['en'],
    );
  }
}
