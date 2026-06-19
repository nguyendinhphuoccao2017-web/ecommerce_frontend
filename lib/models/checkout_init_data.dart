import 'package:ecommerce/models/cart_response.dart';
import 'package:ecommerce/models/customer_address.dart';

class PaymentMethod {
  final String id;
  final String lastFourDigits;
  final String cardType;
  final String cardholderName;
  final bool isDefault;

  PaymentMethod({
    required this.id,
    required this.lastFourDigits,
    required this.cardType,
    required this.cardholderName,
    required this.isDefault,
  });

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      id: json['id'],
      lastFourDigits: json['lastFourDigits'],
      cardType: json['cardType'],
      cardholderName: json['cardholderName'],
      isDefault: json['isDefault'] ?? false,
    );
  }
}

class ShippingZone {
  final String id;
  final String name;
  final String displayName;
  final bool freeShipping;
  final List<ShippingRate> shippingRates;

  ShippingZone({
    required this.id,
    required this.name,
    required this.displayName,
    required this.freeShipping,
    required this.shippingRates,
  });

  factory ShippingZone.fromJson(Map<String, dynamic> json) {
    var ratesList = json['shippingRates'] as List? ?? [];
    return ShippingZone(
      id: json['id'],
      name: json['name'] ?? '',
      displayName: json['displayName'] ?? '',
      freeShipping: json['freeShipping'] ?? false,
      shippingRates: ratesList.map((i) => ShippingRate.fromJson(i)).toList(),
    );
  }
}

class ShippingRate {
  final String id;
  final String weightUnit;
  final double price;
  final String? shippingZoneId;

  ShippingRate({
    required this.id,
    required this.weightUnit,
    required this.price,
    this.shippingZoneId,
  });

  factory ShippingRate.fromJson(Map<String, dynamic> json) {
    return ShippingRate(
      id: json['id'],
      weightUnit: json['weightUnit'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      shippingZoneId: json['shippingZone']?['id'],
    );
  }
}

class CheckoutInitData {
  final CustomerAddress? defaultAddress;
  final PaymentMethod? defaultPaymentMethod;
  final List<ShippingZone> shippingZones;
  final List<ShippingRate> shippingRates;
  final CartResponse? cart;

  CheckoutInitData({
    this.defaultAddress,
    this.defaultPaymentMethod,
    required this.shippingZones,
    required this.shippingRates,
    this.cart,
  });

  factory CheckoutInitData.fromJson(Map<String, dynamic> json) {
    var zonesList = json['shippingZones'] as List? ?? [];
    var ratesList = json['shippingRates'] as List? ?? [];
    return CheckoutInitData(
      defaultAddress: json['defaultAddress'] != null ? CustomerAddress.fromJson(json['defaultAddress']) : null,
      defaultPaymentMethod: json['defaultPaymentMethod'] != null ? PaymentMethod.fromJson(json['defaultPaymentMethod']) : null,
      shippingZones: zonesList.map((i) => ShippingZone.fromJson(i)).toList(),
      shippingRates: ratesList.map((i) => ShippingRate.fromJson(i)).toList(),
      cart: json['cart'] != null ? CartResponse.fromJson(json['cart']) : null,
    );
  }
}
