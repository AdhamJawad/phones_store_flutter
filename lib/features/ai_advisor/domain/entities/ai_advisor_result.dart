import '../../../products/domain/entities/product.dart';
import 'ai_advisor_search_meta.dart';

class AiAdvisorResult {
  const AiAdvisorResult({
    required this.products,
    required this.fallback,
    required this.searchMeta,
    this.filters,
  });

  final Map<String, dynamic>? filters;
  final List<Product> products;
  final bool fallback;
  final AiAdvisorSearchMeta? searchMeta;
}
