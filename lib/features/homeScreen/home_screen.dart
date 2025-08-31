import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zapstract/features/homeScreen/widgets/feedback_screen.dart';
import 'package:zapstract/features/homeScreen/widgets/home_error.dart';

import '../../utils/components/navbar/customnavbar.dart';
import '../article/article_summary_page.dart';
import '../profile/profile_screen.dart';
import '../search/presentation/search_screen.dart';
import 'bloc/home_bloc.dart';
import 'bloc/home_event.dart';
import 'bloc/home_state.dart';
import 'widgets/home_body.dart';
import 'model/research_paper.dart';
import 'widgets/home_app_bar.dart';


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

  void _onSavePaper(ResearchPaper paper) {
    context.read<HomeBloc>().add(SaveResearchPaper(paper.id));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${paper.title} saved to favorites'),
        duration: const Duration(seconds: 2),
        backgroundColor: const Color(0xFF6750A4),
      ),
    );
  }

  void _onSharePaper(ResearchPaper paper) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sharing ${paper.title}'),
        duration: const Duration(seconds: 2),
        backgroundColor: const Color(0xFF6750A4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            HomeAppBar(
              searchController: _searchController,
              onSearchChanged: _onSearchChanged,
            ),
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
                      return HomeBody.buildMainLoadingShimmer(context);
                    }
                    else if (state is FeedbackSubmitting) {
                      return HomeBody.buildFeedbackSubmittingShimmer();
                    }
                    else if (state is FeedbackError) {
                      return HomeErrorWidget(
                        message: state.message,
                        onRetry: () {
                          setState(() {
                            _isPreloadingComplete = false;
                            _isInitialLoad = true;
                          });
                          _preloadedImages.clear();
                          context.read<HomeBloc>().add(LoadResearchPapers());
                        },
                      );
                    }
                    else if (state is HomeLoaded) {
                      if (state.shouldShowFeedback && !state.feedbackGiven) {
                        return const FeedbackScreenWidget();
                      }

                      if (_isInitialLoad && !_isPreloadingComplete) {
                        _preloadCriticalImages(state);
                        return HomeBody.buildCriticalImageLoadingShimmer(context);
                      }

                      return HomeBody(
                        state: state,
                        preloadedImages: _preloadedImages,
                        onSavePaper: _onSavePaper,
                        onSharePaper: _onSharePaper,
                      );
                    }
                    else if (state is HomeError) {
                      return HomeErrorWidget(
                        message: state.message,
                        onRetry: () {
                          setState(() {
                            _isPreloadingComplete = false;
                            _isInitialLoad = true;
                          });
                          _preloadedImages.clear();
                          context.read<HomeBloc>().add(LoadResearchPapers());
                        },
                      );
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

  // Image preloading methods remain here as they're core to the widget
  Future<void> _preloadCriticalImages(HomeLoaded state) async {
    if (_isPreloadingComplete) return;

    final criticalImages = <String>{};

    if (state.featuredPapers.isNotEmpty && state.featuredPapers.first.imageUrl.isNotEmpty) {
      criticalImages.add(state.featuredPapers.first.imageUrl);
    }

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

    _preloadRemainingImages(state);
  }

  Future<void> _preloadRemainingImages(HomeLoaded state) async {
    final allImages = <String>{};

    for (var paper in [...state.papers, ...state.worldPapers, ...state.trendingPapers]) {
      if (paper.imageUrl.isNotEmpty && !_preloadedImages.contains(paper.imageUrl)) {
        allImages.add(paper.imageUrl);
      }
    }

    final imageList = allImages.toList();
    const batchSize = 2;

    for (int i = 0; i < imageList.length; i += batchSize) {
      final batch = imageList.skip(i).take(batchSize);
      await Future.wait(
        batch.map((imageUrl) => _preloadSingleImage(imageUrl)),
        eagerError: false,
      );

      await Future.delayed(const Duration(milliseconds: 500));
    }
  }

  Future<void> _preloadSingleImage(String imageUrl) async {
    if (_preloadedImages.contains(imageUrl)) return;

    try {
      final imageProvider = CachedNetworkImageProvider(imageUrl);
      await precacheImage(imageProvider, context);
      _preloadedImages.add(imageUrl);
    } catch (e) {
      debugPrint('Failed to preload image: $imageUrl, Error: $e');
      _preloadedImages.add(imageUrl);
    }
  }
}
