import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/customer_address.dart';
import '../services/api_service.dart';
import 'auth_provider.dart';

class CheckoutState {
  final bool isLoading;
  final String? error;
  final CustomerAddress? selectedAddress;
  final String selectedPaymentMethod;
  final String selectedDeliveryMethod;
  final List<CustomerAddress> addresses;

  CheckoutState({
    this.isLoading = false,
    this.error,
    this.selectedAddress,
    this.selectedPaymentMethod = 'Credit Card',
    this.selectedDeliveryMethod = 'FedEx',
    this.addresses = const [],
  });

  CheckoutState copyWith({
    bool? isLoading,
    String? error,
    CustomerAddress? selectedAddress,
    String? selectedPaymentMethod,
    String? selectedDeliveryMethod,
    List<CustomerAddress>? addresses,
  }) {
    return CheckoutState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      selectedAddress: selectedAddress ?? this.selectedAddress,
      selectedPaymentMethod: selectedPaymentMethod ?? this.selectedPaymentMethod,
      selectedDeliveryMethod: selectedDeliveryMethod ?? this.selectedDeliveryMethod,
      addresses: addresses ?? this.addresses,
    );
  }
}

final checkoutProvider = StateNotifierProvider<CheckoutNotifier, CheckoutState>((ref) {
  return CheckoutNotifier(ref.read(apiServiceProvider));
});

class CheckoutNotifier extends StateNotifier<CheckoutState> {
  final ApiService _apiService;

  CheckoutNotifier(this._apiService) : super(CheckoutState()) {
    loadAddresses();
  }

  Future<void> loadAddresses() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final addresses = await _apiService.getShippingAddresses();
      state = state.copyWith(
        isLoading: false,
        addresses: addresses,
        selectedAddress: addresses.isNotEmpty ? addresses.first : null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void selectAddress(CustomerAddress address) {
    state = state.copyWith(selectedAddress: address);
  }

  void selectPaymentMethod(String method) {
    state = state.copyWith(selectedPaymentMethod: method);
  }

  void selectDeliveryMethod(String method) {
    state = state.copyWith(selectedDeliveryMethod: method);
  }

  Future<bool> addAddress(Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _apiService.addShippingAddress(data);
      await loadAddresses(); // Reload addresses to get the new one
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
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> submitOrder() async {
    if (state.selectedAddress == null) {
      state = state.copyWith(error: 'Please select a shipping address');
      return false;
    }

    state = state.copyWith(isLoading: true, error: null);
    try {
      await _apiService.submitCheckout({
        'paymentMethod': state.selectedPaymentMethod,
        'shippingAddressId': state.selectedAddress!.id,
        'deliveryMethod': state.selectedDeliveryMethod,
        // couponCode can be added here if you have a couponProvider
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
