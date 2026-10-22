import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/job_request.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';

class AvailableJobsTab extends StatelessWidget {
  const AvailableJobsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final worker = appState.currentWorkerProfile;

    if (worker == null) {
      return const Center(child: Text('Worker profile not found.'));
    }

    final jobs = appState.availableJobsForWorker(worker.id);

    if (jobs.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'No job requests match your profile right now. New matches appear here automatically.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF64748B)),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: jobs.length,
      itemBuilder: (context, i) {
        final job = jobs[i];
        final match = job.matches.firstWhere((m) => m.workerId == worker.id);
        return Card(
          margin: const EdgeInsets.only(bottom: 14),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: Text(job.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15))),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: const Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(20)),
                      child: Text('${(match.matchScore * 100).toStringAsFixed(0)}% match',
                          style: const TextStyle(color: primaryGreen, fontWeight: FontWeight.bold, fontSize: 11)),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(job.description, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)), maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 14,
                  runSpacing: 6,
                  children: [
                    _InfoItem(icon: Icons.location_on_outlined, text: '${match.distanceKm.toStringAsFixed(1)} km'),
                    _InfoItem(icon: Icons.landscape_outlined, text: '${job.farmSizeAcres} acres'),
                    _InfoItem(icon: Icons.event_outlined, text: job.preferredDate.toLocal().toString().split(' ').first),
                    _InfoItem(icon: Icons.currency_rupee_rounded, text: '${job.budgetMin.toStringAsFixed(0)}–${job.budgetMax.toStringAsFixed(0)}'),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => context.read<AppState>().workerDeclineJob(job, worker.id),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF991B1B),
                          side: const BorderSide(color: Color(0xFF991B1B)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Decline'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: FilledButton(
                        onPressed: () => _acceptWithQuote(context, job, worker.id, job.budgetMax),
                        style: FilledButton.styleFrom(
                          backgroundColor: primaryGreen,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Accept & Quote'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _acceptWithQuote(BuildContext context, JobRequest job, String workerId, double suggested) {
    final ctrl = TextEditingController(text: suggested.toStringAsFixed(0));
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Quote Your Price'),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Price for this job (₹)'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: primaryGreen),
            onPressed: () {
              final price = double.tryParse(ctrl.text) ?? suggested;
              context.read<AppState>().workerAcceptJob(job, workerId, price);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Job accepted! Find it under My Jobs.')),
              );
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: const Color(0xFF64748B)),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 12, color: Color(0xFF334155), fontWeight: FontWeight.w600)),
      ],
    );
  }
}
