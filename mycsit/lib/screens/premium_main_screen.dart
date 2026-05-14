import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_theme.dart';
import '../core/components/premium_bottom_nav.dart';
import 'premium_home_screen.dart';
import 'premium_activities_screen.dart';
import 'premium_add_entry_screen.dart';
import 'premium_profile_screen.dart';

class PremiumMainScreen extends ConsumerStatefulWidget {
  const PremiumMainScreen({super.key});

  @override
  ConsumerState<PremiumMainScreen> createState() => _PremiumMainScreenState();
}

class _PremiumMainScreenState extends ConsumerState<PremiumMainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const PremiumHomeScreen(),
    const PremiumActivitiesScreen(),
    const PremiumAddEntryScreen(),
    const PremiumProfileScreen(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: PremiumBottomNav(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}
