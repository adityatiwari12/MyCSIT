import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../models/coding_activity_model.dart';
import '../providers/auth_provider.dart';
import '../providers/user_provider.dart';
import '../services/storage_service.dart';

class AddCodingScreen extends ConsumerStatefulWidget {
  const AddCodingScreen({super.key});

  @override
  ConsumerState<AddCodingScreen> createState() => _AddCodingScreenState();
}

class _AddCodingScreenState extends ConsumerState<AddCodingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _valueController = TextEditingController();
  CodingPlatform _platform = CodingPlatform.leetcode;
  CodingType _codingType = CodingType.milestone;
  File? _proofFile;
  String? _proofFileName;
  double _uploadProgress = 0;
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _valueController.dispose();
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
          entryType: 'coding',
          file: _proofFile!,
          onProgress: (p) => setState(() => _uploadProgress = p),
        );
      }

      await ref.read(firestoreServiceProvider).addCodingActivity(
            userId: uid,
            platform: _platform,
            codingType: _codingType,
            title: _titleController.text.trim(),
            value: int.parse(_valueController.text.trim()),
            proofUrl: proofUrl,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Coding entry submitted for review')),
        );
        context.go('/home/coding');
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
        title: const Text('Add Coding Entry'),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home/coding'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Platform
              const Text('Platform',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF6B7280))),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                children: CodingPlatform.values.map((p) {
                  final selected = _platform == p;
                  return ChoiceChip(
                    label: Text(_platformLabel(p)),
                    selected: selected,
                    onSelected: (_) => setState(() => _platform = p),
                    selectedColor: const Color(0xFF22C55E),
                    backgroundColor: Colors.white,
                    labelStyle: TextStyle(
                      color: selected ? Colors.white : const Color(0xFF6B7280),
                      fontWeight: FontWeight.w600,
                    ),
                    side: BorderSide(
                      color: selected ? const Color(0xFF22C55E) : const Color(0xFFE0E0E0),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // Type
              const Text('Type',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF6B7280))),
              const SizedBox(height: 10),
              Row(
                children: [
                  _TypeToggle(
                    label: 'Milestone / Rating',
                    selected: _codingType == CodingType.milestone,
                    onTap: () => setState(() => _codingType = CodingType.milestone),
                  ),
                  const SizedBox(width: 10),
                  _TypeToggle(
                    label: 'Contests',
                    selected: _codingType == CodingType.contest,
                    onTap: () => setState(() => _codingType = CodingType.contest),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Title
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: _codingType == CodingType.milestone ? 'Milestone Title' : 'Contest Name',
                  hintText: _codingType == CodingType.milestone
                      ? 'e.g. Reached 1500 rating'
                      : 'e.g. Codeforces Round 900',
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter a title' : null,
              ),
              const SizedBox(height: 14),

              // Value
              TextFormField(
                controller: _valueController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: _codingType == CodingType.milestone ? 'Rating / Score' : 'Number of Contests',
                  hintText: _codingType == CodingType.milestone ? 'e.g. 1500' : 'e.g. 5',
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Enter a value';
                  final n = int.tryParse(v.trim());
                  if (n == null || n < 0) return 'Enter a valid positive number';
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Proof
              const Text('Screenshot / Proof',
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
                      Expanded(child: Text(_proofFileName ?? '', style: const TextStyle(fontSize: 13))),
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

              if (_isLoading && _uploadProgress > 0) ...[
                const SizedBox(height: 16),
                LinearProgressIndicator(
                  value: _uploadProgress,
                  backgroundColor: const Color(0xFFEEEEEE),
                  valueColor: const AlwaysStoppedAnimation(Color(0xFF22C55E)),
                ),
              ],

              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF22C55E)),
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

  String _platformLabel(CodingPlatform p) {
    switch (p) {
      case CodingPlatform.leetcode:
        return 'LeetCode';
      case CodingPlatform.codeforces:
        return 'Codeforces';
      case CodingPlatform.codechef:
        return 'CodeChef';
      case CodingPlatform.other:
        return 'Other';
    }
  }
}

class _TypeToggle extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TypeToggle({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFF22C55E) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? const Color(0xFF22C55E) : const Color(0xFFE0E0E0),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: selected ? Colors.white : const Color(0xFF6B7280),
            ),
          ),
        ),
      ),
    );
  }
}
