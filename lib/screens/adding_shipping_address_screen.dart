import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/checkout_provider.dart';
import '../models/customer_address.dart';

class AddingShippingAddressScreen extends ConsumerStatefulWidget {
  final CustomerAddress? address;

  const AddingShippingAddressScreen({super.key, this.address});

  @override
  ConsumerState<AddingShippingAddressScreen> createState() => _AddingShippingAddressScreenState();
}

class _AddingShippingAddressScreenState extends ConsumerState<AddingShippingAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _addressLine1Controller = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipController = TextEditingController();
  final _countryController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.address != null) {
      _fullNameController.text = widget.address!.fullName ?? '';
      _addressLine1Controller.text = widget.address!.addressLine1;
      _cityController.text = widget.address!.city;
      
      String stateVal = widget.address!.state ?? '';
      if (stateVal == 'HCM') stateVal = 'Ho Chi Minh City';
      else if (stateVal == 'CA') stateVal = 'California';
      _stateController.text = stateVal;
      
      _zipController.text = widget.address!.postalCode;
      _countryController.text = widget.address!.country;
    } else {
      _countryController.text = 'United States';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, top: 31, bottom: 40),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _buildTextField('Full name', _fullNameController),
                const SizedBox(height: 20),
                _buildTextField('Address', _addressLine1Controller),
                const SizedBox(height: 20),
                _buildTextField('City', _cityController),
                const SizedBox(height: 20),
                _buildTextField('State/Province/Region', _stateController),
                const SizedBox(height: 20),
                _buildTextField('Zip Code (Postal Code)', _zipController),
                const SizedBox(height: 20),
                _buildTextField('Country', _countryController, isDropdown: true),
                
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _saveAddress,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFDB3022),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                      elevation: 4,
                      shadowColor: const Color(0xFFDB3022).withOpacity(0.5),
                    ),
                    child: const Text(
                      'SAVE ADDRESS', 
                      style: TextStyle(
                        fontFamily: 'Metropolis',
                        fontWeight: FontWeight.w500,
                        color: Colors.white, 
                        fontSize: 14
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text(
        'Adding Shipping Address',
        style: TextStyle(
          fontFamily: 'Metropolis',
          fontWeight: FontWeight.bold,
          fontSize: 18,
          height: 22 / 18,
          color: Color(0xFF222222),
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF222222)),
        onPressed: () => Navigator.pop(context),
      ),
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool isDropdown = false}) {
    if (isDropdown) {
      return Container(
        height: 64,
        width: double.infinity,
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
          child: DropdownButtonFormField<String>(
            isExpanded: true,
            dropdownColor: Colors.white,
            value: controller.text.isNotEmpty ? controller.text : 'United States',
            icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF222222)),
            style: const TextStyle(
              fontFamily: 'Metropolis',
              fontSize: 14,
              color: Color(0xFF222222),
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              labelText: label,
              labelStyle: const TextStyle(
                fontFamily: 'Metropolis',
                fontSize: 14,
                color: Color(0xFF9B9B9B),
              ),
              floatingLabelStyle: const TextStyle(
                fontFamily: 'Metropolis',
                fontSize: 11,
                color: Color(0xFF9B9B9B),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.only(left: 20, right: 20, bottom: 8),
            ),
            items: ['United States', 'Viet Nam'].map((String val) {
              return DropdownMenuItem<String>(
                value: val,
                child: Text(val),
              );
            }).toList(),
            onChanged: (val) {
              if (val != null) {
                setState(() {
                  controller.text = val;
                });
              }
            },
          ),
        ),
      );
    }

    return Container(
      height: 64,
      width: double.infinity,
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
          style: const TextStyle(
            fontFamily: 'Metropolis',
            fontSize: 14,
            color: Color(0xFF222222),
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            labelText: label,
            labelStyle: const TextStyle(
              fontFamily: 'Metropolis',
              fontSize: 14,
              color: Color(0xFF9B9B9B),
            ),
            floatingLabelStyle: const TextStyle(
              fontFamily: 'Metropolis',
              fontSize: 11,
              color: Color(0xFF9B9B9B),
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.only(left: 20, right: 20, bottom: 8),
          ),
          validator: (value) => value == null || value.isEmpty ? 'Required' : null,
        ),
      ),
    );
  }

  Future<void> _saveAddress() async {
    if (_formKey.currentState!.validate()) {
      
      // Hiện hiệu ứng Blur + Loading
      showDialog(
        context: context,
        barrierDismissible: false,
        barrierColor: Colors.white.withOpacity(0.7),
        builder: (context) => const Center(
          child: CircularProgressIndicator(color: Color(0xFFDB3022)),
        ),
      );

      // Chờ thêm 1 giây cho người dùng thấy loading
      await Future.delayed(const Duration(seconds: 1));

      String stateVal = _stateController.text;
      if (stateVal == 'Ho Chi Minh City') stateVal = 'HCM';
      else if (stateVal == 'California') stateVal = 'CA';

      final data = {
        'fullName': _fullNameController.text,
        'addressLine1': _addressLine1Controller.text,
        'city': _cityController.text,
        'state': stateVal,
        'postalCode': _zipController.text,
        'country': _countryController.text,
        'phoneNumber': '0123456789',
        'dialCode': '+1',
      };
      
      bool success;
      if (widget.address != null) {
        success = await ref.read(checkoutProvider.notifier).updateAddress(widget.address!.id, data);
      } else {
        success = await ref.read(checkoutProvider.notifier).addAddress(data);
      }
      
      if (mounted) Navigator.pop(context); // Tắt dialog loading

      if (success) {
        if (mounted) Navigator.pop(context); // Thoát AddingShippingAddressScreen quay về màn hình trước
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(ref.read(checkoutProvider).error ?? 'Error saving address')),
          );
        }
      }
    }
  }
}
