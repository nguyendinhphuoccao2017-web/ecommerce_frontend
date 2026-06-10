import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/favorite_provider.dart';
import '../providers/home_provider.dart';
import '../models/variant_option.dart';

class SizeSelectionBottomSheet extends ConsumerStatefulWidget {
  final String productId;

  const SizeSelectionBottomSheet({super.key, required this.productId});

  @override
  ConsumerState<SizeSelectionBottomSheet> createState() => _SizeSelectionBottomSheetState();
}

class _SizeSelectionBottomSheetState extends ConsumerState<SizeSelectionBottomSheet> {
  bool _isLoading = true;
  List<VariantOption> _variants = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchVariants();
  }

  Future<void> _fetchVariants() async {
    try {
      final api = ref.read(apiServiceProvider);
      final variants = await api.getVariants(widget.productId);
      if (mounted) {
        setState(() {
          _variants = variants;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _selectVariant(String variantOptionId) async {
    // Tự động gọi hàm toggle favorite rồi đóng sheet
    try {
      await ref.read(favoriteNotifierProvider.notifier).toggle(widget.productId, variantOptionId: variantOptionId);
      if (mounted) {
        Navigator.pop(context, true); // Return true means success
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to add favorite: $e')));
        Navigator.pop(context, false);
      }
    }
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
      padding: const EdgeInsets.only(top: 14, left: 16, right: 16, bottom: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Line dash on top
          Container(
            width: 60,
            height: 6,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Select size',
            style: TextStyle(
              fontFamily: 'Metropolis',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF222222),
            ),
          ),
          const SizedBox(height: 32),
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (_errorMessage != null)
            Center(child: Text(_errorMessage!))
          else if (_variants.isEmpty)
            const Center(child: Text('No sizes available for this product.'))
          else
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: _variants.map((variant) {
                return GestureDetector(
                  onTap: () => _selectVariant(variant.id),
                  child: Container(
                    width: 100,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      variant.title, // E.g. 'Size: M' or 'M'
                      style: const TextStyle(
                        fontFamily: 'Metropolis',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF222222),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          const SizedBox(height: 32),
          // Bỏ nút "ADD TO FAVORITES" vì ấn chọn size là tự thêm luôn theo yêu cầu
        ],
      ),
    );
  }
}
