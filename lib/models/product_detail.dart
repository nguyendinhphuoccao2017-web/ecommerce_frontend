class ProductDetail {
  final String id;
  final String productName;
  final String sku;
  final double salePrice;
  final double comparePrice;
  final double averageRating;
  final int totalReviews;
  final String shortDescription;
  final String productDescription;
  final bool isFavorite;
  final List<String> galleries;
  final List<String> tags;
  final int cartQuantity;

  ProductDetail({
    required this.id,
    required this.productName,
    required this.sku,
    required this.salePrice,
    required this.comparePrice,
    required this.averageRating,
    required this.totalReviews,
    required this.shortDescription,
    required this.productDescription,
    required this.isFavorite,
    required this.galleries,
    required this.tags,
    required this.cartQuantity,
  });

  factory ProductDetail.fromJson(Map<String, dynamic> json) {
    return ProductDetail(
      id: json['id'],
      productName: json['productName'] ?? '',
      sku: json['sku'] ?? '',
      salePrice: (json['salePrice'] ?? 0).toDouble(),
      comparePrice: (json['comparePrice'] ?? 0).toDouble(),
      averageRating: (json['averageRating'] ?? 0).toDouble(),
      totalReviews: json['totalReviews'] ?? 0,
      shortDescription: json['shortDescription'] ?? '',
      productDescription: json['productDescription'] ?? '',
      isFavorite: json['isFavorite'] ?? false,
      galleries: List<String>.from(json['galleries'] ?? []),
      tags: List<String>.from(json['tags'] ?? []),
      cartQuantity: json['cartQuantity'] ?? 0,
    );
  }
}
