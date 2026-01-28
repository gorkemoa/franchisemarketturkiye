extension TurkishStringExtensions on String {
  String toTurkishLowerCase() {
    return replaceAll('İ', 'i').replaceAll('I', 'ı').toLowerCase();
  }

  String toTurkishUpperCase() {
    return replaceAll('i', 'İ').replaceAll('ı', 'I').toUpperCase();
  }

  bool turkishContains(String query) {
    return toTurkishLowerCase().contains(query.toTurkishLowerCase());
  }
}
