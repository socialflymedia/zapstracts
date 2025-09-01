import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:zapstract/core/constants/colors/colors.dart';
import 'package:zapstract/features/article/bloc/article_event.dart';
import 'package:zapstract/features/homeScreen/bloc/home_bloc.dart';
import 'package:zapstract/features/homeScreen/bloc/home_event.dart';
import 'package:zapstract/features/homeScreen/home_screen.dart';

import '../../utils/components/article/section.dart';
import '../../utils/components/feedback_form/feedback_form_widget.dart';
import '../homeScreen/bloc/home_state.dart';
import 'bloc/article_bloc.dart';
import 'bloc/article_state.dart';

class ArticleSummaryPage extends StatefulWidget {
  final String paper_id;

  const ArticleSummaryPage({required this.paper_id,Key? key}) : super(key: key);

  @override
  State<ArticleSummaryPage> createState() => _ArticleSummaryPageState();
}

class _ArticleSummaryPageState extends State<ArticleSummaryPage> {
  late PageController _pageController;
  int _currentPage = 0;

  // Define the order of sections for story navigation
  final List<String> _sectionOrder = [
    'hero', // Hero page
    'Abstract',
    'Introduction',
    'Methods',
    'Results',
    'Conclusion',
  // Final summary page with all sections
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    context.read<HomeBloc>().add(CheckFeedbackStatus());
    // Dispatch LoadArticle with the paper_id
    context.read<ArticleBloc>().add(IncreamentSummaryCount());
    context.read<ArticleBloc>().add(LoadArticleEvent(widget.paper_id));
  }



  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _sectionOrder.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final homeState = context.read<HomeBloc>().state;
    // if (homeState is HomeLoaded ) {
    //   print('Current page: $_currentPage, Should show feedback: ${homeState.shouldShowFeedback}, Feedback given: ${homeState.feedbackGiven}');
    //   print('Showing feedback screen');
    //   return _buildFeedbackScreen(); // Or pass any required props if needed
    // }
    return Scaffold(
      body: BlocBuilder<ArticleBloc, ArticleState>(
        builder: (context, state) {
          if (state is ArticleLoading) {

            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is ArticleError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading article',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          if (state is ArticleLoaded) {
            final article = state.article;
            return PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemCount: _sectionOrder.length,
              itemBuilder: (context, index) {
                final sectionKey = _sectionOrder[index];

                if (sectionKey == 'hero') {
                  return _buildHeroPage(context, article);
                }else {
                  print(article.sections);
                  final section = article.sections[sectionKey];
                  print(section);
                  if (section != null) {
                    return _buildSectionStoryPage(context, article, section, sectionKey);
                  }
                }
                print('Section not found for key: ${sectionKey.length}');
                print('Section not found for key: $sectionKey');
                return const SizedBox.shrink();
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildProgressIndicator(BuildContext context) {
    return Row(
      children: [
        // Back button on the left
        IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),


        // Progress indicators
        Expanded(
          child: Row(
            children: List.generate(_sectionOrder.length - 1, (index) {
              return Expanded(
                child: Container(
                  height: 2,
                  margin: EdgeInsets.only(right: index < _sectionOrder.length - 2 ? 4 : 0),
                  decoration: BoxDecoration(
                    color: index <= _currentPage ? Colors.white : Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }


  Widget _buildHeroPage(BuildContext context, article) {
    return GestureDetector(
      onTap: _nextPage,
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity! > 0) {
          _previousPage();
        } else if (details.primaryVelocity! < 0) {
          _nextPage();
        }
      },
      child: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            // Background Image
            article.imageUrl!=null?CachedNetworkImage(
              imageUrl: article.imageUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: Colors.grey[300],
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                color: Colors.grey[300],
                child: const Icon(Icons.error),
              ),
            ):Placeholder(),

            // Gradient Overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.3),
                    Colors.black.withOpacity(0.8),
                  ],
                  stops: const [0.0, 0.6, 1.0],
                ),
              ),
            ),

            // Status Bar


            // Progress indicator
            Positioned(
              top: 20,
              left: 20,
              right: 20,
              child: SafeArea(
                child: Row(
                  children: [
                    // Back arrow


                    // Progress bars
                    Expanded(
                      child: _buildProgressIndicator(context),
                    ),

                    // Time indicator

                  ],
                ),
              ),
            ),

            // Title and content at bottom
            Positioned(
              bottom: 50,
              left: 20,
              right: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),

                ],
              ),
            ),

            // Bottom navigation

          ],
        ),
      ),
    );
  }

  Widget _buildSectionStoryPage(BuildContext context, article, section, String sectionKey) {
    return GestureDetector(
      onTap: _nextPage,
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity! > 0) {
          _previousPage();
        } else if (details.primaryVelocity! < 0) {
          _nextPage();
        }
      },
      child: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            // Background Image with overlay
            article.imageUrl!=null?CachedNetworkImage(
              imageUrl: article.imageUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: Colors.grey[300],
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                color: Colors.grey[300],
                child: const Icon(Icons.error),
              ),
            ):Placeholder(),

            // White overlay for readability
            Container(
              color: Colors.white.withOpacity(0.95),
            ),

            // Status Bar

            // Progress indicator
            Positioned(
              top: 20,
              left: 20,
              right: 20,
              child: SafeArea(
                child: Row(
                  children: [
                    // Back arrow

                    const SizedBox(width: 10),
                    // Progress bars
                    Expanded(
                      child: Row(
                        children: List.generate(_sectionOrder.length , (index) {
                          return Expanded(
                            child: Container(
                              height: 2,
                              margin: EdgeInsets.only(right: index < _sectionOrder.length - 1 ? 4 : 0),
                              decoration: BoxDecoration(
                                color: index <= _currentPage ? AppColors.primary: Colors.grey[300],
                                borderRadius: BorderRadius.circular(1),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Section title
                    Text(
                      section.title,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Content
            Positioned(
              top: 140,
              left: 20,
              right: 20,
              bottom: 100,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Article image card
                    Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: article.imageUrl!=null?CachedNetworkImage(
                          imageUrl: article.imageUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: Colors.grey[300],
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey[300],
                            child: const Icon(Icons.error),
                          ),
                        ):Placeholder(),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Journal badge and read time
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            article.journal,
                            style: TextStyle(
                              color: AppColors.primary.withOpacity(0.8),
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${section.readTime} min read',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Article title
                    Text(
                      article.title,
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[900],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Section title
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        section.title,
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary.withOpacity(0.8),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Section content
                    Text(
                      section.content,
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(
                        height: 1.6,
                        color: Colors.grey[800],
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),

            // Bottom navigation

          ],
        ),
      ),
    );
  }


  Widget _buildFeedbackScreen() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  _buildFeedbackHeader(),
                  const SizedBox(height: 24),
                  const FeedbackFormWidget(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF6750A4).withOpacity(0.1),
            const Color(0xFF6750A4).withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF6750A4).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.celebration,
              color: Color(0xFF6750A4),
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Thank you for exploring!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF6750A4),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'You\'ve viewed 3 research summaries. Your feedback helps us improve the experience for everyone.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

}