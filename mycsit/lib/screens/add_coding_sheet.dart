import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../providers/mock_auth_provider.dart';
import '../data/models/coding_activity_model.dart';
import '../data/repositories/coding_repository.dart';
import '../core/components/image_preview_gallery.dart';

class AddCodingSheet extends ConsumerStatefulWidget {
  const AddCodingSheet({super.key});

  @override
  ConsumerState<AddCodingSheet> createState() => _AddCodingSheetState();
}

class _AddCodingSheetState extends ConsumerState<AddCodingSheet> {
  int _currentStep = 0;
  CodingType? _selectedType;
  String? _selectedPlatform;
  final _titleController = TextEditingController();
  final _contestNameController = TextEditingController();
  final _valueController = TextEditingController();
  String? _selectedDifficulty;
  List<File> _selectedFiles = [];
  bool _isLoading = false;

  final List<CodingType> _codingTypes = [
    CodingType.milestone,
    CodingType.contest,
    CodingType.highValueProblem,
  ];

  final List<String> _platforms = ['LeetCode', 'Codeforces', 'CodeChef', 'Other'];
  final List<String> _difficulties = ['Easy', 'Medium', 'Hard'];

  @override
  void dispose() {
    _titleController.dispose();
    _contestNameController.dispose();
    _valueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(mockCurrentUserProvider);
    
    if (user == null) {
      return const SizedBox.shrink();
    }

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: _buildCurrentStep(),
          ),
          _buildNavigationButtons(user.id),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey, width: 0.2)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
          const SizedBox(width: 16),
          Text(
            'Add Coding Activity - Step ${_currentStep + 1}/4',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _buildStep1();
      case 1:
        return _buildStep2();
      case 2:
        return _buildStep3();
      case 3:
        return _buildStep4();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildStep1() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select Type',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          ..._codingTypes.map((type) {
            final isSelected = _selectedType == type;
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedType = type;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isSelected ? const Color(0xFFFF6B35) : Colors.grey,
                      width: isSelected ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    color: isSelected ? const Color(0xFFFF6B35).withOpacity(0.1) : Colors.white,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _getCodingIcon(type),
                        color: isSelected ? const Color(0xFFFF6B35) : Colors.grey,
                        size: 24,
                      ),
                      const SizedBox(width: 16),
                      Text(
                        _getCodingTitle(type),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? const Color(0xFFFF6B35) : Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildStep2() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select Platform',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _platforms.map((platform) {
              final isSelected = _selectedPlatform == platform;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedPlatform = platform;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isSelected ? const Color(0xFFFF6B35) : Colors.grey,
                      width: isSelected ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    color: isSelected ? const Color(0xFFFF6B35) : Colors.white,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: _getPlatformColor(platform),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            platform[0],
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        platform,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStep3() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Details',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          if (_selectedType == CodingType.milestone) ...[
            TextField(
              controller: _valueController,
              keyboardType: TextInputType.number,
              onChanged: (value) => setState(() {}),
              decoration: const InputDecoration(
                labelText: 'Problems Solved',
                hintText: 'Enter a round number like 50, 100, 200...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            if (_valueController.text.isNotEmpty && !_isRoundNumber())
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.warning, color: Colors.orange, size: 16),
                    SizedBox(width: 8),
                    Text(
                      'Milestones are typically round numbers',
                      style: TextStyle(color: Colors.orange, fontSize: 12),
                    ),
                  ],
                ),
              ),
          ] else if (_selectedType == CodingType.contest) ...[
            TextField(
              controller: _contestNameController,
              onChanged: (value) => setState(() {}),
              decoration: const InputDecoration(
                labelText: 'Contest Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _valueController,
              keyboardType: TextInputType.number,
              onChanged: (value) => setState(() {}),
              decoration: const InputDecoration(
                labelText: 'Your Rank',
                border: OutlineInputBorder(),
              ),
            ),
          ] else if (_selectedType == CodingType.highValueProblem) ...[
            TextField(
              controller: _titleController,
              onChanged: (value) => setState(() {}),
              decoration: const InputDecoration(
                labelText: 'Problem Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedDifficulty,
              decoration: const InputDecoration(
                labelText: 'Difficulty',
                border: OutlineInputBorder(),
              ),
              items: _difficulties.map((difficulty) {
                return DropdownMenuItem(
                  value: difficulty,
                  child: Text(difficulty),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedDifficulty = value;
                });
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStep4() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Upload Proof',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          ImagePreviewGallery(
            files: _selectedFiles,
            onAddMore: _pickFiles,
            onRemove: (index) {
              setState(() {
                _selectedFiles.removeAt(index);
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons(String userId) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey, width: 0.2)),
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  setState(() {
                    _currentStep--;
                  });
                },
                child: const Text('Previous'),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: _canProceed() ? () => _currentStep < 3 ? _nextStep() : _submitCodingActivity(userId) : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B35),
                foregroundColor: Colors.white,
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(_currentStep < 3 ? 'Next' : 'Submit'),
            ),
          ),
        ],
      ),
    );
  }

  bool _canProceed() {
    switch (_currentStep) {
      case 0:
        return _selectedType != null;
      case 1:
        return _selectedPlatform != null;
      case 2:
        if (_selectedType == CodingType.milestone) {
          return _valueController.text.isNotEmpty;
        } else if (_selectedType == CodingType.contest) {
          return _contestNameController.text.isNotEmpty && _valueController.text.isNotEmpty;
        } else if (_selectedType == CodingType.highValueProblem) {
          return _titleController.text.isNotEmpty && _selectedDifficulty != null;
        }
        return false;
      case 3:
        return _selectedFiles.isNotEmpty;
      default:
        return false;
    }
  }

  bool _isRoundNumber() {
    if (_valueController.text.isEmpty) return true;
    final value = int.tryParse(_valueController.text);
    if (value == null) return true;
    return value % 50 == 0;
  }

  void _nextStep() {
    setState(() {
      _currentStep++;
    });
  }

  Future<void> _submitCodingActivity(String userId) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Upload proof
      final proofUrls = await CodingRepository.uploadProofs(_selectedFiles, userId, 'temp');

      // Create coding activity
      final activity = CodingActivityModel(
        userId: userId,
        platform: _selectedPlatform!,
        type: _selectedType!,
        title: _getTitle(),
        value: int.tryParse(_valueController.text),
        contestName: _contestNameController.text.trim().isEmpty ? null : _contestNameController.text.trim(),
        difficulty: _selectedDifficulty,
        proofUrls: proofUrls,
      );

      // Save to database
      await CodingRepository.addCodingActivity(activity);

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Coding activity added successfully!')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _getTitle() {
    if (_selectedType == CodingType.highValueProblem) {
      return _titleController.text.trim();
    } else if (_selectedType == CodingType.contest) {
      return _contestNameController.text.trim();
    } else {
      return '${_valueController.text.trim()} Problems Solved';
    }
  }

  Future<void> _pickFiles() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
        allowMultiple: true,
      );
      
      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _selectedFiles.addAll(result.files.map((e) => File(e.path!)));
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking file: $e')),
      );
    }
  }

  IconData _getCodingIcon(CodingType type) {
    switch (type) {
      case CodingType.milestone: return Icons.flag;
      case CodingType.contest: return Icons.emoji_events;
      case CodingType.highValueProblem: return Icons.code;
    }
  }

  String _getCodingTitle(CodingType type) {
    switch (type) {
      case CodingType.milestone: return 'Milestone';
      case CodingType.contest: return 'Contest';
      case CodingType.highValueProblem: return 'Notable Problem';
    }
  }

  Color _getPlatformColor(String platform) {
    switch (platform) {
      case 'LeetCode': return Colors.yellow;
      case 'Codeforces': return Colors.blue;
      case 'CodeChef': return Colors.brown;
      default: return Colors.grey;
    }
  }
}
