import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/primary_button.dart';
import '../widgets/loading_overlay.dart';
import 'login_screen.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isNameValid = false;

  void _validateName(String value) {
    setState(() {
      _isNameValid = value.trim().contains(' ');
    });
  }

  Future<void> _handleSocialLogin(String provider) async {
    final success = await ref.read(authProvider.notifier).socialLogin(provider);
    if (success && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('$provider login successful')));
    } else if (mounted) {
      final err = ref.read(authProvider).error ?? '$provider login failed';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return LoadingOverlay(
      isLoading: authState.isLoading,
      child: Scaffold(
        backgroundColor: const Color(0xFFF9F9F9),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 18),
              const Text(
                'Sign up',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Metropolis',
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 73),
              CustomTextField(
                label: 'Name',
                controller: _nameController,
                showGreenTick: _isNameValid,
                onChanged: _validateName,
              ),
              const SizedBox(height: 8),
              CustomTextField(label: 'Email', controller: _emailController),
              const SizedBox(height: 8),
              CustomTextField(
                label: 'Password',
                isPassword: true,
                controller: _passwordController,
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    );
                  },
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Already have an account?',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Metropolis',
                          color: Colors.black,
                        ),
                      ),
                      Icon(Icons.arrow_right_alt, color: Color(0xFFDB3022)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),
              PrimaryButton(
                title: 'SIGN UP',
                isLoading: authState.isLoading,
                onPressed: () async {
                  final nameParts = _nameController.text.trim().split(' ');
                  final firstName = nameParts.isNotEmpty ? nameParts.first : '';
                  final lastName = nameParts.length > 1
                      ? nameParts.sublist(1).join(' ')
                      : '';

                  final success = await ref
                      .read(authProvider.notifier)
                      .register(
                        firstName,
                        lastName,
                        _emailController.text,
                        _passwordController.text,
                      );
                  if (success && mounted) {
                    // Navigate to success or home
                  } else if (authState.error != null && mounted) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(authState.error!)));
                  }
                },
              ),
              const SizedBox(height: 126),
              const Center(
                child: Text(
                  'Or sign up with social account',
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'Metropolis',
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _socialButton(
                    'assets/images/button/google-icon.png',
                    () => _handleSocialLogin('google'),
                  ),
                  const SizedBox(width: 16),
                  _socialButton(
                    'assets/images/button/facebook-icon.png',
                    () => _handleSocialLogin('facebook'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _socialButton(String iconPath, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 92,
        height: 64,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(child: Image.asset(iconPath, width: 24, height: 24)),
      ),
    );
  }
}
