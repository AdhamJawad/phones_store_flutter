enum ProductCtaType {
  inventoryBuyNow,
  marketplaceRequestOrder,
  unavailable,
}

class ProductCtaConfig {
  const ProductCtaConfig({
    required this.type,
    required this.titleKey,
    required this.subtitleKey,
    required this.enabled,
  });

  final ProductCtaType type;
  final String titleKey;
  final String subtitleKey;
  final bool enabled;
}
