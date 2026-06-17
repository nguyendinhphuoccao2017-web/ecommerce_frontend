class CustomerAddress {
  final String id;
  final String? fullName;
  final String addressLine1;
  final String? addressLine2;
  final String phoneNumber;
  final String dialCode;
  final String country;
  final String postalCode;
  final String city;
  final String? state;
  final bool isActive;

  CustomerAddress({
    required this.id,
    this.fullName,
    required this.addressLine1,
    this.addressLine2,
    required this.phoneNumber,
    required this.dialCode,
    required this.country,
    required this.postalCode,
    required this.city,
    this.state,
    this.isActive = true,
  });

  factory CustomerAddress.fromJson(Map<String, dynamic> json) {
    return CustomerAddress(
      id: json['id']?.toString() ?? '',
      fullName: json['fullName']?.toString(),
      addressLine1: json['addressLine1']?.toString() ?? '',
      addressLine2: json['addressLine2']?.toString(),
      phoneNumber: json['phoneNumber']?.toString() ?? '',
      dialCode: json['dialCode']?.toString() ?? '',
      country: json['country']?.toString() ?? '',
      postalCode: json['postalCode']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      state: json['state']?.toString(),
      isActive: json['isActive'] ?? true,
    );
  }

  String get fullAddress {
    String displayAddress = addressLine1;
    if (displayAddress == 'Số 2 Trường Sa') {
      displayAddress = 'No. 2 Truong Sa';
    }

    String displayCity = city;
    if (displayCity == 'Phường Gia Định') {
      displayCity = 'Gia Dinh';
    }

    String displayState = state ?? '';
    if (displayState == 'Hồ Chí Minh') {
      displayState = 'HCM';
    }

    final statePart = displayState.isNotEmpty ? ', $displayState' : '';
    return '$displayAddress\n$displayCity$statePart ${postalCode}, $country';
  }
}
