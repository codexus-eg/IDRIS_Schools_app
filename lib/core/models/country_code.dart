class CountryCode {
  const CountryCode({
    required this.nameAr,
    required this.nameEn,
    required this.flag,
    required this.dialCode,
  });

  final String nameAr;
  final String nameEn;
  final String flag;
  final String dialCode;

  String label(bool isArabic) {
    final String countryName = isArabic ? nameAr : nameEn;
    return '$flag  $dialCode  $countryName';
  }
}

abstract final class CountryCodes {
  static const List<CountryCode> all = [
    CountryCode(nameAr: 'السودان', nameEn: 'Sudan', flag: '🇸🇩', dialCode: '+249'),
    CountryCode(nameAr: 'الإمارات', nameEn: 'UAE', flag: '🇦🇪', dialCode: '+971'),
    CountryCode(nameAr: 'مصر', nameEn: 'Egypt', flag: '🇪🇬', dialCode: '+20'),
    CountryCode(nameAr: 'السعودية', nameEn: 'Saudi Arabia', flag: '🇸🇦', dialCode: '+966'),
    CountryCode(nameAr: 'قطر', nameEn: 'Qatar', flag: '🇶🇦', dialCode: '+974'),
    CountryCode(nameAr: 'عمان', nameEn: 'Oman', flag: '🇴🇲', dialCode: '+968'),
    CountryCode(nameAr: 'الكويت', nameEn: 'Kuwait', flag: '🇰🇼', dialCode: '+965'),
    CountryCode(nameAr: 'البحرين', nameEn: 'Bahrain', flag: '🇧🇭', dialCode: '+973'),
    CountryCode(nameAr: 'المملكة المتحدة', nameEn: 'United Kingdom', flag: '🇬🇧', dialCode: '+44'),
  ];

  static CountryCode get defaultCountry => all.first;
}
