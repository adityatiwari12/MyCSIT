import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/data_provider.dart';
import '../providers/user_provider.dart';
import '../models/coding_activity_model.dart';
import '../models/activity_model.dart';

class CodingScreen extends ConsumerWidget {
  const CodingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final codingAsync = ref.watch(codingActivitiesStreamProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        title: const Text('Coding Activities'),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () => context.go('/home/coding/add'),
          ),
        ],
      ),
      body: codingAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (entries) {
          if (entries.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.code_rounded, size: 64, color: Color(0xFFCCCCCC)),
                  const SizedBox(height: 16),
                  const Text('No coding entries yet',
                      style: TextStyle(fontSize: 16, color: Color(0xFF9CA3AF))),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => context.go('/home/coding/add'),
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Add Entry'),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: entries.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) => _CodingCard(entry: entries[index]),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/home/coding/add'),
        backgroundColor: const Color(0xFF22C55E),
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
    );
  }
}

class _CodingCard extends ConsumerWidget {
  final CodingActivityModel entry;
  const _CodingCard({required this.entry});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Color statusColor;
    Color statusBg;
    String statusText;

    switch (entry.status) {
      case EntryStatus.approved:
        statusColor = const Color(0xFF22C55E);
        statusBg = const Color(0xFFDCFCE7);
        statusText = 'Approved';
        break;
      case EntryStatus.rejected:
        statusColor = const Color(0xFFEF4444);
        statusBg = const Color(0xFFFEE2E2);
        statusText = 'Rejected';
        break;
      default:
        statusColor = const Color(0xFFF59E0B);
        statusBg = const Color(0xFFFEF3C7);
        statusText = 'Pending';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF0F0F0)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FFF4),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.code_rounded, color: Color(0xFF22C55E), size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.title,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF1A1A2E)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Row(
                  children: [
                    Text(entry.platformLabel,
                        style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF))),
                    const Text(' • ', style: TextStyle(color: Color(0xFF9CA3AF))),
                    Text(
                      entry.codingType == CodingType.milestone
                          ? 'Rating: ${entry.value}'
                          : 'Contests: ${entry.value}',
                      style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(20)),
                child: Text(statusText,
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: statusColor)),
              ),
              if (entry.status == EntryStatus.rejected)
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Color(0xFFEF4444)),
                  onPressed: () => _confirmDelete(context, ref),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Entry'),
        content: const Text('Delete this coding entry?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Color(0xFFEF4444))),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(firestoreServiceProvider).deleteCodingActivity(entry.id);
    }
  }
}
