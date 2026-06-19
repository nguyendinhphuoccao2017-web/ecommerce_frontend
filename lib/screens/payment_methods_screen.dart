import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/checkout_provider.dart';
import '../widgets/payment_card_widget.dart';
import '../utils/string_utils.dart';

class PaymentMethodsScreen extends ConsumerStatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  ConsumerState<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends ConsumerState<PaymentMethodsScreen> {
  String selectedDefaultCard = '3947';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentMethod = ref.read(checkoutProvider).selectedPaymentMethod;
      if (currentMethod == 'Credit Card' || currentMethod == 'PayPal') {
         ref.read(checkoutProvider.notifier).selectPaymentMethod('5546 8205 3693 3947');
      } else if (currentMethod.contains('4546')) {
         setState(() { selectedDefaultCard = '4546'; });
      } else {
         setState(() { selectedDefaultCard = '3947'; });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF222222)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Payment methods',
          style: TextStyle(
            fontFamily: 'Metropolis',
            fontWeight: FontWeight.bold,
            fontSize: 18,
            height: 22 / 18,
            color: Color(0xFF222222),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(left: 16, right: 16, top: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your payment cards',
              style: TextStyle(
                fontFamily: 'Metropolis',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF222222),
                height: 1,
              ),
            ),
            const SizedBox(height: 29),
            ...ref.watch(checkoutProvider).paymentMethods.map((method) {
              bool isVisa = method.cardType.toLowerCase() == 'visa';
              String fullNumber = isVisa ? '4532 7182 9381 ${method.lastFourDigits}' : '5546 8205 3693 ${method.lastFourDigits}';
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 32.0),
                child: _buildCardItem(
                  maskedNumber: '**** **** **** ${method.lastFourDigits}',
                  fullNumber: fullNumber,
                  cardHolderName: formatCardHolderName(method.cardholderName),
                  expiryDate: '12/25', // Mock expiry date since it's not in DB
                  isBlackCard: !isVisa, // Mastercard -> Black, Visa -> Grey
                  isVisa: isVisa,
                  id: method.lastFourDigits,
                ),
              );
            }).toList(),
            const SizedBox(height: 48),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddCardBottomSheet(context);
        },
        backgroundColor: const Color(0xFF222222),
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildCardItem({
    required String maskedNumber,
    required String fullNumber,
    required String cardHolderName,
    required String expiryDate,
    required bool isBlackCard,
    required bool isVisa,
    required String id,
  }) {
    bool isSelected = selectedDefaultCard == id;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            _showAddCardBottomSheet(context, lastFourDigits: id, cardHolderName: cardHolderName, isDefault: isSelected, fullNumber: fullNumber);
          },
          child: PaymentCardWidget(
            isBlackCard: isBlackCard,
            cardNumber: maskedNumber,
            cardHolderName: cardHolderName,
            expiryDate: expiryDate,
            isVisa: isVisa,
          ),
        ),
        const SizedBox(height: 24),
        GestureDetector(
          onTap: () {
            setState(() {
              selectedDefaultCard = id;
            });
            ref.read(checkoutProvider.notifier).selectPaymentMethod(fullNumber);
          },
          child: Row(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF222222) : Colors.transparent,
                  borderRadius: BorderRadius.circular(4),
                  border: isSelected 
                      ? null 
                      : Border.all(color: const Color(0xFF9B9B9B), width: 2),
                ),
                child: isSelected 
                    ? const Icon(Icons.check, color: Colors.white, size: 16)
                    : null,
              ),
              const SizedBox(width: 13),
              const Text(
                'Use as default payment method',
                style: TextStyle(
                  fontFamily: 'Metropolis',
                  fontSize: 14,
                  color: Color(0xFF222222),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showAddCardBottomSheet(BuildContext context, {String? lastFourDigits, String? cardHolderName, bool isDefault = false, String? fullNumber}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddCardBottomSheet(
        initialLastFour: lastFourDigits,
        initialCardHolderName: cardHolderName,
        initialIsDefault: isDefault,
        onDefaultChanged: (newIsDefault) {
          if (lastFourDigits != null && fullNumber != null) {
            setState(() {
              selectedDefaultCard = newIsDefault ? lastFourDigits : '';
            });
            if (newIsDefault) {
              ref.read(checkoutProvider.notifier).selectPaymentMethod(fullNumber);
            }
          }
        },
      ),
    );
  }
}

class AddCardBottomSheet extends StatefulWidget {
  final String? initialLastFour;
  final String? initialCardHolderName;
  final bool initialIsDefault;
  final ValueChanged<bool>? onDefaultChanged;

  const AddCardBottomSheet({
    super.key, 
    this.initialLastFour, 
    this.initialCardHolderName, 
    this.initialIsDefault = false,
    this.onDefaultChanged,
  });

  @override
  State<AddCardBottomSheet> createState() => _AddCardBottomSheetState();
}

class _AddCardBottomSheetState extends State<AddCardBottomSheet> {
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _expiryController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();
  bool isDefault = false;

  @override
  void initState() {
    super.initState();
    isDefault = widget.initialIsDefault;
    
    // Apply exact mapping logic for existing cards based on last_four_digits
    if (widget.initialLastFour != null) {
      if (widget.initialLastFour == '3947') {
        _cardNumberController.text = '5546 8205 3693 3947';
        _nameController.text = widget.initialCardHolderName ?? 'Jennyfer Doe';
        _expiryController.text = '05/23';
        _cvvController.text = '567';
      } else if (widget.initialLastFour == '4546') {
        _cardNumberController.text = '4532 7182 9381 4546';
        _nameController.text = widget.initialCardHolderName ?? 'Jennyfer Doe';
        _expiryController.text = '11/22';
        _cvvController.text = '567';
      }
    }

    _cardNumberController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _nameController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  Widget? _getCardLogo() {
    final text = _cardNumberController.text.replaceAll(' ', '');
    if (text.isEmpty) return null;
    
    if (text.startsWith('5')) {
      return Container(
        width: 40,
        height: 32,
        padding: const EdgeInsets.only(right: 8),
        alignment: Alignment.centerRight,
        child: Image.network(
          'https://nddvgywmwxlmkmextxre.supabase.co/storage/v1/object/public/payment/mastercard_checkout.png',
          width: 32,
          height: 20,
          fit: BoxFit.contain,
        ),
      );
    } else if (text.startsWith('4')) {
      return Container(
        width: 40,
        height: 32,
        padding: const EdgeInsets.only(right: 8),
        alignment: Alignment.centerRight,
        child: Image.network(
          'https://nddvgywmwxlmkmextxre.supabase.co/storage/v1/object/public/payment/visa_checkout.png',
          width: 32,
          height: 20,
          fit: BoxFit.contain,
        ),
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF9F9F9),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(34),
          topRight: Radius.circular(34),
        ),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 14,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 6,
              decoration: BoxDecoration(
                color: const Color(0xFF9B9B9B),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Add new card',
              style: TextStyle(
                fontFamily: 'Metropolis',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF222222),
                height: 22 / 18,
              ),
            ),
            const SizedBox(height: 22),
            _buildTextField(label: 'Name on card', controller: _nameController),
            const SizedBox(height: 20),
            _buildTextField(
              label: 'Card number',
              controller: _cardNumberController,
              suffixIconWidget: _getCardLogo(),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            _buildTextField(label: 'Expire Date', controller: _expiryController),
            const SizedBox(height: 20),
            _buildTextField(
              label: 'CVV',
              controller: _cvvController,
              suffixIconWidget: const Icon(Icons.help_outline, color: Color(0xFF9B9B9B)),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () {
                setState(() {
                  isDefault = !isDefault;
                });
                if (widget.onDefaultChanged != null) {
                  widget.onDefaultChanged!(isDefault);
                }
              },
              child: Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: isDefault ? const Color(0xFF222222) : Colors.transparent,
                      borderRadius: BorderRadius.circular(4),
                      border: isDefault 
                          ? null 
                          : Border.all(color: const Color(0xFF9B9B9B), width: 2),
                    ),
                    child: isDefault 
                        ? const Icon(Icons.check, color: Colors.white, size: 16)
                        : null,
                  ),
                  const SizedBox(width: 13),
                  const Text(
                    'Set as default payment method',
                    style: TextStyle(
                      fontFamily: 'Metropolis',
                      fontSize: 14,
                      color: Color(0xFF222222),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, isDefault);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFDB3022),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  elevation: 0,
                ),
                child: const Text('ADD CARD', style: TextStyle(fontFamily: 'Metropolis', color: Colors.white, fontSize: 14)),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    TextEditingController? controller,
    Widget? suffixIconWidget,
    TextInputType? keyboardType,
  }) {
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 1),
          ),
        ]
      ),
      child: Center(
        child: TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(
            fontFamily: 'Metropolis',
            fontSize: 14,
            color: Color(0xFF222222),
          ),
          decoration: InputDecoration(
            labelText: label,
            labelStyle: const TextStyle(
              fontFamily: 'Metropolis',
              fontSize: 14,
              color: Color(0xFF9B9B9B),
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            suffixIcon: suffixIconWidget,
          ),
        ),
      ),
    );
  }
}
