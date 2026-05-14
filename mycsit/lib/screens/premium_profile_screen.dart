import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import '../core/theme/app_theme.dart';
import '../core/components/premium_card.dart';
import '../core/components/premium_chip.dart';
import '../core/components/premium_progress.dart';
import '../core/components/premium_empty_state.dart';
import '../providers/mock_auth_provider.dart';
import '../services/mock_auth_service.dart';
import '../data/models/profile_model.dart';
import '../data/repositories/profile_repository.dart';

class PremiumProfileScreen extends ConsumerStatefulWidget {
  const PremiumProfileScreen({super.key});

  @override
  ConsumerState<PremiumProfileScreen> createState() => _PremiumProfileScreenState();
}

class _PremiumProfileScreenState extends ConsumerState<PremiumProfileScreen> {
  ProfileModel? _profile;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final user = ref.read(mockCurrentUserProvider);
    if (user != null) {
      final profile = await ProfileRepository.getProfile(user.id);
      if (profile == null) {
        final newProfile = ProfileModel(
          userId: user.id,
          name: user.name,
        );
        await ProfileRepository.createOrUpdateProfile(newProfile);
        if (mounted) {
          setState(() {
            _profile = newProfile;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _profile = profile;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(mockCurrentUserProvider);
    
    if (user == null || _profile == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Profile Header
            SliverToBoxAdapter(
              child: _buildProfileHeader(context, user),
            ),
            
            // Content
            SliverPadding(
              padding: const EdgeInsets.all(AppTheme.spacingMd),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: AppTheme.spacingMd),
                  
                  // Profile Completeness
                  _buildProfileCompleteness(context),
                  
                  const SizedBox(height: AppTheme.spacingLg),
                  
                  // Academic Summary
                  _buildAcademicSummary(context, user),
                  
                  const SizedBox(height: AppTheme.spacingLg),
                  
                  // Skills & Interests
                  _buildSkillsAndInterests(context),
                  
                  const SizedBox(height: AppTheme.spacingLg),
                  
                  // Coding Platform Stats
                  _buildCodingStats(context),
                  
                  const SizedBox(height: AppTheme.spacingLg),
                  
                  // Achievement Badges
                  _buildAchievementBadges(context),
                  
                  const SizedBox(height: AppTheme.spacingLg),
                  
                  // Activity Stats
                  _buildActivityStats(context),
                  
                  const SizedBox(height: AppTheme.spacingLg),
                  
                  // Social Links
                  _buildSocialLinks(context),
                  
                  const SizedBox(height: AppTheme.spacingLg),
                  
                  // Account Settings
                  _buildAccountSettings(context),
                  
                  const SizedBox(height: AppTheme.spacing2xl),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, dynamic user) {
    return Stack(
      children: [
        // Background gradient
        Container(
          height: 200,
          decoration: const BoxDecoration(
            gradient: AppTheme.primaryGradient,
          ),
        ),
        
        // Content
        Positioned.fill(
          child: SafeArea(
            child: Column(
              children: [
                // App bar
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingMd,
                    vertical: AppTheme.spacingSm,
                  ),
                  child: Row(
                    children: [
                      const Text(
                        'Profile',
                        style: TextStyle(
                          color: AppTheme.textInverse,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.settings, color: AppTheme.textInverse),
                        onPressed: () {
                          // Navigate to settings
                        },
                      ),
                    ],
                  ),
                ),
                
                const Spacer(),
                
                // Avatar and info
                Column(
                  children: [
                    GestureDetector(
                      onTap: _pickProfilePhoto,
                      child: Stack(
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: AppTheme.surface,
                              shape: BoxShape.circle,
                              boxShadow: AppTheme.shadowLg,
                              border: Border.all(
                                color: AppTheme.surface,
                                width: 4,
                              ),
                            ),
                            child: _profile!.profilePhotoUrl != null
                                ? ClipOval(
                                    child: Image.asset(
                                      _profile!.profilePhotoUrl!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return _buildInitials(user);
                                      },
                                    ),
                                  )
                                : _buildInitials(user),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: AppTheme.primaryAccent,
                                shape: BoxShape.circle,
                                boxShadow: AppTheme.shadowMd,
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                color: AppTheme.textInverse,
                                size: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingMd),
                    Text(
                      _profile!.name,
                      style: const TextStyle(
                        color: AppTheme.textInverse,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingXs),
                    Text(
                      'Year ${user.year} • Section ${user.section} • Roll: ${user.rollNumber}',
                      style: const TextStyle(
                        color: AppTheme.textInverse,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingLg),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    ).animate().fadeIn();
  }

  Widget _buildInitials(dynamic user) {
    return Center(
      child: Text(
        user.name.split(' ').map((e) => e[0]).take(2).join().toUpperCase(),
        style: const TextStyle(
          color: AppTheme.primaryAccent,
          fontWeight: FontWeight.bold,
          fontSize: 32,
        ),
      ),
    );
  }

  Widget _buildProfileCompleteness(BuildContext context) {
    final completeness = (_profile!.profileCompleteness * 100).round();
    final incompleteFields = <String>[];

    if (_profile!.profilePhotoUrl == null || _profile!.profilePhotoUrl!.isEmpty) {
      incompleteFields.add('Profile Photo');
    }

    final platforms = ['linkedin', 'github', 'leetcode', 'codeforces', 'codechef'];
    for (final platform in platforms) {
      if (!_profile!.socialLinks.containsKey(platform) || _profile!.socialLinks[platform]!.isEmpty) {
        incompleteFields.add(platform.toUpperCase());
      }
    }

    return PremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PremiumCardHeader(
            title: 'Profile Strength',
            subtitle: 'Complete your profile to unlock features',
            icon: Icons.account_circle,
            iconColor: AppTheme.primaryAccent,
          ),
          const SizedBox(height: AppTheme.spacingMd),
          PremiumProgressBar(
            progress: completeness / 100,
            height: 12,
            progressColor: AppTheme.primaryAccent,
          ),
          const SizedBox(height: AppTheme.spacingMd),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$completeness% Complete',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryAccent,
                    ),
              ),
              if (incompleteFields.isNotEmpty)
                Text(
                  '${incompleteFields.length} remaining',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                ),
            ],
          ),
          if (incompleteFields.isNotEmpty) ...[
            const SizedBox(height: AppTheme.spacingMd),
            Wrap(
              spacing: AppTheme.spacingSm,
              runSpacing: AppTheme.spacingSm,
              children: incompleteFields.map((field) {
                return PremiumChip(
                  label: field,
                  icon: Icons.add_circle_outline,
                  isSelected: false,
                );
              }).toList(),
            ),
          ],
        ],
      ),
    ).animate().fadeIn(delay: 200.ms);
  }

  Widget _buildAcademicSummary(BuildContext context, dynamic user) {
    return PremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PremiumCardHeader(
            title: 'Academic Summary',
            subtitle: 'Your academic performance',
            icon: Icons.school,
            iconColor: AppTheme.info,
          ),
          const SizedBox(height: AppTheme.spacingMd),
          Row(
            children: [
              Expanded(
                child: _buildAcademicStat(
                  context,
                  'CGPA',
                  '8.5',
                  Icons.grade,
                  AppTheme.success,
                ),
              ),
              const SizedBox(width: AppTheme.spacingMd),
              Expanded(
                child: _buildAcademicStat(
                  context,
                  'Attendance',
                  '92%',
                  Icons.present_to_all,
                  AppTheme.info,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingMd),
          Row(
            children: [
              Expanded(
                child: _buildAcademicStat(
                  context,
                  'Credits',
                  '120',
                  Icons.book,
                  AppTheme.warning,
                ),
              ),
              const SizedBox(width: AppTheme.spacingMd),
              Expanded(
                child: _buildAcademicStat(
                  context,
                  'Semester',
                  '6th',
                  Icons.calendar_month,
                  AppTheme.primaryAccent,
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms);
  }

  Widget _buildAcademicStat(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 28, color: color),
          const SizedBox(height: AppTheme.spacingSm),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
          ),
          const SizedBox(height: AppTheme.spacingXxs),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillsAndInterests(BuildContext context) {
    final skills = [
      'Flutter', 'Dart', 'Python', 'JavaScript', 
      'React', 'Node.js', 'Machine Learning', 'UI/UX'
    ];

    return PremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PremiumCardHeader(
            title: 'Skills & Interests',
            subtitle: 'Your technical expertise',
            icon: Icons.psychology,
            iconColor: AppTheme.primaryAccent,
            trailing: TextButton(
              onPressed: () {},
              child: const Text('Edit'),
            ),
          ),
          const SizedBox(height: AppTheme.spacingMd),
          Wrap(
            spacing: AppTheme.spacingSm,
            runSpacing: AppTheme.spacingSm,
            children: skills.map((skill) {
              return PremiumChip(
                label: skill,
                isSelected: true,
              );
            }).toList(),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms);
  }

  Widget _buildCodingStats(BuildContext context) {
    return PremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PremiumCardHeader(
            title: 'Coding Platform Stats',
            subtitle: 'Your competitive programming journey',
            icon: Icons.code,
            iconColor: AppTheme.success,
          ),
          const SizedBox(height: AppTheme.spacingMd),
          _buildPlatformStat(
            context,
            'LeetCode',
            '350+',
            'Rating: 1650',
            Icons.laptop,
            AppTheme.warning,
          ),
          const SizedBox(height: AppTheme.spacingSm),
          _buildPlatformStat(
            context,
            'Codeforces',
            '120+',
            'Rating: 1450',
            Icons.computer,
            AppTheme.info,
          ),
          const SizedBox(height: AppTheme.spacingSm),
          _buildPlatformStat(
            context,
            'CodeChef',
            '80+',
            'Rating: 3 stars',
            Icons.restaurant,
            AppTheme.success,
          ),
        ],
      ),
    ).animate().fadeIn(delay: 500.ms);
  }

  Widget _buildPlatformStat(
    BuildContext context,
    String platform,
    String problems,
    String rating,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingSm),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            ),
            child: Icon(icon, size: 24, color: color),
          ),
          const SizedBox(width: AppTheme.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  platform,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: AppTheme.spacingXxs),
                Text(
                  rating,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingSm,
              vertical: AppTheme.spacingXs,
            ),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            ),
            child: Text(
              problems,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementBadges(BuildContext context) {
    final badges = [
      {'icon': Icons.emoji_events, 'title': 'First Activity', 'color': AppTheme.primaryAccent},
      {'icon': Icons.code, 'title': 'Code Warrior', 'color': AppTheme.success},
      {'icon': Icons.star, 'title': 'Top Performer', 'color': AppTheme.warning},
      {'icon': Icons.local_fire_department, 'title': '7-Day Streak', 'color': AppTheme.error},
      {'icon': Icons.school, 'title': 'Scholar', 'color': AppTheme.info},
      {'icon': Icons.psychology, 'title': 'Problem Solver', 'color': AppTheme.primaryAccent},
    ];

    return PremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PremiumCardHeader(
            title: 'Achievement Badges',
            subtitle: 'Your accomplishments',
            icon: Icons.military_tech,
            iconColor: AppTheme.warning,
            trailing: TextButton(
              onPressed: () {},
              child: const Text('View all'),
            ),
          ),
          const SizedBox(height: AppTheme.spacingMd),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: AppTheme.spacingSm,
              mainAxisSpacing: AppTheme.spacingSm,
              childAspectRatio: 1,
            ),
            itemCount: badges.length,
            itemBuilder: (context, index) {
              final badge = badges[index];
              return Container(
                decoration: BoxDecoration(
                  color: (badge['color'] as Color).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  border: Border.all(
                    color: (badge['color'] as Color).withOpacity(0.3),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      badge['icon'] as IconData,
                      size: 32,
                      color: badge['color'] as Color,
                    ),
                    const SizedBox(height: AppTheme.spacingXs),
                    Text(
                      badge['title'] as String,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    ).animate().fadeIn(delay: 600.ms);
  }

  Widget _buildActivityStats(BuildContext context) {
    return PremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PremiumCardHeader(
            title: 'Activity Stats',
            subtitle: 'Your engagement metrics',
            icon: Icons.bar_chart,
            iconColor: AppTheme.info,
          ),
          const SizedBox(height: AppTheme.spacingMd),
          Row(
            children: [
              Expanded(
                child: _buildActivityStat(
                  context,
                  'Total Activities',
                  '24',
                  Icons.event,
                  AppTheme.primaryAccent,
                ),
              ),
              const SizedBox(width: AppTheme.spacingMd),
              Expanded(
                child: _buildActivityStat(
                  context,
                  'This Month',
                  '8',
                  Icons.calendar_today,
                  AppTheme.success,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingMd),
          Row(
            children: [
              Expanded(
                child: _buildActivityStat(
                  context,
                  'Points Earned',
                  '2,450',
                  Icons.star,
                  AppTheme.warning,
                ),
              ),
              const SizedBox(width: AppTheme.spacingMd),
              Expanded(
                child: _buildActivityStat(
                  context,
                  'Rank',
                  '#15',
                  Icons.emoji_events,
                  AppTheme.info,
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 700.ms);
  }

  Widget _buildActivityStat(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, size: 28, color: color),
        const SizedBox(height: AppTheme.spacingSm),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
        ),
        const SizedBox(height: AppTheme.spacingXxs),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondary,
              ),
        ),
      ],
    );
  }

  Widget _buildSocialLinks(BuildContext context) {
    final platforms = [
      {'name': 'LinkedIn', 'key': 'linkedin', 'icon': Icons.work, 'color': AppTheme.info},
      {'name': 'GitHub', 'key': 'github', 'icon': Icons.code, 'color': AppTheme.textPrimary},
      {'name': 'LeetCode', 'key': 'leetcode', 'icon': Icons.laptop, 'color': AppTheme.warning},
      {'name': 'Codeforces', 'key': 'codeforces', 'icon': Icons.computer, 'color': AppTheme.error},
      {'name': 'CodeChef', 'key': 'codechef', 'icon': Icons.restaurant, 'color': AppTheme.success},
      {'name': 'Portfolio', 'key': 'portfolio', 'icon': Icons.web, 'color': AppTheme.primaryAccent},
    ];

    return PremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PremiumCardHeader(
            title: 'Social Links',
            subtitle: 'Connect your profiles',
            icon: Icons.link,
            iconColor: AppTheme.primaryAccent,
          ),
          const SizedBox(height: AppTheme.spacingMd),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: AppTheme.spacingSm,
              mainAxisSpacing: AppTheme.spacingSm,
              childAspectRatio: 1.5,
            ),
            itemCount: platforms.length,
            itemBuilder: (context, index) {
              final platform = platforms[index];
              final key = platform['key'] as String;
              final hasLink = _profile!.socialLinks.containsKey(key) && 
                           _profile!.socialLinks[key]!.isNotEmpty;
              final color = platform['color'] as Color;
              
              return GestureDetector(
                onTap: () => _showSocialLinkBottomSheet(
                  platform['name'] as String, 
                  key,
                  color,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: hasLink ? color.withOpacity(0.1) : AppTheme.background,
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    border: Border.all(
                      color: hasLink ? color : AppTheme.border,
                      width: hasLink ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        platform['icon'] as IconData,
                        color: hasLink ? color : AppTheme.textMuted,
                        size: 28,
                      ),
                      const SizedBox(height: AppTheme.spacingSm),
                      Text(
                        platform['name'] as String,
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: hasLink ? color : AppTheme.textSecondary,
                            ),
                      ),
                      const SizedBox(height: AppTheme.spacingXxs),
                      if (hasLink) ...[
                        const Icon(Icons.check_circle, color: AppTheme.success, size: 16),
                        Text(
                          'Connected',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: AppTheme.success,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ] else ...[
                        Text(
                          'Add',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: AppTheme.textMuted,
                              ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    ).animate().fadeIn(delay: 800.ms);
  }

  Widget _buildAccountSettings(BuildContext context) {
    return PremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PremiumCardHeader(
            title: 'Account',
            icon: Icons.settings,
            iconColor: AppTheme.textSecondary,
          ),
          const SizedBox(height: AppTheme.spacingSm),
          _buildSettingItem(
            context,
            'Edit Profile',
            Icons.person,
            () {},
          ),
          _buildSettingItem(
            context,
            'Change Password',
            Icons.lock,
            () {},
          ),
          _buildSettingItem(
            context,
            'Notifications',
            Icons.notifications,
            () {},
          ),
          _buildSettingItem(
            context,
            'Privacy',
            Icons.privacy_tip,
            () {},
          ),
          const Divider(height: AppTheme.spacingLg),
          _buildSettingItem(
            context,
            'Logout',
            Icons.logout,
            () async {
              await MockAuthService.signOut();
            },
            isDestructive: true,
          ),
        ],
      ),
    ).animate().fadeIn(delay: 900.ms);
  }

  Widget _buildSettingItem(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: AppTheme.spacingMd,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isDestructive ? AppTheme.error : AppTheme.textSecondary,
            ),
            const SizedBox(width: AppTheme.spacingMd),
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isDestructive ? AppTheme.error : AppTheme.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: 20,
              color: AppTheme.textMuted,
            ),
          ],
        ),
      ),
    );
  }

  void _showSocialLinkBottomSheet(String platformName, String platformKey, Color color) {
    final currentUrl = _profile!.socialLinks[platformKey] ?? '';
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppTheme.radius2xl),
          ),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingLg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: AppTheme.spacingMd),
                  Text(
                    'Add $platformName',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spacingLg),
              TextField(
                controller: TextEditingController(text: currentUrl),
                decoration: InputDecoration(
                  labelText: '$platformName URL',
                  hintText: 'https://$platformKey.com/username',
                  prefixIcon: Icon(Icons.link, color: color),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: AppTheme.spacingLg),
              if (currentUrl.isNotEmpty)
                OutlinedButton(
                  onPressed: () async {
                    try {
                      await ProfileRepository.removeSocialLink(_profile!.userId, platformKey);
                      await _loadProfile();
                      if (mounted) {
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('$platformName link removed'),
                            backgroundColor: AppTheme.success,
                          ),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error: $e'),
                            backgroundColor: AppTheme.error,
                          ),
                        );
                      }
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.error,
                    side: const BorderSide(color: AppTheme.error),
                  ),
                  child: const Text('Remove Link'),
                ),
              const SizedBox(height: AppTheme.spacingMd),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Save feature coming soon!'),
                        backgroundColor: AppTheme.warning,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    foregroundColor: AppTheme.textInverse,
                  ),
                  child: const Text('Save'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickProfilePhoto() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );
      
      if (pickedFile != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile photo upload coming soon!'),
            backgroundColor: AppTheme.warning,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: AppTheme.error,
        ),
      );
    }
  }
}
