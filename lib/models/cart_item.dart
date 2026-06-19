class CartItem {
  final String id;
  final String productId;
  final String productName;
  final String sku;
  final double salePrice;
  final String? image;
  final String? variantOptionId;
  final String? variantTitle;
  final String? color;
  final String? size;
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
    this.color,
    this.size,
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
      color: json['color'],
      size: json['size'],
      quantity: json['quantity'] ?? 1,
      maxQuantity: json['maxQuantity'] ?? 1,
    );
  }

  CartItem copyWith({
    String? id,
    String? productId,
    String? productName,
    String? sku,
    double? salePrice,
    String? image,
    String? variantOptionId,
    String? variantTitle,
    String? color,
    String? size,
    int? quantity,
    int? maxQuantity,
  }) {
    return CartItem(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      sku: sku ?? this.sku,
      salePrice: salePrice ?? this.salePrice,
      image: image ?? this.image,
      variantOptionId: variantOptionId ?? this.variantOptionId,
      variantTitle: variantTitle ?? this.variantTitle,
      color: color ?? this.color,
      size: size ?? this.size,
      quantity: quantity ?? this.quantity,
      maxQuantity: maxQuantity ?? this.maxQuantity,
    );
  }
}
