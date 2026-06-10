class VariantOption {
  final String id;
  final String title;
  final double salePrice;
  final double? comparePrice;
  final int quantity;
  final String? imageUrl;

  VariantOption({
    required this.id,
    required this.title,
    required this.salePrice,
    this.comparePrice,
    required this.quantity,
    this.imageUrl,
  });

  factory VariantOption.fromJson(Map<String, dynamic> json) {
    return VariantOption(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      salePrice: (json['salePrice'] ?? 0).toDouble(),
      comparePrice: json['comparePrice'] != null ? json['comparePrice'].toDouble() : null,
      quantity: json['quantity'] ?? 0,
      imageUrl: json['imageUrl'],
    );
  }
}
