import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_theme.dart';
import '../core/components/image_preview_gallery.dart';
import '../data/models/coding_activity_model.dart';
import '../data/repositories/coding_repository.dart';
import '../providers/auth_provider.dart';
import '../providers/supabase_providers.dart';

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

  static const _platforms = ['LeetCode', 'Codeforces', 'CodeChef', 'Other'];
  static const _difficulties = ['Easy', 'Medium', 'Hard'];

  @override
  void dispose() {
    _titleController.dispose();
    _contestNameController.dispose();
    _valueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final uid = ref.watch(currentUidProvider);
    if (uid == null) return const SizedBox.shrink();

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppTheme.radiusLg),
          topRight: Radius.circular(AppTheme.radiusLg),
        ),
      ),
      child: Column(
        children: [
          _buildHandle(),
          _buildHeader(),
          _buildStepIndicator(),
          Expanded(child: _buildCurrentStep()),
          _buildNavigationButtons(uid),
        ],
      ),
    );
  }

  Widget _buildHandle() {
    return Container(
      margin: const EdgeInsets.only(top: AppTheme.spacingSm),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: AppTheme.border,
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingMd, vertical: AppTheme.spacingSm),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Add Coding Activity',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
      child: Row(
        children: List.generate(4, (i) {
          final isActive = i == _currentStep;
          final isDone = i < _currentStep;
          return Expanded(
            child: Container(
              margin: EdgeInsets.only(right: i < 3 ? AppTheme.spacingXs : 0),
              height: 4,
              decoration: BoxDecoration(
                color: isDone || isActive
                    ? AppTheme.primaryAccent
                    : AppTheme.border,
                borderRadius: BorderRadius.circular(AppTheme.radiusFull),
              ),
            ),
          );
        }),
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
    final types = CodingType.values;
    return Padding(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select type',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppTheme.spacingMd),
          ...types.map((type) {
            final isSelected = _selectedType == type;
            return Padding(
              padding: const EdgeInsets.only(bottom: AppTheme.spacingSm),
              child: GestureDetector(
                onTap: () => setState(() => _selectedType = type),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.all(AppTheme.spacingMd),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.primaryAccent.withOpacity(0.08)
                        : AppTheme.background,
                    border: Border.all(
                      color:
                          isSelected ? AppTheme.primaryAccent : AppTheme.border,
                      width: isSelected ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _typeIcon(type),
                        color: isSelected
                            ? AppTheme.primaryAccent
                            : AppTheme.textMuted,
                      ),
                      const SizedBox(width: AppTheme.spacingMd),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _typeName(type),
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: isSelected
                                        ? AppTheme.primaryAccent
                                        : AppTheme.textPrimary,
                                  ),
                            ),
                            Text(
                              _typeDesc(type),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: AppTheme.textMuted),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStep2() {
    return Padding(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select platform',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppTheme.spacingMd),
          Wrap(
            spacing: AppTheme.spacingSm,
            runSpacing: AppTheme.spacingSm,
            children: _platforms.map((p) {
              final isSelected = _selectedPlatform == p;
              return GestureDetector(
                onTap: () => setState(() => _selectedPlatform = p),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacingMd,
                      vertical: AppTheme.spacingSm),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.primaryAccent
                        : AppTheme.background,
                    border: Border.all(
                      color:
                          isSelected ? AppTheme.primaryAccent : AppTheme.border,
                    ),
                    borderRadius:
                        BorderRadius.circular(AppTheme.radiusFull),
                  ),
                  child: Text(
                    p,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: isSelected ? Colors.white : AppTheme.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Details',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppTheme.spacingMd),
          if (_selectedType == CodingType.milestone) ...[
            TextField(
              controller: _valueController,
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                labelText: 'Problems Solved *',
                hintText: 'e.g. 50, 100, 200, 500',
              ),
            ),
            if (_valueController.text.isNotEmpty && !_isRoundNumber()) ...[
              const SizedBox(height: AppTheme.spacingXs),
              Row(
                children: [
                  const Icon(Icons.info_outline,
                      color: AppTheme.warning, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    'Milestones are typically round numbers (50, 100, 200…)',
                    style: Theme.of(context)
                        .textTheme
                        .labelSmall
                        ?.copyWith(color: AppTheme.warning),
                  ),
                ],
              ),
            ],
          ] else if (_selectedType == CodingType.contest) ...[
            TextField(
              controller: _contestNameController,
              onChanged: (_) => setState(() {}),
              decoration:
                  const InputDecoration(labelText: 'Contest Name *'),
            ),
            const SizedBox(height: AppTheme.spacingMd),
            TextField(
              controller: _valueController,
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(labelText: 'Your Rank *'),
            ),
          ] else if (_selectedType == CodingType.highValueProblem) ...[
            TextField(
              controller: _titleController,
              onChanged: (_) => setState(() {}),
              decoration:
                  const InputDecoration(labelText: 'Problem Name *'),
            ),
            const SizedBox(height: AppTheme.spacingMd),
            DropdownButtonFormField<String>(
              value: _selectedDifficulty,
              decoration:
                  const InputDecoration(labelText: 'Difficulty *'),
              items: _difficulties
                  .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                  .toList(),
              onChanged: (v) => setState(() => _selectedDifficulty = v),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStep4() {
    return Padding(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Upload Proof',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: AppTheme.spacingSm),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingXs, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.textMuted.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                ),
                child: Text(
                  'optional',
                  style: Theme.of(context)
                      .textTheme
                      .labelSmall
                      ?.copyWith(color: AppTheme.textMuted),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingMd),
          Expanded(
            child: ImagePreviewGallery(
              files: _selectedFiles,
              onAddMore: _pickFiles,
              onRemove: (i) => setState(() => _selectedFiles.removeAt(i)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons(String userId) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: AppTheme.border)),
      ),
      child: Row(
        children: [
          if (_currentStep > 0) ...[
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() => _currentStep--),
                child: const Text('Back'),
              ),
            ),
            const SizedBox(width: AppTheme.spacingMd),
          ],
          Expanded(
            child: ElevatedButton(
              onPressed: _canProceed() ? () => _onNext(userId) : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    vertical: AppTheme.spacingMd),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : Text(_currentStep < 3 ? 'Next' : 'Submit'),
            ),
          ),
        ],
      ),
    );
  }

  bool _canProceed() {
    if (_isLoading) return false;
    switch (_currentStep) {
      case 0:
        return _selectedType != null;
      case 1:
        return _selectedPlatform != null;
      case 2:
        if (_selectedType == CodingType.milestone) {
          return _valueController.text.isNotEmpty;
        } else if (_selectedType == CodingType.contest) {
          return _contestNameController.text.isNotEmpty &&
              _valueController.text.isNotEmpty;
        } else {
          return _titleController.text.isNotEmpty &&
              _selectedDifficulty != null;
        }
      case 3:
        return true; // proof is optional
      default:
        return false;
    }
  }

  bool _isRoundNumber() {
    final v = int.tryParse(_valueController.text);
    if (v == null) return true;
    return v % 50 == 0;
  }

  void _onNext(String userId) {
    if (_currentStep < 3) {
      setState(() => _currentStep++);
    } else {
      _submitCodingActivity(userId);
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
        setState(
            () => _selectedFiles.addAll(result.files.map((e) => File(e.path!))));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _submitCodingActivity(String userId) async {
    setState(() => _isLoading = true);
    try {
      List<String> proofUrls = [];
      String? proofUrl;

      if (_selectedFiles.isNotEmpty) {
        proofUrls =
            await CodingRepository.uploadProofs(_selectedFiles, userId, 'new');
        if (proofUrls.isNotEmpty) proofUrl = proofUrls.first;
      }

      final title = _selectedType == CodingType.highValueProblem
          ? _titleController.text.trim()
          : _selectedType == CodingType.contest
              ? _contestNameController.text.trim()
              : '${_valueController.text.trim()} Problems Solved';

      final activity = CodingActivityModel(
        userId: userId,
        platform: _selectedPlatform!,
        type: _selectedType!,
        title: title,
        value: int.tryParse(_valueController.text),
        contestName: _contestNameController.text.trim().isEmpty
            ? null
            : _contestNameController.text.trim(),
        difficulty: _selectedDifficulty,
        proofUrl: proofUrl,
        proofUrls: proofUrls.length > 1 ? proofUrls.sublist(1) : null,
      );

      await CodingRepository.addCodingActivity(activity);
      ref.invalidate(codingActivitiesProvider(userId));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Coding activity submitted for approval.'),
              backgroundColor: AppTheme.success),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  IconData _typeIcon(CodingType type) {
    switch (type) {
      case CodingType.milestone:
        return Icons.flag_outlined;
      case CodingType.contest:
        return Icons.emoji_events_outlined;
      case CodingType.highValueProblem:
        return Icons.code;
    }
  }

  String _typeName(CodingType type) {
    switch (type) {
      case CodingType.milestone:
        return 'Milestone';
      case CodingType.contest:
        return 'Contest';
      case CodingType.highValueProblem:
        return 'Notable Problem';
    }
  }

  String _typeDesc(CodingType type) {
    switch (type) {
      case CodingType.milestone:
        return '50, 100, 200, 500 problems solved';
      case CodingType.contest:
        return 'Competitive programming rank';
      case CodingType.highValueProblem:
        return 'Hard/noteworthy problem solved';
    }
  }
}
