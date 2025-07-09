import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../utils/components/navbar/customnavbar.dart';
import '../article/article_summary_page.dart';
import '../profile/profile_screen.dart';
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

  @override
  void initState() {
    super.initState();
    context.read<HomeBloc>().add(LoadResearchPapers());
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
                  context.read<HomeBloc>().add(RefreshResearchPapers());
                },
                child: BlocBuilder<HomeBloc, HomeState>(
                  builder: (context, state) {
                    if (state is HomeLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    else if (state is HomeLoaded) {
                      return SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (state.featuredPapers.isNotEmpty)
                              _buildFeaturedArticle(context, state.featuredPapers.first),
                            _buildFeedSelector(),
                            const SizedBox(height: 24),
                            _buildFeedContent(state),
                            // const SizedBox(height: 24),
                            // _buildTrendingArticles(state.trendingPapers),
                          ],
                        ),
                      );
                    } else if (state is HomeError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(state.message),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                context.read<HomeBloc>().add(LoadResearchPapers());
                              },
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
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

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        children: [
          // const CircleAvatar(
          //   radius: 20,
          //   backgroundColor: Color(0xFF6750A4),
          //   child: Icon(Icons.person, color: Colors.white),
          // ),
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
                  const ChangeFeedType(FeedType.myFeed),
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
        return _buildPopularArticles(context, state.papers);
      case FeedType.world:
        return _buildPopularArticles(context, state.worldPapers);
      case FeedType.trending:
        return _buildPopularArticles(context, state.trendingPapers);
    }
  }

  Widget _buildFeaturedArticle(BuildContext context, ResearchPaper paper) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>  ArticleSummaryPage( paper_id: paper.id,),
        ),
      ),
      child: Container(
        height: 240,
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          image: DecorationImage(
            image: NetworkImage(paper.imageUrl),
            fit: BoxFit.cover,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Container(
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
                padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
              //const SizedBox(height: 8),
              // Text(
              //   paper.summary,
              //   style: TextStyle(
              //     color: Colors.grey[300],
              //     fontSize: 12,
              //   ),
              //   maxLines: 2,
              //   overflow: TextOverflow.ellipsis,
              // ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPopularArticles(BuildContext context, List<ResearchPaper> papers) {
  // print(papers.toString());
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
         //  print(paper);
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ArticleSummaryPage( paper_id: paper.id),
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
                      child: Image.network(
                        paper.imageUrl,
                        height: 120,
                        width: double.infinity,
                        fit: BoxFit.cover,
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
                                  color:
                                  const Color(0xFF6750A4).withOpacity(0.1),
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
  //  print(papers[0]);
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
                      builder: (context) => ArticleSummaryPage(paper_id: paper.id,),
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
                        child: Image.network(
                          paper.imageUrl,
                          height: 100,
                          width: double.infinity,
                          fit: BoxFit.cover,
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