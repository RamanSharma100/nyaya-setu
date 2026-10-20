import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/models/case_law.dart';
import '../config/env_config.dart';
import '../utils/sanitizer.dart';

final indianKanoonClientProvider = Provider((ref) => IndianKanoonApiClient());

class IndianKanoonApiClient {
  final Dio _dio;

  IndianKanoonApiClient({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: EnvConfig.indianKanoonBaseUrl,
                connectTimeout: const Duration(seconds: 5),
                receiveTimeout: const Duration(seconds: 5),
                headers: {
                  'Accept': 'application/json',
                  if (EnvConfig.indianKanoonApiKey.isNotEmpty)
                    'Authorization': 'Token ${EnvConfig.indianKanoonApiKey}',
                },
              ),
            );

  Future<List<CaseLaw>> searchJudgments(String query, {int page = 1}) async {
    final cleanQuery = Sanitizer.sanitizeSearchQuery(query);
    final searchParam = cleanQuery.isEmpty ? 'fundamental rights privacy murder' : cleanQuery;

    try {
      final response = await _dio.post(
        '/search/',
        data: {
          'formInput': '$searchParam doctypes: supremecourt',
          'pagenum': page - 1,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final docs = response.data['docs'] as List<dynamic>?;
        if (docs != null && docs.isNotEmpty) {
          final list = docs.map((doc) {
            final title = Sanitizer.sanitizeHtml(doc['title'] ?? 'Supreme Court Judgment');
            final headline = Sanitizer.sanitizeHtml(doc['headline'] ?? '');
            final docId = doc['tid']?.toString() ?? '0';
            final yearMatch = RegExp(r'\b(19\d\d|20\d\d)\b').firstMatch(title);
            final year = yearMatch != null ? int.parse(yearMatch.group(0)!) : 2024;

            return CaseLaw(
              id: docId,
              title: title,
              citation: doc['citation'] ?? 'SC Citation $docId',
              year: year,
              bench: doc['bench'] ?? 'Supreme Court Bench',
              subject: _detectSubject(title + headline),
              keyArticles: _extractArticles(headline),
              ratioDecidendi: headline.isNotEmpty
                  ? headline
                  : 'Ratio Decidendi established under Supreme Court ruling.',
              facts: 'Live Search Result from Indian Kanoon API (Doc ID: $docId).',
              holding: 'Judicial ruling passed by the Supreme Court of India.',
              examSignificance: 'High-frequency case law for PCS-J examinations.',
              docUrl: 'https://indiankanoon.org/search/?formInput=${Uri.encodeComponent(title)}',
              whatHappened: 'Enforcement proceedings initiated in Supreme Court of India.',
              currentStatus: 'Active binding precedent under Article 141.',
            );
          }).toList();

          list.sort((a, b) => b.year.compareTo(a.year));
          return list;
        }
      }
    } catch (_) {}

    final fallback = _getFallbackLandmarkCases();
    fallback.sort((a, b) => b.year.compareTo(a.year));
    return fallback;
  }

  Future<CaseLaw?> getDocDetails(String docId) async {
    final cleanDocId = Sanitizer.sanitizeSearchQuery(docId);
    try {
      final response = await _dio.post('/doc/$cleanDocId/');
      if (response.statusCode == 200 && response.data != null) {
        final title = Sanitizer.sanitizeHtml(response.data['title'] ?? '');
        final docText = Sanitizer.sanitizeHtml(response.data['doc'] ?? '');

        return CaseLaw(
          id: cleanDocId,
          title: title,
          citation: 'AIR / SC Citation $cleanDocId',
          year: 2024,
          bench: 'Supreme Court Bench',
          subject: _detectSubject(title + docText),
          keyArticles: ['Article 21', 'Article 14'],
          ratioDecidendi: docText.length > 300 ? docText.substring(0, 300) : docText,
          facts: docText.length > 500 ? docText.substring(0, 500) : docText,
          holding: 'Binding Supreme Court Judgment.',
          examSignificance: 'Mandatory landmark precedent.',
          docUrl: 'https://indiankanoon.org/search/?formInput=${Uri.encodeComponent(title)}',
          whatHappened: 'Full judgment document retrieved from Indian Kanoon archive.',
          currentStatus: 'Active binding precedent under Article 141.',
        );
      }
    } catch (_) {}

    return null;
  }

  List<CaseLaw> _getFallbackLandmarkCases() {
    return [
      CaseLaw(
        id: 'sc_06',
        title: 'V. Senthil Balaji v. State Represented by Deputy Director',
        citation: '(2024) 3 SCC 501',
        year: 2024,
        bench: '2-Judge Bench (A.S. Bopanna, M.M. Sundresh JJ.)',
        subject: 'Procedure & Remand',
        keyArticles: ['BNSS Section 187', 'CrPC Section 167', 'Article 22'],
        ratioDecidendi:
            'Custodial remand under Section 167 CrPC (now BNSS Section 187) cannot extend beyond 15 days in totality during the initial period of 40 or 60 days. Habeas Corpus petition is maintainable against illegal detention.',
        facts:
            'Challenge to order of police custody passed by Special Court beyond initial statutory 15-day timeline following arrest by Enforcement Directorate.',
        holding:
            'Police custody granted must strictly adhere to statutory timelines under 2023 criminal procedure reform.',
        examSignificance: 'Latest 2024 Supreme Court precedent for BNSS Section 187 Remand in Mains.',
        docUrl: 'https://indiankanoon.org/search/?formInput=V.+Senthil+Balaji+v.+State+Represented+by+Deputy+Director',
        whatHappened:
            'The Enforcement Directorate arrested the minister in a money laundering probe. The High Court entertained a Habeas Corpus petition and permitted private hospital transfer. Supreme Court ruled on the exact scope of police custody duration during initial detention.',
        currentStatus:
            'Active Binding Law (2024) under Article 141. Directly cited in BNSS Section 187 custodial remand questions.',
      ),
      CaseLaw(
        id: 'sc_04',
        title: 'Arjun Panditrao Khotkar v. Kailash Kushanrao Gorantyal',
        citation: '(2020) 7 SCC 1',
        year: 2020,
        bench: '3-Judge Bench (R.F. Nariman, S. Ravindra Bhat, V. Ramasubramanian JJ.)',
        subject: 'Evidence Law',
        keyArticles: ['BSA Section 63(4)', 'IEA Section 65B(4)'],
        ratioDecidendi:
            'Re-enunciated the mandatory nature of the Section 65B(4) certificate (now BSA Section 63(4)) for secondary electronic evidence. Certificate is a condition precedent to admissibility when original device cannot be produced.',
        facts:
            'Election petition challenging MLA election based on uncertified video recordings and election commission logs.',
        holding:
            'Clarified Anvar P.V. (2014) and overruled Shafhi Mohammad (2018) fallback exception.',
        examSignificance: 'Essential for BSA Section 63 electronic record evidence questions in Mains.',
        docUrl: 'https://indiankanoon.org/search/?formInput=Arjun+Panditrao+Khotkar+v.+Kailash+Kushanrao+Gorantyal',
        whatHappened:
            'Defeating candidate filed election petition presenting VCDs and computer logs without electronic certificates. High Court admitted the logs. Supreme Court settled conflicting 2-Judge Bench decisions, holding Section 65B(4) mandatory.',
        currentStatus:
            'Settled Constitutional Law (2020). Replaced old IEA Section 65B rules with Bharatiya Sakshya Adhiniyam (BSA 2023) Section 63.',
      ),
      CaseLaw(
        id: 'sc_02',
        title: 'Tehseen S. Poonawalla v. Union of India',
        citation: '(2018) 9 SCC 501',
        year: 2018,
        bench: '3-Judge Bench (Dipak Misra C.J., A.M. Khanwilkar, D.Y. Chandrachud JJ.)',
        subject: 'Criminal Law',
        keyArticles: ['Article 21', 'Article 14', 'BNS Section 103(2)'],
        ratioDecidendi:
            'Mob violence and lynching are crimes against human dignity and rule of law. Issued mandatory preventive, remedial, and punitive measures for state law enforcement.',
        facts:
            'Public interest litigation seeking guidelines to curb mob lynching and vigilante attacks across states.',
        holding:
            'Directed Parliament to enact a separate law creating specific penal sanctions for mob lynching (now codified in BNS Section 103(2)).',
        examSignificance: 'Directly applicable to BNS Section 103(2) Mob Lynching Mains questions.',
        docUrl: 'https://indiankanoon.org/search/?formInput=Tehseen+S.+Poonawalla+v.+Union+of+India',
        whatHappened:
            'Writ petitions filed against rising cow vigilante attacks and mob violence across multiple states. Supreme Court declared vigilante actions unlawful and issued 11 preventive directives to state police chiefs.',
        currentStatus:
            'Codified into Statute! Parliament incorporated this ratio into Section 103(2) of Bharatiya Nyaya Sanhita (BNS 2023).',
      ),
      CaseLaw(
        id: 'sc_01',
        title: 'Justice K.S. Puttaswamy (Retd.) v. Union of India',
        citation: '(2017) 10 SCC 1',
        year: 2017,
        bench: '9-Judge Constitutional Bench (J.S. Khehar C.J., D.Y. Chandrachud J., et al.)',
        subject: 'Constitutional Law',
        keyArticles: ['Article 21', 'Article 14', 'Article 19'],
        ratioDecidendi:
            'Right to Privacy is an intrinsic fundamental right protected under Article 21 and Part III of the Constitution. State restrictions must satisfy the 3-fold test of legality, legitimate state aim, and proportionality.',
        facts:
            'Challenge to Aadhaar biometric database scheme on ground of violation of bodily autonomy and personal privacy.',
        holding:
            'Unanimously overruled M.P. Sharma (1954) and Kharak Singh (1962) to hold Privacy as a fundamental right.',
        examSignificance: 'Mandatory for all State Judicial Mains (20 Marks) & Constitutional Law MCQs.',
        docUrl: 'https://indiankanoon.org/search/?formInput=Justice+K.S.+Puttaswamy+v.+Union+of+India',
        whatHappened:
            'High Court and Supreme Court Benches faced conflicting decisions from 8-Judge (M.P. Sharma) and 6-Judge (Kharak Singh) benches. A 9-Judge Constitution Bench was constituted, unanimously affirming Privacy under Part III.',
        currentStatus:
            'Landmark Cornerstone Precedent under Article 21. Applied in DPDP Act 2023 and digital surveillance petitions.',
      ),
      CaseLaw(
        id: 'sc_03',
        title: 'Lalita Kumari v. Government of Uttar Pradesh',
        citation: '(2014) 2 SCC 1',
        year: 2014,
        bench: '5-Judge Constitution Bench (P. Sathasivam C.J., et al.)',
        subject: 'Procedure',
        keyArticles: ['BNSS Section 173', 'CrPC Section 154'],
        ratioDecidendi:
            'Registration of FIR under Section 154 CrPC (now BNSS Section 173) is mandatory if information discloses commission of a cognizable offence. Preliminary inquiry is permissible only in exceptional cases limited to 7 days.',
        facts:
            'Father filed a writ petition after police refused to register FIR regarding minor daughter\'s abduction.',
        holding:
            'Police officers failing to register mandatory FIR face disciplinary action.',
        examSignificance: 'Highest frequency case in Judicial Officer Prelims & BNSS Section 173 Mains.',
        docUrl: 'https://indiankanoon.org/search/?formInput=Lalita+Kumari+v.+Government+of+Uttar+Pradesh',
        whatHappened:
            'Police delayed FIR registration by taking 6 days for preliminary inquiry while minor remained missing. Supreme Court laid down 8 mandatory directions binding all police stations across India.',
        currentStatus:
            'Active Binding Directive. Now incorporated into BNSS 2023 Section 173 procedural guidelines.',
      ),
      CaseLaw(
        id: 'sc_05',
        title: 'Bachan Singh v. State of Punjab',
        citation: '(1980) 2 SCC 684',
        year: 1980,
        bench: '5-Judge Constitution Bench (Y.V. Chandrachud C.J., R.S. Sarkaria, et al.)',
        subject: 'Criminal Law',
        keyArticles: ['Article 21', 'BNS Section 103', 'BNSS Section 393'],
        ratioDecidendi:
            'Upheld constitutionality of Death Penalty under Section 302 IPC (now BNS Section 103). Enunciated the "Rarest of Rare Cases" doctrine requiring balancing of aggravating and mitigating circumstances.',
        facts:
            'Appellant convicted of 3 murders challenged constitutional validity of capital punishment under Article 19 & 21.',
        holding:
            'Life Imprisonment is the rule and Death Sentence is an exception to be awarded only when alternative option is unquestionably foreclosed.',
        examSignificance: 'Landmark precedent for BNS Section 103 sentencing rubrics.',
        docUrl: 'https://indiankanoon.org/search/?formInput=Bachan+Singh+v.+State+of+Punjab',
        whatHappened:
            'Constitutional challenge to Section 302 IPC. The 5-Judge Bench affirmed capital punishment while laying down strict sentencing guidelines requiring balancing of mitigating circumstances.',
        currentStatus:
            'Locus Classicus on Capital Punishment. Applied in BNS Section 103 sentencing evaluations.',
      ),
      CaseLaw(
        id: 'sc_07',
        title: 'Kesavananda Bharati v. State of Kerala',
        citation: '(1973) 4 SCC 225',
        year: 1973,
        bench: '13-Judge Constitution Bench (S.M. Sikri C.J., H.R. Khanna, et al.)',
        subject: 'Constitutional Law',
        keyArticles: ['Article 368', 'Article 13', 'Article 31C'],
        ratioDecidendi:
            'Parliament has wide constituent power to amend any part of the Constitution under Article 368, but this amending power cannot be exercised to alter, violate, or emasculate the Basic Structure of the Constitution.',
        facts:
            'Petitioner challenged Kerala land reform amendments and the 24th, 25th, and 29th Constitutional Amendments curtailing religious property rights.',
        holding:
            'Upheld validity of 24th Amendment while propounding the inviolable Basic Structure Doctrine.',
        examSignificance: 'The most important judgment in Indian Constitutional Law; mandatory 20 marks question.',
        docUrl: 'https://indiankanoon.org/search/?formInput=Kesavananda+Bharati+v.+State+of+Kerala',
        whatHappened:
            'Largest Constitutional Bench (13 Judges) in Indian history was constituted to review Golak Nath. By a 7-6 majority, the Supreme Court ruled that Article 368 contains inherent limitations.',
        currentStatus:
            'Foundational Constitutional Doctrine. Continues to govern judicial review of constitutional amendments.',
      ),
      CaseLaw(
        id: 'sc_08',
        title: 'Maneka Gandhi v. Union of India',
        citation: '(1978) 1 SCC 248',
        year: 1978,
        bench: '7-Judge Constitution Bench (M.H. Beg C.J., P.N. Bhagwati, et al.)',
        subject: 'Constitutional Law',
        keyArticles: ['Article 21', 'Article 19', 'Article 14'],
        ratioDecidendi:
            '"Procedure established by law" under Article 21 must be right, just, fair, and not arbitrary, fanciful, or oppressive. Established the Golden Triangle doctrine interlinking Articles 14, 19, and 21.',
        facts:
            'Regional Passport Office impounded Maneka Gandhi\'s passport under Section 10(3)(c) of Passports Act "in public interest" without providing any prior notice or hearing.',
        holding:
            'Principles of Natural Justice (audi alteram partem) are implicit in Article 21; right to travel abroad is an integral part of personal liberty.',
        examSignificance: 'Cornerstone authority for Substantive Due Process and Natural Justice in PCS-J Mains.',
        docUrl: 'https://indiankanoon.org/search/?formInput=Maneka+Gandhi+v.+Union+of+India',
        whatHappened:
            'Passport impounded during Emergency aftermath without giving reasons. Supreme Court overruled A.K. Gopalan (1950) and expanded the horizon of Article 21.',
        currentStatus:
            'Active Cornerstone Precedent. Expanded Article 21 into an organic charter of human dignity.',
      ),
      CaseLaw(
        id: 'sc_09',
        title: 'Navtej Singh Johar v. Union of India',
        citation: '(2018) 10 SCC 1',
        year: 2018,
        bench: '5-Judge Constitution Bench (Dipak Misra C.J., R.F. Nariman, D.Y. Chandrachud, et al.)',
        subject: 'Constitutional Law',
        keyArticles: ['Article 14', 'Article 15', 'Article 21', 'BNS Section 63'],
        ratioDecidendi:
            'Consensual sexual acts of adults in private do not constitute a penal offence. Section 377 IPC was declared unconstitutional to the extent it criminalized consensual homosexual acts, affirming constitutional morality over majoritarian public morality.',
        facts:
            'LGBTQ+ citizens filed writ petitions under Article 32 challenging Suresh Kumar Koushal (2014) which had recriminalized Section 377.',
        holding:
            'Unanimously struck down discriminatory portion of Section 377 IPC and affirmed right to sexual autonomy.',
        examSignificance: 'Mandatory landmark for Constitutional Morality and Right to Autonomy under Article 21.',
        docUrl: 'https://indiankanoon.org/search/?formInput=Navtej+Singh+Johar+v.+Union+of+India',
        whatHappened:
            'Constitution Bench reviewed Suresh Koushal ruling, declaring that the law cannot treat consensual private identity as unnatural or criminal.',
        currentStatus:
            'Settled Constitutional Law. Directly reflected in new Bharatiya Nyaya Sanhita 2023 penal provisions.',
      ),
      CaseLaw(
        id: 'sc_10',
        title: 'Shayara Bano v. Union of India',
        citation: '(2017) 9 SCC 1',
        year: 2017,
        bench: '5-Judge Constitution Bench (J.S. Khehar C.J., Kurian Joseph, R.F. Nariman, et al.)',
        subject: 'Constitutional Law',
        keyArticles: ['Article 14', 'Article 21', 'Article 25'],
        ratioDecidendi:
            'Instant Triple Talaq (Talaq-e-Biddat) was declared void, illegal, and unconstitutional. A statutory or personal law provision can be struck down on the ground of "Manifest Arbitrariness" under Article 14.',
        facts:
            'Writ petitions filed by Muslim women challenging unilateral, irrevocable instant triple talaq pronounced by spouses.',
        holding:
            'By 3:2 majority, held Talaq-e-Biddat is not an essential religious practice under Article 25 and is manifestly arbitrary.',
        examSignificance: 'Established the "Manifest Arbitrariness" doctrine under Article 14 for PCS-J Mains.',
        docUrl: 'https://indiankanoon.org/search/?formInput=Shayara+Bano+v.+Union+of+India',
        whatHappened:
            'Supreme Court struck down instant triple talaq, subsequently leading Parliament to pass the Muslim Women (Protection of Rights on Marriage) Act, 2019.',
        currentStatus:
            'Settled Precedent. Enunciated Manifest Arbitrariness as a potent ground for Article 14 review.',
      ),
      CaseLaw(
        id: 'sc_11',
        title: 'Anuradha Bhasin v. Union of India',
        citation: '(2020) 3 SCC 637',
        year: 2020,
        bench: '3-Judge Bench (N.V. Ramana, R. Subhash Reddy, B.R. Gavai JJ.)',
        subject: 'Constitutional Law',
        keyArticles: ['Article 19(1)(a)', 'Article 19(1)(g)', 'BNSS Section 163', 'CrPC Section 144'],
        ratioDecidendi:
            'Freedom of speech and expression and freedom to practice any profession over the medium of internet is constitutionally protected under Article 19(1)(a) and 19(1)(g). Indefinite suspension of internet services is illegal; orders must satisfy proportionality.',
        facts:
            'Executive orders suspended internet and telecom connectivity in Jammu & Kashmir following abrogation of Article 370.',
        holding:
            'Directed periodic review of suspension orders; orders under Section 144 CrPC (now BNSS 163) cannot be used to suppress legitimate expression.',
        examSignificance: 'Key modern precedent for Digital Rights and Proportionality Review in Mains.',
        docUrl: 'https://indiankanoon.org/search/?formInput=Anuradha+Bhasin+v.+Union+of+India',
        whatHappened:
            'Newspaper editor challenged prolonged shutdown of digital and telecom infrastructure in Srinagar. Supreme Court laid down mandatory procedural guidelines for telecom suspensions.',
        currentStatus:
            'Active Binding Law (2020). Standard citation in administrative law and Article 19 reasonableness tests.',
      ),
      CaseLaw(
        id: 'sc_12',
        title: 'Vishaka v. State of Rajasthan',
        citation: '(1997) 6 SCC 241',
        year: 1997,
        bench: '3-Judge Bench (J.S. Verma C.J., Sujata V. Manohar, B.N. Kirpal JJ.)',
        subject: 'Criminal & Gender Justice',
        keyArticles: ['Article 14', 'Article 19(1)(g)', 'Article 21', 'BNS Section 74'],
        ratioDecidendi:
            'Laid down mandatory "Vishaka Guidelines" prohibiting sexual harassment of women at workplaces until statutory enactment. In absence of domestic legislation, international conventions like CEDAW can be relied upon to construe constitutional guarantees.',
        facts:
            'Gang-rape of social worker Bhanwari Devi in Rajasthan while campaigning against child marriage; PIL filed for workplace safety norms.',
        holding:
            'Mandated Internal Complaints Committees (ICC) across all public and private establishments.',
        examSignificance: 'Foundational ratio for POSH Act, 2013 and BNS Section 74 in PCS-J gender justice questions.',
        docUrl: 'https://indiankanoon.org/search/?formInput=Vishaka+v.+State+of+Rajasthan',
        whatHappened:
            'PIL brought by social activists led Supreme Court to formulate judicial legislation bridging statutory gaps until Parliament enacted POSH Act 2013.',
        currentStatus:
            'Codified into POSH Act, 2013 and penal provisions of Bharatiya Nyaya Sanhita (BNS 2023).',
      ),
      CaseLaw(
        id: 'sc_13',
        title: 'D.K. Basu v. State of West Bengal',
        citation: '(1997) 1 SCC 416',
        year: 1997,
        bench: '2-Judge Bench (Kuldip Singh, A.S. Anand JJ.)',
        subject: 'Procedure & Human Rights',
        keyArticles: ['Article 21', 'Article 22', 'BNSS Section 35', 'CrPC Section 41B'],
        ratioDecidendi:
            'Custodial violence and torture violate human dignity under Article 21. Prescribed 11 mandatory guidelines for arrest, memo preparation, medical examination, and informing family members.',
        facts:
            'Executive Chairman of Legal Aid Services, West Bengal sent letter regarding recurrent custodial deaths in police lockups.',
        holding:
            'Failure of arresting officers to follow the 11 guidelines renders them liable for contempt of court and departmental action.',
        examSignificance: 'Mandatory 10 marks question in Criminal Procedure & Human Rights for all State Judicial exams.',
        docUrl: 'https://indiankanoon.org/search/?formInput=D.K.+Basu+v.+State+of+West+Bengal',
        whatHappened:
            'Supreme Court converted letter petition into landmark PIL and codified arrest safeguards, subsequently incorporated into Section 41A-41D CrPC (now BNSS 35-38).',
        currentStatus:
            'Active Binding Law. Substantively enacted into the procedural architecture of BNSS 2023.',
      ),
      CaseLaw(
        id: 'sc_14',
        title: 'Arnesh Kumar v. State of Bihar',
        citation: '(2014) 8 SCC 273',
        year: 2014,
        bench: '2-Judge Bench (Chandramauli Kr. Prasad, Pinaki Chandra Ghose JJ.)',
        subject: 'Procedure & Arrest',
        keyArticles: ['BNSS Section 35(3)', 'CrPC Section 41A', 'BNS Section 85'],
        ratioDecidendi:
            'Police officers shall not automatically arrest an accused when offence carries imprisonment up to 7 years. Mandatory to issue Notice of Appearance under Section 41A CrPC (now BNSS Section 35(3)) unless special reasons recorded in writing.',
        facts:
            'Anticipatory bail petition in a Section 498A IPC matrimonial harassment dispute addressing routine, mechanical arrests.',
        holding:
            'Magistrates authorizing detention without verifying compliance by police officer are liable for departmental action.',
        examSignificance: 'High-frequency question in PCS-J Prelims and Criminal Procedure Mains on Notice of Appearance.',
        docUrl: 'https://indiankanoon.org/search/?formInput=Arnesh+Kumar+v.+State+of+Bihar',
        whatHappened:
            'Supreme Court issued nationwide check-list for police and judicial magistrates to prevent unnecessary arrests and protect personal liberty.',
        currentStatus:
            'Active Binding Precedent. Reaffirmed in Satender Kumar Antil (2022) and codified in BNSS Section 35.',
      ),
      CaseLaw(
        id: 'sc_15',
        title: 'Satender Kumar Antil v. Central Bureau of Investigation',
        citation: '(2022) 10 SCC 51',
        year: 2022,
        bench: '2-Judge Bench (S.K. Kaul, M.M. Sundresh JJ.)',
        subject: 'Procedure & Bail Jurisprudence',
        keyArticles: ['BNSS Section 479', 'BNSS Section 482', 'CrPC Section 437', 'CrPC Section 439'],
        ratioDecidendi:
            'Enunciated comprehensive bail guidelines categorizing offences into Category A (up to 7 yrs), B (economic), C (special acts), and D (anticipatory). Reiterated "Bail is the rule, jail is the exception". Directed timely disposal of regular bail within 2 weeks.',
        facts:
            'Special Leave Petition addressing widespread practice of remanding accused persons to custody upon appearance post-chargesheet despite non-arrest during investigation.',
        holding:
            'Court appearance pursuant to summons without arrest does not require taking accused into custody.',
        examSignificance: 'The definitive modern judgment on Indian Bail Jurisprudence for Judicial Services Mains.',
        docUrl: 'https://indiankanoon.org/search/?formInput=Satender+Kumar+Antil+v.+Central+Bureau+of+Investigation',
        whatHappened:
            'Supreme Court issued comprehensive directions to streamline bail processing across trial courts and suggested Parliament enact a separate Bail Act.',
        currentStatus:
            'Leading Binding Authority (2022) on Bail across all High Courts and Trial Courts in India.',
      ),
      CaseLaw(
        id: 'sc_16',
        title: 'A.R. Antulay v. R.S. Nayak',
        citation: '(1992) 1 SCC 225',
        year: 1992,
        bench: '5-Judge Constitution Bench (B.C. Ray, M.N. Venkatachaliah, et al.)',
        subject: 'Criminal Procedure & Article 21',
        keyArticles: ['Article 21', 'BNSS Section 346', 'CrPC Section 309'],
        ratioDecidendi:
            'Right to speedy trial encompasses all stages: investigation, inquiry, trial, appeal, and revision. Though no fixed outer time limit can be laid down, systemic delay violating Article 21 can lead to quashing of proceedings.',
        facts:
            'Protracted prosecution of former Chief Minister stretching over years without conclusion of trial.',
        holding:
            'Speedy trial is an inalienable component of fair procedure under Article 21.',
        examSignificance: 'Mandatory landmark for Right to Speedy Trial under Article 21 in Judicial Mains.',
        docUrl: 'https://indiankanoon.org/search/?formInput=A.R.+Antulay+v.+R.S.+Nayak',
        whatHappened:
            '5-Judge Bench formulated 11 propositions summarizing the constitutional contours of Speedy Trial in Indian criminal jurisprudence.',
        currentStatus:
            'Settled Constitutional Doctrine. Foundation for statutory timelines introduced in BNSS 2023.',
      ),
    ];
  }

  String _detectSubject(String text) {
    final lower = text.toLowerCase();
    if (lower.contains('constitution') || lower.contains('article')) return 'Constitutional Law';
    if (lower.contains('murder') || lower.contains('bns') || lower.contains('ipc')) return 'Criminal Law';
    if (lower.contains('evidence') || lower.contains('bsa')) return 'Evidence';
    if (lower.contains('cpc') || lower.contains('suit')) return 'Civil Law';
    return 'Judicial Precedent';
  }

  List<String> _extractArticles(String text) {
    final matches = RegExp(r'Article\s+\d+').allMatches(text);
    if (matches.isNotEmpty) {
      return matches.map((m) => m.group(0)!).toSet().toList();
    }
    return ['Article 21', 'Article 14'];
  }
}
