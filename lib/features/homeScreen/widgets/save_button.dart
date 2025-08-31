import 'package:flutter/material.dart';

import '../bloc/home_state.dart';
import '../model/research_paper.dart';

class SaveButtonWidget extends StatelessWidget {
  final ResearchPaper paper;
  final Function(ResearchPaper) onSavePaper;

  const SaveButtonWidget({
    super.key,
    required this.paper,
    required this.onSavePaper,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onSavePaper(paper),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: paper.isSaved
              ? const Color(0xFF6750A4).withOpacity(0.2)
              : const Color(0xFF6750A4).withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              paper.isSaved ? Icons.bookmark : Icons.bookmark_border,
              size: 16,
              color: const Color(0xFF6750A4),
            ),
            const SizedBox(width: 4),
            Text(
              paper.isSaved ? 'Saved' : 'Save',
              style: const TextStyle(
                color: Color(0xFF6750A4),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

