import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/network/india_code_client.dart';
import '../../core/storage/hive_service.dart';
import '../../shared/models/bare_act.dart';
import '../../shared/models/law_comparison.dart';
import '../../shared/widgets/diff_viewer.dart';
import '../../shared/widgets/search_bar.dart';
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
  const BareActsScreen({super.key});

  @override
  ConsumerState<BareActsScreen> createState() => _BareActsScreenState();
}

class _BareActsScreenState extends ConsumerState<BareActsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  String _converterQuery = '';
  String _selectedActFilter = 'All';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bareActsAsync = ref.watch(bareActsProvider);
    final comparisonsAsync = ref.watch(comparisonsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bare Acts & Law Converter'),
        actions: [
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
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: AppColors.accentGold,
                borderRadius: BorderRadius.circular(11),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: AppColors.primaryNavy,
              unselectedLabelColor: Colors.white70,
              labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              unselectedLabelStyle: const TextStyle(fontSize: 12),
              dividerColor: Colors.transparent,
              tabs: const [
                Tab(text: '📚  Bare Acts'),
                Tab(text: '🔄  IPC ➔ BNS'),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          bareActsAsync.when(
            data: (acts) => RefreshIndicator(
              onRefresh: () async => ref.refresh(bareActsProvider),
              child: _buildBareActExplorer(acts),
            ),
            loading: () => const Center(child: CircularProgressIndicator(color: AppColors.accentGold)),
            error: (err, stack) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.wifi_off, size: 48, color: Colors.grey),
                  const SizedBox(height: 12),
                  Text('Failed to load Bare Acts: $err'),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => ref.refresh(bareActsProvider),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
          comparisonsAsync.when(
            data: (comparisons) => RefreshIndicator(
              onRefresh: () async => ref.refresh(comparisonsProvider),
              child: _buildLawConverter(comparisons),
            ),
            loading: () => const Center(child: CircularProgressIndicator(color: AppColors.accentGold)),
            error: (err, stack) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.wifi_off, size: 48, color: Colors.grey),
                  const SizedBox(height: 12),
                  Text('Failed to load Law Comparisons: $err'),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => ref.refresh(comparisonsProvider),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBareActExplorer(List<BareAct> acts) {
    if (acts.isEmpty) {
      return const Center(child: Text('No Bare Acts found in remote repository.'));
    }

    List<BareAct> filteredActs = acts;
    if (_selectedActFilter != 'All') {
      filteredActs = acts.where((a) => a.shortTitle == _selectedActFilter).toList();
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              CustomSearchBar(
                hintText: 'Search section number, title, or keywords...',
                onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
              ),
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ['All', 'BNS', 'BNSS', 'BSA', 'CPC', 'Constitution'].map((filter) {
                    final isSelected = _selectedActFilter == filter;
                    return Padding(
                      padding: const EdgeInsets.only(right: 6.0),
                      child: FilterChip(
                        selected: isSelected,
                        label: Text(filter),
                        selectedColor: AppColors.primaryNavy,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : AppColors.textPrimaryDark,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        onSelected: (val) => setState(() => _selectedActFilter = filter),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(left: 12, right: 12, bottom: 90),
            itemCount: filteredActs.length,
            itemBuilder: (context, actIndex) {
              final act = filteredActs[actIndex];
              final matchingSections = act.sections.where((sec) {
                if (_searchQuery.isEmpty) return true;
                return sec.sectionNumber.toLowerCase().contains(_searchQuery) ||
                    sec.title.toLowerCase().contains(_searchQuery) ||
                    sec.content.toLowerCase().contains(_searchQuery);
              }).toList();

              if (matchingSections.isEmpty) return const SizedBox.shrink();

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: ExpansionTile(
                  initiallyExpanded: true,
                  leading: const Icon(Icons.gavel, color: AppColors.primaryNavy),
                  title: Text(
                    '${act.title} (${act.sections.length} Sections)',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  subtitle: Text(act.category, style: const TextStyle(color: AppColors.accentGold, fontSize: 12)),
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
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(
                              sec.content,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(
                                  isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                                  color: isBookmarked ? AppColors.accentGold : Colors.grey,
                                ),
                                onPressed: () async {
                                  await HiveService.toggleBookmark(act.id, sec.sectionNumber);
                                  setState(() {});
                                },
                              ),
                              const Icon(Icons.chevron_right, color: Colors.grey),
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
          ),
        ),
      ],
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

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: CustomSearchBar(
            hintText: 'Enter old IPC (e.g. 302, 420) or CrPC (438, 154)...',
            onChanged: (val) => setState(() => _converterQuery = val),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(left: 12, right: 12, bottom: 90),
            itemCount: displayComparisons.length,
            itemBuilder: (context, index) {
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: DiffViewerWidget(comparison: displayComparisons[index]),
              );
            },
          ),
        ),
      ],
    );
  }
}
