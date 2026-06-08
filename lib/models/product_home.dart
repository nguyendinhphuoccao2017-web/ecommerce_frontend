class ProductHome {
  final String id;
  final String productName;
  final double salePrice;
  final double comparePrice;
  final String? thumbnailUrl;
  final double averageRating;
  final int totalReviews;

  ProductHome({
    required this.id,
    required this.productName,
    required this.salePrice,
    required this.comparePrice,
    this.thumbnailUrl,
    required this.averageRating,
    required this.totalReviews,
  });

  factory ProductHome.fromJson(Map<String, dynamic> json) {
    return ProductHome(
      id: json['id'] ?? '',
      productName: json['productName'] ?? '',
      salePrice: (json['salePrice'] as num?)?.toDouble() ?? 0.0,
      comparePrice: (json['comparePrice'] as num?)?.toDouble() ?? 0.0,
      thumbnailUrl: json['thumbnailUrl'],
      averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0.0,
      totalReviews: json['totalReviews'] ?? 0,
    );
  }
}
