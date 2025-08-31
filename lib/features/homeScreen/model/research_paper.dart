class ResearchPaper {
  final String id;
  final String title;
  final String summary;
  final String imageUrl;
  final String author;
  final String publishedIn;
  final int readTime;
  final List<String> tags;
  final bool isSaved; // Add this property

  ResearchPaper({
    required this.id,
    required this.title,
    required this.summary,
    required this.imageUrl,
    required this.author,
    required this.publishedIn,
    required this.readTime,
    required this.tags,
    this.isSaved = false, // Default to false
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
      summary: '',
      imageUrl: imageUrl,
      author: map['author'] ?? '',
      publishedIn: map['publication'] ?? '',
      readTime: 5,
      tags: [],
      isSaved: false, // Will be updated when fetched
    );
  }

  // Add copyWith method
  ResearchPaper copyWith({
    String? id,
    String? title,
    String? summary,
    String? imageUrl,
    String? author,
    String? publishedIn,
    int? readTime,
    List<String>? tags,
    bool? isSaved,
  }) {
    return ResearchPaper(
      id: id ?? this.id,
      title: title ?? this.title,
      summary: summary ?? this.summary,
      imageUrl: imageUrl ?? this.imageUrl,
      author: author ?? this.author,
      publishedIn: publishedIn ?? this.publishedIn,
      readTime: readTime ?? this.readTime,
      tags: tags ?? this.tags,
      isSaved: isSaved ?? this.isSaved,
    );
  }
}
