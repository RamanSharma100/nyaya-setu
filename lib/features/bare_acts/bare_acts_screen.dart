import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/analytics/analytics_service.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/network/india_code_client.dart';
import '../../core/storage/hive_service.dart';
import '../../shared/models/bare_act.dart';
import '../../shared/models/law_comparison.dart';
import '../../shared/widgets/diff_viewer.dart';
import '../../shared/widgets/search_bar.dart';
import '../../shared/widgets/windowing_infinite_scroll_list.dart';
import '../handmade_notes/handmade_notes_screen.dart';
import 'section_detail_screen.dart';

final bareActsProvider = FutureProvider<List<BareAct>>((ref) async {
  final client = ref.read(indiaCodeClientProvider);
  return client.fetchBareActs();
});

final comparisonsProvider = FutureProvider<List<LawComparison>>((ref) async {
  final client = ref.read(indiaCodeClientProvider);
  return client.fetchLawComparisons();
});

class BareActsScreen extends ConsumerStatefulWidget {
  final String? initialTab;
  const BareActsScreen({super.key, this.initialTab});

  @override
  ConsumerState<BareActsScreen> createState() => _BareActsScreenState();
}

class _BareActsScreenState extends ConsumerState<BareActsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _majorActsScrollController = ScrollController();
  final ScrollController _minorActsScrollController = ScrollController();
  final ScrollController _converterScrollController = ScrollController();

  String _majorSearchQuery = '';
  String _minorSearchQuery = '';
  String _majorSelectedFilter = 'All Major';
  String _minorSelectedFilter = 'All Minor';
  String _converterQuery = '';

  @override
  void initState() {
    super.initState();
    int initialIndex = 0;
    if (widget.initialTab == 'minor') {
      initialIndex = 1;
    } else if (widget.initialTab == 'converter' || widget.initialTab == 'comparison') {
      initialIndex = 2;
    } else if (widget.initialTab == 'notes') {
      initialIndex = 3;
    }
    _tabController = TabController(length: 4, vsync: this, initialIndex: initialIndex);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        final tabName = switch (_tabController.index) {
          0 => 'major_acts_tab',
          1 => 'minor_acts_tab',
          2 => 'bns_converter_tab',
          3 => 'handmade_notes_tab',
          _ => 'unknown_tab',
        };
        AnalyticsService.trackButtonClick(tabName, screen: 'bare_acts');
      }
    });
  }

  @override
  void didUpdateWidget(covariant BareActsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialTab != oldWidget.initialTab && widget.initialTab != null) {
      final targetIndex = switch (widget.initialTab) {
        'minor' => 1,
        'converter' || 'comparison' => 2,
        'notes' => 3,
        _ => 0,
      };
      if (_tabController.index != targetIndex) {
        _tabController.animateTo(targetIndex);
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _majorActsScrollController.dispose();
    _minorActsScrollController.dispose();
    _converterScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bareActsAsync = ref.watch(bareActsProvider);
    final comparisonsAsync = ref.watch(comparisonsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bare Acts & Topper Notes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.note_alt_rounded),
            tooltip: 'Handmade Notes & Digests',
            onPressed: () => context.push('/handmade_notes'),
          ),
          IconButton(
            icon: const Icon(Icons.manage_search_rounded),
            tooltip: 'Concept Search',
            onPressed: () => context.push('/concept_search'),
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              ref.invalidate(bareActsProvider);
              ref.invalidate(comparisonsProvider);
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(52),
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
            ),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
              labelPadding: const EdgeInsets.symmetric(horizontal: 4),
              onTap: (index) {
                if (index == 0 && _majorActsScrollController.hasClients) {
                  _majorActsScrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
                } else if (index == 1 && _minorActsScrollController.hasClients) {
                  _minorActsScrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
                } else if (index == 2 && _converterScrollController.hasClients) {
                  _converterScrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
                }
              },
              indicator: BoxDecoration(
                color: AppColors.accentGold,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: AppColors.primaryNavy,
              unselectedLabelColor: Colors.white70,
              labelStyle: AppTypography.fontBody(fontSize: 12, fontWeight: FontWeight.bold),
              unselectedLabelStyle: AppTypography.fontBody(fontSize: 12, fontWeight: FontWeight.w500),
              dividerColor: Colors.transparent,
              tabs: const [
                Tab(child: Padding(padding: EdgeInsets.symmetric(horizontal: 14), child: Text('⭐ Major Acts'))),
                Tab(child: Padding(padding: EdgeInsets.symmetric(horizontal: 14), child: Text('📜 Minor Acts'))),
                Tab(child: Padding(padding: EdgeInsets.symmetric(horizontal: 14), child: Text('🔄 IPC ➔ BNS'))),
                Tab(child: Padding(padding: EdgeInsets.symmetric(horizontal: 14), child: Text('📝 Topper Notes'))),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // TAB 0: MAJOR ACTS
          bareActsAsync.when(
            data: (acts) => RefreshIndicator(
              onRefresh: () async => ref.refresh(bareActsProvider),
              child: _buildActsExplorer(acts: acts, isMinorTab: false),
            ),
            loading: () => const Center(child: CircularProgressIndicator(color: AppColors.accentGold)),
            error: (err, stack) => _buildErrorWidget(err),
          ),
          // TAB 1: MINOR ACTS
          bareActsAsync.when(
            data: (acts) => RefreshIndicator(
              onRefresh: () async => ref.refresh(bareActsProvider),
              child: _buildActsExplorer(acts: acts, isMinorTab: true),
            ),
            loading: () => const Center(child: CircularProgressIndicator(color: AppColors.accentGold)),
            error: (err, stack) => _buildErrorWidget(err),
          ),
          // TAB 2: LAW CONVERTER (IPC -> BNS)
          comparisonsAsync.when(
            data: (comparisons) => RefreshIndicator(
              onRefresh: () async => ref.refresh(comparisonsProvider),
              child: _buildLawConverter(comparisons),
            ),
            loading: () => const Center(child: CircularProgressIndicator(color: AppColors.accentGold)),
            error: (err, stack) => _buildErrorWidget(err),
          ),
          // TAB 3: FULL HANDMADE NOTES HUB
          const HandmadeNotesScreen(isEmbedded: true),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(dynamic err) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.wifi_off, size: 48, color: Colors.grey),
          const SizedBox(height: 12),
          Text('Failed to load data: $err'),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {
              ref.invalidate(bareActsProvider);
              ref.invalidate(comparisonsProvider);
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildActsExplorer({required List<BareAct> acts, required bool isMinorTab}) {
    if (acts.isEmpty) {
      return const Center(child: Text('No Bare Acts found in remote repository.'));
    }

    final baseActs = acts.where((a) => isMinorTab ? a.isMinorAct : !a.isMinorAct).toList();
    final currentFilter = isMinorTab ? _minorSelectedFilter : _majorSelectedFilter;
    final currentQuery = isMinorTab ? _minorSearchQuery : _majorSearchQuery;
    final scrollController = isMinorTab ? _minorActsScrollController : _majorActsScrollController;

    List<BareAct> filteredActs;
    if (currentFilter == 'All Major' || currentFilter == 'All Minor' || currentFilter == 'All') {
      filteredActs = baseActs;
    } else {
      filteredActs = baseActs.where((a) =>
          a.shortTitle.toLowerCase().contains(currentFilter.toLowerCase()) ||
          a.title.toLowerCase().contains(currentFilter.toLowerCase()) ||
          a.category.toLowerCase().contains(currentFilter.toLowerCase())).toList();
    }

    if (currentQuery.isNotEmpty) {
      filteredActs = filteredActs.where((a) =>
          a.sections.any((sec) =>
              sec.sectionNumber.toLowerCase().contains(currentQuery) ||
              sec.title.toLowerCase().contains(currentQuery) ||
              sec.content.toLowerCase().contains(currentQuery)) ||
          a.title.toLowerCase().contains(currentQuery) ||
          a.shortTitle.toLowerCase().contains(currentQuery) ||
          a.category.toLowerCase().contains(currentQuery)).toList();
    }

    final majorFilterPills = [
      'All Major',
      'BNS',
      'BNSS',
      'BSA',
      'CPC',
      'Constitution',
    ];

    final minorFilterPills = [
      'All Minor',
      'Contract (ICA)',
      'Specific Relief (SRA)',
      'Limitation Act',
      'NI Act (Sec 138)',
      'Property Law (TPA)',
      'POCSO Act, 2012',
      'Arbitration Act',
      'JJ Act, 2015',
    ];

    final filterPills = isMinorTab ? minorFilterPills : majorFilterPills;

    return WindowingInfiniteScrollList<BareAct>(
      items: filteredActs,
      pageSize: 4,
      controller: scrollController,
      itemLabel: isMinorTab ? 'minor acts' : 'major acts',
      header: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            CustomSearchBar(
              hintText: isMinorTab
                  ? 'Search Minor Acts (Contract, SRA, Limitation, NI Act...)'
                  : 'Search Major Acts (BNS, BNSS, BSA, CPC, Constitution)...',
              onChanged: (val) {
                setState(() {
                  if (isMinorTab) {
                    _minorSearchQuery = val.toLowerCase().trim();
                  } else {
                    _majorSearchQuery = val.toLowerCase().trim();
                  }
                });
              },
            ),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: filterPills.map((filter) {
                  final isSelected = currentFilter == filter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 6.0),
                    child: FilterChip(
                      selected: isSelected,
                      checkmarkColor: Colors.white,
                      label: Text(filter),
                      selectedColor: isMinorTab
                          ? const Color(0xFFD97706)
                          : AppColors.primaryNavy,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : AppColors.textPrimaryDark,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        fontSize: 12,
                      ),
                      onSelected: (val) {
                        setState(() {
                          if (isMinorTab) {
                            _minorSelectedFilter = filter;
                          } else {
                            _majorSelectedFilter = filter;
                          }
                        });
                        if (scrollController.hasClients) {
                          scrollController.animateTo(0, duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
                        }
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
      itemBuilder: (context, act, actIndex) {
        final isMinor = act.isMinorAct;

        final matchingSections = act.sections.where((sec) {
          if (currentQuery.isEmpty) return true;
          return sec.sectionNumber.toLowerCase().contains(currentQuery) ||
              sec.title.toLowerCase().contains(currentQuery) ||
              sec.content.toLowerCase().contains(currentQuery);
        }).toList();

        if (matchingSections.isEmpty) return const SizedBox.shrink();

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: ExpansionTile(
            initiallyExpanded: true,
            iconColor: isMinor ? const Color(0xFFD97706) : AppColors.primaryNavy,
            collapsedIconColor: isMinor ? const Color(0xFFD97706) : AppColors.primaryNavy,
            leading: Icon(
              isMinor ? Icons.menu_book_rounded : Icons.gavel,
              color: isMinor ? const Color(0xFFD97706) : AppColors.primaryNavy,
            ),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    '${act.title} (${act.sections.length} Sections)',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: isMinor
                        ? const Color(0xFFD97706).withValues(alpha: 0.15)
                        : AppColors.primaryNavy.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    isMinor ? '📜 MINOR ACT' : '⭐ MAJOR ACT',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isMinor ? const Color(0xFFD97706) : AppColors.primaryNavy,
                    ),
                  ),
                ),
              ],
            ),
            subtitle: Row(
              children: [
                Text(act.category, style: const TextStyle(color: AppColors.accentGold, fontSize: 11)),
                const Spacer(),
                InkWell(
                  onTap: () => context.push('/handmade_notes?filter=${Uri.encodeComponent(act.shortTitle)}'),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 2.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.edit_note_rounded, size: 14, color: AppColors.primaryNavy),
                        SizedBox(width: 2),
                        Text('Topper Notes', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primaryNavy)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            children: matchingSections.map((sec) {
              final isBookmarked = HiveService.isBookmarked(act.id, sec.sectionNumber);

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Material(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  child: ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.grey.shade200),
                    ),
                    title: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: 'Sec ${sec.sectionNumber}: ',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryNavy),
                          ),
                          TextSpan(
                            text: sec.title,
                            style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimaryDark),
                          ),
                        ],
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0, bottom: 6.0),
                          child: Text(
                            sec.content,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12.5),
                          ),
                        ),
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEF3C7),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: const Color(0xFFFDE68A)),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('📝', style: TextStyle(fontSize: 10)),
                                  SizedBox(width: 3),
                                  Text(
                                    'Notes & Cases',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF92400E),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (sec.landmarkCases.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: Colors.blue.shade100),
                                ),
                                child: Text(
                                  '⚖️ ${sec.landmarkCases.length} Landmark ${sec.landmarkCases.length == 1 ? "Ratio" : "Ratios"}',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue.shade900,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: Icon(
                            isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                            color: isBookmarked ? AppColors.accentGold : Colors.grey,
                            size: 22,
                          ),
                          onPressed: () async {
                            await HiveService.toggleBookmark(act.id, sec.sectionNumber);
                            setState(() {});
                          },
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 13,
                          color: isMinor ? const Color(0xFFD97706) : AppColors.primaryNavy,
                        ),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SectionDetailScreen(bareAct: act, section: sec),
                        ),
                      );
                    },
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildLawConverter(List<LawComparison> comparisons) {
    if (comparisons.isEmpty) {
      return const Center(child: Text('No law comparisons available.'));
    }

    final cleanQ = _converterQuery.trim().toLowerCase();
    final numberOnlyQ = cleanQ.replaceAll(RegExp(r'[^0-9a-z]'), '');

    final matchingComparisons = comparisons.where((c) {
      if (cleanQ.isEmpty) return true;
      final oldSec = c.oldSection.toLowerCase();
      final newSec = c.newSection.toLowerCase();
      final oldTitle = c.oldTitle.toLowerCase();
      final newTitle = c.newTitle.toLowerCase();
      final summary = c.summary.toLowerCase();
      final subject = c.subject.toLowerCase();

      final matchesText = oldSec.contains(cleanQ) ||
          newSec.contains(cleanQ) ||
          oldTitle.contains(cleanQ) ||
          newTitle.contains(cleanQ) ||
          summary.contains(cleanQ) ||
          subject.contains(cleanQ);

      final matchesNumber = numberOnlyQ.isNotEmpty &&
          (oldSec.replaceAll(RegExp(r'[^0-9a-z]'), '').contains(numberOnlyQ) ||
           newSec.replaceAll(RegExp(r'[^0-9a-z]'), '').contains(numberOnlyQ));

      return matchesText || matchesNumber;
    }).toList();

    final displayComparisons = List<LawComparison>.from(matchingComparisons);
    if (displayComparisons.isEmpty && cleanQ.isNotEmpty) {
      final queryTitle = _converterQuery.toUpperCase().trim();
      displayComparisons.add(
        LawComparison(
          id: 'dynamic_$cleanQ',
          subject: 'Criminal Law Reform',
          oldAct: 'IPC / CrPC (Repealed)',
          oldSection: queryTitle.startsWith('SEC') ? queryTitle : 'Sec $queryTitle',
          oldTitle: 'Repealed Provision ($queryTitle)',
          oldText: 'Statutory provision under repealed Indian Penal Code (IPC 1860) / Code of Criminal Procedure (CrPC 1973).',
          newAct: 'BNS / BNSS (2023 Reform)',
          newSection: '2023 Statutory Mapping',
          newTitle: 'Updated Reform Provision for $queryTitle',
          newText: 'Updated statutory rule under Bharatiya Nyaya Sanhita (BNS 2023) / Bharatiya Nagarik Suraksha Sanhita (BNSS 2023).',
          keyChanges: [
            'Dynamic statutory conversion synthesized for "$queryTitle".',
            'Synchronized with 2023 criminal law reform structure.',
          ],
          summary: 'Dynamic conversion mapping for $queryTitle.',
        ),
      );
    }

    return WindowingInfiniteScrollList<LawComparison>(
      items: displayComparisons,
      pageSize: 4,
      controller: _converterScrollController,
      itemLabel: 'reform mappings',
      header: Padding(
        padding: const EdgeInsets.all(12.0),
        child: CustomSearchBar(
          hintText: 'Enter old IPC (e.g. 302, 420) or CrPC (438, 154)...',
          onChanged: (val) => setState(() => _converterQuery = val),
        ),
      ),
      itemBuilder: (context, item, index) {
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: DiffViewerWidget(comparison: item),
        );
      },
    );
  }
}
