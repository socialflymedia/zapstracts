class ScienceGoal {
  final String id;
  final String title;
  final String imageUrl;
  
  const ScienceGoal({
    required this.id,
    required this.title,
    required this.imageUrl,
  });
}

final List<ScienceGoal> scienceGoals = [
  const ScienceGoal(
    id: 'know_more',
    title: 'Know More',
    imageUrl: 'https://images.pexels.com/photos/2467285/pexels-photo-2467285.jpeg',
  ),
  const ScienceGoal(
    id: 'do_research',
    title: 'Do Research',
    imageUrl: 'https://images.pexels.com/photos/796206/pexels-photo-796206.jpeg',
  ),
  const ScienceGoal(
    id: 'stay_updated',
    title: 'Stay Updated',
    imageUrl: 'https://images.pexels.com/photos/256262/pexels-photo-256262.jpeg',
  ),
];