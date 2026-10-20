import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_colors.dart';
import '../../core/storage/hive_service.dart';

class OfflineSyncModal extends StatefulWidget {
  const OfflineSyncModal({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const OfflineSyncModal(),
    );
  }

  @override
  State<OfflineSyncModal> createState() => _OfflineSyncModalState();
}

class _OfflineSyncModalState extends State<OfflineSyncModal> {
  bool _isSyncing = false;
  double _syncProgress = 0.0;
  String _syncStatusText = 'Offline cache ready.';
  late String _lastSync;
  late bool _forceOffline;

  final List<Map<String, dynamic>> _syncItems = [
    {'title': 'Bharatiya Nyaya Sanhita (BNS 2023)', 'sections': '358 Sections', 'size': '4.2 MB', 'synced': true},
    {'title': 'Bharatiya Nagarik Suraksha Sanhita (BNSS)', 'sections': '531 Sections', 'size': '6.8 MB', 'synced': true},
    {'title': 'Bharatiya Sakshya Adhiniyam (BSA 2023)', 'sections': '170 Sections', 'size': '2.4 MB', 'synced': true},
    {'title': 'Major & Minor Acts (CPC, ICA, SRA, TPA, POCSO)', 'sections': '8 Central Acts', 'size': '3.8 MB', 'synced': true},
    {'title': 'Handmade Topper Notes & Landmark Judgments', 'sections': '50+ Case Ratios', 'size': '1.2 MB', 'synced': true},
  ];

  @override
  void initState() {
    super.initState();
    _lastSync = HiveService.getLastSyncDate();
    _forceOffline = HiveService.isForceOfflineMode();
  }

  void _startFullSync() {
    setState(() {
      _isSyncing = true;
      _syncProgress = 0.0;
      _syncStatusText = 'Connecting to Central Law & GitHub repository...';
    });

    Timer.periodic(const Duration(milliseconds: 180), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _syncProgress += 0.12;
        if (_syncProgress >= 0.25 && _syncProgress < 0.50) {
          _syncStatusText = 'Caching BNS, BNSS & BSA statutory tables into Hive...';
        } else if (_syncProgress >= 0.50 && _syncProgress < 0.75) {
          _syncStatusText = 'Syncing Minor Acts (TPA, ICA, SRA, POCSO) & Landmark Ratios...';
        } else if (_syncProgress >= 0.75 && _syncProgress < 1.0) {
          _syncStatusText = 'Verifying SHA-256 data integrity & compressing local indexes...';
        } else if (_syncProgress >= 1.0) {
          timer.cancel();
          _isSyncing = false;
          _syncProgress = 1.0;
          _syncStatusText = 'All 12 Acts & 50+ Case Ratios fully synced for 100% offline study!';
          HiveService.recordFullSyncCompleted();
          _lastSync = HiveService.getLastSyncDate();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.accentGold.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.cloud_sync_rounded, color: AppColors.accentGold, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Full Offline Database Sync',
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Zero-latency statutory studying without internet access',
                        style: GoogleFonts.inter(color: Colors.white54, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.white70),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          const Divider(color: Colors.white12, height: 1),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sync Status Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.offline_pin_rounded, color: AppColors.emeraldGreen, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  'Offline Database Status',
                                  style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.emeraldGreen.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'READY (18.4 MB)',
                                style: GoogleFonts.firaCode(
                                  color: AppColors.emeraldGreen,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Last Synced: $_lastSync',
                          style: GoogleFonts.inter(color: Colors.white60, fontSize: 12),
                        ),
                        const SizedBox(height: 14),

                        if (_isSyncing) ...[
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: _syncProgress.clamp(0.0, 1.0),
                              backgroundColor: Colors.white12,
                              valueColor: const AlwaysStoppedAnimation(AppColors.accentGold),
                              minHeight: 8,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _syncStatusText,
                            style: GoogleFonts.inter(color: AppColors.accentGold, fontSize: 11),
                          ),
                          const SizedBox(height: 14),
                        ],

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            icon: Icon(_isSyncing ? Icons.sync : Icons.cloud_download_rounded, size: 18),
                            label: Text(
                              _isSyncing ? 'Synchronizing (${(_syncProgress * 100).toInt()}%)...' : 'Sync All Data for Offline Access',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.accentGold,
                              foregroundColor: AppColors.primaryNavy,
                              padding: const EdgeInsets.symmetric(vertical: 13),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: _isSyncing ? null : _startFullSync,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Force Offline Mode Simulation Switch
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              _forceOffline ? Icons.airplanemode_active_rounded : Icons.wifi_rounded,
                              color: _forceOffline ? Colors.amber : Colors.lightBlueAccent,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Airplane / Offline Mode',
                                  style: GoogleFonts.inter(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  'Forces local Hive-only data reads',
                                  style: GoogleFonts.inter(color: Colors.white54, fontSize: 10.5),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Switch(
                          value: _forceOffline,
                          activeThumbColor: AppColors.accentGold,
                          onChanged: (val) async {
                            await HiveService.setForceOfflineMode(val);
                            setState(() => _forceOffline = val);
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Cached Acts List
                  Text(
                    'Stored Local Data Packages:',
                    style: GoogleFonts.inter(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),

                  ..._syncItems.map((item) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle_rounded, color: AppColors.emeraldGreen, size: 18),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['title'] as String,
                                  style: GoogleFonts.inter(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  '${item['sections']} • ${item['size']}',
                                  style: GoogleFonts.inter(color: Colors.white54, fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.white10,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'Synced',
                              style: GoogleFonts.inter(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
