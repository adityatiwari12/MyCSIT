import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../models/activity_model.dart';
import '../providers/auth_provider.dart';
import '../providers/user_provider.dart';
import '../services/storage_service.dart';

class AddActivityScreen extends ConsumerStatefulWidget {
  const AddActivityScreen({super.key});

  @override
  ConsumerState<AddActivityScreen> createState() => _AddActivityScreenState();
}

class _AddActivityScreenState extends ConsumerState<AddActivityScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  ActivityType _selectedType = ActivityType.hackathon;
  File? _proofFile;
  String? _proofFileName;
  double _uploadProgress = 0;
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
    );
    if (result != null && result.files.single.path != null) {
      setState(() {
        _proofFile = File(result.files.single.path!);
        _proofFileName = result.files.single.name;
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (image != null) {
      setState(() {
        _proofFile = File(image.path);
        _proofFileName = image.name;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final uid = ref.read(currentUidProvider)!;
      String? proofUrl;

      if (_proofFile != null) {
        final storage = StorageService();
        proofUrl = await storage.uploadProof(
          userId: uid,
          entryType: 'activities',
          file: _proofFile!,
          onProgress: (p) => setState(() => _uploadProgress = p),
        );
      }

      await ref.read(firestoreServiceProvider).addActivity(
            userId: uid,
            type: _selectedType,
            title: _titleController.text.trim(),
            description: _descController.text.trim().nullIfEmpty,
            proofUrl: proofUrl,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Activity submitted for review')),
        );
        context.go('/home/activities');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        title: const Text('Add Activity'),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home/activities'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Type selector
              const Text('Activity Type',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF6B7280))),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ActivityType.values.map((type) {
                  final selected = _selectedType == type;
                  return ChoiceChip(
                    label: Text(_typeLabel(type)),
                    selected: selected,
                    onSelected: (_) => setState(() => _selectedType = type),
                    selectedColor: const Color(0xFFFF6B35),
                    backgroundColor: Colors.white,
                    labelStyle: TextStyle(
                      color: selected ? Colors.white : const Color(0xFF6B7280),
                      fontWeight: FontWeight.w600,
                    ),
                    side: BorderSide(
                      color: selected ? const Color(0xFFFF6B35) : const Color(0xFFE0E0E0),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // Title
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  hintText: 'Brief title of your activity',
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter a title' : null,
              ),
              const SizedBox(height: 14),

              // Description
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                  hintText: 'Add details about this activity',
                  filled: true,
                  fillColor: Colors.white,
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 20),

              // Proof upload
              const Text('Proof Document',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF6B7280))),
              const SizedBox(height: 10),
              if (_proofFile != null)
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FFF4),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF22C55E).withOpacity(0.4)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.attach_file_rounded, color: Color(0xFF22C55E), size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(_proofFileName ?? '', style: const TextStyle(fontSize: 13)),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, size: 18, color: Color(0xFF9CA3AF)),
                        onPressed: () => setState(() {
                          _proofFile = null;
                          _proofFileName = null;
                        }),
                      ),
                    ],
                  ),
                )
              else
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _pickImage,
                        icon: const Icon(Icons.photo_outlined),
                        label: const Text('Image'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _pickFile,
                        icon: const Icon(Icons.picture_as_pdf_outlined),
                        label: const Text('PDF'),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 8),
              const Text('Accepted: JPG, PNG, PDF (max 5MB)',
                  style: TextStyle(fontSize: 11, color: Color(0xFF9CA3AF))),

              if (_isLoading && _uploadProgress > 0) ...[
                const SizedBox(height: 16),
                LinearProgressIndicator(
                  value: _uploadProgress,
                  backgroundColor: const Color(0xFFEEEEEE),
                  valueColor: const AlwaysStoppedAnimation(Color(0xFFFF6B35)),
                ),
              ],

              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Submit for Review'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _typeLabel(ActivityType type) {
    switch (type) {
      case ActivityType.hackathon:
        return 'Hackathon';
      case ActivityType.achievement:
        return 'Achievement';
      case ActivityType.certification:
        return 'Certification';
      case ActivityType.internship:
        return 'Internship';
      case ActivityType.research:
        return 'Research';
      case ActivityType.project:
        return 'Project';
    }
  }
}

extension on String {
  String? get nullIfEmpty => isEmpty ? null : this;
}
