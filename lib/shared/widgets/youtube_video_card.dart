import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/youtube_helper.dart';
import 'youtube_player_modal.dart';

class YouTubeVideoCard extends StatefulWidget {
  final LegalYouTubeVideo? video;
  final String? searchQuery;
  final String? compactLabel;
  final VoidCallback? onTap;

  const YouTubeVideoCard({
    super.key,
    this.video,
    this.searchQuery,
    this.compactLabel,
    this.onTap,
  }) : assert(video != null || searchQuery != null, 'Either video or searchQuery must be provided');

  @override
  State<YouTubeVideoCard> createState() => _YouTubeVideoCardState();
}

class _YouTubeVideoCardState extends State<YouTubeVideoCard> {
  late LegalYouTubeVideo _video;

  @override
  void initState() {
    super.initState();
    _initVideo();
    _loadDynamic();
  }

  @override
  void didUpdateWidget(covariant YouTubeVideoCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.video != oldWidget.video || widget.searchQuery != oldWidget.searchQuery) {
      _initVideo();
      _loadDynamic();
    }
  }

  void _initVideo() {
    if (widget.video != null) {
      _video = widget.video!;
    } else if (widget.searchQuery != null) {
      _video = YouTubeHelper.getMatchingVideo(widget.searchQuery!);
    } else {
      _video = YouTubeHelper.getMatchingVideo('law');
    }
  }

  void _loadDynamic() {
    final query = widget.searchQuery;
    if (query != null && query.trim().isNotEmpty) {
      YouTubeHelper.fetchVideoDynamically(query).then((dynamicVideo) {
        if (mounted && dynamicVideo.videoId != _video.videoId) {
          setState(() {
            _video = dynamicVideo;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final video = _video;
    final compactLabel = widget.compactLabel;
    final onTap = widget.onTap;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Stack(
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.network(
                    video.thumbnailUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: AppColors.primaryNavy,
                        child: Center(
                          child: Icon(
                            Icons.play_circle_fill,
                            size: 54,
                            color: AppColors.accentGold.withValues(alpha: 0.8),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withValues(alpha: 0.4),
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.6),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Center(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          if (onTap != null) {
                            onTap!();
                          } else {
                            YouTubePlayerModal.show(context, video);
                          }
                        },
                        customBorder: const CircleBorder(),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.shade600.withValues(alpha: 0.9),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.3),
                                blurRadius: 12,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 34,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryNavy.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.accentGold.withValues(alpha: 0.6)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.ondemand_video, color: AppColors.accentGold, size: 13),
                        const SizedBox(width: 4),
                        Text(
                          compactLabel ?? 'YOUTUBE TUTORIAL',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      video.duration,
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () {
                    if (onTap != null) {
                      onTap!();
                    } else {
                      YouTubePlayerModal.show(context, video);
                    }
                  },
                  child: Text(
                    video.title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryNavy,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.account_circle, size: 14, color: AppColors.textMutedDark),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        video.channelName,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.textMutedDark,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        if (onTap != null) {
                          onTap!();
                        } else {
                          YouTubePlayerModal.show(context, video);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.accentGold.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.accentGold.withValues(alpha: 0.4),
                            width: 0.8,
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.play_circle_fill_rounded,
                              size: 13,
                              color: AppColors.accentGold,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Watch in App',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.accentGold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
