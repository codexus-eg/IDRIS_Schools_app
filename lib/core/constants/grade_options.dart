abstract final class GradeOptions {
  static const List<String> sudaneseArabic = [
    'الروضة الأولى',
    'الروضة الثانية',
    'التمهيدي',
    'الصف الأول الابتدائي',
    'الصف الثاني الابتدائي',
    'الصف الثالث الابتدائي',
    'الصف الرابع الابتدائي',
    'الصف الخامس الابتدائي',
    'الصف السادس الابتدائي',
    'الصف الأول المتوسط',
    'الصف الثاني المتوسط',
    'الصف الثالث المتوسط',
    'الصف الأول الثانوي',
    'الصف الثاني الثانوي',
    'الصف الثالث الثانوي',
  ];

  static const List<String> cambridgeEnglish = [
    'Pre-K',
    'KG1',
    'KG2',
    'Grade 1',
    'Grade 2',
    'Grade 3',
    'Grade 4',
    'Grade 5',
    'Grade 6',
    'Grade 7',
    'Grade 8',
    'Grade 9',
    'Grade 10',
    'Grade 11',
    'Grade 12',
  ];

  static List<String> byCurriculum(String curriculum) {
    return curriculum == 'cambridge' ? cambridgeEnglish : sudaneseArabic;
  }
}
