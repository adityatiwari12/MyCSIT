import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_theme.dart';
import '../core/components/image_preview_gallery.dart';
import '../data/models/activity_model.dart';
import '../data/repositories/activity_repository.dart';
import '../providers/auth_provider.dart';
import '../providers/supabase_providers.dart';

class AddActivitySheet extends ConsumerStatefulWidget {
  const AddActivitySheet({super.key});

  @override
  ConsumerState<AddActivitySheet> createState() => _AddActivitySheetState();
}

class _AddActivitySheetState extends ConsumerState<AddActivitySheet> {
  int _currentStep = 0;
  ActivityType? _selectedType;
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime? _selectedDate;
  List<File> _selectedFiles = [];
  bool _isLoading = false;

  static const _activityTypes = [
    ActivityType.hackathon,
    ActivityType.certification,
    ActivityType.research,
    ActivityType.project,
    ActivityType.internship,
    ActivityType.achievement,
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
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
              'Add Activity',
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
        children: List.generate(3, (i) {
          final isActive = i == _currentStep;
          final isDone = i < _currentStep;
          return Expanded(
            child: Container(
              margin: EdgeInsets.only(right: i < 2 ? AppTheme.spacingXs : 0),
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
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildStep1() {
    return Padding(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What type of activity?',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppTheme.spacingMd),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: AppTheme.spacingSm,
              mainAxisSpacing: AppTheme.spacingSm,
              childAspectRatio: 1.3,
              children: _activityTypes.map((type) {
                final isSelected = _selectedType == type;
                return GestureDetector(
                  onTap: () => setState(() => _selectedType = type),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.primaryAccent.withOpacity(0.1)
                          : AppTheme.background,
                      border: Border.all(
                        color: isSelected
                            ? AppTheme.primaryAccent
                            : AppTheme.border,
                        width: isSelected ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _typeIcon(type),
                          color: isSelected
                              ? AppTheme.primaryAccent
                              : AppTheme.textMuted,
                          size: 28,
                        ),
                        const SizedBox(height: AppTheme.spacingXs),
                        Text(
                          _typeName(type),
                          style: Theme.of(context)
                              .textTheme
                              .labelMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? AppTheme.primaryAccent
                                    : AppTheme.textPrimary,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Activity Details',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppTheme.spacingMd),
          TextField(
            controller: _titleController,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(labelText: 'Title *'),
          ),
          const SizedBox(height: AppTheme.spacingMd),
          GestureDetector(
            onTap: _selectDate,
            child: InputDecorator(
              decoration: const InputDecoration(labelText: 'Date *'),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today,
                      size: 18, color: AppTheme.textMuted),
                  const SizedBox(width: AppTheme.spacingSm),
                  Text(
                    _selectedDate != null
                        ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                        : 'Select date',
                    style: _selectedDate == null
                        ? Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: AppTheme.textMuted)
                        : null,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppTheme.spacingMd),
          TextField(
            controller: _descriptionController,
            maxLines: 3,
            decoration:
                const InputDecoration(labelText: 'Description (optional)'),
          ),
        ],
      ),
    );
  }

  Widget _buildStep3() {
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
              onRemove: (index) =>
                  setState(() => _selectedFiles.removeAt(index)),
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
              onPressed:
                  _canProceed() ? () => _onNext(userId) : null,
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
                  : Text(_currentStep < 2 ? 'Next' : 'Submit'),
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
        return _titleController.text.trim().isNotEmpty && _selectedDate != null;
      case 2:
        return true; // proof is optional
      default:
        return false;
    }
  }

  void _onNext(String userId) {
    if (_currentStep < 2) {
      setState(() => _currentStep++);
    } else {
      _submitActivity(userId);
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _selectedDate = picked);
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
            .showSnackBar(SnackBar(content: Text('Error picking file: $e')));
      }
    }
  }

  Future<void> _submitActivity(String userId) async {
    setState(() => _isLoading = true);
    try {
      List<String> proofUrls = [];
      String? proofUrl;

      if (_selectedFiles.isNotEmpty) {
        proofUrls =
            await ActivityRepository.uploadProofs(_selectedFiles, userId, 'new');
        if (proofUrls.isNotEmpty) proofUrl = proofUrls.first;
      }

      final activity = ActivityModel(
        userId: userId,
        type: _selectedType!,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        date: _selectedDate!,
        proofUrl: proofUrl,
        proofUrls: proofUrls.length > 1 ? proofUrls.sublist(1) : null,
      );

      await ActivityRepository.addActivity(activity);
      ref.invalidate(activitiesProvider(userId));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Activity submitted for approval.'),
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

  IconData _typeIcon(ActivityType type) {
    switch (type) {
      case ActivityType.hackathon:
        return Icons.emoji_events;
      case ActivityType.certification:
        return Icons.workspace_premium;
      case ActivityType.research:
        return Icons.science;
      case ActivityType.project:
        return Icons.code;
      case ActivityType.internship:
        return Icons.work_outline;
      case ActivityType.achievement:
        return Icons.military_tech;
    }
  }

  String _typeName(ActivityType type) {
    switch (type) {
      case ActivityType.hackathon:
        return 'Hackathon';
      case ActivityType.certification:
        return 'Certification';
      case ActivityType.research:
        return 'Research';
      case ActivityType.project:
        return 'Project';
      case ActivityType.internship:
        return 'Internship';
      case ActivityType.achievement:
        return 'Achievement';
    }
  }
}
