import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/mock_auth_provider.dart';
import '../services/mock_auth_service.dart';
import '../data/models/profile_model.dart';
import '../data/repositories/profile_repository.dart';

class FunctionalProfileScreen extends ConsumerStatefulWidget {
  const FunctionalProfileScreen({super.key});

  @override
  ConsumerState<FunctionalProfileScreen> createState() => _FunctionalProfileScreenState();
}

class _FunctionalProfileScreenState extends ConsumerState<FunctionalProfileScreen> {
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
        // Create initial profile
        final newProfile = ProfileModel(
          userId: user.id,
          name: user.name,
        );
        await ProfileRepository.createOrUpdateProfile(newProfile);
        setState(() {
          _profile = newProfile;
        });
      } else {
        setState(() {
          _profile = profile;
        });
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            _buildUserInfo(user),
            _buildProfileCompleteness(),
            _buildSocialLinks(),
            _buildAccountSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 100,
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
            bottom: -40,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: _pickProfilePhoto,
                child: Stack(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.white, width: 3),
                        borderRadius: BorderRadius.circular(40),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: _profile!.profilePhotoUrl != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(37),
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
                        width: 24,
                        height: 24,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFF6B35),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.edit,
                          color: Colors.white,
                          size: 14,
                        ),
                      ),
                    ),
                  ],
                ),
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
        _profile!.name.isNotEmpty ? _profile!.name[0].toUpperCase() : 'U',
        style: const TextStyle(
          color: Color(0xFFFF6B35),
          fontWeight: FontWeight.bold,
          fontSize: 24,
        ),
      ),
    );
  }

  Widget _buildUserInfo(dynamic user) {
    return Container(
      margin: const EdgeInsets.only(top: 50),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Text(
            _profile!.name,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Year ${user.year} • Section ${user.section} • Roll: ${user.rollNumber}',
            style: const TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 13,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCompleteness() {
    final completeness = (_profile!.profileCompleteness * 100).round();
    final incompleteFields = <String>[];

    if (_profile!.profilePhotoUrl == null || _profile!.profilePhotoUrl!.isEmpty) {
      incompleteFields.add('Add Profile Photo');
    }

    final platforms = ['linkedin', 'github', 'leetcode', 'codeforces', 'codechef'];
    for (final platform in platforms) {
      if (!_profile!.socialLinks.containsKey(platform) || _profile!.socialLinks[platform]!.isEmpty) {
        incompleteFields.add('Add ${platform.toUpperCase()}');
      }
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
          LinearProgressIndicator(
            value: completeness / 100,
            backgroundColor: Colors.grey[200],
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFF6B35)),
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 8),
          Text(
            '$completeness% Complete',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          if (incompleteFields.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: incompleteFields.map((field) {
                return Chip(
                  label: Text(
                    field,
                    style: const TextStyle(fontSize: 12),
                  ),
                  backgroundColor: Colors.grey[200],
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
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
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.5,
            children: platforms.map((platform) {
              final key = platform['key'] as String;
              final hasLink = _profile!.socialLinks.containsKey(key) && 
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
                      const SizedBox(height: 8),
                      Text(
                        platform['name'] as String,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: hasLink ? const Color(0xFFFF6B35) : Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (hasLink) ...[
                        const Icon(Icons.check_circle, color: Colors.green, size: 12),
                        Text(
                          'Linked',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.green[700],
                          ),
                        ),
                      ] else ...[
                        Text(
                          'Add',
                          style: TextStyle(
                            fontSize: 10,
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
            child: ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                'Logout',
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSocialLinkBottomSheet(String platformName, String platformKey) {
    final currentUrl = _profile!.socialLinks[platformKey] ?? '';
    
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
                    await _loadProfile();
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
