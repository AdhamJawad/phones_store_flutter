class AiAdvisorSearchMeta {
  const AiAdvisorSearchMeta({
    required this.fallbackApplied,
    required this.matchStrategy,
    required this.resultCount,
    required this.appliedFilters,
    required this.relaxedFilters,
    this.rawQuery,
    this.matchedKeywords = const <String>[],
    this.providerFailureCode,
  });

  final bool fallbackApplied;
  final String matchStrategy;
  final int resultCount;
  final Map<String, dynamic> appliedFilters;
  final List<String> relaxedFilters;
  final String? rawQuery;
  final List<String> matchedKeywords;
  final String? providerFailureCode;
}
