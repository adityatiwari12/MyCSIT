import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/student_model.dart';

class AuthRepository {
  static final _client = Supabase.instance.client;

  static Future<StudentModel?> getCurrentStudent() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;
    try {
      final data = await _client
          .from('users')
          .select()
          .eq('id', user.id)
          .maybeSingle();
      if (data == null) return null;
      return StudentModel.fromMap(data);
    } catch (_) {
      return null;
    }
  }

  static Stream<StudentModel?> watchCurrentStudent() {
    final user = _client.auth.currentUser;
    if (user == null) return const Stream.empty();

    return _client
        .from('users')
        .stream(primaryKey: ['id'])
        .eq('id', user.id)
        .map((rows) {
          if (rows.isEmpty) return null;
          return StudentModel.fromMap(rows.first);
        });
  }
}
