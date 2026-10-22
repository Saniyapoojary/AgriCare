import 'package:flutter/material.dart';

import '../models/job_request.dart';
import '../theme/app_theme.dart';

const _stepOrder = [
  JobStatus.open,
  JobStatus.matched,
  JobStatus.confirmed,
  JobStatus.inProgress,
  JobStatus.completed,
];

/// Horizontal step tracker for a job's lifecycle:
/// open -> matched -> confirmed -> in progress -> completed.
class JobStatusTimeline extends StatelessWidget {
  final JobStatus status;
  const JobStatusTimeline({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    if (status == JobStatus.cancelled) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFFEE2E2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          children: [
            Icon(Icons.cancel_rounded, color: Color(0xFF991B1B), size: 18),
            SizedBox(width: 8),
            Text('Job Cancelled', style: TextStyle(color: Color(0xFF991B1B), fontWeight: FontWeight.bold)),
          ],
        ),
      );
    }

    final currentIndex = _stepOrder.indexOf(status);

    return Row(
      children: List.generate(_stepOrder.length * 2 - 1, (i) {
        if (i.isOdd) {
          final leftDone = (i - 1) ~/ 2 < currentIndex || ((i - 1) ~/ 2 <= currentIndex);
          return Expanded(
            child: Container(
              height: 2,
              color: leftDone ? primaryGreen : borderSlate,
            ),
          );
        }
        final stepIndex = i ~/ 2;
        final done = stepIndex <= currentIndex;
        final isCurrent = stepIndex == currentIndex;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: isCurrent ? 16 : 12,
              height: isCurrent ? 16 : 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: done ? primaryGreen : Colors.white,
                border: Border.all(color: done ? primaryGreen : borderSlate, width: 2),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _stepOrder[stepIndex].label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                color: done ? primaryGreen : const Color(0xFF94A3B8),
              ),
            ),
          ],
        );
      }),
    );
  }
}
