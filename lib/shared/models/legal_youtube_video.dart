class LegalYouTubeVideo {
  final String videoId;
  final String title;
  final String channelName;
  final String duration;
  final String description;

  const LegalYouTubeVideo({
    required this.videoId,
    required this.title,
    required this.channelName,
    required this.duration,
    required this.description,
  });

  String get thumbnailUrl => 'https://img.youtube.com/vi/$videoId/hqdefault.jpg';
  String get videoUrl => 'https://www.youtube.com/watch?v=$videoId';
  String get embedUrl => 'https://www.youtube-nocookie.com/embed/$videoId?autoplay=1&playsinline=1&rel=0';
}
