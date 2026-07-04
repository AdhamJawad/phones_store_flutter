import '../../domain/entities/ai_advisor_search_meta.dart';

class AiAdvisorSearchMetaModel extends AiAdvisorSearchMeta {
  const AiAdvisorSearchMetaModel({
    required super.fallbackApplied,
    required super.matchStrategy,
    required super.resultCount,
    required super.appliedFilters,
    required super.relaxedFilters,
    super.rawQuery,
    super.matchedKeywords,
    super.providerFailureCode,
  });

  factory AiAdvisorSearchMetaModel.fromJson(Map<String, dynamic> json) {
    return AiAdvisorSearchMetaModel(
      fallbackApplied: json['fallback_applied'] as bool? ?? false,
      matchStrategy: json['match_strategy'] as String? ?? '',
      resultCount: (json['result_count'] as num?)?.toInt() ?? 0,
      appliedFilters: json['applied_filters'] is Map<String, dynamic>
          ? json['applied_filters'] as Map<String, dynamic>
          : json['applied_filters'] is Map
          ? Map<String, dynamic>.from(json['applied_filters'] as Map)
          : const <String, dynamic>{},
      relaxedFilters:
          (json['relaxed_filters'] as List?)
              ?.map((value) => '$value')
              .toList(growable: false) ??
          const <String>[],
      rawQuery: json['raw_query'] as String?,
      matchedKeywords:
          (json['matched_keywords'] as List?)
              ?.map((value) => '$value')
              .toList(growable: false) ??
          const <String>[],
      providerFailureCode: json['provider_failure_code'] as String?,
    );
  }
}
