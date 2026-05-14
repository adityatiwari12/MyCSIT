import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/mock_auth_provider.dart';
import '../services/mock_auth_service.dart';
import '../services/scoring_service.dart';
import '../data/models/profile_model.dart';
import '../data/repositories/profile_repository.dart';

class EnhancedProfileScreen extends ConsumerStatefulWidget {
  const EnhancedProfileScreen({super.key});

  @override
  ConsumerState<EnhancedProfileScreen> createState() => _EnhancedProfileScreenState();
}

class _EnhancedProfileScreenState extends ConsumerState<EnhancedProfileScreen> {
  ProfileModel? _profile;
  Map<String, dynamic>? _scoringData;
  List<Map<String, dynamic>>? _leaderboard;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final user = ref.read(mockCurrentUserProvider);
    if (user != null) {
      try {
        final profile = await ProfileRepository.getProfile(user.id);
        final scoringData = await ScoringService.calculateComprehensiveScore(user.id);
        final leaderboard = await ScoringService.getLeaderboard();
        
        if (profile == null) {
          // Create initial profile with mock data
          final newProfile = ProfileModel(
            userId: user.id,
            name: user.name,
            cgpa: 8.5, // Mock CGPA
            attendance: 85.0, // Mock attendance
          );
          await ProfileRepository.createOrUpdateProfile(newProfile);
          setState(() {
            _profile = newProfile;
            _scoringData = scoringData;
            _leaderboard = leaderboard;
            _isLoading = false;
          });
        } else {
          setState(() {
            _profile = profile;
            _scoringData = scoringData;
            _leaderboard = leaderboard;
            _isLoading = false;
          });
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(mockCurrentUserProvider);
    
    if (user == null || _isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            _buildUserInfo(user),
            _buildScoreCard(),
            _buildDomainStatusCards(),
            _buildLeaderboard(),
            _buildSocialLinks(),
            _buildAccountSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 120,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFF6B35), Color(0xFFFF9F1C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            bottom: -50,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: _pickProfilePhoto,
                child: Stack(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.white, width: 3),
                        borderRadius: BorderRadius.circular(50),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: _profile?.profilePhotoUrl != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(47),
                              child: Image.asset(
                                _profile!.profilePhotoUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return _buildInitials();
                                },
                              ),
                            )
                          : _buildInitials(),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFF6B35),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.edit,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 40,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.notifications,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInitials() {
    return Center(
      child: Text(
        _profile?.name.isNotEmpty == true ? _profile!.name[0].toUpperCase() : 'U',
        style: const TextStyle(
          color: Color(0xFFFF6B35),
          fontWeight: FontWeight.bold,
          fontSize: 32,
        ),
      ),
    );
  }

  Widget _buildUserInfo(dynamic user) {
    return Container(
      margin: const EdgeInsets.only(top: 60),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Text(
            _profile?.name ?? user.name,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFFF6B35).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Year ${user.year} • Section ${user.section} • Roll: ${user.rollNumber}',
              style: const TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 14,
                color: Color(0xFFFF6B35),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreCard() {
    final totalScore = _scoringData?['totalScore'] ?? 0;
    final completeness = (_scoringData?['profileCompleteness'] ?? 0.0) * 100;

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total Score',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      totalScore.toString(),
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFF6B35),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 60,
                height: 60,
                child: Stack(
                  children: [
                    CircularProgressIndicator(
                      value: completeness / 100,
                      backgroundColor: Colors.grey[200],
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFF6B35)),
                      strokeWidth: 6,
                    ),
                    Center(
                      child: Text(
                        '${completeness.round()}%',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: completeness / 100,
            backgroundColor: Colors.grey[200],
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFF6B35)),
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 8),
          const Text(
            'Profile Completeness',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDomainStatusCards() {
    final domainStats = _scoringData?['domainStats'] ?? {};
    final domainScores = _scoringData?['domainScores'] ?? {};

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Domain Status',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 120, // Fixed height for domain cards container
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildDomainCard(
                  'Hackathons & Events',
                  domainStats['hackathons'] ?? {},
                  domainScores['hackathons'] ?? 0,
                  [Colors.purple, Colors.pink],
                  Icons.emoji_events,
                ),
                const SizedBox(width: 12),
                _buildDomainCard(
                  'Projects & Internships',
                  domainStats['projects'] ?? {},
                  domainScores['projects'] ?? 0,
                  [Colors.blue, Colors.cyan],
                  Icons.work,
                ),
                const SizedBox(width: 12),
                _buildDomainCard(
                  'Academic',
                  domainStats['academic'] ?? {},
                  domainScores['academic'] ?? 0,
                  [Colors.green, Colors.teal],
                  Icons.school,
                ),
                const SizedBox(width: 12),
                _buildDomainCard(
                  'Coding Activity',
                  domainStats['coding'] ?? {},
                  domainScores['coding'] ?? 0,
                  [Colors.orange, Colors.red],
                  Icons.code,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDomainCard(
    String title,
    Map<String, dynamic> stats,
    double score,
    List<Color> colors,
    IconData icon,
  ) {
    final total = stats['total'] ?? 0;
    final approved = stats['approved'] ?? 0;
    final pending = stats['pending'] ?? 0;
    final rejected = stats['rejected'] ?? 0;

    return Container(
      width: 200, // Fixed width to prevent overflow
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: colors),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Score: ${score.round()}',
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 4,
            runSpacing: 4,
            children: [
              _buildStatChip('T', total, Colors.grey),
              _buildStatChip('A', approved, Colors.green),
              _buildStatChip('P', pending, Colors.orange),
              _buildStatChip('R', rejected, Colors.red),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(String label, int value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$label:$value',
        style: TextStyle(
          fontSize: 8,
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildLeaderboard() {
    if (_leaderboard == null || _leaderboard!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Leaderboard',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 16),
          ..._leaderboard!.take(5).map((entry) {
            final isCurrentUser = entry['name'] == _profile?.name;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isCurrentUser ? const Color(0xFFFF6B35).withOpacity(0.1) : Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: isCurrentUser 
                    ? Border.all(color: const Color(0xFFFF6B35))
                    : null,
              ),
              child: Row(
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: _getRankColor(entry['rank']),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Center(
                      child: Text(
                        entry['rank'].toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      entry['name'],
                      style: TextStyle(
                        fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.normal,
                        color: isCurrentUser ? const Color(0xFFFF6B35) : Colors.black,
                      ),
                    ),
                  ),
                  Text(
                    entry['score'].toString(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isCurrentUser ? const Color(0xFFFF6B35) : Colors.black,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1: return Colors.amber;
      case 2: return Colors.grey;
      case 3: return Colors.brown;
      default: return Colors.blue;
    }
  }

  Widget _buildSocialLinks() {
    final platforms = [
      {'name': 'LinkedIn', 'key': 'linkedin', 'icon': Icons.work},
      {'name': 'GitHub', 'key': 'github', 'icon': Icons.code},
      {'name': 'LeetCode', 'key': 'leetcode', 'icon': Icons.laptop},
      {'name': 'Codeforces', 'key': 'codeforces', 'icon': Icons.computer},
      {'name': 'CodeChef', 'key': 'codechef', 'icon': Icons.restaurant},
      {'name': 'Portfolio', 'key': 'portfolio', 'icon': Icons.web},
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Online Presence',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 180, // Fixed height to prevent overflow
            child: GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.5,
              children: platforms.map((platform) {
                final key = platform['key'] as String;
                final hasLink = _profile?.socialLinks.containsKey(key) == true && 
                             _profile!.socialLinks[key]!.isNotEmpty;
                
                return GestureDetector(
                  onTap: () => _showSocialLinkBottomSheet(platform['name'] as String, key),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          platform['icon'] as IconData,
                          color: hasLink ? const Color(0xFFFF6B35) : Colors.grey[600],
                          size: 24,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          platform['name'] as String,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: hasLink ? const Color(0xFFFF6B35) : Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        if (hasLink) ...[
                          const Icon(Icons.check_circle, color: Colors.green, size: 12),
                          Text(
                            'Linked',
                            style: TextStyle(
                              fontSize: 9,
                              color: Colors.green[700],
                            ),
                          ),
                        ] else ...[
                          Text(
                            'Add',
                            style: TextStyle(
                              fontSize: 9,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
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

  Widget _buildAccountSection() {
    return Container(
      margin: const EdgeInsets.all(20),
      child: Column(
        children: [
          GestureDetector(
            onTap: () async {
              await MockAuthService.signOut();
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.logout, color: Colors.red),
                  SizedBox(width: 12),
                  Text(
                    'Logout',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSocialLinkBottomSheet(String platformName, String platformKey) {
    final currentUrl = _profile?.socialLinks[platformKey] ?? '';
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
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
                const SizedBox(width: 16),
                Text(
                  'Add $platformName',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              controller: TextEditingController(text: currentUrl),
              decoration: InputDecoration(
                labelText: '$platformName URL',
                hintText: 'https://$platformKey.com/username',
                border: const OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 20),
            if (currentUrl.isNotEmpty)
              ElevatedButton(
                onPressed: () async {
                  try {
                    await ProfileRepository.removeSocialLink(_profile!.userId, platformKey);
                    await _loadProfileData();
                    if (mounted) {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('$platformName link removed')),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e')),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Remove Link'),
              ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () async {
                // Simplified save functionality
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Save feature coming soon!')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B35),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 48),
              ),
              child: const Text('Save'),
            ),
          ],
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
        // In a real app, you'd upload the file and get a URL
        // For now, we'll just show a success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile photo upload coming soon!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
}
