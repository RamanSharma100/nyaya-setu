import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../core/constants/app_colors.dart';

class WebPreviewScreen extends StatefulWidget {
  final String initialUrl;
  final String title;

  const WebPreviewScreen({
    super.key,
    required this.initialUrl,
    this.title = 'In-App Web Article Reader',
  });

  @override
  State<WebPreviewScreen> createState() => _WebPreviewScreenState();
}

class _WebPreviewScreenState extends State<WebPreviewScreen> {
  WebViewController? _controller;
  int _loadingProgress = 0;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _initWebView();
  }

  void _initWebView() {
    final cleanUrl = widget.initialUrl.trim().isEmpty ? 'https://news.google.com' : widget.initialUrl.trim();
    try {
      final controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(Colors.white)
        ..setNavigationDelegate(
          NavigationDelegate(
            onProgress: (int progress) {
              if (mounted) setState(() => _loadingProgress = progress);
            },
            onPageStarted: (String url) {
              if (mounted) {
                setState(() {
                  _loadingProgress = 10;
                  _hasError = false;
                });
              }
            },
            onPageFinished: (String url) {
              if (mounted) setState(() => _loadingProgress = 100);
            },
            onWebResourceError: (WebResourceError error) {
              if (error.isForMainFrame ?? false) {
                if (mounted) {
                  setState(() {
                    _hasError = true;
                    _errorMessage = error.description;
                  });
                }
              }
            },
          ),
        )
        ..loadRequest(Uri.parse(cleanUrl));

      _controller = controller;
    } catch (e) {
      _hasError = true;
      _errorMessage = e.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    final cleanUrl = widget.initialUrl.trim().isEmpty ? 'https://news.google.com' : widget.initialUrl.trim();

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              cleanUrl,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(fontSize: 11, color: Colors.white70),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Reload Page',
            onPressed: () {
              if (_controller != null) {
                _controller!.reload();
              } else {
                _initWebView();
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.open_in_browser),
            tooltip: 'Open in System Browser',
            onPressed: () async {
              final uri = Uri.parse(cleanUrl);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (_loadingProgress < 100 && !_hasError)
            LinearProgressIndicator(
              value: _loadingProgress / 100.0,
              backgroundColor: Colors.grey.shade200,
              color: AppColors.accentGold,
              minHeight: 3,
            ),
          Expanded(
            child: _hasError
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.public_off, size: 56, color: Colors.grey),
                          const SizedBox(height: 16),
                          Text(
                            'Unable to load web preview',
                            style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryNavy),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _errorMessage.isNotEmpty ? _errorMessage : 'Web server blocked preview or link unavailable.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(fontSize: 13, color: Colors.grey.shade700),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            onPressed: () async {
                              final uri = Uri.parse(cleanUrl);
                              if (await canLaunchUrl(uri)) {
                                await launchUrl(uri, mode: LaunchMode.externalApplication);
                              }
                            },
                            icon: const Icon(Icons.open_in_browser),
                            label: const Text('Open External Browser'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryNavy,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : _controller != null
                    ? WebViewWidget(controller: _controller!)
                    : const Center(child: CircularProgressIndicator(color: AppColors.accentGold)),
          ),
        ],
      ),
    );
  }
}
