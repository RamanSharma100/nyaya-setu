class LawComparison {
  final String id;
  final String subject;
  final String oldAct;
  final String oldSection;
  final String oldTitle;
  final String oldText;
  final String newAct;
  final String newSection;
  final String newTitle;
  final String newText;
  final List<String> keyChanges;
  final String summary;

  LawComparison({
    required this.id,
    required this.subject,
    required this.oldAct,
    required this.oldSection,
    required this.oldTitle,
    required this.oldText,
    required this.newAct,
    required this.newSection,
    required this.newTitle,
    required this.newText,
    required this.keyChanges,
    required this.summary,
  });

  factory LawComparison.fromJson(Map<String, dynamic> json) {
    return LawComparison(
      id: json['id'] ?? '',
      subject: json['subject'] ?? '',
      oldAct: json['oldAct'] ?? '',
      oldSection: json['oldSection'] ?? '',
      oldTitle: json['oldTitle'] ?? '',
      oldText: json['oldText'] ?? '',
      newAct: json['newAct'] ?? '',
      newSection: json['newSection'] ?? '',
      newTitle: json['newTitle'] ?? '',
      newText: json['newText'] ?? '',
      keyChanges: (json['keyChanges'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      summary: json['summary'] ?? '',
    );
  }
}
