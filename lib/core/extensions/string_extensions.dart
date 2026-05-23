extension StringExtensions on String {
  bool get isUrl => startsWith('http://') || startsWith('https://');
}
