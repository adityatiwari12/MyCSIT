import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final _client = Supabase.instance.client;

  Stream<User?> get authStateChanges => _client.auth.onAuthStateChange
      .map((state) => state.session?.user);

  User? get currentUser => _client.auth.currentUser;

  Future<AuthResponse> signIn(String email, String password) {
    // Use the actual email provided instead of synthetic email
    return _client.auth.signInWithPassword(email: email.trim(), password: password);
  }

  Future<void> signOut() => _client.auth.signOut();

  Future<AuthResponse> registerStudent({
    required String name,
    required String rollNumber,
    required String password,
    required int year,
    required String section,
    required String email,
  }) async {
    try {
      // Use the actual email provided by student instead of synthetic email
      // Disable email confirmation to avoid rate limit errors
      final response =
          await _client.auth.signUp(
            email: email, 
            password: password,
            emailRedirectTo: null,
            data: {
              'disable_email_confirmation': true,
            },
          );
      
      if (response.user != null) {
        try {
          await _client.from('users').insert({
            'id': response.user!.id,
            'name': name,
            'roll_number': rollNumber.trim().toUpperCase(),
            'year': year,
            'section': section,
            'role': 'student',
            'status': 'pending',
            'created_at': DateTime.now().toIso8601String(),
          });
        } catch (dbError) {
          print('Database insert failed: $dbError');
          // If DB insert fails, delete the auth user to prevent orphaned accounts
          await _client.auth.admin.deleteUser(response.user!.id);
          throw Exception('Failed to create user record. Please try again.');
        }
      }
      return response;
    } catch (authError) {
      print('Auth signup failed: $authError');
      throw authError;
    }
  }
}
