import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final _client = Supabase.instance.client;

  Stream<User?> get authStateChanges => _client.auth.onAuthStateChange
      .map((state) => state.session?.user);

  User? get currentUser => _client.auth.currentUser;

  Future<AuthResponse> signIn(String email, String password) {
    // Try login with roll number as email (since we register with rollnumber@mycsit.app)
    final loginEmail = email.contains('@') ? email : '${email.trim().toLowerCase()}@mycsit.app';
    print('Attempting login with email: $loginEmail');
    
    return _client.auth.signInWithPassword(email: loginEmail, password: password);
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
      print('Starting registration for email: $email');
      
      // Create real Supabase auth user
      final authEmail = '${rollNumber.trim().toLowerCase()}@mycsit.app';
      print('Using auth email: $authEmail (instead of: $email)');
      
      final authResponse = await _client.auth.signUp(
        email: authEmail, // Use roll number as email to avoid rate limits
        password: password,
        data: {
          'name': name,
          'roll_number': rollNumber.trim().toUpperCase(),
        },
      );
      
      print('Auth response: ${authResponse.user?.id}');
      
      if (authResponse.user != null) {
        try {
          print('Storing user data in database');
          
          final insertData = {
            'id': authResponse.user!.id,
            'name': name,
            'roll_number': rollNumber.trim().toUpperCase(),
            'year': year,
            'section': section,
            'role': 'student',
            'status': 'active',
            'created_at': DateTime.now().toIso8601String(),
          };
          
          print('Insert data: $insertData');
          
          await _client.from('users').insert(insertData);
          print('User data stored successfully');
          
          return authResponse;
          
        } catch (dbError) {
          print('Database insert failed: $dbError');
          // Continue even if DB insert fails - user is already authenticated
          return authResponse;
        }
      }
      
      return authResponse;
      
    } catch (error) {
      print('Registration failed: $error');
      throw error;
    }
  }
}
