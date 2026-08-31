class CaseLaw {
  final String id;
  final String title;
  final String citation;
  final int year;
  final String bench;
  final String subject;
  final List<String> keyArticles;
  final String ratioDecidendi;
  final String facts;
  final String holding;
  final String examSignificance;
  final String docUrl;
  final String whatHappened;
  final String currentStatus;

  CaseLaw({
    required this.id,
    required this.title,
    required this.citation,
    required this.year,
    required this.bench,
    required this.subject,
    required this.keyArticles,
    required this.ratioDecidendi,
    required this.facts,
    required this.holding,
    required this.examSignificance,
    this.docUrl = 'https://indiankanoon.org',
    this.whatHappened = '',
    this.currentStatus = '',
  });

  factory CaseLaw.fromJson(Map<String, dynamic> json) {
    return CaseLaw(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      citation: json['citation'] ?? '',
      year: json['year'] ?? 2024,
      bench: json['bench'] ?? '',
      subject: json['subject'] ?? '',
      keyArticles: (json['keyArticles'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      ratioDecidendi: json['ratioDecidendi'] ?? '',
      facts: json['facts'] ?? '',
      holding: json['holding'] ?? '',
      examSignificance: json['examSignificance'] ?? '',
      docUrl: json['docUrl'] ?? 'https://indiankanoon.org',
      whatHappened: json['whatHappened'] ?? '',
      currentStatus: json['currentStatus'] ?? '',
    );
  }
}

class LegalNewsItem {
  final String title;
  final String link;
  final String pubDate;
  final String description;

  LegalNewsItem({
    required this.title,
    required this.link,
    required this.pubDate,
    required this.description,
  });
}
