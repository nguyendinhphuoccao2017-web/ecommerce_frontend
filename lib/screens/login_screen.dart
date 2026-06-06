import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/primary_button.dart';
import '../widgets/loading_overlay.dart';
import 'forgot_password_screen.dart';
import 'home_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isEmailValid = false;
  String? _emailError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _validateEmail(String value) {
    setState(() {
      _emailError = null;
      if (value.contains('@') && value.contains('.')) {
        _isEmailValid = true;
      } else {
        _isEmailValid = false;
        if (value.isNotEmpty) {
           _emailError = "Not a valid email address. Should be your@email.com";
        }
      }
    });
  }

  Future<void> _handleSocialLogin(String provider) async {
    if (ref.read(authProvider).isLoading) return;
    await ref.read(authProvider.notifier).socialLogin(provider);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authProvider, (previous, next) {
      if (!ModalRoute.of(context)!.isCurrent) return;

      if (next.error != null && next.error != previous?.error) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Login Failed'),
            content: Text(next.error!),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              )
            ],
          )
        );
      } else if (next.isAuthSuccess && next.isAuthSuccess != previous?.isAuthSuccess) {
        if (next.isSocialAuth) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Social Login successful!')));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Login successful!')));
        }
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
      }
    });

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
                'Login',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Metropolis',
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 73),
              CustomTextField(
                label: 'Email',
                controller: _emailController,
                showGreenTick: _isEmailValid && _emailError == null,
                showRedTick: _emailError != null,
                errorText: _emailError,
                onChanged: _validateEmail,
              ),
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
                      MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
                    );
                  },
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Forgot your password?',
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
                title: 'LOGIN',
                isLoading: authState.isLoading,
                onPressed: () {
                  ref.read(authProvider.notifier).login(
                    _emailController.text,
                    _passwordController.text,
                  );
                },
              ),
              const SizedBox(height: 126),
              const Center(
                child: Text(
                  'Or login with social account',
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
                  _socialButton('assets/images/button/google-icon.png', () => _handleSocialLogin('google')),
                  const SizedBox(width: 16),
                  _socialButton('assets/images/button/facebook-icon.png', () => _handleSocialLogin('facebook')),
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
            )
          ],
        ),
        child: Center(
          child: Image.asset(iconPath, width: 24, height: 24),
        ),
      ),
    );
  }
}
