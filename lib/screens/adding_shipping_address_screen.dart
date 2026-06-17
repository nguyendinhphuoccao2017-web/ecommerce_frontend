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
      _stateController.text = widget.address!.state ?? '';
      _zipController.text = widget.address!.postalCode;
      _countryController.text = widget.address!.country;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        title: const Text('Adding Shipping Address', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField('Full name', _fullNameController),
              const SizedBox(height: 16),
              _buildTextField('Address', _addressLine1Controller),
              const SizedBox(height: 16),
              _buildTextField('City', _cityController),
              const SizedBox(height: 16),
              _buildTextField('State/Province/Region', _stateController),
              const SizedBox(height: 16),
              _buildTextField('Zip Code (Postal Code)', _zipController),
              const SizedBox(height: 16),
              _buildTextField('Country', _countryController, isDropdown: true),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final data = {
                        'fullName': _fullNameController.text,
                        'addressLine1': _addressLine1Controller.text,
                        'city': _cityController.text,
                        'state': _stateController.text,
                        'postalCode': _zipController.text,
                        'country': _countryController.text,
                        'phoneNumber': '0123456789', // Mock since design removed it
                        'dialCode': '+1',
                      };
                      bool success;
                      if (widget.address != null) {
                        success = await ref.read(checkoutProvider.notifier).updateAddress(widget.address!.id, data);
                      } else {
                        success = await ref.read(checkoutProvider.notifier).addAddress(data);
                      }
                      
                      if (success) {
                        if (context.mounted) Navigator.pop(context);
                      } else {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(ref.read(checkoutProvider).error ?? 'Error saving address')),
                          );
                        }
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFDB3022),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  ),
                  child: const Text('SAVE ADDRESS', style: TextStyle(color: Colors.white, fontSize: 14)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool isDropdown = false}) {
    return TextFormField(
      controller: controller,
      readOnly: isDropdown,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide.none,
        ),
        suffixIcon: isDropdown ? const Icon(Icons.chevron_right, color: Colors.black) : null,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      validator: (value) => value == null || value.isEmpty ? 'Required' : null,
    );
  }
}
