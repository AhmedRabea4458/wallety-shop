/// Converts Arabic numerals (٠-٩) to Western numerals (0-9).
/// Also handles mixed input and common Arabic decimal separators.
String arabicToWesternNumerals(String input) {
  const arabicToWestern = {
    '٠': '0',
    '١': '1',
    '٢': '2',
    '٣': '3',
    '٤': '4',
    '٥': '5',
    '٦': '6',
    '٧': '7',
    '٨': '8',
    '٩': '9',
    '٫': '.', // Arabic decimal separator
  };

  return input.split('').map((char) => arabicToWestern[char] ?? char).join('');
}

/// Converts Western numerals to Arabic numerals for display.
String westernToArabicNumerals(String input) {
  const westernToArabic = {
    '0': '٠',
    '1': '١',
    '2': '٢',
    '3': '٣',
    '4': '٤',
    '5': '٥',
    '6': '٦',
    '7': '٧',
    '8': '٨',
    '9': '9',
    '.': '٫',
  };

  return input.split('').map((char) => westernToArabic[char] ?? char).join('');
}

/// Parses a string that may contain Arabic or Western numerals to a double.
double parseArabicNumerals(String input) {
  final western = arabicToWesternNumerals(input);
  return double.tryParse(western) ?? 0.0;
}
