import 'cart_item.dart';

class CartResponse {
  final String cardId;
  final List<CartItem> items;
  final double subtotal;

  CartResponse({
    required this.cardId,
    required this.items,
    required this.subtotal,
  });

  factory CartResponse.fromJson(Map<String, dynamic> json) {
    var itemsList = json['items'] as List? ?? [];
    List<CartItem> items = itemsList.map((i) => CartItem.fromJson(i)).toList();
    
    return CartResponse(
      cardId: json['cardId'],
      items: items,
      subtotal: (json['subtotal'] ?? 0).toDouble(),
    );
  }
}
