import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_colors.dart';
import '../../core/network/concept_aggregator_service.dart';
import '../../shared/widgets/search_bar.dart';
import '../bare_acts/section_detail_screen.dart';

final dynamicConceptSearchProvider = FutureProvider.family<List<DynamicConceptItem>, String>((ref, query) async {
  final service = ref.read(conceptAggregatorServiceProvider);
  return service.searchConceptsDynamically(query);
});

class ConceptSearchScreen extends ConsumerStatefulWidget {
  const ConceptSearchScreen({super.key});

  @override
  ConsumerState<ConceptSearchScreen> createState() => _ConceptSearchScreenState();
}

class _ConceptSearchScreenState extends ConsumerState<ConceptSearchScreen> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchResultsAsync = ref.watch(dynamicConceptSearchProvider(_searchQuery));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Concept & Exam Search Engine'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(dynamicConceptSearchProvider(_searchQuery)),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primaryNavy, AppColors.secondaryNavy],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Live Multi-API Search Engine',
                      style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.emeraldGreen,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '100% INTERACTIVE',
                        style: GoogleFonts.inter(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Tap any concept card to view full statutory details, practical case examples, landmark SC ratios, and related Mains exam questions!',
                  style: GoogleFonts.inter(color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(height: 12),
                CustomSearchBar(
                  controller: _searchController,
                  hintText: 'Search concept, act, or state exam (e.g. DJS, BNS 103)...',
                  onChanged: (val) => setState(() => _searchQuery = val),
                ),
              ],
            ),
          ),
          Expanded(
            child: searchResultsAsync.when(
              data: (items) => RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(dynamicConceptSearchProvider(_searchQuery));
                  await ref.read(dynamicConceptSearchProvider(_searchQuery).future);
                },
                child: items.isEmpty
                    ? Center(
                        child: Text(
                          'No live concepts matched your search query.\nTry searching "Mob Lynching", "Res Judicata", or "Zero FIR".',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.only(left: 12, right: 12, top: 12, bottom: 90),
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final item = items[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            child: Material(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(16),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: () => _openConceptDetailModal(context, item),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              item.conceptName,
                                              style: GoogleFonts.outfit(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.primaryNavy,
                                              ),
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: AppColors.accentGold,
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              item.examCategory,
                                              style: GoogleFonts.inter(
                                                color: AppColors.primaryNavy,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 11,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            item.actAndSection,
                                            style: GoogleFonts.inter(
                                              color: AppColors.crimsonRed,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              Text(
                                                'Tap to Explore',
                                                style: GoogleFonts.inter(color: AppColors.primaryNavy, fontSize: 11, fontWeight: FontWeight.bold),
                                              ),
                                              const Icon(Icons.chevron_right, color: AppColors.primaryNavy, size: 18),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        item.definition,
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.inter(fontSize: 14, height: 1.5),
                                      ),
                                      const SizedBox(height: 14),
                                      Text(
                                        'Appeared in State Judicial Exams:',
                                        style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.primaryNavy),
                                      ),
                                      const SizedBox(height: 6),
                                      Wrap(
                                        spacing: 6,
                                        runSpacing: 6,
                                        children: item.stateExamAppearances.map((examTag) {
                                          return Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: AppColors.emeraldGreen.withValues(alpha: 0.15),
                                              borderRadius: BorderRadius.circular(12),
                                              border: Border.all(color: AppColors.emeraldGreen.withValues(alpha: 0.4)),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Icon(Icons.school, size: 14, color: AppColors.emeraldGreen),
                                                const SizedBox(width: 4),
                                                Text(
                                                  examTag,
                                                  style: GoogleFonts.inter(
                                                    color: AppColors.emeraldGreen,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                      const SizedBox(height: 14),
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade100,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                const Icon(Icons.gavel, size: 16, color: AppColors.primaryNavy),
                                                const SizedBox(width: 6),
                                                Expanded(
                                                  child: Text(
                                                    item.landmarkCase,
                                                    style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Ratio: ${item.caseRatio}',
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMutedDark),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
              loading: () => const Center(child: CircularProgressIndicator(color: AppColors.accentGold)),
              error: (err, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.wifi_off, size: 48, color: Colors.grey),
                    const SizedBox(height: 12),
                    Text('Failed to aggregate live API concept search: $err'),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => ref.refresh(dynamicConceptSearchProvider(_searchQuery)),
                      child: const Text('Retry Search'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openConceptDetailModal(BuildContext context, DynamicConceptItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (modalContext) {
        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          item.conceptName,
                          style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primaryNavy),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(modalContext),
                      ),
                    ],
                  ),
                  Text(item.actAndSection, style: GoogleFonts.inter(color: AppColors.crimsonRed, fontWeight: FontWeight.bold, fontSize: 14)),
                  const Divider(height: 24),

                  Text('State Judicial Exam Appearances:', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: AppColors.primaryNavy)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: item.stateExamAppearances.map((exam) {
                      return Chip(
                        avatar: const Icon(Icons.school, size: 16, color: AppColors.emeraldGreen),
                        label: Text(exam, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.emeraldGreen)),
                        backgroundColor: AppColors.emeraldGreen.withValues(alpha: 0.12),
                        side: BorderSide(color: AppColors.emeraldGreen.withValues(alpha: 0.4)),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  Text('Statutory Definition & Summary:', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: AppColors.primaryNavy)),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
                    child: Text(item.definition, style: GoogleFonts.inter(fontSize: 14, height: 1.5)),
                  ),
                  const SizedBox(height: 16),

                  if (item.practicalExamples.isNotEmpty) ...[
                    Text('Practical Real-World Case Scenarios:', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: AppColors.primaryNavy)),
                    const SizedBox(height: 8),
                    ...item.practicalExamples.map((ex) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.emeraldGreen.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.emeraldGreen.withValues(alpha: 0.3)),
                        ),
                        child: Text(ex, style: GoogleFonts.inter(fontSize: 13, height: 1.4)),
                      );
                    }),
                    const SizedBox(height: 16),
                  ],

                  if (item.keyIngredients.isNotEmpty) ...[
                    Text('Key Legal Ingredients Checklist:', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: AppColors.primaryNavy)),
                    const SizedBox(height: 8),
                    ...item.keyIngredients.map((ing) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 6.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.check_circle, color: AppColors.emeraldGreen, size: 16),
                            const SizedBox(width: 6),
                            Expanded(child: Text(ing, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500))),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 16),
                  ],

                  Text('Landmark Supreme Court Ratio Decidendi:', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: AppColors.primaryNavy)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.blue.shade200)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.landmarkCase, style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: AppColors.primaryNavy, fontSize: 14)),
                        const SizedBox(height: 4),
                        Text(item.caseRatio, style: GoogleFonts.inter(fontSize: 13, height: 1.4)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  Row(
                    children: [
                      if (item.rawAct != null && item.rawSection != null) ...[
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(modalContext);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SectionDetailScreen(bareAct: item.rawAct!, section: item.rawSection!),
                                ),
                              );
                            },
                            icon: const Icon(Icons.menu_book),
                            label: const Text('Full Section View'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryNavy,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                      ],
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(modalContext);
                            context.push('/mains');
                          },
                          icon: const Icon(Icons.edit_note),
                          label: const Text('Practice Mains Q'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accentGold,
                            foregroundColor: AppColors.primaryNavy,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
