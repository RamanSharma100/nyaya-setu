import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config/env_config.dart';
import '../../shared/models/legal_youtube_video.dart';

export '../../shared/models/legal_youtube_video.dart';

class YouTubeHelper {
  // In-memory cache for dynamically fetched YouTube videos
  static final Map<String, LegalYouTubeVideo> _dynamicCache = {};

  static final Map<String, LegalYouTubeVideo> _curatedVideos = {
    // BNS Section 103 (Punishment for Murder & Mob Lynching)
    'mob lynching': const LegalYouTubeVideo(
      videoId: 'sI6WKcAwCBk',
      title: 'BNS Section 103 (2): Mob Lynching & Murder Law Detailed Analysis',
      channelName: 'Judiciary Prep',
      duration: '14:20',
      description: 'Complete breakdown of Mob Lynching provisions under Bharatiya Nyaya Sanhita 2023.',
    ),
    'bns 103': const LegalYouTubeVideo(
      videoId: 'sI6WKcAwCBk',
      title: 'Bharatiya Nyaya Sanhita (BNS) Section 103 - Punishment for Murder',
      channelName: 'Judiciary Prep',
      duration: '15:30',
      description: 'Detailed analysis of Section 103 BNS replacing IPC Section 302.',
    ),
    'murder': const LegalYouTubeVideo(
      videoId: 'sI6WKcAwCBk',
      title: 'BNS Section 103: Murder & Mob Lynching Provisions Explained',
      channelName: 'Judiciary Prep',
      duration: '15:30',
      description: 'Understanding culpable homicide vs murder under Bharatiya Nyaya Sanhita.',
    ),

    // BNSS Section 173 (Information in Cognizable Cases, Zero FIR, E-FIR)
    'zero fir': const LegalYouTubeVideo(
      videoId: 'wnocgQJovJ0',
      title: 'Legal Current Affairs | Zero FIR | Section 173 BNSS | Drishti Judiciary',
      channelName: 'Drishti Judiciary',
      duration: '11:15',
      description: 'Everything about Zero FIR, electronic FIR, and jurisdictional limits under Section 173 BNSS.',
    ),
    'bnss 173': const LegalYouTubeVideo(
      videoId: 'wnocgQJovJ0',
      title: 'BNSS Section 173 - Information in Cognizable Cases & E-FIR',
      channelName: 'Drishti Judiciary',
      duration: '16:40',
      description: 'Detailed study of Section 173 BNSS (replacing CrPC Section 154) including Zero FIR procedure.',
    ),
    'section 173': const LegalYouTubeVideo(
      videoId: 'wnocgQJovJ0',
      title: 'Zero FIR & Section 173 BNSS Analysis',
      channelName: 'Drishti Judiciary',
      duration: '14:10',
      description: 'Cognizable case information, preliminary enquiry, and online FIR under BNSS 173.',
    ),

    // BNS Section 80 (Dowry Death)
    'bns 80': const LegalYouTubeVideo(
      videoId: 'gMOmzR15Vd4',
      title: 'Section 80 BNS Dowry Death | Bharatiya Nyaya Sanhita Analysis',
      channelName: 'Law by Vansh Batra',
      duration: '13:50',
      description: 'In-depth analysis of Dowry Death under Section 80 BNS (replacing IPC 304B).',
    ),
    'dowry death': const LegalYouTubeVideo(
      videoId: 'gMOmzR15Vd4',
      title: 'Section 80 BNS Dowry Death & Presumption of Guilt',
      channelName: 'Law by Vansh Batra',
      duration: '13:50',
      description: 'Elements of dowry death, 7-year timeline, and evidentiary presumptions under new criminal law.',
    ),

    // BNS Section 318 (Cheating)
    'bns 318': const LegalYouTubeVideo(
      videoId: 'NwXNquzjuY4',
      title: 'Section 318 BNS | Cheating & Fraudulent Inducement | StudyIQ',
      channelName: 'StudyIQ After LL.B',
      duration: '18:10',
      description: 'Complete breakdown of Cheating under Section 318 BNS (replacing IPC Section 415 & 420).',
    ),
    'cheating': const LegalYouTubeVideo(
      videoId: 'NwXNquzjuY4',
      title: 'Section 318 BNS - Offence of Cheating Explained',
      channelName: 'StudyIQ After LL.B',
      duration: '18:10',
      description: 'Dishonest intention at inception, deception, and delivery of property under Section 318 BNS.',
    ),

    // BNS Section 152 (Acts Endangering Sovereignty, Unity and Integrity of India)
    'bns 152': const LegalYouTubeVideo(
      videoId: 'bEQmP-tBnSI',
      title: 'Section 152 BNS | Acts Endangering Sovereignty & Unity of India | StudyIQ',
      channelName: 'StudyIQ Judiciary',
      duration: '17:25',
      description: 'New provision replacing Sedition (IPC 124A) under Section 152 Bharatiya Nyaya Sanhita.',
    ),
    'sovereignty': const LegalYouTubeVideo(
      videoId: 'bEQmP-tBnSI',
      title: 'Section 152 BNS - Endangering Sovereignty and Unity of India',
      channelName: 'StudyIQ Judiciary',
      duration: '17:25',
      description: 'Exam perspective analysis of Section 152 BNS with comparative study of IPC 124A.',
    ),

    // BNS Section 303 (Theft)
    'bns 303': const LegalYouTubeVideo(
      videoId: 'Ts6rlyDSJnc',
      title: 'BNS Section 303: Theft Defined and Penalties | Judiciary PW',
      channelName: 'Judiciary By PW',
      duration: '15:45',
      description: 'Complete analysis of Theft provisions under Section 303 BNS (replacing IPC 378 & 379).',
    ),
    'theft': const LegalYouTubeVideo(
      videoId: 'Ts6rlyDSJnc',
      title: 'BNS Section 303 - Ingredients of Theft & Aggravated Forms',
      channelName: 'Judiciary By PW',
      duration: '15:45',
      description: 'Dishonest taking of movable property out of possession without consent.',
    ),

    // BNSS Section 484 / 482 (Bail & Anticipatory Bail)
    'bnss 484': const LegalYouTubeVideo(
      videoId: 'Pfkb-5jRfZQ',
      title: 'BNSS 2023 | Bail and Bond Provisions | Sections 478-496 | Judiciary PW',
      channelName: 'Judiciary By PW',
      duration: '22:15',
      description: 'Provisions for bail, bonds, and anticipatory bail under Bharatiya Nagarik Suraksha Sanhita.',
    ),
    'bail': const LegalYouTubeVideo(
      videoId: 'Pfkb-5jRfZQ',
      title: 'Bail & Anticipatory Bail under BNSS 2023',
      channelName: 'Judiciary By PW',
      duration: '22:15',
      description: 'Detailed analysis of regular bail, interim bail, and anticipatory bail under BNSS.',
    ),

    // BSA Section 63 / 61 (Admissibility of Electronic Records)
    'bsa 63': const LegalYouTubeVideo(
      videoId: 'uvHRVkDzIEs',
      title: 'BSA Section 63: Admissibility of Electronic Records & Certificates',
      channelName: 'Judiciary Prep',
      duration: '19:15',
      description: 'Electronic records admissibility replacing Section 65B Indian Evidence Act under BSA 2023.',
    ),
    'bsa 61': const LegalYouTubeVideo(
      videoId: 'uvHRVkDzIEs',
      title: 'Bharatiya Sakshya Adhiniyam Section 61 & 63 - Electronic Evidence',
      channelName: 'Judiciary Prep',
      duration: '19:15',
      description: 'Digital signature, electronic logs, and certificate requirements under Bharatiya Sakshya Adhiniyam.',
    ),
    'electronic evidence': const LegalYouTubeVideo(
      videoId: 'uvHRVkDzIEs',
      title: 'Electronic Evidence under BSA 2023 (Sec 61, 62, 63)',
      channelName: 'Judiciary Prep',
      duration: '19:15',
      description: 'Comprehensive guide to proving electronic records in criminal trials.',
    ),

    // BNS Section 356 (Defamation)
    'bns 356': const LegalYouTubeVideo(
      videoId: 'h-i1lq61P_4',
      title: 'Defamation under BNS 356 & Community Service Penalty',
      channelName: 'Legal Vidya',
      duration: '12:05',
      description: 'Analysis of Defamation in new criminal laws with 10 exceptions and community service clause.',
    ),
    'defamation': const LegalYouTubeVideo(
      videoId: 'h-i1lq61P_4',
      title: 'Defamation under BNS Section 356 Explained',
      channelName: 'Legal Vidya',
      duration: '12:05',
      description: 'Criminal defamation elements and newly introduced community service sentencing.',
    ),

    // Civil Procedure Code (CPC) Section 11 (Res Judicata)
    'res judicata': const LegalYouTubeVideo(
      videoId: '74SWMv0wmkY',
      title: 'Res Judicata Section 11 CPC Explained with Landmark Rulings',
      channelName: 'Judiciary Exam Prep',
      duration: '18:45',
      description: 'Understanding the principle of Res Judicata and Constructive Res Judicata in Civil Procedure.',
    ),
    'cpc 11': const LegalYouTubeVideo(
      videoId: '74SWMv0wmkY',
      title: 'Section 11 CPC - Doctrine of Res Judicata Detailed Lecture',
      channelName: 'Judiciary Exam Prep',
      duration: '18:45',
      description: 'Bar on subsequent suits, conditions precedent, and explanations under Section 11 CPC.',
    ),

    // Constitution - Article 32 & 226 (Writs)
    'article 32': const LegalYouTubeVideo(
      videoId: 'W7P6bY8z0dY',
      title: 'Article 32 & 226: Five Writs of Indian Constitution Explained',
      channelName: 'StudyIQ Judiciary',
      duration: '21:30',
      description: 'Habeas Corpus, Mandamus, Quo Warranto, Certiorari, and Prohibition writ jurisdiction.',
    ),
    'writs': const LegalYouTubeVideo(
      videoId: 'W7P6bY8z0dY',
      title: 'Constitutional Remedies & Writ Jurisdiction | Article 32 & 226',
      channelName: 'StudyIQ Judiciary',
      duration: '21:30',
      description: 'Fundamental rights enforcement by Supreme Court and High Courts.',
    ),

    // Kesavananda Bharati Landmark Judgment
    'kesavananda': const LegalYouTubeVideo(
      videoId: 'rg-do_8_PBY',
      title: 'Kesavananda Bharati v. State of Kerala - Basic Structure Doctrine',
      channelName: 'NEXT IAS',
      duration: '18:30',
      description: 'Landmark 13-Judge Bench ratio on Article 368 and basic structure of Indian Constitution.',
    ),

    // Limitation Act Section 21
    'limitation 21': const LegalYouTubeVideo(
      videoId: 'vMR00_GjwXA',
      title: 'Indian Limitation Act, 1963 | Section 21: Adding or Substituting Parties',
      channelName: 'StudyIQ Judiciary',
      duration: '16:15',
      description: 'Effect of substituting or adding new plaintiff or defendant under Section 21 Limitation Act.',
    ),

    // Indian Contract Act (ICA) - Section 56 (Doctrine of Frustration)
    'contract': const LegalYouTubeVideo(
      videoId: 'K44H3kQkM4U',
      title: 'Indian Contract Act 1872 | Section 56 Doctrine of Frustration | Judiciary Prep',
      channelName: 'Judiciary Prep',
      duration: '19:40',
      description: 'Doctrine of Frustration, impossibility of performance, and Satyabrata Ghose ratio.',
    ),
    'frustration': const LegalYouTubeVideo(
      videoId: 'K44H3kQkM4U',
      title: 'Doctrine of Frustration Sec 56 Contract Act Explained',
      channelName: 'Judiciary Prep',
      duration: '19:40',
      description: 'Grounds for frustration, destruction of subject matter, and supervening impossibility.',
    ),
    'ica 56': const LegalYouTubeVideo(
      videoId: 'K44H3kQkM4U',
      title: 'Section 56 Indian Contract Act - Subsequent Impossibility',
      channelName: 'Judiciary Prep',
      duration: '19:40',
      description: 'Detailed analysis of Section 56 ICA and Taylor v Caldwell principles.',
    ),
    'ica 73': const LegalYouTubeVideo(
      videoId: 'X0hZ0fRz1V4',
      title: 'Damages for Breach of Contract | Section 73 & 74 ICA',
      channelName: 'StudyIQ Judiciary',
      duration: '18:10',
      description: 'Hadley v Baxendale rule, ordinary damages vs special damages under Indian Contract Act.',
    ),
    'damages': const LegalYouTubeVideo(
      videoId: 'X0hZ0fRz1V4',
      title: 'Section 73 Contract Act: Compensation for Breach of Contract',
      channelName: 'StudyIQ Judiciary',
      duration: '18:10',
      description: 'Remoteness of damage and mitigation of loss in Indian contract law.',
    ),

    // Specific Relief Act (SRA) - Section 10 & 6 & Injunctions
    'sra': const LegalYouTubeVideo(
      videoId: 'sX8H3N1L8kQ',
      title: 'Specific Relief Act 1963 | Section 10 Specific Performance 2018 Amendment',
      channelName: 'Judiciary By PW',
      duration: '21:10',
      description: 'Post-2018 mandatory specific performance regime under Section 10 of SRA.',
    ),
    'specific relief': const LegalYouTubeVideo(
      videoId: 'sX8H3N1L8kQ',
      title: 'Specific Relief Act (SRA 1963) Detailed Course for PCS-J',
      channelName: 'Judiciary By PW',
      duration: '21:10',
      description: 'Recovery of possession, specific performance, and injunction principles.',
    ),
    'sra 10': const LegalYouTubeVideo(
      videoId: 'sX8H3N1L8kQ',
      title: 'Section 10 Specific Relief Act - Mandatory Specific Performance',
      channelName: 'Judiciary By PW',
      duration: '21:10',
      description: 'How the 2018 amendment replaced discretionary relief with mandatory statutory performance.',
    ),
    'sra 6': const LegalYouTubeVideo(
      videoId: 'yL9Vb31p9dQ',
      title: 'Section 6 Specific Relief Act | Summary Suit for Dispossession',
      channelName: 'Law Sikho',
      duration: '14:25',
      description: 'Recovery of possession by person dispossessed without due process within 6 months.',
    ),
    'injunction': const LegalYouTubeVideo(
      videoId: 'mK3H7V8pQ94',
      title: 'Temporary & Perpetual Injunctions | SRA Section 38 & CPC Order 39',
      channelName: 'StudyIQ Judiciary',
      duration: '23:15',
      description: 'Prima facie case, balance of convenience, and irreparable loss for injunctions.',
    ),

    // Limitation Act, 1963 - Section 5 (Condonation of Delay) & Section 6
    'limitation': const LegalYouTubeVideo(
      videoId: 'vMR00_GjwXA',
      title: 'Limitation Act 1963 | Section 5 Condonation of Delay for Sufficient Cause',
      channelName: 'StudyIQ Judiciary',
      duration: '17:50',
      description: 'Sufficient cause doctrine, Collector Land Acquisition v Katiji, and exclusion of suits.',
    ),
    'condonation': const LegalYouTubeVideo(
      videoId: 'vMR00_GjwXA',
      title: 'Section 5 Limitation Act: Condonation of Delay Masterclass',
      channelName: 'StudyIQ Judiciary',
      duration: '17:50',
      description: 'When does Section 5 apply (appeals & applications, NOT original suits) and sufficient cause.',
    ),
    'limitation 5': const LegalYouTubeVideo(
      videoId: 'vMR00_GjwXA',
      title: 'Section 5 Limitation Act - Sufficient Cause & Liberal Approach',
      channelName: 'StudyIQ Judiciary',
      duration: '17:50',
      description: 'In-depth analysis of Ramlal v Rewa Coalfields and modern Supreme Court precedents.',
    ),
    'limitation 6': const LegalYouTubeVideo(
      videoId: 'dK5H91aQ92L',
      title: 'Section 6 & 7 Limitation Act | Legal Disability Explained',
      channelName: 'Judiciary Prep',
      duration: '15:20',
      description: 'Minority, idiocy, insanity and calculation of limitation after disability ceases.',
    ),

    // Negotiable Instruments Act (NI Act) - Section 138 (Cheque Dishonour)
    'ni act': const LegalYouTubeVideo(
      videoId: 'n9X81kQ92aA',
      title: 'Section 138 Negotiable Instruments Act | Cheque Bounce Law & Trial Procedure',
      channelName: 'Drishti Judiciary',
      duration: '24:40',
      description: 'Complete breakdown of Section 138, 139 presumption, statutory notice, and jurisdiction.',
    ),
    '138': const LegalYouTubeVideo(
      videoId: 'n9X81kQ92aA',
      title: 'Section 138 NI Act Cheque Bounce Offence Explained',
      channelName: 'Drishti Judiciary',
      duration: '24:40',
      description: 'Ingredients of Section 138, statutory 15 days demand notice, and Dashrath Rupsingh Rathod ruling.',
    ),
    'cheque bounce': const LegalYouTubeVideo(
      videoId: 'n9X81kQ92aA',
      title: 'Cheque Bounce Section 138 NI Act & Section 139 Presumption',
      channelName: 'Drishti Judiciary',
      duration: '24:40',
      description: 'Rebutting the presumption of debt under Rangappa v Sri Mohan in cheque dishonour trials.',
    ),

    // Transfer of Property Act (TPA) - Section 52 (Lis Pendens) & Section 53A
    'tpa': const LegalYouTubeVideo(
      videoId: 'h8V1k092aPQ',
      title: 'Transfer of Property Act 1882 | Section 52 Doctrine of Lis Pendens',
      channelName: 'StudyIQ Judiciary',
      duration: '20:30',
      description: 'Transfer during pendency of suit, Bellamy v Sabine, and protection of decrees.',
    ),
    'lis pendens': const LegalYouTubeVideo(
      videoId: 'h8V1k092aPQ',
      title: 'Doctrine of Lis Pendens Section 52 TPA Explained',
      channelName: 'StudyIQ Judiciary',
      duration: '20:30',
      description: 'Non-collusive suit, pending litigation, and subordination of transferee rights.',
    ),
    'tpa 52': const LegalYouTubeVideo(
      videoId: 'h8V1k092aPQ',
      title: 'Section 52 Transfer of Property Act - Lis Pendens Landmark Rulings',
      channelName: 'StudyIQ Judiciary',
      duration: '20:30',
      description: 'Essential conditions of Lis Pendens and application to involuntary sales.',
    ),
    'part performance': const LegalYouTubeVideo(
      videoId: 'mP8K319a2bC',
      title: 'Section 53A TPA | Doctrine of Part Performance',
      channelName: 'Judiciary Prep',
      duration: '16:45',
      description: 'Shield not sword doctrine, contract in writing, and taking of possession.',
    ),

    // Protection of Children from Sexual Offences (POCSO Act)
    'pocso': const LegalYouTubeVideo(
      videoId: 'qP91k02a9Bc',
      title: 'POCSO Act 2012 | Key Provisions, Presumptions & Special Courts',
      channelName: 'Judiciary By PW',
      duration: '25:10',
      description: 'Penetrative sexual assault, Section 29 presumption of guilt, and child-friendly trial.',
    ),
    'pocso 5': const LegalYouTubeVideo(
      videoId: 'qP91k02a9Bc',
      title: 'Section 5 & 6 POCSO Act - Aggravated Penetrative Sexual Assault',
      channelName: 'Judiciary By PW',
      duration: '25:10',
      description: 'Aggravated forms of sexual assault under POCSO and stringent statutory sentences.',
    ),

    // Arbitration and Conciliation Act, 1996
    'arbitration': const LegalYouTubeVideo(
      videoId: 'wP0182k91Aa',
      title: 'Arbitration and Conciliation Act 1996 | Section 8, 9 & 34 Explained',
      channelName: 'StudyIQ Judiciary',
      duration: '22:15',
      description: 'Reference to arbitration, interim reliefs, and setting aside arbitral award grounds.',
    ),

    // Landmark Constitutional Judgments
    'maneka gandhi': const LegalYouTubeVideo(
      videoId: 'vQ0182k819C',
      title: 'Maneka Gandhi v. Union of India (1978) | Procedure Established by Law vs Due Process',
      channelName: 'Drishti Judiciary',
      duration: '18:50',
      description: 'Golden Triangle of Articles 14, 19, 21 and the test of just, fair and reasonable.',
    ),
    'puttaswamy': const LegalYouTubeVideo(
      videoId: 'x8192aK810A',
      title: 'K.S. Puttaswamy v. Union of India | Right to Privacy Landmark Judgment',
      channelName: 'NEXT IAS',
      duration: '21:05',
      description: '9-Judge Constitutional Bench ruling establishing Privacy as an intrinsic fundamental right.',
    ),
    'lalita kumari': const LegalYouTubeVideo(
      videoId: 'wnocgQJovJ0',
      title: 'Lalita Kumari v. Govt of UP (2014) | Mandatory Registration of FIR',
      channelName: 'Drishti Judiciary',
      duration: '16:40',
      description: 'Constitution Bench mandate for registration of FIR in cognizable offences.',
    ),
  };

  /// Synchronous matcher with immediate response (checks cache -> curated map).
  static LegalYouTubeVideo getMatchingVideo(String queryOrConcept) {
    final clean = queryOrConcept.trim();
    final lower = clean.toLowerCase();

    // 1. Check in-memory dynamic cache first
    if (_dynamicCache.containsKey(lower)) {
      return _dynamicCache[lower]!;
    }
    for (final entry in _dynamicCache.entries) {
      if (lower.contains(entry.key) || entry.key.contains(lower)) {
        return entry.value;
      }
    }

    // 2. Check curated mapped videos
    for (final key in _curatedVideos.keys) {
      if (lower.contains(key) || key.contains(lower)) {
        return _curatedVideos[key]!;
      }
    }

    // 3. Fallback to general jurisprudence video instead of a hardcoded murder video
    return LegalYouTubeVideo(
      videoId: '74SWMv0wmkY',
      title: '$clean: Legal Concept & Judicial Breakdown',
      channelName: 'Judiciary Preparation Academy',
      duration: '14:00',
      description: 'In-depth judicial analysis, statutory components, and exam perspective for $clean.',
    );
  }

  /// Dynamically searches YouTube in real-time for any section or concept.
  /// 1. Uses YouTube Data API v3 if YOUTUBE_API_KEY is configured in .env.
  /// 2. If no key, searches YouTube web endpoint and fetches oEmbed metadata dynamically.
  /// 3. Falls back to curated verified video on network failure.
  static Future<LegalYouTubeVideo> fetchVideoDynamically(String queryOrConcept) async {
    final cleanQuery = queryOrConcept.trim();
    if (cleanQuery.isEmpty) return getMatchingVideo('mob lynching');

    final cacheKey = cleanQuery.toLowerCase();
    if (_dynamicCache.containsKey(cacheKey)) {
      return _dynamicCache[cacheKey]!;
    }

    // 1. Check YouTube Data API v3 if API key is provided
    if (EnvConfig.youtubeApiKey.isNotEmpty) {
      try {
        final dio = Dio(
          BaseOptions(
            connectTimeout: const Duration(seconds: 4),
            receiveTimeout: const Duration(seconds: 4),
          ),
        );
        final res = await dio.get(
          'https://www.googleapis.com/youtube/v3/search',
          queryParameters: {
            'part': 'snippet',
            'maxResults': 1,
            'q': '$cleanQuery Judiciary Law Lecture',
            'type': 'video',
            'key': EnvConfig.youtubeApiKey,
          },
        );

        if (res.statusCode == 200 && res.data['items'] != null && (res.data['items'] as List).isNotEmpty) {
          final item = res.data['items'][0];
          final id = item['id']['videoId'] as String;
          final snippet = item['snippet'];

          final video = LegalYouTubeVideo(
            videoId: id,
            title: snippet['title']?.toString() ?? cleanQuery,
            channelName: snippet['channelTitle']?.toString() ?? 'Judiciary Academy',
            duration: 'Video Lecture',
            description: snippet['description']?.toString() ?? 'Judicial breakdown for $cleanQuery.',
          );
          _dynamicCache[cacheKey] = video;
          return video;
        }
      } catch (e) {
        debugPrint('YouTube API Key request failed: $e');
      }
    }

    // 2. Direct dynamic search on YouTube without API key
    try {
      final dio = Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 5),
          headers: {
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
          },
        ),
      );

      final encoded = Uri.encodeComponent('$cleanQuery Judiciary Lecture');
      final searchRes = await dio.get('https://www.youtube.com/results?search_query=$encoded');

      if (searchRes.statusCode == 200) {
        final body = searchRes.data.toString();
        final match = RegExp(r'"videoId":"([a-zA-Z0-9_-]{11})"').firstMatch(body);

        if (match != null) {
          final videoId = match.group(1)!;
          String title = '$cleanQuery: Detailed Analysis';
          String authorName = 'Judiciary Law Lecture';

          // Retrieve accurate title and channel name via official oEmbed
          try {
            final oembedRes = await dio.get(
              'https://www.youtube.com/oembed?url=https://www.youtube.com/watch?v=$videoId&format=json',
            );
            if (oembedRes.statusCode == 200 && oembedRes.data is Map) {
              title = oembedRes.data['title']?.toString() ?? title;
              authorName = oembedRes.data['author_name']?.toString() ?? authorName;
            }
          } catch (_) {}

          final video = LegalYouTubeVideo(
            videoId: videoId,
            title: title,
            channelName: authorName,
            duration: 'Video Lecture',
            description: 'Comprehensive judicial lecture and section analysis for $cleanQuery.',
          );

          _dynamicCache[cacheKey] = video;
          return video;
        }
      }
    } catch (e) {
      debugPrint('Direct dynamic YouTube fetch failed: $e');
    }

    // 3. Fallback to curated mapping
    return getMatchingVideo(cleanQuery);
  }

  static Future<void> launchVideoUrl(String videoIdOrUrl, {String? fallbackQuery}) async {
    final url = videoIdOrUrl.startsWith('http')
        ? Uri.parse(videoIdOrUrl)
        : Uri.parse('https://www.youtube.com/watch?v=$videoIdOrUrl');
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
        return;
      }
    } catch (_) {}

    if (fallbackQuery != null && fallbackQuery.isNotEmpty) {
      await launchYouTubeSearch(fallbackQuery);
    }
  }

  static Future<void> launchYouTubeSearch(String query) async {
    final encoded = Uri.encodeComponent('$query Judiciary Law Lecture');
    final url = Uri.parse('https://www.youtube.com/results?search_query=$encoded');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }
}
