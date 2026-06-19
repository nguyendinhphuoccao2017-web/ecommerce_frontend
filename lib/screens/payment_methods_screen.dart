import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/checkout_provider.dart';
import '../widgets/payment_card_widget.dart';

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
            _buildCardItem(
              maskedNumber: '**** **** **** 3947',
              fullNumber: '5546 8205 3693 3947',
              cardHolderName: 'Jennyfer Doe',
              expiryDate: '05/23',
              isBlackCard: true,
              isVisa: false,
              id: '3947',
            ),
            const SizedBox(height: 32),
            _buildCardItem(
              maskedNumber: '**** **** **** 4546',
              fullNumber: '4123 4567 8901 4546',
              cardHolderName: 'Jennyfer Doe',
              expiryDate: '11/22',
              isBlackCard: false,
              isVisa: true,
              id: '4546',
            ),
            const SizedBox(height: 80),
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
        PaymentCardWidget(
          isBlackCard: isBlackCard,
          cardNumber: maskedNumber,
          cardHolderName: cardHolderName,
          expiryDate: expiryDate,
          isVisa: isVisa,
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

  void _showAddCardBottomSheet(BuildContext context) {
    bool isDefault = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(34))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 16,
              right: 16,
              top: 32,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 60,
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Add new card', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                _buildTextField('Name on card', ''),
                const SizedBox(height: 16),
                _buildTextField('Card number', '5546 8205 3693 3947', isMastercard: true),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _buildTextField('Expire Date', '05/23')),
                    const SizedBox(width: 16),
                    Expanded(child: _buildTextField('CVV', '567', suffixIcon: Icons.help_outline)),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Checkbox(
                      value: isDefault,
                      activeColor: Colors.black,
                      onChanged: (val) {
                        setModalState(() {
                          isDefault = val ?? false;
                        });
                      },
                    ),
                    const Text('Set as default payment method', style: TextStyle(fontSize: 14)),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFDB3022),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                    ),
                    child: const Text('ADD CARD', style: TextStyle(color: Colors.white, fontSize: 14)),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          );
        }
      ),
    );
  }

  Widget _buildTextField(String label, String hint, {bool isMastercard = false, IconData? suffixIcon}) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide.none,
        ),
        suffixIcon: isMastercard 
            ? _buildMastercardSmallLogo() 
            : (suffixIcon != null ? Icon(suffixIcon, color: Colors.grey) : null),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _buildMastercardSmallLogo() {
    return Container(
      width: 40,
      height: 24,
      padding: const EdgeInsets.only(right: 8),
      alignment: Alignment.centerRight,
      child: Image.network(
        'https://nddvgywmwxlmkmextxre.supabase.co/storage/v1/object/public/payment/mastercard.png',
        width: 32,
        height: 20,
        fit: BoxFit.contain,
      ),
    );
  }
}
