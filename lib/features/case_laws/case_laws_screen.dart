import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/network/indian_kanoon_client.dart';
import '../../core/network/legal_news_rss_client.dart';
import '../../core/utils/youtube_helper.dart';
import '../../shared/models/case_law.dart';
import '../../shared/widgets/search_bar.dart';
import '../../shared/widgets/web_preview_screen.dart';
import '../../shared/widgets/youtube_video_card.dart';

final indianKanoonClientProvider = Provider((ref) => IndianKanoonApiClient());
final legalNewsRssClientProvider = Provider((ref) => LegalNewsRssClient());

final landmarkCasesProvider = FutureProvider<List<CaseLaw>>((ref) async {
  final client = ref.read(indianKanoonClientProvider);
  return client.searchJudgments('');
});

final legalNewsProvider = FutureProvider<List<LegalNewsItem>>((ref) async {
  final client = ref.read(legalNewsRssClientProvider);
  return client.fetchLiveLawNews();
});

class CaseLawsScreen extends ConsumerStatefulWidget {
  const CaseLawsScreen({super.key});

  @override
  ConsumerState<CaseLawsScreen> createState() => _CaseLawsScreenState();
}

class _CaseLawsScreenState extends ConsumerState<CaseLawsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';

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
    final landmarkCasesAsync = ref.watch(landmarkCasesProvider);
    final legalNewsAsync = ref.watch(legalNewsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Landmark Judgments & Video Digests'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(landmarkCasesProvider);
              ref.invalidate(legalNewsProvider);
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
              labelStyle: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
              unselectedLabelStyle: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              dividerColor: Colors.transparent,
              tabs: const [
                Tab(text: '⚖️  Landmark SC Cases'),
                Tab(text: '📰  Live Legal Feed'),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          landmarkCasesAsync.when(
            data: (cases) => RefreshIndicator(
              onRefresh: () async => ref.refresh(landmarkCasesProvider),
              child: _buildLandmarkCasesTab(cases),
            ),
            loading: () => const Center(child: CircularProgressIndicator(color: AppColors.accentGold)),
            error: (err, stack) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.wifi_off, size: 48, color: Colors.grey),
                  const SizedBox(height: 12),
                  Text('Failed to connect to Indian Kanoon: $err'),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => ref.refresh(landmarkCasesProvider),
                    child: const Text('Retry Fetching Kanoon API'),
                  ),
                ],
              ),
            ),
          ),
          legalNewsAsync.when(
            data: (newsItems) => RefreshIndicator(
              onRefresh: () async => ref.refresh(legalNewsProvider),
              child: _buildLiveNewsTab(newsItems),
            ),
            loading: () => const Center(child: CircularProgressIndicator(color: AppColors.accentGold)),
            error: (err, stack) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.rss_feed, size: 48, color: Colors.grey),
                  const SizedBox(height: 12),
                  Text('Failed to load Legal RSS Feed: $err'),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => ref.refresh(legalNewsProvider),
                    child: const Text('Retry RSS Feed'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLandmarkCasesTab(List<CaseLaw> cases) {
    final filteredCases = cases.where((c) {
      if (_searchQuery.isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      return c.title.toLowerCase().contains(q) ||
          c.citation.toLowerCase().contains(q) ||
          c.ratioDecidendi.toLowerCase().contains(q) ||
          c.subject.toLowerCase().contains(q);
    }).toList();

    filteredCases.sort((a, b) => b.year.compareTo(a.year));

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: CustomSearchBar(
            hintText: 'Search case name, citation, bench, or ratio...',
            onChanged: (val) => setState(() => _searchQuery = val),
          ),
        ),
        Expanded(
          child: filteredCases.isEmpty
              ? const Center(child: Text('No matching cases found.'))
              : ListView.builder(
                  padding: const EdgeInsets.only(left: 12, right: 12, bottom: 90),
                  itemCount: filteredCases.length,
                  itemBuilder: (context, index) {
                    final item = filteredCases[index];
                    final video = YouTubeHelper.getMatchingVideo('${item.title} ${item.citation}');

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: ExpansionTile(
                        leading: const CircleAvatar(
                          backgroundColor: AppColors.primaryNavy,
                          child: Icon(Icons.balance, color: AppColors.accentGold, size: 20),
                        ),
                        title: Text(
                          item.title,
                          style: AppTypography.fontHeading(fontWeight: FontWeight.w700, fontSize: 16),
                        ),
                        subtitle: Text('${item.citation} (${item.year}) • ${item.subject}', style: GoogleFonts.inter(fontSize: 12)),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.groups, color: AppColors.accentGold, size: 18),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text('Bench: ${item.bench}', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13)),
                                    ),
                                  ],
                                ),
                                const Divider(),

                                // YouTube Video Digest for Case Law
                                Text('Case Video Breakdown:', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: AppColors.primaryNavy)),
                                const SizedBox(height: 6),
                                YouTubeVideoCard(
                                  video: video,
                                  searchQuery: '${item.title} ${item.citation}',
                                  compactLabel: 'CASE DIGEST VIDEO',
                                ),
                                const SizedBox(height: 12),

                                Text('Ratio Decidendi:', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: AppColors.primaryNavy)),
                                const SizedBox(height: 4),
                                Text(item.ratioDecidendi, style: AppTypography.fontStatute(fontSize: 14, height: 1.6, color: const Color(0xFF1E293B))),
                                const SizedBox(height: 12),
                                Text('Holding & Facts:', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: AppColors.primaryNavy)),
                                const SizedBox(height: 4),
                                Text(item.holding, style: GoogleFonts.inter(fontSize: 13, color: AppColors.textMutedDark)),
                                if (item.whatHappened.isNotEmpty) ...[
                                  const SizedBox(height: 12),
                                  Text('What Happened & Case History:', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: AppColors.primaryNavy)),
                                  const SizedBox(height: 4),
                                  Text(item.whatHappened, style: GoogleFonts.inter(fontSize: 13, height: 1.4, color: AppColors.textPrimaryDark)),
                                ],
                                if (item.currentStatus.isNotEmpty) ...[
                                  const SizedBox(height: 12),
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.blue.shade200)),
                                    child: Text(
                                      'Current Standing: ${item.currentStatus}',
                                      style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryNavy),
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(color: Colors.amber.shade50, borderRadius: BorderRadius.circular(8)),
                                  child: Text(
                                    'Exam Significance: ${item.examSignificance}',
                                    style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryNavy),
                                  ),
                                ),
                                const SizedBox(height: 14),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => WebPreviewScreen(
                                            initialUrl: item.docUrl,
                                            title: item.title,
                                          ),
                                        ),
                                      );
                                    },
                                    icon: const Icon(Icons.open_in_browser),
                                    label: const Text('Read Full Judgment & Case Files'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primaryNavy,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildLiveNewsTab(List<LegalNewsItem> news) {
    if (news.isEmpty) {
      return const Center(child: Text('No legal news articles available.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.only(left: 12, right: 12, top: 12, bottom: 90),
      itemCount: news.length,
      itemBuilder: (context, index) {
        final item = news[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => _openNewsDetailModal(context, item),
              child: Padding(
                padding: const EdgeInsets.all(14.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(color: AppColors.emeraldGreen, borderRadius: BorderRadius.circular(8)),
                          child: Text('LIVE LEGAL RSS', style: GoogleFonts.inter(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                        Text(item.pubDate, style: GoogleFonts.inter(color: Colors.grey, fontSize: 11)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(item.title, style: AppTypography.fontHeading(fontSize: 15, fontWeight: FontWeight.w700, height: 1.3)),
                    const SizedBox(height: 6),
                    Text(item.description, maxLines: 3, overflow: TextOverflow.ellipsis, style: GoogleFonts.inter(fontSize: 13, color: AppColors.textMutedDark)),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text('Read Full Coverage', style: GoogleFonts.inter(color: AppColors.primaryNavy, fontSize: 11, fontWeight: FontWeight.bold)),
                        const Icon(Icons.chevron_right, size: 16, color: AppColors.primaryNavy),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _openNewsDetailModal(BuildContext context, LegalNewsItem news) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (modalContext) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          maxChildSize: 0.9,
          minChildSize: 0.4,
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
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: AppColors.emeraldGreen, borderRadius: BorderRadius.circular(10)),
                        child: Text('LIVE LEGAL RSS', style: GoogleFonts.inter(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(modalContext),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(news.title, style: AppTypography.fontHeading(fontSize: 19, fontWeight: FontWeight.w700, color: AppColors.primaryNavy)),
                  const SizedBox(height: 4),
                  Text('Published: ${news.pubDate}', style: GoogleFonts.inter(fontSize: 12, color: Colors.grey.shade600)),
                  const Divider(height: 24),
                  Text('Legal News Summary:', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: AppColors.primaryNavy)),
                  const SizedBox(height: 8),
                  Text(news.description, style: GoogleFonts.inter(fontSize: 14, height: 1.6)),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.blue.shade200)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.school, color: AppColors.primaryNavy, size: 18),
                            const SizedBox(width: 6),
                            Text('PCS-J Judicial Relevance', style: AppTypography.fontHeading(fontWeight: FontWeight.w700, color: AppColors.primaryNavy)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Track recent Supreme Court notifications, statutory amendments, and High Court administrative decisions for Mains essay & interview rounds.',
                          style: GoogleFonts.inter(fontSize: 12, height: 1.4),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(modalContext);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => WebPreviewScreen(
                              initialUrl: news.link,
                              title: news.title,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.open_in_browser),
                      label: const Text('Read Full Article in App'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accentGold,
                        foregroundColor: AppColors.primaryNavy,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Copied source link: ${news.link}')),
                            );
                          },
                          icon: const Icon(Icons.link, size: 16),
                          label: const Text('Copy Link'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => Navigator.pop(modalContext),
                          icon: const Icon(Icons.check_circle),
                          label: const Text('Mark Read'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryNavy,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
