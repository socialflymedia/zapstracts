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
    id: 'Physics',
    title: 'Physics',
    imageUrl: 'https://images.pexels.com/photos/2467285/pexels-photo-2467285.jpeg',
  ),
  const ScienceGoal(
    id: 'Chemistry',
    title: 'Chemistry',
    imageUrl: 'https://images.pexels.com/photos/796206/pexels-photo-796206.jpeg',
  ),
  const ScienceGoal(
    id: 'Biology',
    title: 'Biology',
    imageUrl: 'https://images.pexels.com/photos/256262/pexels-photo-256262.jpeg',
  ),
];