import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/activity_model.dart';
import '../data/repositories/activity_repository.dart';

class FunctionalActivityDetailScreen extends ConsumerStatefulWidget {
  final ActivityModel? activity;
  
  const FunctionalActivityDetailScreen({super.key, required this.activity});

  @override
  ConsumerState<FunctionalActivityDetailScreen> createState() => _ActivityDetailScreenState();
}

class _ActivityDetailScreenState extends ConsumerState<FunctionalActivityDetailScreen> {
  bool _isEditing = false;
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime? _editedDate;

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.activity?.title ?? '';
    _descriptionController.text = widget.activity?.description ?? '';
    _editedDate = widget.activity?.date;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Activity' : 'Activity Details'),
        backgroundColor: const Color(0xFFFF6B35),
        foregroundColor: Colors.white,
        actions: [
          if (widget.activity?.status == ActivityStatus.rejected && !_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
            ),
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveActivity,
            ),
        ],
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
            if (widget.activity?.rejectionReason != null) ...[
              const SizedBox(height: 16),
              _buildRejectionReason(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    if (widget.activity == null) {
      return const SizedBox.shrink();
    }
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _getStatusColor(widget.activity!.status).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getStatusColor(widget.activity!.status),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            _getStatusIcon(widget.activity!.status),
            color: _getStatusColor(widget.activity!.status),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Status: ${widget.activity!.status.name.toUpperCase()}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _getStatusColor(widget.activity!.status),
                ),
              ),
              if (widget.activity!.approvedBy != null)
                Text(
                  'Approved by: ${widget.activity!.approvedBy}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
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
            _buildInfoRow('Type', widget.activity?.type.name.toUpperCase() ?? ''),
            const SizedBox(height: 12),
            if (_isEditing) ...[
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: _selectDate,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today),
                      const SizedBox(width: 12),
                      Text(
                        _editedDate != null
                            ? '${_editedDate!.day}/${_editedDate!.month}/${_editedDate!.year}'
                            : 'Select Date',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
              ),
            ] else ...[
              _buildInfoRow('Title', widget.activity?.title ?? ''),
              const SizedBox(height: 12),
              _buildInfoRow('Date', widget.activity != null ? '${widget.activity!.date.day}/${widget.activity!.date.month}/${widget.activity!.date.year}' : ''),
              const SizedBox(height: 12),
              _buildInfoRow('Description', widget.activity?.description ?? ''),
            ],
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
            if (widget.activity?.proofUrl != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      _getFileIcon(widget.activity!.proofUrl!),
                      color: const Color(0xFFFF6B35),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.activity!.proofUrl!.split('/').last,
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

  Widget _buildRejectionReason() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.error, color: Colors.red),
              SizedBox(width: 8),
              Text(
                'Rejection Reason',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            widget.activity?.rejectionReason ?? '',
            style: const TextStyle(color: Colors.red),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(ActivityStatus status) {
    switch (status) {
      case ActivityStatus.pending:
        return Colors.amber;
      case ActivityStatus.approved:
        return Colors.green;
      case ActivityStatus.rejected:
        return Colors.red;
    }
  }

  IconData _getStatusIcon(ActivityStatus status) {
    switch (status) {
      case ActivityStatus.pending:
        return Icons.hourglass_empty;
      case ActivityStatus.approved:
        return Icons.check_circle;
      case ActivityStatus.rejected:
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

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _editedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _editedDate = picked;
      });
    }
  }

  Future<void> _saveActivity() async {
    if (_titleController.text.trim().isEmpty || _editedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    try {
      final updatedActivity = widget.activity!.copyWith(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        date: _editedDate!,
        status: ActivityStatus.pending, // Reset to pending when resubmitted
        rejectionReason: null,
        updatedAt: DateTime.now(),
      );

      await ActivityRepository.updateActivity(updatedActivity);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Activity updated successfully!')),
        );
        setState(() {
          _isEditing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }
}
