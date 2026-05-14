import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/coding_activity_model.dart';
import '../data/repositories/coding_repository.dart';

class CodingActivityDetailScreen extends ConsumerStatefulWidget {
  final CodingActivityModel activity;
  
  const CodingActivityDetailScreen({super.key, required this.activity});

  @override
  ConsumerState<CodingActivityDetailScreen> createState() => _CodingActivityDetailScreenState();
}

class _CodingActivityDetailScreenState extends ConsumerState<CodingActivityDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Coding Activity Details'),
        backgroundColor: const Color(0xFFFF6B35),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusCard(),
            const SizedBox(height: 16),
            _buildActivityInfo(),
            const SizedBox(height: 16),
            _buildProofSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _getStatusColor(widget.activity.status).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getStatusColor(widget.activity.status),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            _getStatusIcon(widget.activity.status),
            color: _getStatusColor(widget.activity.status),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Status: ${widget.activity.status.name.toUpperCase()}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _getStatusColor(widget.activity.status),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActivityInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('Type', widget.activity.type.name.toUpperCase()),
            const SizedBox(height: 12),
            _buildInfoRow('Platform', widget.activity.platform),
            const SizedBox(height: 12),
            _buildInfoRow('Title', widget.activity.title),
            if (widget.activity.value != null) ...[
              const SizedBox(height: 12),
              _buildInfoRow('Value', _getValueDisplay()),
            ],
            if (widget.activity.contestName != null) ...[
              const SizedBox(height: 12),
              _buildInfoRow('Contest Name', widget.activity.contestName!),
            ],
            if (widget.activity.difficulty != null) ...[
              const SizedBox(height: 12),
              _buildInfoRow('Difficulty', widget.activity.difficulty!),
            ],
            const SizedBox(height: 12),
            _buildInfoRow('Created On', '${widget.activity.createdAt.day}/${widget.activity.createdAt.month}/${widget.activity.createdAt.year}'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildProofSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Proof Document',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            if (widget.activity.proofUrl != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      _getFileIcon(widget.activity.proofUrl!),
                      color: const Color(0xFFFF6B35),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.activity.proofUrl!.split('/').last,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.open_in_new),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Open proof feature coming soon!')),
                        );
                      },
                    ),
                  ],
                ),
              )
            else
              const Text('No proof uploaded'),
          ],
        ),
      ),
    );
  }

  String _getValueDisplay() {
    switch (widget.activity.type) {
      case CodingType.milestone:
        return '${widget.activity.value} problems solved';
      case CodingType.contest:
        return 'Rank ${widget.activity.value}';
      case CodingType.highValueProblem:
        return widget.activity.title;
    }
  }

  Color _getStatusColor(CodingStatus status) {
    switch (status) {
      case CodingStatus.pending:
        return Colors.amber;
      case CodingStatus.approved:
        return Colors.green;
      case CodingStatus.rejected:
        return Colors.red;
    }
  }

  IconData _getStatusIcon(CodingStatus status) {
    switch (status) {
      case CodingStatus.pending:
        return Icons.hourglass_empty;
      case CodingStatus.approved:
        return Icons.check_circle;
      case CodingStatus.rejected:
        return Icons.error;
    }
  }

  IconData _getFileIcon(String filePath) {
    if (filePath.toLowerCase().endsWith('.pdf')) {
      return Icons.picture_as_pdf;
    } else if (filePath.toLowerCase().endsWith('.jpg') || 
               filePath.toLowerCase().endsWith('.jpeg') || 
               filePath.toLowerCase().endsWith('.png')) {
      return Icons.image;
    }
    return Icons.insert_drive_file;
  }
}
