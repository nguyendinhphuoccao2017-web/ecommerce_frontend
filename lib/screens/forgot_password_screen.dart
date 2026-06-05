import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/primary_button.dart';
import '../widgets/loading_overlay.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  bool _isEmailValid = false;
  String? _emailError;

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
                'Forgot password',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Metropolis',
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 87),
              const Text(
                'Please, enter your email address. You will receive a link to create a new password via email.',
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Metropolis',
                  color: Colors.black,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Email',
                hintText: 'email2',
                controller: _emailController,
                showRedTick: _emailError != null,
                showGreenTick: _isEmailValid && _emailError == null,
                errorText: _emailError,
                onChanged: _validateEmail,
              ),
              const SizedBox(height: 55),
              PrimaryButton(
                title: 'SEND',
                isLoading: authState.isLoading,
                onPressed: () async {
                  if (!_isEmailValid) {
                    setState(() {
                      _emailError = "Not a valid email address. Should be your@email.com";
                    });
                    return;
                  }
                  final success = await ref.read(authProvider.notifier).forgotPassword(
                    _emailController.text,
                  );
                  if (success && mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Password reset link sent!')),
                    );
                  } else if (authState.error != null && mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(authState.error!)));
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
