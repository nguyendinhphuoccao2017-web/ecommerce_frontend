import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/checkout_init_data.dart';
import '../models/customer_address.dart';
import '../services/api_service.dart';
import 'auth_provider.dart';

class CheckoutState {
  final bool isLoading;
  final String? error;
  final CheckoutInitData? initData;
  final String? selectedAddressId;
  final String? selectedPaymentMethodId;
  final String? selectedDeliveryMethodId;
  
  // Backward compatibility for other screens
  final List<CustomerAddress> addresses;
  final CustomerAddress? selectedAddress;
  final String selectedPaymentMethod;
  
  // All payment methods for dynamic rendering
  final List<PaymentMethod> paymentMethods;

  CheckoutState({
    this.isLoading = false,
    this.error,
    this.initData,
    this.selectedAddressId,
    this.selectedPaymentMethodId,
    this.selectedDeliveryMethodId,
    this.addresses = const [],
    this.selectedAddress,
    this.selectedPaymentMethod = 'Credit Card',
    this.paymentMethods = const [],
  });

  CheckoutState copyWith({
    bool? isLoading,
    String? error,
    CheckoutInitData? initData,
    String? selectedAddressId,
    String? selectedPaymentMethodId,
    String? selectedDeliveryMethodId,
    List<CustomerAddress>? addresses,
    CustomerAddress? selectedAddress,
    String? selectedPaymentMethod,
    List<PaymentMethod>? paymentMethods,
  }) {
    return CheckoutState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      initData: initData ?? this.initData,
      selectedAddressId: selectedAddressId ?? this.selectedAddressId,
      selectedPaymentMethodId: selectedPaymentMethodId ?? this.selectedPaymentMethodId,
      selectedDeliveryMethodId: selectedDeliveryMethodId ?? this.selectedDeliveryMethodId,
      addresses: addresses ?? this.addresses,
      selectedAddress: selectedAddress ?? this.selectedAddress,
      selectedPaymentMethod: selectedPaymentMethod ?? this.selectedPaymentMethod,
      paymentMethods: paymentMethods ?? this.paymentMethods,
    );
  }
}

final checkoutProvider = StateNotifierProvider<CheckoutNotifier, CheckoutState>((ref) {
  return CheckoutNotifier(ref.read(apiServiceProvider));
});

class CheckoutNotifier extends StateNotifier<CheckoutState> {
  final ApiService _apiService;

  CheckoutNotifier(this._apiService) : super(CheckoutState()) {
    loadInitData();
    loadAddresses(); // Restore old method for screens that need it
  }

  Future<void> loadInitData() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final initData = await _apiService.getCheckoutInitData();
      state = state.copyWith(
        isLoading: false,
        initData: initData,
        selectedAddressId: initData.defaultAddress?.id,
        selectedPaymentMethodId: initData.defaultPaymentMethod?.id,
        selectedDeliveryMethodId: initData.shippingZones.isNotEmpty ? initData.shippingZones.first.id : null,
        // Sync backward compatibility fields
        selectedAddress: initData.defaultAddress,
        selectedPaymentMethod: initData.defaultPaymentMethod?.lastFourDigits ?? 'Credit Card',
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
    
    // Load mock payment methods for Giai đoạn 1
    final mockMethodsJson = [{"id":"14d133d7-0898-48cd-adc8-39d46ed5d327","card_type":"Visa","cardholder_name":"Thiện Lành Cuộc Sống","is_default":false,"last_four_digits":"4546","customer_id":"975d3e5e-1c18-47df-851e-2763f5294cae"},{"id":"16b6cd2a-77f9-4262-8e6c-a913a7826af5","card_type":"Visa","cardholder_name":"Nguyễn Đình Phước Cao 09_CNTT2_","is_default":false,"last_four_digits":"4546","customer_id":"4cfd3460-bdee-4c29-8237-e5584516ee65"},{"id":"2ba66298-7039-4984-a43d-461327d59b9a","card_type":"Mastercard","cardholder_name":"Nguyễn Đình Phước Cao 09_CNTT2_","is_default":true,"last_four_digits":"3947","customer_id":"4cfd3460-bdee-4c29-8237-e5584516ee65"},{"id":"629eaf65-587c-44ed-a41f-01d6664b369a","card_type":"Visa","cardholder_name":"Phước Cao","is_default":false,"last_four_digits":"4546","customer_id":"16cd73d2-4a28-4fef-8023-880173d2558a"},{"id":"651a6411-a2df-41e8-9d06-78349d68f38d","card_type":"Mastercard","cardholder_name":"Phước Cao","is_default":true,"last_four_digits":"3947","customer_id":"16cd73d2-4a28-4fef-8023-880173d2558a"},{"id":"8bb126d0-65d7-41a6-9e36-2defb896f672","card_type":"Mastercard","cardholder_name":"Christian Peter Joseph","is_default":true,"last_four_digits":"3947","customer_id":"5674de3a-67ad-4a89-afac-7cfaea75c991"},{"id":"93dc36fd-f035-4b05-9094-a11200adcd4b","card_type":"Mastercard","cardholder_name":"Thiện Lành Cuộc Sống","is_default":true,"last_four_digits":"3947","customer_id":"975d3e5e-1c18-47df-851e-2763f5294cae"},{"id":"cb96bcfb-9388-498f-88de-4ef8f0e27215","card_type":"Mastercard","cardholder_name":"cao nguyễn","is_default":true,"last_four_digits":"3947","customer_id":"139b7bcf-54ec-4b97-b6b8-53b885c9f457"},{"id":"da70d90b-8a95-4942-bf57-7778862715d7","card_type":"Visa","cardholder_name":"Christian Peter Joseph","is_default":false,"last_four_digits":"4546","customer_id":"5674de3a-67ad-4a89-afac-7cfaea75c991"},{"id":"ee50f550-1f8c-4cc2-8773-c004fa4300d5","card_type":"Visa","cardholder_name":"cao nguyễn","is_default":false,"last_four_digits":"4546","customer_id":"139b7bcf-54ec-4b97-b6b8-53b885c9f457"}];
    final methods = mockMethodsJson.map((e) => PaymentMethod.fromJson(e)).toList();
    state = state.copyWith(paymentMethods: methods);
  }

  Future<void> loadAddresses() async {
    try {
      final addresses = await _apiService.getShippingAddresses();
      state = state.copyWith(
        addresses: addresses,
        selectedAddress: state.selectedAddress ?? (addresses.isNotEmpty ? addresses.first : null),
      );
    } catch (e) {
      // ignore
    }
  }

  void selectAddress(CustomerAddress address) {
    state = state.copyWith(
      selectedAddress: address,
      selectedAddressId: address.id, // Keep in sync
    );
  }

  void selectPaymentMethod(String method) {
    state = state.copyWith(
      selectedPaymentMethod: method,
      selectedPaymentMethodId: method, // We don't have UUID here if it's the full number, but mock logic relies on String
    );
  }

  void selectDeliveryMethod(String id) {
    state = state.copyWith(selectedDeliveryMethodId: id);
  }

  Future<bool> addAddress(Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _apiService.addShippingAddress(data);
      await loadAddresses(); // Reload addresses to get the new one
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> updateAddress(String id, Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _apiService.updateShippingAddress(id, data);
      await loadAddresses(); // Reload addresses to get the updated one
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> submitOrder() async {
    if (state.selectedAddressId == null && state.selectedAddress == null) {
      state = state.copyWith(error: 'Please select a shipping address');
      return false;
    }

    state = state.copyWith(isLoading: true, error: null);
    try {
      await _apiService.submitCheckout({
        'paymentMethod': state.selectedPaymentMethodId ?? state.selectedPaymentMethod,
        'shippingAddressId': state.selectedAddressId ?? state.selectedAddress!.id,
        'deliveryMethod': state.selectedDeliveryMethodId ?? 'FedEx',
        'couponCode': null, 
      });
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
}
