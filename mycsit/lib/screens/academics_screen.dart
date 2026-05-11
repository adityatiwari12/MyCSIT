import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/data_provider.dart';
import '../models/semester_model.dart';

class AcademicsScreen extends ConsumerWidget {
  const AcademicsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final semestersAsync = ref.watch(semestersStreamProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        title: const Text('Academics'),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: semestersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (semesters) {
          if (semesters.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.school_outlined, size: 64, color: Color(0xFFCCCCCC)),
                  SizedBox(height: 16),
                  Text('No academic records yet',
                      style: TextStyle(fontSize: 16, color: Color(0xFF9CA3AF))),
                  SizedBox(height: 8),
                  Text('Faculty will add your marks here',
                      style: TextStyle(fontSize: 13, color: Color(0xFFCCCCCC))),
                ],
              ),
            );
          }

          final latestCgpa = semesters.lastWhere(
            (s) => s.cgpa != null,
            orElse: () => semesters.last,
          ).cgpa;

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      if (latestCgpa != null)
                        _CgpaCard(cgpa: latestCgpa),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _SemesterCard(semester: semesters[index]),
                    childCount: semesters.length,
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          );
        },
      ),
    );
  }
}

class _CgpaCard extends StatelessWidget {
  final double cgpa;
  const _CgpaCard({required this.cgpa});

  @override
  Widget build(BuildContext context) {
    final color = cgpa >= 8.5
        ? const Color(0xFF22C55E)
        : cgpa >= 7.0
            ? const Color(0xFF3B82F6)
            : const Color(0xFFF59E0B);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF0F0F0)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Current CGPA',
                    style: TextStyle(fontSize: 13, color: Color(0xFF9CA3AF))),
                const SizedBox(height: 4),
                Text(
                  cgpa.toStringAsFixed(2),
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text('out of 10.0',
                    style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF))),
              ],
            ),
          ),
          SizedBox(
            width: 80,
            height: 80,
            child: CircularProgressIndicator(
              value: cgpa / 10,
              backgroundColor: const Color(0xFFEEEEEE),
              valueColor: AlwaysStoppedAnimation(color),
              strokeWidth: 8,
            ),
          ),
        ],
      ),
    );
  }
}

class _SemesterCard extends StatefulWidget {
  final SemesterModel semester;
  const _SemesterCard({required this.semester});

  @override
  State<_SemesterCard> createState() => _SemesterCardState();
}

class _SemesterCardState extends State<_SemesterCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final sem = widget.semester;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF0F0F0)),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F7FF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Sem ${sem.semesterNumber}',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, color: Color(0xFF3B82F6), fontSize: 13),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (sem.cgpa != null)
                          Text(
                            'CGPA: ${sem.cgpa!.toStringAsFixed(2)}',
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                          ),
                        if (sem.attendance != null)
                          Text(
                            'Attendance: ${sem.attendance!.toStringAsFixed(1)}%',
                            style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
                          ),
                      ],
                    ),
                  ),
                  Icon(
                    _expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: const Color(0xFF9CA3AF),
                  ),
                ],
              ),
            ),
          ),
          if (_expanded && sem.subjects.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
              child: Column(
                children: [
                  const Divider(height: 1),
                  const SizedBox(height: 12),
                  ...sem.subjects.map(
                    (s) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(s.name,
                                style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
                          ),
                          Text(
                            '${s.marks.toStringAsFixed(0)} / ${s.maxMarks.toStringAsFixed(0)}',
                            style: const TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1A1A2E)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
