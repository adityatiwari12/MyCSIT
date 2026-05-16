import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_theme.dart';
import '../core/components/premium_card.dart';
import '../core/components/premium_progress.dart';
import '../data/models/profile_model.dart';
import '../data/repositories/profile_repository.dart';
import '../providers/auth_provider.dart';
import '../providers/supabase_providers.dart';
import '../services/auth_service.dart';

class PremiumProfileScreen extends ConsumerStatefulWidget {
  const PremiumProfileScreen({super.key});

  @override
  ConsumerState<PremiumProfileScreen> createState() =>
      _PremiumProfileScreenState();
}

class _PremiumProfileScreenState extends ConsumerState<PremiumProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final studentAsync = ref.watch(currentStudentProvider);
    final student = studentAsync.valueOrNull;
    final uid = ref.watch(currentUidProvider);

    if (uid == null || student == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final profileAsync = ref.watch(profileProvider(uid));
    final activitiesAsync = ref.watch(activitiesProvider(uid));
    final codingAsync = ref.watch(codingActivitiesProvider(uid));
    final scoreAsync = ref.watch(scoreCacheProvider(uid));

    final profile = profileAsync.valueOrNull;
    final activities = activitiesAsync.valueOrNull ?? [];
    final codingActivities = codingAsync.valueOrNull ?? [];
    final score = scoreAsync.valueOrNull ?? {};

    final approvedActivities =
        activities.where((a) => a.status.name == 'approved').length;
    final approvedCoding =
        codingActivities.where((c) => c.status.name == 'approved').length;
    final completeness = profile?.computedCompleteness ?? 0;

    final initials = student.name
        .split(' ')
        .where((w) => w.isNotEmpty)
        .take(2)
        .map((w) => w[0])
        .join();

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: _buildHeader(context, student.name, student.rollNumber,
                  student.year, student.section, initials),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(AppTheme.spacingMd),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildCompletenessCard(context, completeness),
                  const SizedBox(height: AppTheme.spacingMd),
                  _buildStatsCard(context, activities.length, codingActivities.length,
                      approvedActivities, approvedCoding, score),
                  const SizedBox(height: AppTheme.spacingMd),
                  _buildSocialLinksCard(context, uid, profile),
                  const SizedBox(height: AppTheme.spacingMd),
                  _buildBioCard(context, uid, profile),
                  const SizedBox(height: AppTheme.spacingMd),
                  _buildSignOutButton(context),
                  const SizedBox(height: AppTheme.spacing2xl),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String name, String rollNumber,
      int year, String section, String initials) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingLg),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    initials,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ),
              const SizedBox(width: AppTheme.spacingMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      rollNumber,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white70,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Year $year · Section $section',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white60,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn();
  }

  Widget _buildCompletenessCard(BuildContext context, int completeness) {
    return PremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Profile Completeness',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              Text(
                '$completeness%',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTheme.primaryAccent,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingMd),
          PremiumProgressBar(
            progress: completeness / 100.0,
            progressColor: completeness >= 80
                ? AppTheme.success
                : completeness >= 50
                    ? AppTheme.warning
                    : AppTheme.error,
            height: 8,
          ),
          if (completeness < 100) ...[
            const SizedBox(height: AppTheme.spacingSm),
            Text(
              'Add social links and bio to improve your profile.',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: AppTheme.textMuted),
            ),
          ],
        ],
      ),
    ).animate().fadeIn(delay: 100.ms);
  }

  Widget _buildStatsCard(
      BuildContext context,
      int totalActivities,
      int totalCoding,
      int approvedActivities,
      int approvedCoding,
      Map<String, double> score) {
    return PremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PremiumCardHeader(
            title: 'Statistics',
            subtitle: 'Your overall performance',
            icon: Icons.insights,
            iconColor: AppTheme.info,
          ),
          const SizedBox(height: AppTheme.spacingMd),
          Row(
            children: [
              _statTile(
                  context, '$totalActivities', 'Activities', AppTheme.info),
              _statTile(
                  context, '$approvedActivities', 'Approved', AppTheme.success),
              _statTile(
                  context, '$totalCoding', 'Coding', AppTheme.primaryAccent),
              _statTile(context,
                  score['total']?.toStringAsFixed(0) ?? '0', 'Score', AppTheme.warning),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 150.ms);
  }

  Widget _statTile(
      BuildContext context, String value, String label, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: Theme.of(context)
                .textTheme
                .labelSmall
                ?.copyWith(color: AppTheme.textMuted),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSocialLinksCard(
      BuildContext context, String uid, ProfileModel? profile) {
    final links = [
      (
        'LinkedIn',
        Icons.linked_camera_outlined,
        AppTheme.info,
        profile?.linkedinUrl,
        (String v) => profile?.copyWith(linkedinUrl: v) ??
            ProfileModel(userId: uid, linkedinUrl: v)
      ),
      (
        'GitHub',
        Icons.code,
        const Color(0xFF333333),
        profile?.githubUrl,
        (String v) => profile?.copyWith(githubUrl: v) ??
            ProfileModel(userId: uid, githubUrl: v)
      ),
      (
        'LeetCode',
        Icons.psychology_outlined,
        const Color(0xFFFFA116),
        profile?.leetcodeUrl,
        (String v) => profile?.copyWith(leetcodeUrl: v) ??
            ProfileModel(userId: uid, leetcodeUrl: v)
      ),
      (
        'Codeforces',
        Icons.bolt,
        const Color(0xFF1F8EF1),
        profile?.codeforcesUrl,
        (String v) => profile?.copyWith(codeforcesUrl: v) ??
            ProfileModel(userId: uid, codeforcesUrl: v)
      ),
      (
        'CodeChef',
        Icons.restaurant_menu,
        const Color(0xFF5B4638),
        profile?.codechefUrl,
        (String v) => profile?.copyWith(codechefUrl: v) ??
            ProfileModel(userId: uid, codechefUrl: v)
      ),
      (
        'Portfolio',
        Icons.language,
        AppTheme.primaryAccent,
        profile?.portfolioUrl,
        (String v) => profile?.copyWith(portfolioUrl: v) ??
            ProfileModel(userId: uid, portfolioUrl: v)
      ),
    ];

    return PremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PremiumCardHeader(
            title: 'Social Links',
            subtitle: 'Showcase your profiles',
            icon: Icons.link,
            iconColor: AppTheme.primaryAccent,
          ),
          const SizedBox(height: AppTheme.spacingMd),
          ...links.map((link) {
            final (name, icon, color, value, updater) = link;
            final hasValue = value?.isNotEmpty == true;
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: color.withOpacity(0.12),
                radius: 20,
                child: Icon(icon, color: color, size: 20),
              ),
              title: Text(name,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w600)),
              subtitle: hasValue
                  ? Text(value!,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: AppTheme.textMuted),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis)
                  : Text('Not added',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: AppTheme.textMuted)),
              trailing: IconButton(
                icon: Icon(
                  hasValue ? Icons.edit_outlined : Icons.add,
                  color: AppTheme.primaryAccent,
                  size: 20,
                ),
                onPressed: () =>
                    _editSocialLink(context, uid, name, value, profile, updater),
              ),
            );
          }),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms);
  }

  Widget _buildBioCard(
      BuildContext context, String uid, ProfileModel? profile) {
    return PremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: PremiumCardHeader(
                  title: 'Bio',
                  subtitle: 'Tell faculty about yourself',
                  icon: Icons.person_outline,
                  iconColor: AppTheme.success,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined,
                    color: AppTheme.primaryAccent, size: 20),
                onPressed: () => _editBio(context, uid, profile),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingXs),
          Text(
            profile?.bio?.isNotEmpty == true
                ? profile!.bio!
                : 'No bio added yet. Tap the edit button to add one.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: profile?.bio?.isNotEmpty == true
                      ? AppTheme.textPrimary
                      : AppTheme.textMuted,
                  height: 1.5,
                ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 250.ms);
  }

  Widget _buildSignOutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () async => AuthService.signOut(),
        icon: const Icon(Icons.logout, color: AppTheme.error),
        label: const Text('Sign Out',
            style: TextStyle(color: AppTheme.error, fontWeight: FontWeight.w600)),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppTheme.error),
          padding:
              const EdgeInsets.symmetric(vertical: AppTheme.spacingMd),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusFull)),
        ),
      ),
    ).animate().fadeIn(delay: 300.ms);
  }

  Future<void> _editSocialLink(
    BuildContext context,
    String uid,
    String name,
    String? currentValue,
    ProfileModel? profile,
    ProfileModel Function(String) updater,
  ) async {
    final ctrl = TextEditingController(text: currentValue ?? '');
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Edit $name'),
        content: TextField(
          controller: ctrl,
          decoration: InputDecoration(
            hintText: 'Enter your $name URL or username',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    ctrl.dispose();
    if (result == null) return;

    try {
      final updated = updater(result);
      await ProfileRepository.upsertProfile(updated);
      ref.invalidate(profileProvider(uid));
    } finally {
    }
  }

  Future<void> _editBio(
      BuildContext context, String uid, ProfileModel? profile) async {
    final ctrl = TextEditingController(text: profile?.bio ?? '');
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Bio'),
        content: TextField(
          controller: ctrl,
          maxLines: 4,
          decoration: const InputDecoration(
            hintText: 'Write a short bio about yourself…',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    ctrl.dispose();
    if (result == null) return;

    try {
      final updated = profile?.copyWith(bio: result) ??
          ProfileModel(userId: uid, bio: result);
      await ProfileRepository.upsertProfile(updated);
      ref.invalidate(profileProvider(uid));
    } finally {
    }
  }
}
