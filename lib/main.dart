import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/signup_screen.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://nddvgywmwxlmkmextxre.supabase.co',
    anonKey: 'sb_publishable_7iWFF4sn0ABzncq2Er-DFw_SZ1lSzYA',
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce,
    ),
  );

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ecommerce Auth',
      theme: ThemeData(
        fontFamily: 'Metropolis',
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFDB3022)),
        useMaterial3: true,
      ),
      home: const SignupScreen(),
    );
  }
}
