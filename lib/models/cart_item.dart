class CartItem {
  final String id;
  final String productId;
  final String productName;
  final String sku;
  final double salePrice;
  final String? image;
  final String? variantOptionId;
  final String? variantTitle;
  final int quantity;
  final int maxQuantity;

  CartItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.sku,
    required this.salePrice,
    this.image,
    this.variantOptionId,
    this.variantTitle,
    required this.quantity,
    required this.maxQuantity,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'],
      productId: json['productId'],
      productName: json['productName'],
      sku: json['sku'],
      salePrice: (json['salePrice'] ?? 0).toDouble(),
      image: json['image'],
      variantOptionId: json['variantOptionId'],
      variantTitle: json['variantTitle'],
      quantity: json['quantity'] ?? 1,
      maxQuantity: json['maxQuantity'] ?? 1,
    );
  }
}
