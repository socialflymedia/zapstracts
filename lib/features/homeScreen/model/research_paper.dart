class ResearchPaper {
  final String id;
  final String title;
  final String summary;
  final String imageUrl;
  final String author;
  final String publishedIn;
  final int readTime;
  final List<String> tags;

  ResearchPaper({
    required this.id,
    required this.title,
    required this.summary,
    required this.imageUrl,
    required this.author,
    required this.publishedIn,
    required this.readTime,
    required this.tags,
  });

  factory ResearchPaper.fromMap(Map<String, dynamic> map) {
    final List<dynamic>? summaryImages = map['summary_images'];
    final String imageUrl = (summaryImages != null &&
        summaryImages.isNotEmpty &&
        summaryImages[0] is Map &&
        summaryImages[0]['card_image_url'] != null)
        ? summaryImages[0]['card_image_url']
        : '';

    return ResearchPaper(
      id: map['paper_id'] ?? '',
      title: map['title'] ?? '',
      summary: 'No summary available',
      imageUrl: imageUrl,
      author: map['author'] ?? '',
      publishedIn: map['publication'] ?? '',
      readTime: 5,
      tags: [],
    );
  }

}
