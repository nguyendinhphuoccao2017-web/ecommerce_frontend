import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  final supabase = SupabaseClient('https://mock.supabase.co', 'mock_key');
  // supabase.auth.signInWithIdToken(...)
  print(OAuthProvider.values);
}
