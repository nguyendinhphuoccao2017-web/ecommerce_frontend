class Coupon {
  final String id;
  final String code;
  final double discountValue;
  final String discountType;
  final DateTime? couponStartDate;
  final DateTime? couponEndDate;

  Coupon({
    required this.id,
    required this.code,
    required this.discountValue,
    required this.discountType,
    this.couponStartDate,
    this.couponEndDate,
  });

  factory Coupon.fromJson(Map<String, dynamic> json) {
    return Coupon(
      id: json['id'],
      code: json['code'],
      discountValue: (json['discountValue'] as num).toDouble(),
      discountType: json['discountType'],
      couponStartDate: json['couponStartDate'] != null ? DateTime.parse(json['couponStartDate']) : null,
      couponEndDate: json['couponEndDate'] != null ? DateTime.parse(json['couponEndDate']) : null,
    );
  }
}
