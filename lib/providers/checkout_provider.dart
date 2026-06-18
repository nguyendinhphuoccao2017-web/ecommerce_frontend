import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/checkout_init_data.dart';
import '../services/api_service.dart';

class CheckoutState {
  final bool isLoading;
  final String? error;
  final CheckoutInitData? initData;
  final String? selectedAddressId;
  final String? selectedPaymentMethodId;
  final String? selectedDeliveryMethodId;

  CheckoutState({
    this.isLoading = false,
    this.error,
    this.initData,
    this.selectedAddressId,
    this.selectedPaymentMethodId,
    this.selectedDeliveryMethodId,
  });

  CheckoutState copyWith({
    bool? isLoading,
    String? error,
    CheckoutInitData? initData,
    String? selectedAddressId,
    String? selectedPaymentMethodId,
    String? selectedDeliveryMethodId,
  }) {
    return CheckoutState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      initData: initData ?? this.initData,
      selectedAddressId: selectedAddressId ?? this.selectedAddressId,
      selectedPaymentMethodId: selectedPaymentMethodId ?? this.selectedPaymentMethodId,
      selectedDeliveryMethodId: selectedDeliveryMethodId ?? this.selectedDeliveryMethodId,
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
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void selectDeliveryMethod(String id) {
    state = state.copyWith(selectedDeliveryMethodId: id);
  }

  Future<bool> submitOrder() async {
    if (state.selectedAddressId == null) {
      state = state.copyWith(error: 'Please select a shipping address');
      return false;
    }

    state = state.copyWith(isLoading: true, error: null);
    try {
      await _apiService.submitCheckout({
        'paymentMethod': state.selectedPaymentMethodId ?? 'Credit Card',
        'shippingAddressId': state.selectedAddressId,
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
