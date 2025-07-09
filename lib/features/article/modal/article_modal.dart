import 'package:equatable/equatable.dart';

class Article extends Equatable {
  final String id;
  final String title;
  final String subtitle;
  final String imageUrl;
  final String author;
  final String journal;
  final int readTime;
  final Map<String, ArticleSection> sections;

  const Article({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.author,
    required this.journal,
    required this.readTime,
    required this.sections,
  });

  @override
  List<Object?> get props => [
    id,
    title,
    subtitle,
    imageUrl,
    author,
    journal,
    readTime,
    sections,
  ];
}

class ArticleSection extends Equatable {
  final String title;
  final String content;
  final int readTime;

  const ArticleSection({
    required this.title,
    required this.content,
    required this.readTime,
  });

  @override
  List<Object?> get props => [title, content, readTime];
}