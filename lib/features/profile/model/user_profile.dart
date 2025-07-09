import 'package:equatable/equatable.dart';

class UserProfile extends Equatable {
  final String name;
  final String subject;
  final String occupation;
  final int papersRead;
  final int bookmarks;
  final int following;
  final Map<String, double> researchStats;
  final String language;
  final bool notificationsEnabled;

  const UserProfile({
    required this.name,
    required this.subject,
    required this.occupation,
    required this.papersRead,
    required this.bookmarks,
    required this.following,
    required this.researchStats,
    required this.language,
    required this.notificationsEnabled,
  });

  @override
  List<Object?> get props => [
    name,
    occupation,
    papersRead,
    bookmarks,
    following,
    researchStats,
    language,
    notificationsEnabled,
    subject
  ];

  UserProfile copyWith({
    String? name,
    String? address,
    String? occupation,
    int? papersRead,
    int? bookmarks,
    int? following,
    Map<String, double>? researchStats,
    String? language,
    bool? notificationsEnabled,
  }) {
    return UserProfile(
      name: name ?? this.name,
      subject: address ?? this.subject,
      occupation: occupation ?? this.occupation,
      papersRead: papersRead ?? this.papersRead,
      bookmarks: bookmarks ?? this.bookmarks,
      following: following ?? this.following,
      researchStats: researchStats ?? this.researchStats,
      language: language ?? this.language,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    );
  }
}