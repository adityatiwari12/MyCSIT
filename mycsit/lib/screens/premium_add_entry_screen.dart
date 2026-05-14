import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/app_theme.dart';
import '../core/components/premium_card.dart';
import 'add_activity_sheet.dart';
import 'add_coding_sheet.dart';

class PremiumAddEntryScreen extends StatelessWidget {
  const PremiumAddEntryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // App Bar
            _buildAppBar(context),
            
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppTheme.spacingMd),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppTheme.spacingMd),
                    
                    // Welcome section
                    _buildWelcomeSection(context),
                    
                    const SizedBox(height: AppTheme.spacingLg),
                    
                    // Entry type selection
                    Text(
                      'What would you like to add?',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: AppTheme.spacingMd),
                    
                    // Activity Card
                    _buildEntryCard(
                      context,
                      'Activity',
                      'Workshops, seminars, competitions, and more',
                      Icons.event,
                      AppTheme.info,
                      () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) => const AddActivitySheet(),
                        );
                      },
                    ),
                    
                    const SizedBox(height: AppTheme.spacingMd),
                    
                    // Coding Card
                    _buildEntryCard(
                      context,
                      'Coding Problem',
                      'LeetCode, Codeforces, CodeChef solutions',
                      Icons.code,
                      AppTheme.success,
                      () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) => const AddCodingSheet(),
                        );
                      },
                    ),
                    
                    const SizedBox(height: AppTheme.spacingMd),
                    
                    // Academic Card
                    _buildEntryCard(
                      context,
                      'Academic Record',
                      'Grades, attendance, and achievements',
                      Icons.school,
                      AppTheme.warning,
                      () {
                        // Keep academic route as is for now or use sheet
                        // Navigator.pushNamed(context, '/add-academic');
                      },
                    ),
                    
                    const SizedBox(height: AppTheme.spacingLg),
                    
                    // Quick tips section
                    _buildQuickTips(context),
                    
                    const SizedBox(height: AppTheme.spacing2xl),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingMd,
        vertical: AppTheme.spacingSm,
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              boxShadow: AppTheme.shadowSm,
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          const SizedBox(width: AppTheme.spacingMd),
          Text(
            'Add Entry',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingLg),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        boxShadow: AppTheme.shadowColored,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.add_circle_outline,
            size: 48,
            color: AppTheme.textInverse,
          ),
          const SizedBox(height: AppTheme.spacingMd),
          Text(
            'Track Your Progress',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppTheme.textInverse,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: AppTheme.spacingSm),
          Text(
            'Add activities, coding problems, and academic achievements to build your profile.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textInverse,
                ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.1, end: 0);
  }

  Widget _buildEntryCard(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        child: Container(
          padding: const EdgeInsets.all(AppTheme.spacingLg),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            border: Border.all(color: AppTheme.border),
            boxShadow: AppTheme.shadowSm,
          ),
          child: Row(
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: color,
                ),
              ),
              const SizedBox(width: AppTheme.spacingMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: AppTheme.spacingXs),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(AppTheme.spacingSm),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                ),
                child: Icon(
                  Icons.chevron_right,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: 200.ms).slideX(begin: 0.1, end: 0);
  }

  Widget _buildQuickTips(BuildContext context) {
    return PremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PremiumCardHeader(
            title: 'Quick Tips',
            subtitle: 'Make the most of your entries',
            icon: Icons.lightbulb,
            iconColor: AppTheme.warning,
          ),
          const SizedBox(height: AppTheme.spacingMd),
          _buildTip(
            context,
            'Add proof screenshots',
            'Attach screenshots or certificates for verification',
            Icons.image,
          ),
          const SizedBox(height: AppTheme.spacingSm),
          _buildTip(
            context,
            'Be descriptive',
            'Provide detailed descriptions for better visibility',
            Icons.description,
          ),
          const SizedBox(height: AppTheme.spacingSm),
          _buildTip(
            context,
            'Stay consistent',
            'Regular updates improve your profile strength',
            Icons.trending_up,
          ),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms);
  }

  Widget _buildTip(
    BuildContext context,
    String title,
    String description,
    IconData icon,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(AppTheme.spacingSm),
          decoration: BoxDecoration(
            color: AppTheme.warning.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          ),
          child: Icon(icon, size: 20, color: AppTheme.warning),
        ),
        const SizedBox(width: AppTheme.spacingMd),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: AppTheme.spacingXxs),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
