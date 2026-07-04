import '../../../products/data/models/product_model.dart';
import '../../domain/entities/ai_advisor_result.dart';
import 'ai_advisor_search_meta_model.dart';

class AiAdvisorResultModel extends AiAdvisorResult {
  const AiAdvisorResultModel({
    required super.products,
    required super.fallback,
    required super.searchMeta,
    super.filters,
  });

  factory AiAdvisorResultModel.fromJson(Map<String, dynamic> json) {
    return AiAdvisorResultModel(
      filters: json['filters'] is Map<String, dynamic>
          ? json['filters'] as Map<String, dynamic>
          : json['filters'] is Map
          ? Map<String, dynamic>.from(json['filters'] as Map)
          : null,
      products:
          (json['products'] as List?)
              ?.whereType<Map>()
              .map(
                (item) =>
                    ProductModel.fromJson(Map<String, dynamic>.from(item)),
              )
              .toList(growable: false) ??
          const <ProductModel>[],
      fallback: json['fallback'] as bool? ?? false,
      searchMeta: json['search_meta'] is Map<String, dynamic>
          ? AiAdvisorSearchMetaModel.fromJson(
              json['search_meta'] as Map<String, dynamic>,
            )
          : json['search_meta'] is Map
          ? AiAdvisorSearchMetaModel.fromJson(
              Map<String, dynamic>.from(json['search_meta'] as Map),
            )
          : null,
    );
  }
}
