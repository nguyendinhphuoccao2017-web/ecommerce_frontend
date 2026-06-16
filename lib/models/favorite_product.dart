class FavoriteProduct {
  final String productId;
  final String productName;
  final String slug;
  final double salePrice;
  final double? comparePrice;
  final String? thumbnailUrl;
  final double averageRating;
  final int totalReviews;
  final bool isFavorite;
  final List<String> tags;
  final List<String> categories;
  final String? variantTitle;
  final String? variantOptionId;
  final String? sku;
  final int availableStock;

  FavoriteProduct({
    required this.productId,
    required this.productName,
    required this.slug,
    required this.salePrice,
    this.comparePrice,
    this.thumbnailUrl,
    required this.averageRating,
    required this.totalReviews,
    required this.isFavorite,
    required this.tags,
    required this.categories,
    this.variantTitle,
    this.variantOptionId,
    this.sku,
    required this.availableStock,
  });

  factory FavoriteProduct.fromJson(Map<String, dynamic> json) {
    return FavoriteProduct(
      productId: json['productId'] ?? '',
      productName: json['productName'] ?? '',
      slug: json['slug'] ?? '',
      salePrice: (json['salePrice'] ?? 0).toDouble(),
      comparePrice: json['comparePrice'] != null ? json['comparePrice'].toDouble() : null,
      thumbnailUrl: json['thumbnailUrl'],
      averageRating: (json['averageRating'] ?? 0).toDouble(),
      totalReviews: json['totalReviews'] ?? 0,
      isFavorite: json['isFavorite'] ?? true,
      tags: List<String>.from(json['tags'] ?? []),
      categories: List<String>.from(json['categories'] ?? []),
      variantTitle: json['variantTitle'],
      variantOptionId: json['variantOptionId'],
      sku: json['sku'],
      availableStock: json['availableStock'] ?? 0,
    );
  }
}
