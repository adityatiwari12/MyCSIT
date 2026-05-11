import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:uuid/uuid.dart';

class StorageService {
  final _client = Supabase.instance.client;
  final _uuid = const Uuid();

  Future<String> uploadProof({
    required String userId,
    required String entryType,
    required File file,
    void Function(double)? onProgress,
  }) async {
    final ext = file.path.split('.').last.toLowerCase();
    final fileName = '${_uuid.v4()}.$ext';
    final path = '$userId/$entryType/$fileName';

    File uploadFile = file;
    if (ext == 'jpg' || ext == 'jpeg' || ext == 'png') {
      final compressed = await FlutterImageCompress.compressAndGetFile(
        file.path,
        '${file.path}_compressed.$ext',
        quality: 80,
        minWidth: 1280,
        minHeight: 720,
      );
      if (compressed != null) uploadFile = File(compressed.path);
    }

    onProgress?.call(0);
    await _client.storage.from('proofs').upload(
          path,
          uploadFile,
          fileOptions: FileOptions(contentType: _contentType(ext)),
        );
    onProgress?.call(1);

    return _client.storage.from('proofs').getPublicUrl(path);
  }

  Future<void> deleteProof(String publicUrl) async {
    try {
      final uri = Uri.parse(publicUrl);
      final segments = uri.pathSegments;
      final proofsIdx = segments.indexOf('proofs');
      if (proofsIdx >= 0 && proofsIdx < segments.length - 1) {
        final path = segments.sublist(proofsIdx + 1).join('/');
        await _client.storage.from('proofs').remove([path]);
      }
    } catch (_) {}
  }

  String _contentType(String ext) {
    switch (ext) {
      case 'pdf':
        return 'application/pdf';
      case 'png':
        return 'image/png';
      default:
        return 'image/jpeg';
    }
  }
}
