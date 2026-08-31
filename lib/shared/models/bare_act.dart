class Section {
  final String sectionNumber;
  final String chapter;
  final String title;
  final String content;
  final String explanation;
  final String? punishment;
  final bool? bailable;
  final bool? cognizable;
  final String? triableBy;
  final String? oldEquivalent;
  final List<String> examples;
  final List<String> keyIngredients;
  final List<String> landmarkCases;
  final String examTips;

  Section({
    required this.sectionNumber,
    required this.chapter,
    required this.title,
    required this.content,
    required this.explanation,
    this.punishment,
    this.bailable,
    this.cognizable,
    this.triableBy,
    this.oldEquivalent,
    this.examples = const [],
    this.keyIngredients = const [],
    this.landmarkCases = const [],
    this.examTips = '',
  });

  factory Section.fromJson(Map<String, dynamic> json) {
    return Section(
      sectionNumber: json['sectionNumber'] ?? '',
      chapter: json['chapter'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      explanation: json['explanation'] ?? '',
      punishment: json['punishment'],
      bailable: json['bailable'],
      cognizable: json['cognizable'],
      triableBy: json['triableBy'],
      oldEquivalent: json['oldEquivalent'],
      examples: (json['examples'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      keyIngredients: (json['keyIngredients'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      landmarkCases: (json['landmarkCases'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      examTips: json['examTips'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sectionNumber': sectionNumber,
      'chapter': chapter,
      'title': title,
      'content': content,
      'explanation': explanation,
      'punishment': punishment,
      'bailable': bailable,
      'cognizable': cognizable,
      'triableBy': triableBy,
      'oldEquivalent': oldEquivalent,
      'examples': examples,
      'keyIngredients': keyIngredients,
      'landmarkCases': landmarkCases,
      'examTips': examTips,
    };
  }
}

class BareAct {
  final String id;
  final String title;
  final String shortTitle;
  final int enactmentYear;
  final String category;
  final int totalSections;
  final String description;
  final List<Section> sections;

  BareAct({
    required this.id,
    required this.title,
    required this.shortTitle,
    required this.enactmentYear,
    required this.category,
    required this.totalSections,
    required this.description,
    required this.sections,
  });

  factory BareAct.fromJson(Map<String, dynamic> json) {
    return BareAct(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      shortTitle: json['shortTitle'] ?? '',
      enactmentYear: json['enactmentYear'] ?? 2023,
      category: json['category'] ?? 'General',
      totalSections: json['totalSections'] ?? 0,
      description: json['description'] ?? '',
      sections: (json['sections'] as List<dynamic>?)
              ?.map((e) => Section.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
