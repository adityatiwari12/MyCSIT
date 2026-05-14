import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/mock_auth_service.dart';

class MockAuthStateNotifier extends StateNotifier<MockUser?> {
  MockAuthStateNotifier() : super(null);

  void updateUser(MockUser? user) {
    state = user;
  }
}

final mockAuthServiceProvider = Provider<MockAuthService>((ref) => MockAuthService());

final mockAuthStateNotifierProvider = StateNotifierProvider<MockAuthStateNotifier, MockUser?>((ref) {
  return MockAuthStateNotifier();
});

final mockCurrentUserProvider = Provider<MockUser?>((ref) {
  return ref.watch(mockAuthStateNotifierProvider);
});

// Update the mock service to use the notifier
void updateMockAuthState(MockUser? user) {
  // This will be called from the mock auth service
}
