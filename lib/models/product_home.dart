class ProductHome {
  final String id;
  final String productName;
  final double salePrice;
  final double comparePrice;
  final String? thumbnailUrl;
  final double averageRating;
  final int totalReviews;
  final String? placeholder;
  final String? sku;
  final bool isFavorite;

  ProductHome({
    required this.id,
    required this.productName,
    required this.salePrice,
    required this.comparePrice,
    this.thumbnailUrl,
    required this.averageRating,
    required this.totalReviews,
    this.placeholder,
    this.sku,
    this.isFavorite = false,
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
      placeholder: json['placeholder'],
      sku: json['sku'],
      isFavorite: json['isFavorite'] ?? false,
    );
  }

  ProductHome copyWith({
    bool? isFavorite,
  }) {
    return ProductHome(
      id: id,
      productName: productName,
      salePrice: salePrice,
      comparePrice: comparePrice,
      thumbnailUrl: thumbnailUrl,
      averageRating: averageRating,
      totalReviews: totalReviews,
      placeholder: placeholder,
      sku: sku,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
