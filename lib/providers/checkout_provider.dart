import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/customer_address.dart';
import '../services/api_service.dart';
import 'auth_provider.dart';

class CheckoutState {
  final bool isLoading;
  final String? error;
  final CustomerAddress? selectedAddress;
  final String selectedPaymentMethod;
  final List<CustomerAddress> addresses;

  CheckoutState({
    this.isLoading = false,
    this.error,
    this.selectedAddress,
    this.selectedPaymentMethod = 'Credit Card',
    this.addresses = const [],
  });

  CheckoutState copyWith({
    bool? isLoading,
    String? error,
    CustomerAddress? selectedAddress,
    String? selectedPaymentMethod,
    List<CustomerAddress>? addresses,
  }) {
    return CheckoutState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      selectedAddress: selectedAddress ?? this.selectedAddress,
      selectedPaymentMethod: selectedPaymentMethod ?? this.selectedPaymentMethod,
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
      // In a real app we'd pass the address ID and payment method.
      // The backend expects CheckoutRequestDTO
      await _apiService.submitCheckout({
        'paymentMethod': state.selectedPaymentMethod,
        // 'addressId': state.selectedAddress!.id,
      });
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
}
