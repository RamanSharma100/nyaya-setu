import 'legal_youtube_video.dart';

class LandmarkJudgmentNote {
  final String caseName;
  final String citation;
  final int year;
  final String bench;
  final String ratioDecidendi;
  final String whatWasHeld;
  final String examSignificance;

  const LandmarkJudgmentNote({
    required this.caseName,
    required this.citation,
    required this.year,
    required this.bench,
    required this.ratioDecidendi,
    required this.whatWasHeld,
    required this.examSignificance,
  });

  factory LandmarkJudgmentNote.fromJson(Map<String, dynamic> json) {
    return LandmarkJudgmentNote(
      caseName: json['caseName'] ?? '',
      citation: json['citation'] ?? '',
      year: json['year'] is int ? json['year'] : int.tryParse(json['year']?.toString() ?? '2024') ?? 2024,
      bench: json['bench'] ?? '',
      ratioDecidendi: json['ratioDecidendi'] ?? '',
      whatWasHeld: json['whatWasHeld'] ?? '',
      examSignificance: json['examSignificance'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'caseName': caseName,
      'citation': citation,
      'year': year,
      'bench': bench,
      'ratioDecidendi': ratioDecidendi,
      'whatWasHeld': whatWasHeld,
      'examSignificance': examSignificance,
    };
  }
}

class HandmadeNote {
  final String id;
  final String title;
  final String subject;
  final String actShortTitle;
  final String sectionNumber;
  final bool isMinorAct;
  final String category;
  final String coreRule;
  final String conceptSummary;
  final List<String> bulletPoints;
  final List<LandmarkJudgmentNote> landmarkJudgments;
  final List<String> mnemonicTricks;
  final String mainsAnswerFramework;
  final String prelimsTrapAlert;
  final LegalYouTubeVideo videoLecture;
  final String videoSearchQuery;
  final String source;
  final String userAnnotation;
  final bool isBookmarked;
  final DateTime? createdAt;

  HandmadeNote({
    required this.id,
    required this.title,
    required this.subject,
    required this.actShortTitle,
    required this.sectionNumber,
    required this.isMinorAct,
    required this.category,
    required this.coreRule,
    required this.conceptSummary,
    this.bulletPoints = const [],
    this.landmarkJudgments = const [],
    this.mnemonicTricks = const [],
    this.mainsAnswerFramework = '',
    this.prelimsTrapAlert = '',
    required this.videoLecture,
    this.videoSearchQuery = '',
    this.source = 'Faculty Judicial Notes',
    this.userAnnotation = '',
    this.isBookmarked = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  HandmadeNote copyWith({
    String? id,
    String? title,
    String? subject,
    String? actShortTitle,
    String? sectionNumber,
    bool? isMinorAct,
    String? category,
    String? coreRule,
    String? conceptSummary,
    List<String>? bulletPoints,
    List<LandmarkJudgmentNote>? landmarkJudgments,
    List<String>? mnemonicTricks,
    String? mainsAnswerFramework,
    String? prelimsTrapAlert,
    LegalYouTubeVideo? videoLecture,
    String? videoSearchQuery,
    String? source,
    String? userAnnotation,
    bool? isBookmarked,
    DateTime? createdAt,
  }) {
    return HandmadeNote(
      id: id ?? this.id,
      title: title ?? this.title,
      subject: subject ?? this.subject,
      actShortTitle: actShortTitle ?? this.actShortTitle,
      sectionNumber: sectionNumber ?? this.sectionNumber,
      isMinorAct: isMinorAct ?? this.isMinorAct,
      category: category ?? this.category,
      coreRule: coreRule ?? this.coreRule,
      conceptSummary: conceptSummary ?? this.conceptSummary,
      bulletPoints: bulletPoints ?? this.bulletPoints,
      landmarkJudgments: landmarkJudgments ?? this.landmarkJudgments,
      mnemonicTricks: mnemonicTricks ?? this.mnemonicTricks,
      mainsAnswerFramework: mainsAnswerFramework ?? this.mainsAnswerFramework,
      prelimsTrapAlert: prelimsTrapAlert ?? this.prelimsTrapAlert,
      videoLecture: videoLecture ?? this.videoLecture,
      videoSearchQuery: videoSearchQuery ?? this.videoSearchQuery,
      source: source ?? this.source,
      userAnnotation: userAnnotation ?? this.userAnnotation,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory HandmadeNote.fromJson(Map<String, dynamic> json) {
    return HandmadeNote(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      subject: json['subject'] ?? '',
      actShortTitle: json['actShortTitle'] ?? '',
      sectionNumber: json['sectionNumber'] ?? '',
      isMinorAct: json['isMinorAct'] ?? false,
      category: json['category'] ?? 'General',
      coreRule: json['coreRule'] ?? '',
      conceptSummary: json['conceptSummary'] ?? '',
      bulletPoints: (json['bulletPoints'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      landmarkJudgments: (json['landmarkJudgments'] as List<dynamic>?)
              ?.map((e) => LandmarkJudgmentNote.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      mnemonicTricks: (json['mnemonicTricks'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      mainsAnswerFramework: json['mainsAnswerFramework'] ?? '',
      prelimsTrapAlert: json['prelimsTrapAlert'] ?? '',
      videoLecture: LegalYouTubeVideo(
        videoId: json['videoId'] ?? 'sI6WKcAwCBk',
        title: json['videoTitle'] ?? 'Judicial Lecture',
        channelName: json['channelName'] ?? 'Judiciary Prep',
        duration: json['duration'] ?? '15:00',
        description: json['videoDesc'] ?? '',
      ),
      videoSearchQuery: json['videoSearchQuery'] ?? '',
      source: json['source'] ?? 'Faculty Judicial Notes',
      userAnnotation: json['userAnnotation'] ?? '',
      isBookmarked: json['isBookmarked'] ?? false,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
    );
  }
}
