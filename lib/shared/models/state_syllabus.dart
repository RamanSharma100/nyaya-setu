class ExamPattern {
  final int prelimsMarks;
  final String prelimsDuration;
  final String negativeMarking;
  final int mainsPapers;
  final int mainsTotalMarks;

  ExamPattern({
    required this.prelimsMarks,
    required this.prelimsDuration,
    required this.negativeMarking,
    required this.mainsPapers,
    required this.mainsTotalMarks,
  });

  factory ExamPattern.fromJson(Map<String, dynamic> json) {
    return ExamPattern(
      prelimsMarks: json['prelimsMarks'] ?? 0,
      prelimsDuration: json['prelimsDuration'] ?? '',
      negativeMarking: json['negativeMarking'] ?? 'None',
      mainsPapers: json['mainsPapers'] ?? 0,
      mainsTotalMarks: json['mainsTotalMarks'] ?? 0,
    );
  }
}

class MainsPaper {
  final String name;
  final int marks;

  MainsPaper({required this.name, required this.marks});

  factory MainsPaper.fromJson(Map<String, dynamic> json) {
    return MainsPaper(
      name: json['name'] ?? '',
      marks: json['marks'] ?? 0,
    );
  }
}

class StateSyllabus {
  final String id;
  final String stateName;
  final String code;
  final ExamPattern examPattern;
  final List<String> prelimsSubjects;
  final List<MainsPaper> mainsPapers;
  final List<String> localActs;

  StateSyllabus({
    required this.id,
    required this.stateName,
    required this.code,
    required this.examPattern,
    required this.prelimsSubjects,
    required this.mainsPapers,
    required this.localActs,
  });

  factory StateSyllabus.fromJson(Map<String, dynamic> json) {
    return StateSyllabus(
      id: json['id'] ?? '',
      stateName: json['stateName'] ?? '',
      code: json['code'] ?? '',
      examPattern: ExamPattern.fromJson(json['examPattern'] ?? {}),
      prelimsSubjects: (json['prelimsSubjects'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      mainsPapers: (json['mainsPapers'] as List<dynamic>?)
              ?.map((e) => MainsPaper.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      localActs: (json['localActs'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }
}
