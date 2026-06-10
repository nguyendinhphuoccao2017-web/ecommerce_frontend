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
  String? _selectedVariantId;

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

  void _selectVariant(String variantOptionId) {
    setState(() {
      _selectedVariantId = variantOptionId;
    });
  }

  void _addToFavorites() async {
    if (_selectedVariantId == null) return;
    try {
      await ref.read(favoriteNotifierProvider.notifier).toggle(widget.productId, variantOptionId: _selectedVariantId);
      if (mounted) {
        Navigator.pop(context, true);
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
            const SizedBox(height: 100, child: Center(child: CircularProgressIndicator()))
          else if (_errorMessage != null)
            SizedBox(height: 100, child: Center(child: Text(_errorMessage!)))
          else if (_variants.isEmpty)
            const SizedBox(height: 100, child: Center(child: Text('No sizes available for this product.')))
          else
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: _variants.map((variant) {
                final isSelected = _selectedVariantId == variant.id;
                return GestureDetector(
                  onTap: () => _selectVariant(variant.id),
                  child: Container(
                    width: 100,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFFDB3022) : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: isSelected ? const Color(0xFFDB3022) : Colors.grey[300]!),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      variant.title,
                      style: TextStyle(
                        fontFamily: 'Metropolis',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isSelected ? Colors.white : const Color(0xFF222222),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          const SizedBox(height: 32),
          // Size info row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: Color(0xFFEEEEEE)),
                bottom: BorderSide(color: Color(0xFFEEEEEE)),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  'Size info',
                  style: TextStyle(
                    fontFamily: 'Metropolis',
                    fontSize: 16,
                    color: Color(0xFF222222),
                  ),
                ),
                Icon(Icons.chevron_right, color: Color(0xFF222222)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _selectedVariantId == null ? null : _addToFavorites,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDB3022),
                disabledBackgroundColor: Colors.grey[400],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                elevation: _selectedVariantId == null ? 0 : 4,
                shadowColor: const Color(0xFFDB3022).withOpacity(0.5),
              ),
              child: const Text(
                'ADD TO FAVORITES',
                style: TextStyle(
                  fontFamily: 'Metropolis',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
