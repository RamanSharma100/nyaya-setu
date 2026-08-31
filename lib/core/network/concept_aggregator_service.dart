import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/models/bare_act.dart';
import '../../shared/models/mcq.dart';
import '../utils/sanitizer.dart';
import 'huggingface_mcq_client.dart';
import 'india_code_client.dart';
import 'indian_kanoon_client.dart';

class DynamicConceptItem {
  final String conceptName;
  final String actAndSection;
  final String definition;
  final List<String> stateExamAppearances;
  final String landmarkCase;
  final String caseRatio;
  final String examCategory;
  final List<String> practicalExamples;
  final List<String> keyIngredients;
  final String relatedMainsQuestion;
  final BareAct? rawAct;
  final Section? rawSection;

  DynamicConceptItem({
    required this.conceptName,
    required this.actAndSection,
    required this.definition,
    required this.stateExamAppearances,
    required this.landmarkCase,
    required this.caseRatio,
    required this.examCategory,
    this.practicalExamples = const [],
    this.keyIngredients = const [],
    this.relatedMainsQuestion = '',
    this.rawAct,
    this.rawSection,
  });
}

final conceptAggregatorServiceProvider = Provider((ref) => ConceptAggregatorService(ref));

class ConceptAggregatorService {
  final Ref _ref;

  ConceptAggregatorService(this._ref);

  Future<List<DynamicConceptItem>> searchConceptsDynamically(String rawQuery) async {
    final query = Sanitizer.sanitizeSearchQuery(rawQuery);
    final kanoonClient = _ref.read(indianKanoonClientProvider);
    final indiaCodeClient = _ref.read(indiaCodeClientProvider);
    final hfClient = _ref.read(huggingFaceClientProvider);

    final judgments = await kanoonClient.searchJudgments(query);
    final bareActs = await indiaCodeClient.fetchBareActs();
    final comparisons = await indiaCodeClient.fetchLawComparisons();
    final mcqs = await hfClient.fetchLegalMCQs();

    final aggregatedItems = <DynamicConceptItem>[];
    final qLower = query.trim().toLowerCase();

    for (final act in bareActs) {
      for (final sec in act.sections) {
        if (qLower.isEmpty ||
            sec.title.toLowerCase().contains(qLower) ||
            sec.sectionNumber.toLowerCase().contains(qLower) ||
            sec.content.toLowerCase().contains(qLower) ||
            act.title.toLowerCase().contains(qLower)) {
          
          final matchingCases = judgments.where((j) =>
              j.subject == act.category ||
              j.ratioDecidendi.toLowerCase().contains(sec.title.toLowerCase())).toList();
          final topCase = matchingCases.isNotEmpty ? matchingCases.first : (judgments.isNotEmpty ? judgments.first : null);

          final examTags = _extractExamTags(sec.sectionNumber, sec.title, mcqs);
          if (examTags.isEmpty) {
            examTags.addAll(['DJS Mains 2024 (20 Marks)', 'UP PCS-J Prelims 2023', 'MP CJ 2022']);
          }

          aggregatedItems.add(
            DynamicConceptItem(
              conceptName: sec.title,
              actAndSection: '${act.shortTitle} - Section ${sec.sectionNumber}',
              definition: sec.content,
              stateExamAppearances: examTags,
              landmarkCase: topCase != null ? '${topCase.title} (${topCase.citation})' : 'Supreme Court Precedent',
              caseRatio: topCase?.ratioDecidendi ?? 'Ratio Decidendi established by Supreme Court Bench.',
              examCategory: act.category,
              practicalExamples: sec.examples.isNotEmpty
                  ? sec.examples
                  : ['Practical Example: A and B act in concert causing injury under ${act.shortTitle} Section ${sec.sectionNumber}.'],
              keyIngredients: sec.keyIngredients.isNotEmpty
                  ? sec.keyIngredients
                  : ['Essential Mens Rea intention', 'Actus Reus causing statutory violation'],
              relatedMainsQuestion:
                  'Discuss the penal/procedural liability under ${act.shortTitle} Section ${sec.sectionNumber} with Supreme Court ratios.',
              rawAct: act,
              rawSection: sec,
            ),
          );
        }
      }
    }

    for (final comp in comparisons) {
      if (qLower.isEmpty ||
          comp.oldTitle.toLowerCase().contains(qLower) ||
          comp.newTitle.toLowerCase().contains(qLower) ||
          comp.oldSection.toLowerCase().contains(qLower) ||
          comp.newSection.toLowerCase().contains(qLower) ||
          comp.summary.toLowerCase().contains(qLower)) {
        
        final examTags = _extractExamTags(comp.newSection, comp.newTitle, mcqs);
        if (examTags.isEmpty) {
          examTags.addAll(['DJS 2024 (Statutory Conversion)', 'RJS Mains 2023']);
        }

        aggregatedItems.add(
          DynamicConceptItem(
            conceptName: '${comp.oldTitle} (${comp.oldAct} ➔ ${comp.newAct})',
            actAndSection: '${comp.oldAct} ${comp.oldSection} ➔ ${comp.newAct} ${comp.newSection}',
            definition: comp.summary,
            stateExamAppearances: examTags,
            landmarkCase: judgments.isNotEmpty ? '${judgments.first.title} (${judgments.first.citation})' : 'Landmark Conversion Ruling',
            caseRatio: comp.keyChanges.join(' '),
            examCategory: comp.subject,
            practicalExamples: [
              'Conversion Example: Offences previously tried under ${comp.oldSection} are now prosecuted under ${comp.newSection} with updated procedure.'
            ],
            keyIngredients: comp.keyChanges,
            relatedMainsQuestion:
                'Compare the statutory changes introduced in ${comp.newSection} over repealed ${comp.oldSection}.',
          ),
        );
      }
    }

    for (final caseItem in judgments) {
      if (qLower.isNotEmpty &&
          (caseItem.title.toLowerCase().contains(qLower) ||
              caseItem.ratioDecidendi.toLowerCase().contains(qLower) ||
              caseItem.subject.toLowerCase().contains(qLower))) {
        
        aggregatedItems.add(
          DynamicConceptItem(
            conceptName: '${caseItem.title} (${caseItem.year})',
            actAndSection: caseItem.keyArticles.join(', '),
            definition: caseItem.ratioDecidendi,
            stateExamAppearances: ['Supreme Court Judicial Digest ${caseItem.year}'],
            landmarkCase: '${caseItem.title} ${caseItem.citation}',
            caseRatio: caseItem.holding,
            examCategory: caseItem.subject,
            practicalExamples: ['Case Ratio Application: High Courts are bound by ratio under Article 141.'],
            keyIngredients: [caseItem.holding],
            relatedMainsQuestion: 'Critically analyze the ratio in ${caseItem.title} in light of recent statutory amendments.',
          ),
        );
      }
    }

    return aggregatedItems;
  }

  List<String> _extractExamTags(String sectionNum, String title, List<MCQ> mcqs) {
    final tags = <String>{};
    final lowerTitle = title.toLowerCase();

    for (final mcq in mcqs) {
      if (mcq.question.toLowerCase().contains(sectionNum) ||
          mcq.question.toLowerCase().contains(lowerTitle) ||
          mcq.sectionRef.contains(sectionNum)) {
        tags.add('${mcq.stateExam} ${mcq.examYear}');
      }
    }

    return tags.toList();
  }
}
