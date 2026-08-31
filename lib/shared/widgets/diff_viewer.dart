import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../models/law_comparison.dart';

class DiffViewerWidget extends StatelessWidget {
  final LawComparison comparison;

  const DiffViewerWidget({super.key, required this.comparison});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primaryNavy, AppColors.secondaryNavy],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${comparison.oldAct} ${comparison.oldSection} ➔ ${comparison.newAct} ${comparison.newSection}',
                        style: const TextStyle(
                          color: AppColors.accentGold,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        comparison.newTitle,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.accentGold,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    comparison.subject,
                    style: const TextStyle(
                      color: AppColors.primaryNavy,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // REPEALED LAW CARD (FULL WIDTH ROW)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.diffRemovedBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.shade300),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.history, color: Colors.red.shade800, size: 18),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'REPEALED (${comparison.oldAct})',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: Colors.red.shade900,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  comparison.oldSection,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.red.shade900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  comparison.oldText,
                  style: TextStyle(
                    color: Colors.red.shade900,
                    fontSize: 13,
                    height: 1.4,
                    decoration: TextDecoration.lineThrough,
                    decorationColor: Colors.red.shade700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primaryNavy,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.arrow_downward, color: AppColors.accentGold, size: 16),
                  SizedBox(width: 4),
                  Text(
                    '2023 Statutory Reform Mapping',
                    style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          // NEW LAW CARD (FULL WIDTH ROW)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.diffAddedBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.shade400),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.gavel, color: Colors.green.shade800, size: 18),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'NEW LAW (${comparison.newAct})',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: Colors.green.shade900,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  comparison.newSection,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.green.shade900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  comparison.newText,
                  style: TextStyle(
                    color: Colors.green.shade900,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Statutory Changes & Impact',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...comparison.keyChanges.map((change) => Padding(
                      padding: const EdgeInsets.only(bottom: 6.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.arrow_right, color: AppColors.primaryNavy),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              change,
                              style: const TextStyle(fontSize: 13, color: AppColors.textPrimaryDark),
                            ),
                          ),
                        ],
                      ),
                    )),
                const Divider(),
                Text(
                  'Summary: ${comparison.summary}',
                  style: const TextStyle(
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryNavy,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
