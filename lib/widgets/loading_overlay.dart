import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/loading_provider.dart';

class LoadingOverlay extends ConsumerWidget {
  final Widget child;
  final bool isLoading;

  const LoadingOverlay({super.key, required this.child, this.isLoading = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isGlobalLoading = ref.watch(loadingProvider);
    final showLoading = isLoading || isGlobalLoading;

    return Stack(
      children: [
        child,
        if (showLoading)
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
              child: Container(
                color: Colors.black.withOpacity(0.3),
                child: const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
