import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/models/mcq.dart';
import '../config/env_config.dart';

final huggingFaceClientProvider = Provider((ref) => HuggingFaceLegalMCQClient());

class HuggingFaceLegalMCQClient {
  final Dio _dio;

  HuggingFaceLegalMCQClient({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: EnvConfig.huggingFaceBaseUrl,
                connectTimeout: const Duration(seconds: 8),
                receiveTimeout: const Duration(seconds: 8),
              ),
            );

  Future<List<MCQ>> fetchLegalMCQs({int limit = 50}) async {
    try {
      final response = await _dio.get(
        '/rows',
        queryParameters: {
          'dataset': 'opennyaiorg/aibe_dataset',
          'config': 'default',
          'split': 'train',
          'offset': 0,
          'limit': limit,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final rows = response.data['rows'] as List<dynamic>?;
        if (rows != null && rows.isNotEmpty) {
          final mcqList = <MCQ>[];

          for (int i = 0; i < rows.length; i++) {
            final rowData = rows[i]['row'] as Map<String, dynamic>?;
            if (rowData == null) continue;

            final questionText = rowData['question']?.toString() ?? '';
            final optionA = rowData['option_a']?.toString() ?? rowData['A']?.toString() ?? 'Option A';
            final optionB = rowData['option_b']?.toString() ?? rowData['B']?.toString() ?? 'Option B';
            final optionC = rowData['option_c']?.toString() ?? rowData['C']?.toString() ?? 'Option C';
            final optionD = rowData['option_d']?.toString() ?? rowData['D']?.toString() ?? 'Option D';
            final answerKey = rowData['answer']?.toString().toUpperCase() ?? 'A';

            int correctIndex = 0;
            if (answerKey == 'B' || answerKey == '2' || answerKey == 'OPTION_B') correctIndex = 1;
            if (answerKey == 'C' || answerKey == '3' || answerKey == 'OPTION_C') correctIndex = 2;
            if (answerKey == 'D' || answerKey == '4' || answerKey == 'OPTION_D') correctIndex = 3;

            final subject = _deriveSubject(questionText);

            mcqList.add(
              MCQ(
                id: 'hf_${i + 1}',
                subject: subject,
                stateExam: 'AIBE / PCS-J',
                examYear: 2024,
                question: questionText,
                options: [optionA, optionB, optionC, optionD],
                correctIndex: correctIndex,
                explanation: rowData['explanation']?.toString() ??
                    'Correct option is ($answerKey). Governed under statutory legal principles.',
                sectionRef: _extractSectionRef(questionText),
              ),
            );
          }

          if (mcqList.isNotEmpty) {
            mcqList.shuffle();
            return mcqList;
          }
        }
      }
    } catch (_) {}

    final list = _getExpandedJudicialMCQBank();
    list.shuffle();
    return list;
  }

  String _deriveSubject(String text) {
    final t = text.toLowerCase();
    if (t.contains('constitution') || t.contains('article')) return 'Constitutional Law';
    if (t.contains('penal') || t.contains('murder') || t.contains('bns') || t.contains('ipc')) return 'Criminal Law';
    if (t.contains('procedure') || t.contains('crpc') || t.contains('bnss')) return 'Procedure';
    if (t.contains('evidence') || t.contains('bsa')) return 'Evidence';
    if (t.contains('cpc') || t.contains('civil')) return 'Civil Law';
    return 'Judicial Service';
  }

  String _extractSectionRef(String text) {
    final match = RegExp(r'Section\s+\d+|Article\s+\d+').firstMatch(text);
    return match?.group(0) ?? 'PCS-J Standard Section';
  }

  List<MCQ> _getExpandedJudicialMCQBank() {
    return [
      MCQ(
        id: 'mcq_01',
        subject: 'Criminal Law',
        stateExam: 'DJS / UP PCS-J',
        examYear: 2024,
        question:
            'Under Bharatiya Nyaya Sanhita (BNS), 2023, what is the minimum number of persons required acting in concert to constitute the offence of Mob Lynching under Section 103(2)?',
        options: ['3 or more', '5 or more', '7 or more', '10 or more'],
        correctIndex: 1,
        explanation:
            'BNS Section 103(2) explicitly specifies that when a group of 5 or more persons acting in concert commits murder on grounds of race, caste, community, or personal belief, each member is punishable with Death or Life Imprisonment.',
        sectionRef: 'BNS Section 103(2)',
      ),
      MCQ(
        id: 'mcq_02',
        subject: 'Procedure',
        stateExam: 'MP CJ / RJS',
        examYear: 2024,
        question:
            'Under Bharatiya Nagarik Suraksha Sanhita (BNSS) Section 173, an electronic FIR (e-FIR) must be signed by the informant within how many days of being lodged?',
        options: ['24 Hours', '3 Days', '7 Days', '15 Days'],
        correctIndex: 1,
        explanation:
            'BNSS Section 173 proviso mandates that information given by electronic communication (e-FIR) shall be taken on record upon being signed within three days by the person giving it.',
        sectionRef: 'BNSS Section 173',
      ),
      MCQ(
        id: 'mcq_03',
        subject: 'Evidence',
        stateExam: 'UP PCS-J',
        examYear: 2024,
        question:
            'Which section of Bharatiya Sakshya Adhiniyam (BSA), 2023 corresponds to repealed IEA Section 65B for admissibility of electronic records accompanied by a certificate?',
        options: ['Section 59', 'Section 63', 'Section 65', 'Section 70'],
        correctIndex: 1,
        explanation:
            'BSA Section 63 replaces IEA Section 65B. Sub-section (4) mandates an electronic certificate for secondary electronic evidence.',
        sectionRef: 'BSA Section 63',
      ),
      MCQ(
        id: 'mcq_04',
        subject: 'Civil Law',
        stateExam: 'DJS / MP CJ',
        examYear: 2023,
        question:
            'Explanation IV to Section 11 of the Code of Civil Procedure (CPC), 1908 deals with which of the following statutory doctrines?',
        options: ['Res Sub-Judice', 'Direct Res Judicata', 'Constructive Res Judicata', 'Foreign Judgment Bar'],
        correctIndex: 2,
        explanation:
            'Explanation IV to Section 11 CPC codifies Constructive Res Judicata: Any matter which might and ought to have been made ground of defence or attack in a former suit shall be deemed to have been a matter directly and substantially in issue in such suit.',
        sectionRef: 'CPC Section 11 Explanation IV',
      ),
      MCQ(
        id: 'mcq_05',
        subject: 'Constitutional Law',
        stateExam: 'All-India Judicial',
        examYear: 2023,
        question:
            'In which landmark 9-judge bench decision did the Supreme Court hold that the Right to Privacy is an intrinsic fundamental right under Article 21?',
        options: [
          'Kharak Singh v. State of U.P. (1963)',
          'M.P. Sharma v. Satish Chandra (1954)',
          'Justice K.S. Puttaswamy v. Union of India (2017)',
          'Maneka Gandhi v. Union of India (1978)'
        ],
        correctIndex: 2,
        explanation:
            'Justice K.S. Puttaswamy v. Union of India (2017) 10 SCC 1 unanimously held that Right to Privacy is protected as an intrinsic part of the right to life and personal liberty under Article 21.',
        sectionRef: 'Constitution Article 21',
      ),
      MCQ(
        id: 'mcq_06',
        subject: 'Criminal Law',
        stateExam: 'DJS 2024',
        examYear: 2024,
        question:
            'Under BNS 2023 Section 303(2), community service is introduced as a punishment for first-time theft where the value of stolen property is less than:',
        options: ['₹ 1,000', '₹ 5,000', '₹ 10,000', '₹ 50,000'],
        correctIndex: 1,
        explanation:
            'BNS Section 303(2) proviso provides that where stolen property value is less than ₹5,000 and it is a first offence upon return/restoration, punishment may include Community Service.',
        sectionRef: 'BNS Section 303(2)',
      ),
      MCQ(
        id: 'mcq_07',
        subject: 'Procedure',
        stateExam: 'UP PCS-J 2024',
        examYear: 2024,
        question:
            'Under BNSS 2023 Section 187, what is the maximum initial period of police custody that can be granted by a magistrate within the first 40 or 60 days of detention?',
        options: ['7 Days', '15 Days in whole or parts', '30 Days', '90 Days'],
        correctIndex: 1,
        explanation:
            'BNSS Section 187 permits 15 days of police custody in whole or in parts during the initial 40 or 60 days of total remand period.',
        sectionRef: 'BNSS Section 187',
      ),
      MCQ(
        id: 'mcq_08',
        subject: 'Evidence',
        stateExam: 'RJS 2024',
        examYear: 2024,
        question:
            'Under BSA 2023 Section 24, a confession made to a police officer shall not be proved against a person accused of an offence, except when made in the immediate presence of a:',
        options: ['Superintendent of Police', 'Magistrate', 'Advocate', 'Public Prosecutor'],
        correctIndex: 1,
        explanation:
            'BSA Section 24 retains the fundamental rule that confessions made to police officers are inadmissible unless made in the immediate presence of a Magistrate.',
        sectionRef: 'BSA Section 24',
      ),
      MCQ(
        id: 'mcq_09',
        subject: 'Civil Law',
        stateExam: 'MP CJ 2024',
        examYear: 2024,
        question:
            'Which Order and Rule of the Code of Civil Procedure (CPC), 1908 governs the mandatory rejection of a plaint for failing to disclose a cause of action?',
        options: ['Order VI Rule 17', 'Order VII Rule 11(a)', 'Order VIII Rule 1', 'Order IX Rule 13'],
        correctIndex: 1,
        explanation:
            'CPC Order VII Rule 11(a) mandates that the plaint shall be rejected where it does not disclose a clear cause of action.',
        sectionRef: 'CPC Order VII Rule 11',
      ),
      MCQ(
        id: 'mcq_10',
        subject: 'Constitutional Law',
        stateExam: 'BJS 2024',
        examYear: 2024,
        question:
            'Under Article 141 of the Constitution of India, the law declared by the Supreme Court shall be binding on:',
        options: [
          'Only High Courts in India',
          'All courts within the territory of India',
          'Only District & Subordinate Courts',
          'Only Tribunals and Commissions'
        ],
        correctIndex: 1,
        explanation:
            'Article 141 explicitly commands that the law declared by the Supreme Court shall be binding on all courts within the territory of India.',
        sectionRef: 'Constitution Article 141',
      ),
      MCQ(
        id: 'mcq_11',
        subject: 'Criminal Law',
        stateExam: 'HCS-J 2024',
        examYear: 2024,
        question:
            'What is the new penal provision under BNS Section 152 replacing repealed IPC Section 124A (Sedition)?',
        options: [
          'Acts endangering sovereignty, unity and integrity of India',
          'Defamation against public officials',
          'Unlawful assembly near courts',
          'Disobedience to public servant'
        ],
        correctIndex: 0,
        explanation:
            'BNS Section 152 penalizes acts endangering sovereignty, unity and integrity of India, replacing the colonial sedition law.',
        sectionRef: 'BNS Section 152',
      ),
      MCQ(
        id: 'mcq_12',
        subject: 'Procedure',
        stateExam: 'DJS 2023',
        examYear: 2023,
        question:
            'Under BNSS Section 484 (replacing CrPC Section 438), an application for Anticipatory Bail can be filed before:',
        options: [
          'High Court or Court of Session',
          'Judicial Magistrate First Class only',
          'Executive Magistrate only',
          'Supreme Court directly'
        ],
        correctIndex: 0,
        explanation:
            'BNSS Section 484 empowers both the High Court and the Court of Session to grant direction for bail to a person apprehending arrest.',
        sectionRef: 'BNSS Section 484',
      ),
      MCQ(
        id: 'mcq_13',
        subject: 'Evidence',
        stateExam: 'UP PCS-J 2023',
        examYear: 2023,
        question:
            'Under BSA Section 119 (replacing IEA Section 118), who among the following is competent to testify as a witness in a judicial proceeding?',
        options: [
          'All persons unless the court considers they are prevented from understanding questions',
          'Only literate persons above 18 years',
          'Only eye-witnesses recorded in FIR',
          'Only government gazetted officers'
        ],
        correctIndex: 0,
        explanation:
            'BSA Section 119 states that all persons shall be competent to testify unless the Court considers that they are prevented from understanding the questions put to them by tender years, extreme old age, or disease.',
        sectionRef: 'BSA Section 119',
      ),
      MCQ(
        id: 'mcq_14',
        subject: 'Civil Law',
        stateExam: 'RJS 2023',
        examYear: 2023,
        question:
            'Which section of the Specific Relief Act, 1963 governs mandatory injunctions to prevent the breach of an obligation?',
        options: ['Section 36', 'Section 37', 'Section 39', 'Section 41'],
        correctIndex: 2,
        explanation:
            'Specific Relief Act Section 39 governs Mandatory Injunctions to compel the performance of certain acts which the court is capable of enforcing.',
        sectionRef: 'Specific Relief Act Section 39',
      ),
      MCQ(
        id: 'mcq_15',
        subject: 'Constitutional Law',
        stateExam: 'UP PCS-J 2024',
        examYear: 2024,
        question:
            'Which writ is issued by High Courts under Article 226 to command a public authority to perform a mandatory statutory duty?',
        options: ['Habeas Corpus', 'Mandamus', 'Quo Warranto', 'Certiorari'],
        correctIndex: 1,
        explanation:
            'Writ of Mandamus is an order issued by a superior court commanding a public or statutory authority to perform a mandatory duty imposed by law.',
        sectionRef: 'Constitution Article 226',
      ),
    ];
  }
}
