import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

import '../../utils/components/feedback_form/feedback_form_widget.dart';
import '../../utils/components/navbar/customnavbar.dart';
import '../article/article_summary_page.dart';
import '../profile/profile_screen.dart';
import '../search/presentation/search_screen.dart';
import 'bloc/home_bloc.dart';
import 'bloc/home_event.dart';
import 'bloc/home_state.dart';
import 'model/research_paper.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 1;
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _preloadedImages = <String>{};
  bool _isPreloadingComplete = false;
  bool _isInitialLoad = true;

  @override
  void initState() {
    super.initState();
    final bloc = context.read<HomeBloc>();
    bloc.add(LoadResearchPapers());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Preload only critical images for faster initial load
  Future<void> _preloadCriticalImages(HomeLoaded state) async {
    if (_isPreloadingComplete) return;

    final criticalImages = <String>{};

    // Add featured paper image
    if (state.featuredPapers.isNotEmpty && state.featuredPapers.first.imageUrl.isNotEmpty) {
      criticalImages.add(state.featuredPapers.first.imageUrl);
    }

    // Add first 3 papers from current feed
    List<ResearchPaper> currentFeedPapers;
    switch (state.selectedFeed) {
      case FeedType.myFeed:
        currentFeedPapers = state.papers;
        break;
      case FeedType.world:
        currentFeedPapers = state.worldPapers;
        break;
      case FeedType.trending:
        currentFeedPapers = state.trendingPapers;
        break;
    }

    for (var paper in currentFeedPapers.take(3)) {
      if (paper.imageUrl.isNotEmpty) {
        criticalImages.add(paper.imageUrl);
      }
    }

    // Preload critical images
    await Future.wait(
      criticalImages.map((imageUrl) => _preloadSingleImage(imageUrl)),
      eagerError: false,
    );

    if (mounted) {
      setState(() {
        _isPreloadingComplete = true;
        _isInitialLoad = false;
      });
    }

    // Preload remaining images in background after showing content
    _preloadRemainingImages(state);
  }

  /// Preload remaining images in background
  Future<void> _preloadRemainingImages(HomeLoaded state) async {
    final allImages = <String>{};

    for (var paper in [...state.papers, ...state.worldPapers, ...state.trendingPapers]) {
      if (paper.imageUrl.isNotEmpty && !_preloadedImages.contains(paper.imageUrl)) {
        allImages.add(paper.imageUrl);
      }
    }

    // Preload in small batches with delays
    final imageList = allImages.toList();
    const batchSize = 2;

    for (int i = 0; i < imageList.length; i += batchSize) {
      final batch = imageList.skip(i).take(batchSize);
      await Future.wait(
        batch.map((imageUrl) => _preloadSingleImage(imageUrl)),
        eagerError: false,
      );

      await Future.delayed(const Duration(milliseconds: 500)); // Longer delay for background loading
    }
  }

  /// Preload a single image with error handling
  Future<void> _preloadSingleImage(String imageUrl) async {
    if (_preloadedImages.contains(imageUrl)) return;

    try {
      final imageProvider = CachedNetworkImageProvider(imageUrl);
      await precacheImage(imageProvider, context);
      _preloadedImages.add(imageUrl);
    } catch (e) {
      debugPrint('Failed to preload image: $imageUrl, Error: $e');
      // Still mark as "preloaded" to avoid infinite retry
      _preloadedImages.add(imageUrl);
    }
  }

  void _onNavItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (index == 0) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SearchScreen()),
      );
    }
    if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ProfileScreen()),
      );
    }
  }

  void _onSearchChanged(String query) {
    context.read<HomeBloc>().add(SearchResearchPapers(query));
  }

  /// Updated optimized image widget - no loading states since critical images are preloaded
  Widget _buildOptimizedImage({
    required String imageUrl,
    required double height,
    double? width,
    BoxFit fit = BoxFit.cover,
    BorderRadius? borderRadius,
  }) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      height: height,
      width: width ?? double.infinity,
      fit: fit,
      // Show placeholder only for non-critical images that might not be preloaded
      placeholder: !_preloadedImages.contains(imageUrl) ? (context, url) => Container(
        height: height,
        width: width ?? double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: borderRadius,
        ),
        child: const Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6750A4)),
          ),
        ),
      ) : null,
      errorWidget: (context, url, error) => Container(
        height: height,
        width: width ?? double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: borderRadius,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image_not_supported, color: Colors.grey[400], size: 24),
            const SizedBox(height: 4),
            Text(
              'Image unavailable',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
      ),
      fadeInDuration: const Duration(milliseconds: 100), // Faster since critical images are preloaded
      fadeOutDuration: const Duration(milliseconds: 100),
      memCacheHeight: (height * MediaQuery.of(context).devicePixelRatio).round(),
      memCacheWidth: width != null
          ? (width! * MediaQuery.of(context).devicePixelRatio).round()
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  setState(() {
                    _isPreloadingComplete = false;
                    _isInitialLoad = true;
                  });
                  _preloadedImages.clear();
                  context.read<HomeBloc>().add(RefreshResearchPapers());
                },
                child: BlocBuilder<HomeBloc, HomeState>(
                  builder: (context, state) {
                    if (state is HomeLoading) {
                      return _buildMainLoadingShimmer();
                    }
                    else if (state is FeedbackSubmitting) {
                      return _buildFeedbackSubmittingShimmer();
                    }
                    else if (state is FeedbackError) {
                      return _buildErrorWidget(state.message);
                    }
                    else if (state is HomeLoaded) {
                      // If it's initial load and critical images aren't preloaded yet, start preloading
                      if (state.shouldShowFeedback && !state.feedbackGiven) {
                        return _buildFeedbackScreen();
                      }

                      if (_isInitialLoad && !_isPreloadingComplete) {
                        _preloadCriticalImages(state);
                        return _buildCriticalImageLoadingShimmer(); // Show loading while preloading critical images
                      }

                      // Show content when critical images are ready
                      return SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (state.featuredPapers.isNotEmpty)
                              _buildFeaturedArticle(context, state.featuredPapers.first),
                            _buildFeedSelector(),
                            const SizedBox(height: 24),
                            _buildFeedContent(state),
                          ],
                        ),
                      );
                    }
                    else if (state is HomeError) {
                      return _buildErrorWidget(state.message);
                    }
                    return const SizedBox();
                  },
                ),
              ),
            ),
            CustomNavBar(
              selectedIndex: _selectedIndex,
              onItemSelected: _onNavItemTapped,
            ),
          ],
        ),
      ),
    );
  }

  /// Custom loading shimmer specifically for critical image preloading
  Widget _buildCriticalImageLoadingShimmer() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Featured article shimmer with loading text
          Container(
            height: 240,
            margin: const EdgeInsets.all(16),
            child: Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6750A4)),
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Loading featured content...',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Feed selector shimmer
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(3, (index) => _buildFeedOptionShimmer()),
            ),
          ),

          const SizedBox(height: 24),

          // Loading text with progress indicator
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6750A4)),
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Almost ready...',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF6750A4),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // First few article cards shimmer (representing critical content)
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: 3, // Only show 3 since we're preloading critical images
            itemBuilder: (context, index) => _buildArticleCardShimmer(),
          ),
        ],
      ),
    );
  }

  /// Main loading shimmer for the entire home screen
  Widget _buildMainLoadingShimmer() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Featured article shimmer
          Container(
            height: 240,
            margin: const EdgeInsets.all(16),
            child: Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),

          // Feed selector shimmer
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(3, (index) => _buildFeedOptionShimmer()),
            ),
          ),

          const SizedBox(height: 24),

          // Popular articles shimmer
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                height: 22,
                width: 150,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Article cards shimmer
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: 5,
            itemBuilder: (context, index) => _buildArticleCardShimmer(),
          ),
        ],
      ),
    );
  }

  /// Feed option shimmer
  Widget _buildFeedOptionShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              color: Colors.grey,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: 60,
            height: 14,
            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }

  /// Article card shimmer
  Widget _buildArticleCardShimmer() {
    return Container(
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
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image shimmer
            Container(
              height: 120,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category and read time shimmer
                  Row(
                    children: [
                      Container(
                        width: 80,
                        height: 20,
                        decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 60,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Title shimmer
                  Container(
                    width: double.infinity,
                    height: 18,
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),

                  const SizedBox(height: 4),

                  Container(
                    width: MediaQuery.of(context).size.width * 0.7,
                    height: 18,
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Summary shimmer
                  Container(
                    width: double.infinity,
                    height: 14,
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),

                  const SizedBox(height: 4),

                  Container(
                    width: MediaQuery.of(context).size.width * 0.6,
                    height: 14,
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Feedback submitting shimmer
  Widget _buildFeedbackSubmittingShimmer() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              width: 60,
              height: 60,
              decoration: const BoxDecoration(
                color: Colors.grey,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              width: 150,
              height: 16,
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Error widget helper
  Widget _buildErrorWidget(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _isPreloadingComplete = false;
                _isInitialLoad = true;
              });
              _preloadedImages.clear();
              context.read<HomeBloc>().add(LoadResearchPapers());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6750A4),
              foregroundColor: Colors.white,
            ),
            child: const Text('Retry'),
          ),
        ],
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

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        children: [
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                decoration: InputDecoration(
                  icon: Icon(Icons.search, color: Colors.grey[600]),
                  hintText: 'Search research papers...',
                  hintStyle: TextStyle(color: Colors.grey[600]),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedSelector() {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        if (state is! HomeLoaded) return const SizedBox();

        return Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildFeedOption(
                imagePath: 'assets/icons/folder.png',
                label: 'My Feed',
                isSelected: state.selectedFeed == FeedType.myFeed,
                onTap: () => context.read<HomeBloc>().add(
                  ChangeFeedType(FeedType.myFeed),
                ),
              ),
              _buildFeedOption(
                imagePath: 'assets/icons/earth.png',
                label: 'The World',
                isSelected: state.selectedFeed == FeedType.world,
                onTap: () => context.read<HomeBloc>().add(
                  const ChangeFeedType(FeedType.world),
                ),
              ),
              _buildFeedOption(
                imagePath: 'assets/icons/trending.png',
                label: 'Trending',
                isSelected: state.selectedFeed == FeedType.trending,
                onTap: () => context.read<HomeBloc>().add(
                  const ChangeFeedType(FeedType.trending),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFeedOption({
    required String imagePath,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF6750A4).withOpacity(0.1) : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Image.asset(
              imagePath,
              width: 40,
              height: 40,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: isSelected ? const Color(0xFF6750A4) : Colors.grey,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedContent(HomeLoaded state) {
    switch (state.selectedFeed) {
      case FeedType.myFeed:
        return _buildPopularArticles(context, state.papers, state.shouldShowFeedback);
      case FeedType.world:
        return _buildPopularArticles(context, state.worldPapers, state.shouldShowFeedback);
      case FeedType.trending:
        return _buildPopularArticles(context, state.trendingPapers, state.shouldShowFeedback);
    }
  }

  Widget _buildFeaturedArticle(BuildContext context, ResearchPaper paper) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ArticleSummaryPage(paper_id: paper.id),
        ),
      ),
      child: Container(
        height: 240,
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              _buildOptimizedImage(
                imageUrl: paper.imageUrl,
                height: 240,
                borderRadius: BorderRadius.circular(20),
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.8),
                      Colors.transparent,
                    ],
                  ),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6750A4),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Featured Research',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      paper.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPopularArticles(BuildContext context, List<ResearchPaper> papers, bool shouldShowFeedback) {
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
                      child: _buildOptimizedImage(
                        imageUrl: paper.imageUrl,
                        height: 120,
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
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildTrendingArticles(List<ResearchPaper> papers) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Trending in Science',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 205,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: papers.length,
            itemBuilder: (context, index) {
              final paper = papers[index];
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
                  width: 160,
                  margin: const EdgeInsets.only(right: 16),
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
                        child: _buildOptimizedImage(
                          imageUrl: paper.imageUrl,
                          height: 100,
                          width: 160,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(16),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              paper.publishedIn,
                              style: const TextStyle(
                                color: Color(0xFF6750A4),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              paper.title,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
