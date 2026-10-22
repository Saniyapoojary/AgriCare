import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../models/job_request.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/status_timeline.dart';

class WorkerMyJobsTab extends StatelessWidget {
  const WorkerMyJobsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final worker = appState.currentWorkerProfile;
    if (worker == null) {
      return const Center(child: Text('Worker profile not found.'));
    }

    final jobs = appState.activeJobsForWorker(worker.id);

    if (jobs.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text('No accepted jobs yet. Accept a request from the Available tab.',
              textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF64748B))),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: jobs.length,
      itemBuilder: (context, i) => _JobCard(job: jobs[i]),
    );
  }
}

class _JobCard extends StatelessWidget {
  final JobRequest job;
  const _JobCard({required this.job});

  Future<void> _submitCompletionPhoto(BuildContext context) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.camera, maxWidth: 1080, imageQuality: 85);
    if (picked == null) return;
    if (context.mounted) {
      context.read<AppState>().workerSubmitCompletionPhoto(job, picked.path);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completion photo submitted. Awaiting farmer confirmation.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(job.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 4),
            Text('Budget: ₹${job.budgetMin.toStringAsFixed(0)}–₹${job.budgetMax.toStringAsFixed(0)} • ${job.farmSizeAcres} acres',
                style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
            const SizedBox(height: 14),
            JobStatusTimeline(status: job.status),
            const SizedBox(height: 16),
            if (job.status == JobStatus.confirmed)
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => context.read<AppState>().workerStartJob(job),
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: const Text('Start Job', style: TextStyle(fontWeight: FontWeight.bold)),
                  style: FilledButton.styleFrom(
                    backgroundColor: primaryGreen,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            if (job.status == JobStatus.inProgress && job.completionPhotoPath == null)
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => _submitCompletionPhoto(context),
                  icon: const Icon(Icons.camera_alt_rounded),
                  label: const Text('Submit Completion Photo', style: TextStyle(fontWeight: FontWeight.bold)),
                  style: FilledButton.styleFrom(
                    backgroundColor: primaryGreen,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            if (job.status == JobStatus.inProgress && job.completionPhotoPath != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: const Color(0xFFFFFBEB), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFFDE68A))),
                child: const Row(
                  children: [
                    Icon(Icons.hourglass_top_rounded, size: 18, color: Color(0xFF92400E)),
                    SizedBox(width: 8),
                    Expanded(child: Text('Awaiting farmer confirmation & rating.', style: TextStyle(fontSize: 12, color: Color(0xFF92400E), fontWeight: FontWeight.w600))),
                  ],
                ),
              ),
            if (job.status == JobStatus.completed && job.rating != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: const Color(0xFFF0FDF4), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFBBF7D0))),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_rounded, size: 18, color: primaryGreen),
                    const SizedBox(width: 8),
                    Text('Completed — rated ${job.rating!.overall}/5. Deposit released.',
                        style: const TextStyle(fontSize: 12, color: darkGreen, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
