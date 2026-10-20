import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_colors.dart';

/// A high-performance windowing and infinite scroll widget for live API feeds.
/// 
/// Virtualizes large datasets into progressive windows, automatically loads the
/// next window when scrolling near the bottom, and provides a visible window status
/// indicator as well as an interactive load-more trigger.
class WindowingInfiniteScrollList<T> extends StatefulWidget {
  final List<T> items;
  final int pageSize;
  final ScrollController controller;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final EdgeInsetsGeometry padding;
  final Widget? header;
  final Widget? emptyWidget;
  final String itemLabel;
  final Future<void> Function()? onRefresh;
  final Future<void> Function()? onLoadMore;
  final bool showWindowBadge;

  const WindowingInfiniteScrollList({
    super.key,
    required this.items,
    required this.controller,
    required this.itemBuilder,
    this.pageSize = 4,
    this.padding = const EdgeInsets.only(left: 12, right: 12, bottom: 90),
    this.header,
    this.emptyWidget,
    this.itemLabel = 'records',
    this.onRefresh,
    this.onLoadMore,
    this.showWindowBadge = true,
  });

  @override
  State<WindowingInfiniteScrollList<T>> createState() => _WindowingInfiniteScrollListState<T>();
}

class _WindowingInfiniteScrollListState<T> extends State<WindowingInfiniteScrollList<T>> {
  late int _visibleCount;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _visibleCount = min(widget.pageSize, widget.items.length);
    widget.controller.addListener(_scrollListener);
  }

  @override
  void didUpdateWidget(covariant WindowingInfiniteScrollList<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items != widget.items) {
      setState(() {
        _visibleCount = min(widget.pageSize, widget.items.length);
        _isLoadingMore = false;
      });
    }
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_scrollListener);
      widget.controller.addListener(_scrollListener);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_scrollListener);
    super.dispose();
  }

  void _scrollListener() {
    if (!widget.controller.hasClients) return;
    final maxScroll = widget.controller.position.maxScrollExtent;
    final currentScroll = widget.controller.position.pixels;

    if (currentScroll >= maxScroll - 300 && !_isLoadingMore) {
      _triggerLoadMore();
    }
  }

  Future<void> _triggerLoadMore() async {
    if (_isLoadingMore) return;

    if (_visibleCount < widget.items.length) {
      setState(() => _isLoadingMore = true);
      await Future.delayed(const Duration(milliseconds: 280));
      if (!mounted) return;
      setState(() {
        _visibleCount = min(_visibleCount + widget.pageSize, widget.items.length);
        _isLoadingMore = false;
      });
    } else if (widget.onLoadMore != null) {
      setState(() => _isLoadingMore = true);
      try {
        await widget.onLoadMore!();
      } finally {
        if (mounted) {
          setState(() {
            _visibleCount = min(_visibleCount + widget.pageSize, widget.items.length);
            _isLoadingMore = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) {
      return Column(
        children: [
          if (widget.header != null) widget.header!,
          Expanded(
            child: widget.emptyWidget ??
                Center(
                  child: Text(
                    'No ${widget.itemLabel} available.',
                    style: GoogleFonts.inter(color: Colors.grey),
                  ),
                ),
          ),
        ],
      );
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final totalCount = widget.items.length;
    final hasReachedEnd = _visibleCount >= totalCount;

    Widget listView = NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollUpdateNotification ||
            notification is OverscrollNotification ||
            notification is ScrollEndNotification) {
          final metrics = notification.metrics;
          if (metrics.pixels >= metrics.maxScrollExtent - 300 && !_isLoadingMore) {
            _triggerLoadMore();
          }
        }
        return false;
      },
      child: ListView.builder(
        controller: widget.controller,
        physics: const AlwaysScrollableScrollPhysics(parent: ClampingScrollPhysics()),
        padding: widget.padding,
        itemCount: _visibleCount + 2, // 1 for top window badge, 1 for bottom load indicator
        itemBuilder: (context, index) {
          // Item 0: Windowing Status Badge
          if (index == 0) {
            if (!widget.showWindowBadge) return const SizedBox.shrink();
            return Container(
              margin: const EdgeInsets.only(bottom: 12, top: 4),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.emeraldGreen,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Live Window: $_visibleCount of $totalCount ${widget.itemLabel}',
                        style: GoogleFonts.inter(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white70 : AppColors.textPrimaryDark,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.accentGold.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.all_inclusive_rounded, size: 12, color: AppColors.accentGold),
                        const SizedBox(width: 4),
                        Text(
                          hasReachedEnd ? 'All Loaded' : 'Infinite Scroll',
                          style: GoogleFonts.inter(
                            fontSize: 9.5,
                            fontWeight: FontWeight.bold,
                            color: AppColors.accentGold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }

          // Bottom Loader / End-of-List Indicator
          if (index == _visibleCount + 1) {
            if (_isLoadingMore) {
              return Container(
                padding: const EdgeInsets.symmetric(vertical: 20),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        valueColor: AlwaysStoppedAnimation(AppColors.accentGold),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Loading next live window of ${widget.itemLabel}...',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white60 : Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              );
            }

            if (!hasReachedEnd) {
              final remaining = totalCount - _visibleCount;
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 14),
                child: Material(
                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    onTap: _triggerLoadMore,
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.arrow_downward_rounded, size: 16, color: AppColors.accentGold),
                          const SizedBox(width: 8),
                          Text(
                            'Load More ($remaining remaining) • Scroll down to auto-load',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white70 : AppColors.primaryNavy,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }

            if (hasReachedEnd && totalCount > widget.pageSize) {
              return Container(
                padding: const EdgeInsets.symmetric(vertical: 18),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check_circle_outline_rounded, size: 15, color: AppColors.emeraldGreen),
                    const SizedBox(width: 6),
                    Text(
                      'All $totalCount ${widget.itemLabel} loaded • 100% Up to date',
                      style: GoogleFonts.inter(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white38 : Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              );
            }

            return const SizedBox.shrink();
          }

          // Actual Item (index - 1 because index 0 is the top badge)
          final itemIndex = index - 1;
          return widget.itemBuilder(context, widget.items[itemIndex], itemIndex);
        },
      ),
    );

    if (widget.onRefresh != null) {
      listView = RefreshIndicator(
        onRefresh: widget.onRefresh!,
        child: listView,
      );
    }

    return Column(
      children: [
        if (widget.header != null) widget.header!,
        Expanded(child: listView),
      ],
    );
  }
}
