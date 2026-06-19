import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/checkout_init_data.dart';
import '../models/customer_address.dart';
import '../services/api_service.dart';
import 'auth_provider.dart';
import 'cart_provider.dart';

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
  return CheckoutNotifier(ref.read(apiServiceProvider), ref);
});

class CheckoutNotifier extends StateNotifier<CheckoutState> {
  final ApiService _apiService;
  final Ref _ref;

  CheckoutNotifier(this._apiService, this._ref) : super(CheckoutState()) {
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
    
    // Load payment methods from API (Giai đoạn 2)
    try {
      final methods = await _apiService.getCustomerPaymentMethods();
      state = state.copyWith(paymentMethods: methods);
    } catch (e) {
      print('=== ERROR FETCHING PAYMENT METHODS ===');
      print(e.toString());
    }
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
      
      // Invalidate the cart so it re-fetches and clears out the purchased items
      _ref.invalidate(cartProvider);
      
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
}
