import 'package:flutter/foundation.dart';

class MockUser {
  final String id;
  final String name;
  final String rollNumber;
  final String email;
  final int year;
  final String section;
  final String role;
  final String status;

  MockUser({
    required this.id,
    required this.name,
    required this.rollNumber,
    required this.email,
    required this.year,
    required this.section,
    this.role = 'student',
    this.status = 'active',
  });
}

class MockAuthService {
  static MockUser? _currentUser;
  static final List<MockUser> _users = [];
  static Function(MockUser?)? _authStateCallback;
  
  static MockUser? get currentUser => _currentUser;
  
  static void setAuthStateCallback(Function(MockUser?) callback) {
    _authStateCallback = callback;
  }
  
  static void _notifyAuthStateChange() {
    if (_authStateCallback != null) {
      _authStateCallback!(_currentUser);
    }
  }
  
  static Stream<MockUser?> get authStateChanges => 
      Stream.value(_currentUser);

  static Future<MockUser> registerStudent({
    required String name,
    required String rollNumber,
    required String password,
    required int year,
    required String section,
    required String email,
  }) async {
    print('MockAuth: Starting registration for $rollNumber');
    
    // Check if roll number already exists
    if (_users.any((u) => u.rollNumber == rollNumber)) {
      print('MockAuth: Roll number already exists: $rollNumber');
      throw Exception('Roll number already registered');
    }
    
    // Create new user
    final user = MockUser(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      rollNumber: rollNumber,
      email: email,
      year: year,
      section: section,
    );
    
    _users.add(user);
    _currentUser = user;
    
    print('MockAuth: Registration successful for $rollNumber');
    print('MockAuth: Total users: ${_users.length}');
    
    _notifyAuthStateChange();
    
    return user;
  }

  static Future<MockUser> signIn(String rollNumber, String password) async {
    print('MockAuth: Starting login for $rollNumber');
    print('MockAuth: Current users: ${_users.length}');
    
    // Find user by roll number (no password validation for now)
    try {
      final user = _users.firstWhere(
        (u) => u.rollNumber.toLowerCase() == rollNumber.toLowerCase(),
      );
      
      _currentUser = user;
      print('MockAuth: Login successful for $rollNumber');
      
      _notifyAuthStateChange();
      
      return user;
    } catch (e) {
      print('MockAuth: Login failed - user not found: $rollNumber');
      throw Exception('User not found');
    }
  }

  static Future<void> signOut() async {
    _currentUser = null;
    _notifyAuthStateChange();
  }

  static List<MockUser> getAllStudents() {
    return _users.where((u) => u.role == 'student').toList();
  }
}
