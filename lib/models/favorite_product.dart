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
  final String? variantTitle;
  final String? variantOptionId;
  final String? sku;

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
    this.variantTitle,
    this.variantOptionId,
    this.sku,
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
      variantTitle: json['variantTitle'],
      variantOptionId: json['variantOptionId'],
      sku: json['sku'],
    );
  }
}
