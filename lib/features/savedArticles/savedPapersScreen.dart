import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../Data/repositories/home/home_repositorty.dart';
import '../article/article_summary_page.dart';
import '../homeScreen/model/research_paper.dart';


class SavedPapersScreen extends StatefulWidget {
  const SavedPapersScreen({super.key});

  @override
  State<SavedPapersScreen> createState() => _SavedPapersScreenState();
}

class _SavedPapersScreenState extends State<SavedPapersScreen> {
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _preloadedImages = <String>{};
  final HomeRepository _repository = HomeRepository(); // Adjust based on your repository

  bool _isPreloadingComplete = false;
  bool _isInitialLoad = true;
  bool _isLoading = true;
  List<ResearchPaper> _savedPapers = [];
  List<ResearchPaper> _filteredPapers = [];
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadSavedPapers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedPapers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final savedPapers = await _repository.fetchSavedPapers();
      setState(() {
        _savedPapers = savedPapers;
        _filteredPapers = savedPapers;
        _isLoading = false;
      });

      // Start preloading critical images
      if (_savedPapers.isNotEmpty) {
        _preloadCriticalImages();
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load saved papers: $e';
      });
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredPapers = _savedPapers;
      } else {
        _filteredPapers = _savedPapers.where((paper) =>
        paper.title.toLowerCase().contains(query.toLowerCase()) ||
            paper.summary.toLowerCase().contains(query.toLowerCase())
        ).toList();
      }
    });
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

  void _onRemovePaper(ResearchPaper paper) {
    // TODO: Implement remove from saved papers
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${paper.title} removed from saved papers'),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.red,
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
            _buildAppBar(),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  setState(() {
                    _isPreloadingComplete = false;
                    _isInitialLoad = true;
                  });
                  _preloadedImages.clear();
                  await _loadSavedPapers();
                },
                child: _buildBody(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: EdgeInsets.all(16.w),
      color: Colors.white,
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              Icons.arrow_back,
              size: 24.sp,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Container(
              height: 40.h,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                decoration: InputDecoration(
                  icon: Icon(Icons.search, color: Colors.grey[600], size: 20.sp),
                  hintText: 'Search saved papers...',
                  hintStyle: TextStyle(color: Colors.grey[600], fontSize: 14.sp),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return _buildMainLoadingShimmer();
    }

    if (_errorMessage.isNotEmpty) {
      return _buildErrorWidget();
    }

    if (_savedPapers.isEmpty) {
      return _buildEmptyState();
    }

    if (_isInitialLoad && !_isPreloadingComplete) {
      return _buildCriticalImageLoadingShimmer();
    }

    return _buildSavedPapersList();
  }

  Widget _buildSavedPapersList() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            child: Row(
              children: [
                Text(
                  'Saved Research Papers',
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6750A4).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    '${_filteredPapers.length} papers',
                    style: TextStyle(
                      color: const Color(0xFF6750A4),
                      fontWeight: FontWeight.w600,
                      fontSize: 12.sp,
                    ),
                  ),
                ),
              ],
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            itemCount: _filteredPapers.length,
            itemBuilder: (context, index) {
              final paper = _filteredPapers[index];
              return _buildPaperCard(paper);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPaperCard(ResearchPaper paper) {
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
        margin: EdgeInsets.only(bottom: 16.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8.r,
              offset: Offset(0, 2.h),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(16.r),
              ),
              child: _buildOptimizedImage(
                imageUrl: paper.imageUrl,
                height: 120.h,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6750A4).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text(
                          paper.publishedIn,
                          style: TextStyle(
                            color: const Color(0xFF6750A4),
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        '${paper.readTime} min read',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    paper.title,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    paper.summary,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey[600],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Remove button (since it's saved)
                      GestureDetector(
                        onTap: () => _onRemovePaper(paper),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 8.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.bookmark_remove,
                                size: 16.sp,
                                color: Colors.red,
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                'Remove',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Share button
                      GestureDetector(
                        onTap: () => _onSharePaper(paper),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 8.h,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: const Color(0xFF6750A4).withOpacity(0.3),
                            ),
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.share_outlined,
                                size: 16.sp,
                                color: const Color(0xFF6750A4),
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                'Share',
                                style: TextStyle(
                                  color: const Color(0xFF6750A4),
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
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

  Widget _buildOptimizedImage({
    required String imageUrl,
    required double height,
    double? width,
    BoxFit fit = BoxFit.cover,
  }) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      height: height,
      width: width ?? double.infinity,
      fit: fit,
      placeholder: !_preloadedImages.contains(imageUrl) ? (context, url) => Container(
        height: height,
        width: width ?? double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(16.r),
          ),
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
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(16.r),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image_not_supported, color: Colors.grey[400], size: 24.sp),
            SizedBox(height: 4.h),
            Text(
              'Image unavailable',
              style: TextStyle(color: Colors.grey[600], fontSize: 12.sp),
            ),
          ],
        ),
      ),
      fadeInDuration: const Duration(milliseconds: 100),
      fadeOutDuration: const Duration(milliseconds: 100),
      memCacheHeight: (height * MediaQuery.of(context).devicePixelRatio).round(),
      memCacheWidth: width != null
          ? (width! * MediaQuery.of(context).devicePixelRatio).round()
          : null,
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bookmark_border,
            size: 80.sp,
            color: Colors.grey[400],
          ),
          SizedBox(height: 24.h),
          Text(
            'No saved papers yet',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            'Start saving research papers\nto see them here',
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 32.h),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6750A4),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25.r),
              ),
            ),
            child: Text(
              'Explore Research Papers',
              style: TextStyle(fontSize: 14.sp),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64.sp,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16.h),
          Text(
            _errorMessage,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 16.h),
          ElevatedButton(
            onPressed: _loadSavedPapers,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6750A4),
              foregroundColor: Colors.white,
            ),
            child: Text(
              'Retry',
              style: TextStyle(fontSize: 14.sp),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainLoadingShimmer() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 16.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              children: [
                Container(
                  height: 22.h,
                  width: 200.w,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
                const Spacer(),
                Container(
                  height: 20.h,
                  width: 80.w,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            itemCount: 5,
            itemBuilder: (context, index) => _buildArticleCardShimmer(),
          ),
        ],
      ),
    );
  }

  Widget _buildCriticalImageLoadingShimmer() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 24.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              children: [
                SizedBox(
                  width: 16.w,
                  height: 16.w,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6750A4)),
                  ),
                ),
                SizedBox(width: 12.w),
                Text(
                  'Loading your saved papers...',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF6750A4),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            itemCount: 3,
            itemBuilder: (context, index) => _buildArticleCardShimmer(),
          ),
        ],
      ),
    );
  }

  Widget _buildArticleCardShimmer() {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 120.h,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(16.r),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 80.w,
                      height: 20.h,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Container(
                      width: 60.w,
                      height: 12.h,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Container(
                  width: double.infinity,
                  height: 18.h,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
                SizedBox(height: 4.h),
                Container(
                  width: 0.7.sw,
                  height: 18.h,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
                SizedBox(height: 8.h),
                Container(
                  width: double.infinity,
                  height: 14.h,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
                SizedBox(height: 4.h),
                Container(
                  width: 0.6.sw,
                  height: 14.h,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
                SizedBox(height: 12.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 80.w,
                      height: 32.h,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                    ),
                    Container(
                      width: 80.w,
                      height: 32.h,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Image preloading methods
  Future<void> _preloadCriticalImages() async {
    if (_isPreloadingComplete) return;

    final criticalImages = <String>{};

    for (var paper in _savedPapers.take(3)) {
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

    _preloadRemainingImages();
  }

  Future<void> _preloadRemainingImages() async {
    final allImages = <String>{};

    for (var paper in _savedPapers) {
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
