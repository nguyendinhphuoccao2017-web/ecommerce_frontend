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
  final String? slug;
  final bool isFavorite;
  final List<String> tags;

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
    this.slug,
    this.isFavorite = false,
    this.tags = const [],
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
      slug: json['slug'],
      isFavorite: json['isFavorite'] ?? false,
      tags: json['tags'] != null ? List<String>.from(json['tags']) : [],
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
      slug: slug,
      isFavorite: isFavorite ?? this.isFavorite,
      tags: tags,
    );
  }
}
