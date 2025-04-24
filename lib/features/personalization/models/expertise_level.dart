class ExpertiseLevel {
  final String id;
  final String title;
  final String emoji;
  final String description;
  final double sliderValue;
  
  const ExpertiseLevel({
    required this.id,
    required this.title,
    required this.emoji,
    required this.description,
    required this.sliderValue,
  });
}

final List<ExpertiseLevel> expertiseLevels = [
  const ExpertiseLevel(
    id: 'novice',
    title: 'Novice',
    emoji: '👍',
    description: '"Just starting to dip your toes in? We\'ll keep it super simple and guide you step by step."',
    sliderValue: 0.0,
  ),
  const ExpertiseLevel(
    id: 'learning',
    title: 'Learning',
    emoji: '📘',
    description: '"Eager to grow? You\'ve started the journey, and we\'ll help connect the dots."',
    sliderValue: 0.33,
  ),
  const ExpertiseLevel(
    id: 'student',
    title: 'Student',
    emoji: '🎓',
    description: '"Actively studying or working in science? Let\'s cut through the clutter and get to the essence."',
    sliderValue: 0.66,
  ),
  const ExpertiseLevel(
    id: 'expert',
    title: 'Expert',
    emoji: '❤️',
    description: '"Need the gist without fluff? Expect sharp, concise insights at your level."',
    sliderValue: 1.0,
  ),
];