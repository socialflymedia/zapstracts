class ResearchPaper {
  final String id;
  final String title;
  final String summary;
  final String imageUrl;
  final String author;
  final String publishedIn;
  final int readTime;
  final List<String> tags;

  const ResearchPaper({
    required this.id,
    required this.title,
    required this.summary,
    required this.imageUrl,
    required this.author,
    required this.publishedIn,
    required this.readTime,
    required this.tags,
  });
}

final List<ResearchPaper> dummyPapers = [
  ResearchPaper(
    id: '1',
    title: 'Quantum Entanglement Breakthrough',
    summary: 'Researchers have developed a groundbreaking method for maintaining quantum entanglement over longer distances, potentially revolutionizing quantum computing.',
    imageUrl: 'https://images.pexels.com/photos/2156/sky-earth-space-working.jpg',
    author: 'Dr. Sarah Johnson',
    publishedIn: 'Nature',
    readTime: 5,
    tags: ['quantum', 'physics', 'technology'],
  ),
  ResearchPaper(
    id: '2',
    title: 'Dark Matter Distribution in Galaxy Clusters',
    summary: 'New observations reveal unexpected patterns in dark matter distribution across multiple galaxy clusters.',
    imageUrl: 'https://images.pexels.com/photos/816608/pexels-photo-816608.jpeg',
    author: 'Dr. Michael Chen',
    publishedIn: 'Astrophysical Journal',
    readTime: 8,
    tags: ['astrophysics', 'dark matter', 'galaxy'],
  ),
  ResearchPaper(
    id: '3',
    title: 'CRISPR Gene Editing Breakthrough',
    summary: 'Scientists develop more precise gene editing technique with fewer off-target effects.',
    imageUrl: 'https://images.pexels.com/photos/2280571/pexels-photo-2280571.jpeg',
    author: 'Dr. Emily Rodriguez',
    publishedIn: 'Cell',
    readTime: 6,
    tags: ['genetics', 'CRISPR', 'biotechnology'],
  ),
];