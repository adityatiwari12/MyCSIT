import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/models/student_model.dart';

class AuthService {
  static final _client = Supabase.instance.client;

  static String _emailFromRoll(String rollNumber) =>
      '${rollNumber.trim().toLowerCase()}@mycsit.app';

  static Stream<User?> get authStateChanges =>
      _client.auth.onAuthStateChange.map((e) => e.session?.user);

  static User? get currentUser => _client.auth.currentUser;

  static Future<void> register({
    required String name,
    required String rollNumber,
    required String password,
    required int year,
    required String section,
    required String email,
  }) async {
    final authEmail = _emailFromRoll(rollNumber);
    final res = await _client.auth.signUp(
      email: authEmail,
      password: password,
      data: {'name': name, 'roll_number': rollNumber.trim().toUpperCase()},
    );

    if (res.user == null) {
      throw Exception('Registration failed — no user returned from auth.');
    }

    await _client.from('users').insert({
      'id': res.user!.id,
      'name': name.trim(),
      'roll_number': rollNumber.trim().toUpperCase(),
      'year': year,
      'section': section,
      'role': 'student',
      'status': 'pending',
    });
  }

  static Future<void> signIn(String rollNumber, String password) async {
    final authEmail = rollNumber.contains('@')
        ? rollNumber
        : _emailFromRoll(rollNumber);
    await _client.auth.signInWithPassword(
      email: authEmail,
      password: password,
    );
  }

  static Future<void> signOut() async {
    await _client.auth.signOut();
  }

  static Future<StudentModel?> fetchCurrentStudent() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;
    final data = await _client
        .from('users')
        .select()
        .eq('id', user.id)
        .maybeSingle();
    if (data == null) return null;
    return StudentModel.fromMap(data);
  }

  static String friendlyError(Object error) {
    final msg = error.toString();
    if (msg.contains('Email rate limit') || msg.contains('429')) {
      return 'Too many attempts. Please wait a few minutes and try again.';
    }
    if (msg.contains('already registered') || msg.contains('already exists') ||
        msg.contains('duplicate') || msg.contains('unique')) {
      return 'This roll number is already registered.';
    }
    if (msg.contains('Invalid login credentials') ||
        msg.contains('invalid_credentials')) {
      return 'Invalid roll number or password.';
    }
    if (msg.contains('network') || msg.contains('SocketException')) {
      return 'Network error. Check your internet connection.';
    }
    if (msg.contains('weak_password')) {
      return 'Password is too weak. Use at least 6 characters.';
    }
    return 'Something went wrong. Please try again.';
  }
}
