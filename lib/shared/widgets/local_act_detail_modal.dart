import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_colors.dart';
import '../../core/storage/hive_service.dart';

class LocalActDetailModal extends StatefulWidget {
  final String stateCode;
  final String actName;
  final VoidCallback onStatusChanged;

  const LocalActDetailModal({
    super.key,
    required this.stateCode,
    required this.actName,
    required this.onStatusChanged,
  });

  static void show(BuildContext context, {
    required String stateCode,
    required String actName,
    required VoidCallback onStatusChanged,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => LocalActDetailModal(
        stateCode: stateCode,
        actName: actName,
        onStatusChanged: onStatusChanged,
      ),
    );
  }

  @override
  State<LocalActDetailModal> createState() => _LocalActDetailModalState();
}

class _LocalActDetailModalState extends State<LocalActDetailModal> {
  late bool _isDone;

  @override
  void initState() {
    super.initState();
    _isDone = HiveService.isLocalActCompleted(widget.stateCode, widget.actName);
  }

  @override
  Widget build(BuildContext context) {
    final details = _getLocalActKnowledge(widget.actName);

    return Container(
      height: MediaQuery.of(context).size.height * 0.82,
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
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
                  child: const Icon(Icons.menu_book_rounded, color: AppColors.accentGold, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.actName,
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${widget.stateCode} Judicial Syllabus High-Yield Digest',
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
                  // Overview Box
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text('⚖️', style: TextStyle(fontSize: 16)),
                            const SizedBox(width: 8),
                            Text(
                              'Judicial Exam Importance:',
                              style: GoogleFonts.inter(color: AppColors.accentGold, fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          details['importance'] ?? 'High frequency area in State Prelims and Mains.',
                          style: GoogleFonts.inter(color: Colors.white, fontSize: 13, height: 1.45),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // High Yield Sections
                  Text(
                    'High-Yield Topics & Sections:',
                    style: GoogleFonts.inter(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ...(details['topics'] as List<String>? ?? []).map(
                    (t) => Container(
                      margin: const EdgeInsets.only(bottom: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.arrow_right_rounded, color: AppColors.accentGold, size: 20),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              t,
                              style: GoogleFonts.inter(color: Colors.white, fontSize: 12.5, height: 1.35),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Prelims Trap Box
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.warning_amber_rounded, color: Colors.amber, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            details['trap'] ?? 'Watch out for limitation periods and non-appealable revisional decrees.',
                            style: GoogleFonts.inter(color: Colors.amber.shade200, fontSize: 12, height: 1.4),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Completion Toggle Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: Icon(_isDone ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded, size: 20),
                      label: Text(
                        _isDone ? 'Marked as Completed ✓' : 'Mark as Completed',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isDone ? AppColors.emeraldGreen : AppColors.primaryNavy,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: () async {
                        await HiveService.toggleLocalActCompleted(widget.stateCode, widget.actName);
                        setState(() => _isDone = !_isDone);
                        widget.onStatusChanged();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getLocalActKnowledge(String act) {
    if (act.contains('Rent')) {
      return {
        'importance':
            'Crucial for civil law papers. Frequently tests bonafide landlord necessity, sub-letting without consent, and deposit of rent in court.',
        'topics': [
          'Bonafide requirement for eviction and landlord self-occupation.',
          'Summary trial procedure under Section 25B (Leave to Defend within 15 days).',
          'Fixation of Standard Rent and lawful increase clauses.',
          'Tenant protection against unlawful disconnection of basic amenities.',
        ],
        'trap':
            'Limitation alert: Application for leave to defend must strictly be filed within 15 days of summon service. Limitation Act Section 5 condonation does NOT apply!',
      };
    } else if (act.contains('Revenue')) {
      return {
        'importance':
            'Top scorer in Mains. Direct questions on Mutation (Dakhil-Kharij), Classes of Tenure Holders (Bhumidhar), and Gram Sabha land management.',
        'topics': [
          'Hierarchy of Revenue Courts and separation of civil vs revenue jurisdiction.',
          'Mutation Proceedings vs Title Declaratory Suits.',
          'Partition of joint holdings and ejectment of unauthorized occupants.',
          'Surrender and abandonment of agricultural holdings.',
        ],
        'trap':
            'Jurisdiction trap: Remember mutation entries in revenue records do NOT confer title. Exclusive jurisdiction for title declaration lies under civil law declarations.',
      };
    } else {
      return {
        'importance':
            'High-yield criminal law subject. Mandatory child-friendly trial procedures, preliminary assessment under Sec 15, and non-bailable presumption under Sec 29 & 30.',
        'topics': [
          'Section 3 to 10: Penetrative sexual assault, aggravated forms & penalties.',
          'Section 19: Mandatory reporting duty on any person or hospital institution.',
          'Section 29 & 30: Statutory Presumption of Guilt shifting burden of proof on the accused.',
          'Section 33: Child-friendly court recording without visual confrontation with accused.',
        ],
        'trap':
            'Supreme Court in Attorney General for India v. Satish (2021): Skin-to-skin contact is NOT required; sexual assault applies even when contact occurs over clothing.',
      };
    }
  }
}
