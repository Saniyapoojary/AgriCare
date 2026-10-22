import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/job_request.dart';
import '../../models/spray_worker.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/status_timeline.dart';
import 'job_detail_screen.dart';

class FarmerJobsTab extends StatelessWidget {
  const FarmerJobsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Container(
            color: Colors.white,
            child: const TabBar(
              labelColor: primaryGreen,
              unselectedLabelColor: Color(0xFF64748B),
              indicatorColor: primaryGreen,
              tabs: [
                Tab(text: 'Marketplace'),
                Tab(text: 'My Jobs'),
              ],
            ),
          ),
          const Expanded(
            child: TabBarView(
              children: [
                _MarketplaceView(),
                _MyJobsView(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Marketplace: browse & directly book any available worker.
// ---------------------------------------------------------------------------

class _MarketplaceView extends StatefulWidget {
  const _MarketplaceView();

  @override
  State<_MarketplaceView> createState() => _MarketplaceViewState();
}

class _MarketplaceViewState extends State<_MarketplaceView> {
  String? _skillFilter;

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final workers = appState.workers
        .where((w) => _skillFilter == null || w.specializedDiseases.contains(_skillFilter))
        .toList();
    final skills = appState.workers.expand((w) => w.specializedDiseases).toSet().toList()..sort();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _FilterChip(label: 'All', selected: _skillFilter == null, onTap: () => setState(() => _skillFilter = null)),
                ...skills.map((s) => Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: _FilterChip(label: s, selected: _skillFilter == s, onTap: () => setState(() => _skillFilter = s)),
                    )),
              ],
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: workers.length,
            itemBuilder: (context, i) => _WorkerCard(worker: workers[i]),
          ),
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _FilterChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: const Color(0xFFDCFCE7),
      labelStyle: TextStyle(color: selected ? primaryGreen : const Color(0xFF334155), fontWeight: FontWeight.bold),
    );
  }
}

class _WorkerCard extends StatelessWidget {
  final SprayWorker worker;
  const _WorkerCard({required this.worker});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: const Color(0xFFDCFCE7),
                  child: Text(worker.name.substring(0, 1),
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: primaryGreen)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(child: Text(worker.name, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)),
                          const SizedBox(width: 6),
                          if (worker.isAvailable) const Icon(Icons.verified_rounded, size: 18, color: primaryGreen),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(worker.roleSpecialty, style: const TextStyle(color: Color(0xFF64748B), fontSize: 13, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('₹${worker.dailyRate}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: primaryGreen)),
                    const Text('/day', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _InfoBadge(icon: Icons.verified_user_outlined, text: 'Reliability: ${worker.reliabilityScore.toStringAsFixed(0)}/100', color: primaryGreen),
                _InfoBadge(icon: Icons.star_rounded, text: '${worker.rating.toStringAsFixed(1)} (${worker.completedJobs})', color: const Color(0xFFD97706)),
                _InfoBadge(icon: worker.isAvailable ? Icons.event_available_rounded : Icons.event_busy_rounded, text: worker.isAvailable ? 'Available' : 'Busy'),
              ],
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: worker.isAvailable ? () => _showBookingModal(context, worker) : null,
                icon: const Icon(Icons.calendar_today_rounded, size: 16),
                label: const Text('Book Spray Service', style: TextStyle(fontWeight: FontWeight.bold)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: primaryGreen,
                  side: const BorderSide(color: primaryGreen, width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showBookingModal(BuildContext context, SprayWorker worker) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (modalContext) {
        return Padding(
          padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: MediaQuery.of(modalContext).viewInsets.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(width: 44, height: 5, decoration: BoxDecoration(color: const Color(0xFFCBD5E1), borderRadius: BorderRadius.circular(3))),
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Confirm Spray Booking', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800)),
                  IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.pop(modalContext)),
                ],
              ),
              const Divider(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  radius: 24,
                  backgroundColor: const Color(0xFFDCFCE7),
                  child: Text(worker.name.substring(0, 1), style: const TextStyle(fontWeight: FontWeight.bold, color: primaryGreen, fontSize: 18)),
                ),
                title: Text(worker.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                subtitle: Text(worker.roleSpecialty),
                trailing: Text('₹${worker.dailyRate}/day', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: primaryGreen)),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: const Color(0xFFF0FDF4), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFBBF7D0))),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Operator Daily Fee:', style: TextStyle(color: Color(0xFF334155))),
                        Text('₹${worker.dailyRate}', style: const TextStyle(fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Fixed Escrow Security Deposit:', style: TextStyle(fontWeight: FontWeight.bold, color: primaryGreen)),
                        Text('₹200', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: primaryGreen)),
                      ],
                    ),
                    const Divider(height: 20),
                    const Row(
                      children: [
                        Icon(Icons.verified_user_rounded, size: 20, color: primaryGreen),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            '₹200 deposit is locked in Escrow and released only after service completion.',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: darkGreen),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    final appState = context.read<AppState>();
                    final job = appState.createDirectJobRequest(
                      title: '${worker.roleSpecialty} — direct booking',
                      description: 'Direct booking of ${worker.name} from the marketplace.',
                      requiredSkill: worker.specializedDiseases.isNotEmpty ? worker.specializedDiseases.first : 'General',
                      farmSizeAcres: 1.0,
                      preferredDate: DateTime.now().add(const Duration(days: 2)),
                      budgetMin: worker.dailyRate.toDouble(),
                      budgetMax: worker.dailyRate.toDouble(),
                    );
                    appState.confirmWorker(job, worker.id, quotedPrice: worker.dailyRate.toDouble());
                    Navigator.pop(modalContext);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Job requested with ${worker.name}! ₹200 Security Deposit secured in Escrow.', style: const TextStyle(fontWeight: FontWeight.bold)),
                        backgroundColor: primaryGreen,
                        duration: const Duration(seconds: 4),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    );
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: primaryGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Confirm & Pay Security Deposit (₹200)', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _InfoBadge extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color? color;
  const _InfoBadge({required this.icon, required this.text, this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color ?? const Color(0xFF64748B)),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 12, color: Color(0xFF334155), fontWeight: FontWeight.w600)),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// My Jobs: jobs the farmer has created, tracked through their lifecycle.
// ---------------------------------------------------------------------------

class _MyJobsView extends StatelessWidget {
  const _MyJobsView();

  @override
  Widget build(BuildContext context) {
    final jobs = context.watch<AppState>().jobsForCurrentFarmer();
    if (jobs.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text('No job requests yet. Scan a crop or book a worker from the Marketplace.',
              textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF64748B))),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: jobs.length,
      itemBuilder: (context, i) {
        final job = jobs[i];
        return Card(
          margin: const EdgeInsets.only(bottom: 14),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => JobDetailScreen(jobId: job.id))),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: Text(job.title, style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis)),
                      _StatusChip(status: job.status),
                    ],
                  ),
                  const SizedBox(height: 12),
                  JobStatusTimeline(status: job.status),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _StatusChip extends StatelessWidget {
  final JobStatus status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = status == JobStatus.completed
        ? primaryGreen
        : status == JobStatus.cancelled
            ? const Color(0xFF991B1B)
            : const Color(0xFFD97706);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withAlpha(30), borderRadius: BorderRadius.circular(20)),
      child: Text(status.label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }
}
