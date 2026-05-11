import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/auth_provider.dart';
import '../providers/user_provider.dart';
import '../models/user_model.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
        actions: [
          TextButton.icon(
            onPressed: () async {
              await ref.read(authServiceProvider).signOut();
              if (context.mounted) context.go('/login');
            },
            icon: const Icon(Icons.logout_rounded, size: 18),
            label: const Text('Sign Out'),
            style: TextButton.styleFrom(foregroundColor: const Color(0xFF6B7280)),
          ),
        ],
      ),
      body: userAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (user) {
          if (user == null) return const SizedBox.shrink();
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _ProfileHeader(user: user),
                const SizedBox(height: 20),
                _SocialLinksCard(user: user),
                const SizedBox(height: 20),
                _AccountInfoCard(user: user),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final UserModel user;
  const _ProfileHeader({required this.user});

  @override
  Widget build(BuildContext context) {
    final completeness = user.socialLinks.completedCount / 6;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF0F0F0)),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 48,
            backgroundColor: const Color(0xFFFFF3EE),
            child: Text(
              user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
              style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Color(0xFFFF6B35)),
            ),
          ),
          const SizedBox(height: 14),
          Text(user.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
          const SizedBox(height: 4),
          Text(user.rollNumber, style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280))),
          const SizedBox(height: 4),
          Text('Year ${user.year} • Section ${user.section}',
              style: const TextStyle(fontSize: 13, color: Color(0xFF9CA3AF))),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Profile Completeness',
                            style: TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                        Text(
                          '${(completeness * 100).round()}%',
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFFF6B35)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    LinearProgressIndicator(
                      value: completeness,
                      backgroundColor: const Color(0xFFEEEEEE),
                      valueColor: const AlwaysStoppedAnimation(Color(0xFFFF6B35)),
                      minHeight: 6,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SocialLinksCard extends ConsumerStatefulWidget {
  final UserModel user;
  const _SocialLinksCard({required this.user});

  @override
  ConsumerState<_SocialLinksCard> createState() => _SocialLinksCardState();
}

class _SocialLinksCardState extends ConsumerState<_SocialLinksCard> {
  bool _editing = false;
  bool _saving = false;
  final _controllers = <String, TextEditingController>{};

  static const _fields = [
    ('linkedin', 'LinkedIn', Icons.link_rounded),
    ('github', 'GitHub', Icons.code_rounded),
    ('portfolio', 'Portfolio', Icons.web_rounded),
    ('leetcode', 'LeetCode', Icons.terminal_rounded),
    ('codeforces', 'Codeforces', Icons.sports_esports_rounded),
    ('codechef', 'CodeChef', Icons.restaurant_menu_rounded),
  ];

  @override
  void initState() {
    super.initState();
    final links = widget.user.socialLinks;
    _controllers['linkedin'] = TextEditingController(text: links.linkedin ?? '');
    _controllers['github'] = TextEditingController(text: links.github ?? '');
    _controllers['portfolio'] = TextEditingController(text: links.portfolio ?? '');
    _controllers['leetcode'] = TextEditingController(text: links.leetcode ?? '');
    _controllers['codeforces'] = TextEditingController(text: links.codeforces ?? '');
    _controllers['codechef'] = TextEditingController(text: links.codechef ?? '');
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final links = SocialLinks(
        linkedin: _controllers['linkedin']!.text.trim().nullIfEmpty,
        github: _controllers['github']!.text.trim().nullIfEmpty,
        portfolio: _controllers['portfolio']!.text.trim().nullIfEmpty,
        leetcode: _controllers['leetcode']!.text.trim().nullIfEmpty,
        codeforces: _controllers['codeforces']!.text.trim().nullIfEmpty,
        codechef: _controllers['codechef']!.text.trim().nullIfEmpty,
      );
      final uid = widget.user.uid;
      await ref.read(firestoreServiceProvider).updateSocialLinks(uid, links);
      if (mounted) setState(() => _editing = false);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF0F0F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Social Links',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
              if (_editing)
                Row(
                  children: [
                    TextButton(
                      onPressed: () => setState(() => _editing = false),
                      child: const Text('Cancel', style: TextStyle(color: Color(0xFF9CA3AF))),
                    ),
                    TextButton(
                      onPressed: _saving ? null : _save,
                      child: _saving
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Save', style: TextStyle(color: Color(0xFFFF6B35), fontWeight: FontWeight.w700)),
                    ),
                  ],
                )
              else
                TextButton.icon(
                  onPressed: () => setState(() => _editing = true),
                  icon: const Icon(Icons.edit_outlined, size: 16),
                  label: const Text('Edit'),
                  style: TextButton.styleFrom(foregroundColor: const Color(0xFFFF6B35)),
                ),
            ],
          ),
          const SizedBox(height: 12),
          ..._fields.map((field) {
            final (key, label, icon) = field;
            final value = _controllers[key]!.text;
            if (_editing) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: TextFormField(
                  controller: _controllers[key],
                  decoration: InputDecoration(
                    labelText: label,
                    prefixIcon: Icon(icon, size: 18),
                    hintText: 'https://',
                  ),
                  keyboardType: TextInputType.url,
                ),
              );
            }
            final isEmpty = value.isEmpty;
            return _SocialLinkRow(
              icon: icon,
              label: label,
              url: isEmpty ? null : value,
            );
          }),
        ],
      ),
    );
  }
}

class _SocialLinkRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? url;

  const _SocialLinkRow({required this.icon, required this.label, this.url});

  @override
  Widget build(BuildContext context) {
    final isLinked = url != null && url!.isNotEmpty;
    return GestureDetector(
      onTap: isLinked
          ? () async {
              final uri = Uri.parse(url!);
              if (await canLaunchUrl(uri)) launchUrl(uri, mode: LaunchMode.externalApplication);
            }
          : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isLinked ? const Color(0xFFFFF8F5) : const Color(0xFFFAFAFA),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isLinked ? const Color(0xFFFF6B35).withOpacity(0.3) : const Color(0xFFEEEEEE),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: isLinked ? const Color(0xFFFF6B35) : const Color(0xFFCCCCCC)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                isLinked ? url! : 'Not linked',
                style: TextStyle(
                  fontSize: 13,
                  color: isLinked ? const Color(0xFF1A1A2E) : const Color(0xFF9CA3AF),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(
              isLinked ? Icons.check_circle_rounded : Icons.add_circle_outline_rounded,
              size: 18,
              color: isLinked ? const Color(0xFF22C55E) : const Color(0xFFCCCCCC),
            ),
          ],
        ),
      ),
    );
  }
}

class _AccountInfoCard extends StatelessWidget {
  final UserModel user;
  const _AccountInfoCard({required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF0F0F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Account Info',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
          const SizedBox(height: 14),
          _InfoRow('Email', user.email),
          _InfoRow('Status', user.status.name[0].toUpperCase() + user.status.name.substring(1)),
          _InfoRow('Member since', _formatDate(user.createdAt)),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[dt.month - 1]} ${dt.year}';
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFF9CA3AF))),
          Text(value,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1A1A2E))),
        ],
      ),
    );
  }
}

extension on String {
  String? get nullIfEmpty => isEmpty ? null : this;
}
