import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/job_request.dart';
import '../../models/rating.dart';
import '../../models/spray_worker.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/status_timeline.dart';

class JobDetailScreen extends StatelessWidget {
  final String jobId;
  const JobDetailScreen({super.key, required this.jobId});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final job = appState.jobs.firstWhere((j) => j.id == jobId);
    final confirmedWorker = job.confirmedWorkerId != null ? appState.workerById(job.confirmedWorkerId!) : null;

    return Scaffold(
      appBar: AppBar(title: const Text('Job Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(job.title, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text(job.description, style: const TextStyle(color: Color(0xFF64748B), fontSize: 13)),
            const SizedBox(height: 18),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: JobStatusTimeline(status: job.status),
              ),
            ),
            const SizedBox(height: 18),
            if (job.status == JobStatus.matched) _MatchesList(job: job),
            if (confirmedWorker != null && job.status != JobStatus.matched) _ConfirmedWorkerCard(job: job, worker: confirmedWorker),
            if (job.status == JobStatus.inProgress && job.completionPhotoPath != null)
              Container(
                margin: const EdgeInsets.only(top: 14),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: const Color(0xFFFFFBEB), borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFFDE68A))),
                child: const Row(
                  children: [
                    Icon(Icons.photo_camera_back_rounded, color: Color(0xFF92400E)),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text('Worker submitted completion evidence. Review and confirm below to release the deposit.',
                          style: TextStyle(fontSize: 12, color: Color(0xFF92400E), fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ),
            if (job.status == JobStatus.inProgress)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () => _openRatingSheet(context, job),
                    icon: const Icon(Icons.rate_review_rounded),
                    label: const Text('Confirm Completion & Rate', style: TextStyle(fontWeight: FontWeight.bold)),
                    style: FilledButton.styleFrom(
                      backgroundColor: primaryGreen,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
              ),
            if (job.status == JobStatus.completed && job.rating != null) _RatingSummary(rating: job.rating!),
            if (job.status == JobStatus.confirmed || job.status == JobStatus.inProgress)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: TextButton.icon(
                  onPressed: () => _confirmCancel(context, job),
                  icon: const Icon(Icons.cancel_outlined, color: Color(0xFF991B1B)),
                  label: const Text('Cancel Job', style: TextStyle(color: Color(0xFF991B1B))),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _confirmCancel(BuildContext context, JobRequest job) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Job?'),
        content: const Text('The held security deposit will be refunded to your wallet.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Keep Job')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFF991B1B)),
            onPressed: () {
              context.read<AppState>().cancelJob(job);
              Navigator.pop(ctx);
            },
            child: const Text('Cancel Job'),
          ),
        ],
      ),
    );
  }

  void _openRatingSheet(BuildContext context, JobRequest job) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (_) => _RatingSheet(job: job),
    );
  }
}

class _MatchesList extends StatelessWidget {
  final JobRequest job;
  const _MatchesList({required this.job});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    if (job.matches.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text('No workers matched this job yet.', style: TextStyle(color: Color(0xFF64748B))),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 10),
          child: Text('Top Matched Workers', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        ),
        ...job.matches.map((m) {
          final worker = appState.workerById(m.workerId);
          if (worker == null) return const SizedBox.shrink();
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 26,
                        height: 26,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(color: primaryGreen, shape: BoxShape.circle),
                        child: Text('#${m.rank}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                      const SizedBox(width: 10),
                      Expanded(child: Text(worker.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15))),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: const Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(20)),
                        child: Text('${(m.matchScore * 100).toStringAsFixed(0)}% match',
                            style: const TextStyle(color: primaryGreen, fontWeight: FontWeight.bold, fontSize: 11)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(m.matchReason, style: const TextStyle(fontSize: 12, color: Color(0xFF475569), fontStyle: FontStyle.italic)),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => appState.confirmWorker(job, worker.id, quotedPrice: worker.dailyRate.toDouble()),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: primaryGreen,
                        side: const BorderSide(color: primaryGreen),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text('Select ${worker.name.split(' ').first} (₹${worker.dailyRate}/day)'),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}

class _ConfirmedWorkerCard extends StatelessWidget {
  final JobRequest job;
  final SprayWorker worker;
  const _ConfirmedWorkerCard({required this.job, required this.worker});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: const Color(0xFFDCFCE7),
                  child: Text(worker.name.substring(0, 1), style: const TextStyle(fontWeight: FontWeight.bold, color: primaryGreen)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(worker.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(worker.roleSpecialty, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Escrow Security Deposit', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                Text(
                  job.depositStatus == DepositStatus.held ? '₹${job.depositAmount.toStringAsFixed(0)} Held' : job.depositStatus.name,
                  style: const TextStyle(fontWeight: FontWeight.bold, color: primaryGreen),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RatingSummary extends StatelessWidget {
  final JobRating rating;
  const _RatingSummary({required this.rating});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(top: 14),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Your Rating', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Row(
              children: List.generate(
                5,
                (i) => Icon(i < rating.overall ? Icons.star_rounded : Icons.star_border_rounded, color: const Color(0xFFD97706)),
              ),
            ),
            if (rating.comment.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(rating.comment, style: const TextStyle(fontStyle: FontStyle.italic, color: Color(0xFF475569))),
            ],
          ],
        ),
      ),
    );
  }
}

class _RatingSheet extends StatefulWidget {
  final JobRequest job;
  const _RatingSheet({required this.job});

  @override
  State<_RatingSheet> createState() => _RatingSheetState();
}

class _RatingSheetState extends State<_RatingSheet> {
  int _punctuality = 5;
  int _quality = 5;
  int _communication = 5;
  int _overall = 5;
  final _commentCtrl = TextEditingController();

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  Widget _starRow(String label, int value, void Function(int) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(child: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
          Row(
            children: List.generate(
              5,
              (i) => IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: Icon(i < value ? Icons.star_rounded : Icons.star_border_rounded, color: const Color(0xFFD97706), size: 22),
                onPressed: () => onChanged(i + 1),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: MediaQuery.of(context).viewInsets.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Rate the Completed Job', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 16),
          _starRow('Punctuality', _punctuality, (v) => setState(() => _punctuality = v)),
          _starRow('Quality of Work', _quality, (v) => setState(() => _quality = v)),
          _starRow('Communication', _communication, (v) => setState(() => _communication = v)),
          _starRow('Overall Satisfaction', _overall, (v) => setState(() => _overall = v)),
          TextField(
            controller: _commentCtrl,
            decoration: const InputDecoration(labelText: 'Comment (optional)'),
            maxLines: 2,
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                context.read<AppState>().confirmCompletionAndRate(
                      widget.job,
                      JobRating(
                        punctuality: _punctuality,
                        quality: _quality,
                        communication: _communication,
                        overall: _overall,
                        comment: _commentCtrl.text.trim(),
                        createdAt: DateTime.now(),
                      ),
                    );
                Navigator.pop(context);
              },
              style: FilledButton.styleFrom(
                backgroundColor: primaryGreen,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('Submit Rating & Release Deposit', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
