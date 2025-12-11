class AsmaulHusna {
  final int number;
  final String name;
  final String transliteration;
  final String meaning;

  AsmaulHusna({
    required this.number,
    required this.name,
    required this.transliteration,
    required this.meaning,
  });

  factory AsmaulHusna.fromJson(Map<String, dynamic> json) {
    return AsmaulHusna(
      number: json['number'] ?? 0,
      name: json['name'] ?? '',
      transliteration: json['transliteration'] ?? '',
      meaning: json['en'] != null ? json['en']['meaning'] : '',
    );
  }
}
