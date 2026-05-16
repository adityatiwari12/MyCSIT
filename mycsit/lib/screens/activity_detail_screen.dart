import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/theme/app_theme.dart';
import '../data/models/activity_model.dart';
import '../data/repositories/activity_repository.dart';
import '../providers/auth_provider.dart';
import '../providers/supabase_providers.dart';

class ActivityDetailScreen extends ConsumerStatefulWidget {
  final String activityId;

  const ActivityDetailScreen({super.key, required this.activityId});

  @override
  ConsumerState<ActivityDetailScreen> createState() =>
      _ActivityDetailScreenState();
}

class _ActivityDetailScreenState extends ConsumerState<ActivityDetailScreen> {
  ActivityModel? _activity;
  bool _isLoading = true;
  bool _isEditing = false;
  bool _isSaving = false;
  late TextEditingController _titleCtrl;
  late TextEditingController _descCtrl;
  DateTime? _editedDate;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController();
    _descCtrl = TextEditingController();
    _loadActivity();
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadActivity() async {
    final uid = ref.read(currentUidProvider);
    if (uid == null) return;

    try {
      // Try Supabase first
      final row = await Supabase.instance.client
          .from('activities')
          .select()
          .eq('id', widget.activityId)
          .maybeSingle();

      if (row != null) {
        final a = ActivityModel.fromSupabaseMap(row);
        _titleCtrl.text = a.title;
        _descCtrl.text = a.description;
        _editedDate = a.date;
        if (mounted) setState(() { _activity = a; _isLoading = false; });
        return;
      }
    } catch (_) {}

    // Fallback: search Hive
    final uid2 = ref.read(currentUidProvider) ?? '';
    final all = await ActivityRepository.getActivities(uid2);
    final found = all.cast<ActivityModel?>()
        .firstWhere((a) => a?.id == widget.activityId, orElse: () => null);
    if (found != null) {
      _titleCtrl.text = found.title;
      _descCtrl.text = found.description;
      _editedDate = found.date;
    }
    if (mounted) setState(() { _activity = found; _isLoading = false; });
  }

  Future<void> _saveActivity() async {
    if (_activity == null) return;
    if (_titleCtrl.text.trim().isEmpty || _editedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Title and date are required.')),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final updated = _activity!.copyWith(
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        date: _editedDate!,
        status: ActivityStatus.pending,
        rejectionReason: null,
        updatedAt: DateTime.now(),
      );

      await ActivityRepository.updateActivity(updated);
      ref.invalidate(activitiesProvider(updated.userId));

      if (mounted) {
        setState(() { _activity = updated; _isEditing = false; _isSaving = false; });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Resubmitted for approval.')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _openProof(String url) async {
    if (url.isEmpty) return;
    try {
      if (url.startsWith('/') || url.startsWith('file://')) {
        // Local file
        final file = File(url.replaceFirst('file://', ''));
        if (await file.exists()) {
          final uri = Uri.file(url);
          await launchUrl(uri);
          return;
        }
      }
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open proof file.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Activity' : 'Activity Details'),
        backgroundColor: AppTheme.surface,
        foregroundColor: AppTheme.textPrimary,
        elevation: 0,
        actions: [
          if (_activity?.status == ActivityStatus.rejected && !_isEditing)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => setState(() => _isEditing = true),
            ),
          if (_isEditing)
            _isSaving
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : IconButton(
                    icon: const Icon(Icons.check),
                    onPressed: _saveActivity,
                  ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _activity == null
              ? const Center(child: Text('Activity not found.'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(AppTheme.spacingMd),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildStatusBanner(),
                      const SizedBox(height: AppTheme.spacingMd),
                      _buildInfoCard(),
                      const SizedBox(height: AppTheme.spacingMd),
                      _buildProofSection(),
                      if (_activity!.rejectionReason != null) ...[
                        const SizedBox(height: AppTheme.spacingMd),
                        _buildRejectionBanner(),
                      ],
                    ],
                  ),
                ),
    );
  }

  Widget _buildStatusBanner() {
    final a = _activity!;
    Color color;
    Color bg;
    IconData icon;
    String label;

    switch (a.status) {
      case ActivityStatus.pending:
        color = AppTheme.warning;
        bg = AppTheme.warningLight;
        icon = Icons.hourglass_empty;
        label = 'Pending Approval';
        break;
      case ActivityStatus.approved:
        color = AppTheme.success;
        bg = AppTheme.successLight;
        icon = Icons.check_circle;
        label = 'Approved';
        break;
      case ActivityStatus.rejected:
        color = AppTheme.error;
        bg = AppTheme.errorLight;
        icon = Icons.cancel;
        label = 'Rejected';
        break;
    }

    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: AppTheme.spacingMd),
          Text(
            label,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    final a = _activity!;

    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: AppTheme.border),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _row('Type', a.type.name.toUpperCase()),
          const Divider(height: AppTheme.spacingLg),
          if (_isEditing) ...[
            TextField(
              controller: _titleCtrl,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: AppTheme.spacingMd),
            GestureDetector(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _editedDate ?? DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (picked != null) setState(() => _editedDate = picked);
              },
              child: InputDecorator(
                decoration: const InputDecoration(labelText: 'Date'),
                child: Text(
                  _editedDate != null
                      ? '${_editedDate!.day}/${_editedDate!.month}/${_editedDate!.year}'
                      : 'Select date',
                ),
              ),
            ),
            const SizedBox(height: AppTheme.spacingMd),
            TextField(
              controller: _descCtrl,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
          ] else ...[
            _row('Title', a.title),
            const Divider(height: AppTheme.spacingLg),
            _row('Date', '${a.date.day}/${a.date.month}/${a.date.year}'),
            if (a.description.isNotEmpty) ...[
              const Divider(height: AppTheme.spacingLg),
              _row('Description', a.description),
            ],
          ],
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: AppTheme.textMuted,
              ),
        ),
        const SizedBox(height: AppTheme.spacingXs),
        Text(value, style: Theme.of(context).textTheme.bodyLarge),
      ],
    );
  }

  Widget _buildProofSection() {
    final a = _activity!;
    final proofs = <String>[
      if (a.proofUrl?.isNotEmpty == true) a.proofUrl!,
      ...?a.proofUrls,
    ].toSet().toList();

    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: AppTheme.border),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Proof Documents',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: AppTheme.spacingMd),
          if (proofs.isEmpty)
            Text(
              'No proof uploaded.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textMuted,
                  ),
            )
          else
            ...proofs.map((url) => _proofItem(url)),
        ],
      ),
    );
  }

  Widget _proofItem(String url) {
    final isPdf = url.toLowerCase().endsWith('.pdf');
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacingSm),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(
          isPdf ? Icons.picture_as_pdf : Icons.image_outlined,
          color: AppTheme.primaryAccent,
        ),
        title: Text(
          url.split('/').last,
          style: Theme.of(context).textTheme.bodyMedium,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: IconButton(
          icon: const Icon(Icons.open_in_new, color: AppTheme.primaryAccent),
          onPressed: () => _openProof(url),
        ),
      ),
    );
  }

  Widget _buildRejectionBanner() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: AppTheme.errorLight,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: AppTheme.error.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline, color: AppTheme.error, size: 18),
              const SizedBox(width: AppTheme.spacingSm),
              Text(
                'Rejection Reason',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: AppTheme.error,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingSm),
          Text(
            _activity!.rejectionReason!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.error,
                ),
          ),
        ],
      ),
    );
  }
}
