import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/models/student_model.dart';
import '../data/repositories/auth_repository.dart';
import '../services/auth_service.dart';

// Raw Supabase auth user stream
final authStateProvider = StreamProvider<User?>((ref) {
  return AuthService.authStateChanges;
});

// Full student profile from public.users, live via realtime
final currentStudentProvider = StreamProvider<StudentModel?>((ref) {
  final authAsync = ref.watch(authStateProvider);
  final user = authAsync.valueOrNull;
  if (user == null) return const Stream.empty();
  return AuthRepository.watchCurrentStudent();
});

// Convenience: just the status string ('pending' | 'active' | 'rejected' | null)
final studentStatusProvider = Provider<String?>((ref) {
  return ref.watch(currentStudentProvider).valueOrNull?.status;
});

// Convenience: uid
final currentUidProvider = Provider<String?>((ref) {
  return ref.watch(authStateProvider).valueOrNull?.id;
});
