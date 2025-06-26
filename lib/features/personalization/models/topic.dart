class Topic {
  final String id;
  final String name;
  final String displayName;

  const Topic({
    required this.id,
    required this.name,
    required this.displayName,
  });
}

const List<Topic> availableTopics = [
  Topic(id: 'zoology', name: 'zoology', displayName: 'Zoology'),
  Topic(id: 'neuroscience', name: 'neuroscience', displayName: 'Neuroscience'),
  Topic(id: 'ecology', name: 'ecology', displayName: 'Ecology'),
  Topic(id: 'infection', name: 'infection', displayName: 'Infection'),
  Topic(id: 'botany', name: 'botany', displayName: 'Botany'),
  Topic(id: 'developmental', name: 'developmental', displayName: 'Developmental'),
  Topic(id: 'animal_sciences', name: 'animal_sciences', displayName: 'Animal sciences'),
  Topic(id: 'cancer_biology', name: 'cancer_biology', displayName: 'Cancer Biology'),
  Topic(id: 'cell_biology', name: 'cell_biology', displayName: 'Cell Biology'),
  Topic(id: 'genetics', name: 'genetics', displayName: 'Genetics'),
  Topic(id: 'molecular_biology', name: 'molecular_biology', displayName: 'Molecular biology'),
  Topic(id: 'epidemiology', name: 'epidemiology', displayName: 'Epidemiology'),
];