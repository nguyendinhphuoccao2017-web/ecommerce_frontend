import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/nav_provider.dart';
import '../widgets/primary_button.dart';
import 'home_screen.dart';

class SuccessScreen extends ConsumerWidget {
  const SuccessScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              const Spacer(),
              Image.network(
                'https://nddvgywmwxlmkmextxre.supabase.co/storage/v1/object/public/success/bags.png',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.shopping_bag_outlined, size: 150, color: Color(0xFFDB3022));
                },
              ),
              const SizedBox(height: 45),
              const Text(
                'Success!',
                style: TextStyle(
                  fontFamily: 'Metropolis',
                  fontWeight: FontWeight.w700,
                  fontSize: 34,
                  height: 1.0,
                  color: Color(0xFF000000),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Your order will be delivered soon.\nThank you for choosing our app!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Metropolis',
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  height: 1.5,
                  color: Color(0xFF000000),
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: PrimaryButton(
                  title: 'CONTINUE SHOPPING',
                  onPressed: () {
                    ref.read(navIndexProvider.notifier).state = 0; // Chuyển về Home Tab
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const HomeScreen()),
                      (route) => false,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
