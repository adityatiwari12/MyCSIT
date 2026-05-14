import 'dart:io';
import 'package:flutter/material.dart';

class ImagePreviewGallery extends StatelessWidget {
  final List<File> files;
  final Function(int) onRemove;
  final VoidCallback onAddMore;

  const ImagePreviewGallery({
    super.key,
    required this.files,
    required this.onRemove,
    required this.onAddMore,
  });

  @override
  Widget build(BuildContext context) {
    if (files.isEmpty) {
      return GestureDetector(
        onTap: onAddMore,
        child: Container(
          height: 120,
          decoration: BoxDecoration(
            border: Border.all(
              color: const Color(0xFFFF6B35),
              width: 2,
              style: BorderStyle.solid,
            ),
            borderRadius: BorderRadius.circular(16),
            color: const Color(0xFFFF6B35).withOpacity(0.05),
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.upload_file, color: Color(0xFFFF6B35), size: 32),
              SizedBox(height: 8),
              Text(
                'Tap to select PDFs or images',
                style: TextStyle(color: Color(0xFFFF6B35)),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: files.length + 1,
            itemBuilder: (context, index) {
              if (index == files.length) {
                return _buildAddMoreButton();
              }
              return _buildFilePreview(files[index], index);
            },
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${files.length} file(s) selected',
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildFilePreview(File file, int index) {
    final isPdf = file.path.toLowerCase().endsWith('.pdf');
    final fileName = file.path.split('/').last;

    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: isPdf
                ? Container(
                    color: Colors.grey.shade100,
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.picture_as_pdf, color: Colors.red, size: 40),
                        SizedBox(height: 4),
                        Text('PDF', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                      ],
                    ),
                  )
                : Image.file(
                    file,
                    fit: BoxFit.cover,
                  ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: () => onRemove(index),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 16),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: Text(
                fileName,
                style: const TextStyle(color: Colors.white, fontSize: 10),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddMoreButton() {
    return GestureDetector(
      onTap: onAddMore,
      child: Container(
        width: 100,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFFF6B35), width: 2),
          color: const Color(0xFFFF6B35).withOpacity(0.05),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_photo_alternate, color: Color(0xFFFF6B35), size: 32),
            SizedBox(height: 8),
            Text(
              'Add More',
              style: TextStyle(color: Color(0xFFFF6B35), fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
