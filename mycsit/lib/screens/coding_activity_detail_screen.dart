import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/theme/app_theme.dart';
import '../data/models/coding_activity_model.dart';
import '../data/repositories/coding_repository.dart';
import '../providers/auth_provider.dart';

class CodingActivityDetailScreen extends ConsumerStatefulWidget {
  final String activityId;

  const CodingActivityDetailScreen({super.key, required this.activityId});

  @override
  ConsumerState<CodingActivityDetailScreen> createState() =>
      _CodingActivityDetailScreenState();
}

class _CodingActivityDetailScreenState
    extends ConsumerState<CodingActivityDetailScreen> {
  CodingActivityModel? _activity;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadActivity();
  }

  Future<void> _loadActivity() async {
    final uid = ref.read(currentUidProvider);
    if (uid == null) return;

    try {
      final row = await Supabase.instance.client
          .from('coding_activities')
          .select()
          .eq('id', widget.activityId)
          .maybeSingle();

      if (row != null) {
        final a = CodingActivityModel.fromSupabaseMap(row);
        if (mounted) setState(() { _activity = a; _isLoading = false; });
        return;
      }
    } catch (_) {}

    // Fallback: search Hive
    final uid2 = ref.read(currentUidProvider) ?? '';
    final all = await CodingRepository.getCodingActivities(uid2);
    final found = all
        .cast<CodingActivityModel?>()
        .firstWhere((a) => a?.id == widget.activityId, orElse: () => null);
    if (mounted) setState(() { _activity = found; _isLoading = false; });
  }

  Future<void> _openProof(String url) async {
    if (url.isEmpty) return;
    try {
      if (url.startsWith('/') || url.startsWith('file://')) {
        final file = File(url.replaceFirst('file://', ''));
        if (await file.exists()) {
          await launchUrl(Uri.file(url));
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
        title: const Text('Coding Activity Details'),
        backgroundColor: AppTheme.surface,
        foregroundColor: AppTheme.textPrimary,
        elevation: 0,
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
      case CodingStatus.pending:
        color = AppTheme.warning;
        bg = AppTheme.warningLight;
        icon = Icons.hourglass_empty;
        label = 'Pending Approval';
        break;
      case CodingStatus.approved:
        color = AppTheme.success;
        bg = AppTheme.successLight;
        icon = Icons.check_circle;
        label = 'Approved';
        break;
      case CodingStatus.rejected:
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
          _row('Platform', a.platform),
          const Divider(height: AppTheme.spacingLg),
          _row('Title', a.title),
          if (a.value != null) ...[
            const Divider(height: AppTheme.spacingLg),
            _row('Value', _valueLabel(a)),
          ],
          if (a.contestName != null) ...[
            const Divider(height: AppTheme.spacingLg),
            _row('Contest', a.contestName!),
          ],
          if (a.difficulty != null) ...[
            const Divider(height: AppTheme.spacingLg),
            _row('Difficulty', a.difficulty!),
          ],
          const Divider(height: AppTheme.spacingLg),
          _row(
            'Submitted',
            '${a.createdAt.day}/${a.createdAt.month}/${a.createdAt.year}',
          ),
        ],
      ),
    );
  }

  String _valueLabel(CodingActivityModel a) {
    switch (a.type) {
      case CodingType.milestone:
        return '${a.value} problems solved';
      case CodingType.contest:
        return 'Rank ${a.value}';
      case CodingType.highValueProblem:
        return a.title;
    }
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
