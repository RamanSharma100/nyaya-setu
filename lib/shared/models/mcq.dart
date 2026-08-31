class MCQ {
  final String id;
  final String subject;
  final String stateExam;
  final int examYear;
  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;
  final String sectionRef;

  MCQ({
    required this.id,
    required this.subject,
    required this.stateExam,
    required this.examYear,
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
    required this.sectionRef,
  });

  factory MCQ.fromJson(Map<String, dynamic> json) {
    return MCQ(
      id: json['id'] ?? '',
      subject: json['subject'] ?? '',
      stateExam: json['stateExam'] ?? '',
      examYear: json['examYear'] ?? 2024,
      question: json['question'] ?? '',
      options: (json['options'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      correctIndex: json['correctIndex'] ?? 0,
      explanation: json['explanation'] ?? '',
      sectionRef: json['sectionRef'] ?? '',
    );
  }
}
