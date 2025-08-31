import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zapstract/features/homeScreen/widgets/save_button.dart';

import '../../../utils/optimized_image.dart';
import '../../article/article_summary_page.dart';
import '../bloc/home_state.dart';
import '../model/research_paper.dart';


class PopularArticlesWidget extends StatelessWidget {
  final List<ResearchPaper> papers;
  final Set<String> preloadedImages;
  final Function(ResearchPaper) onSavePaper;
  final Function(ResearchPaper) onSharePaper;
  final HomeLoaded state;

  const PopularArticlesWidget({
    super.key,
    required this.papers,
    required this.preloadedImages,
    required this.onSavePaper,
    required this.onSharePaper,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Popular Research',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: papers.length,
          itemBuilder: (context, index) {
            final paper = papers[index];
            return _buildArticleCard(context, paper);
          },
        ),
      ],
    );
  }

  Widget _buildArticleCard(BuildContext context, ResearchPaper paper) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ArticleSummaryPage(paper_id: paper.id),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
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
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: OptimizedImage.build(
                context: context, // Pass context
                imageUrl: paper.imageUrl,
                height: 120,
                preloadedImages: preloadedImages,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6750A4).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          paper.publishedIn,
                          style: const TextStyle(
                            color: Color(0xFF6750A4),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${paper.readTime} min read',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    paper.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    paper.summary,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SaveButtonWidget(
                        paper: paper,
                        // state: state,
                        onSavePaper: onSavePaper,
                      ),
                      _buildShareButton(paper),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShareButton(ResearchPaper paper) {
    return GestureDetector(
      onTap: () => onSharePaper(paper),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          border: Border.all(
            color: const Color(0xFF6750A4).withOpacity(0.3),
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.share_outlined,
              size: 16,
              color: const Color(0xFF6750A4),
            ),
            const SizedBox(width: 4),
            const Text(
              'Share',
              style: TextStyle(
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
