import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/job_request.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/severity_badge.dart';
import 'job_detail_screen.dart';
import 'reports_screen.dart';

class FarmerDashboardTab extends StatelessWidget {
  final void Function(int tabIndex) onNavigate;
  const FarmerDashboardTab({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final user = appState.currentUser!;
    final reports = appState.reportsForCurrentFarmer();
    final jobs = appState.jobsForCurrentFarmer();
    final activeJobs = jobs.where((j) =>
        j.status == JobStatus.matched ||
        j.status == JobStatus.confirmed ||
        j.status == JobStatus.inProgress);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Namaste, ${user.name.split(' ').first} 🙏',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
          const SizedBox(height: 4),
          Text(user.address, style: const TextStyle(color: Color(0xFF64748B), fontSize: 13)),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                  child: _StatCard(
                icon: Icons.account_balance_wallet_rounded,
                label: 'Wallet',
                value: '₹${user.walletBalance.toStringAsFixed(0)}',
                color: primaryGreen,
              )),
              const SizedBox(width: 12),
              Expanded(
                  child: _StatCard(
                icon: Icons.description_outlined,
                label: 'Reports',
                value: '${reports.length}',
                color: const Color(0xFF2563EB),
              )),
              const SizedBox(width: 12),
              Expanded(
                  child: _StatCard(
                icon: Icons.engineering_rounded,
                label: 'Active Jobs',
                value: '${activeJobs.length}',
                color: const Color(0xFFD97706),
              )),
            ],
          ),
          const SizedBox(height: 20),
          _QuickActions(onNavigate: onNavigate),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Recent Diagnostics', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              TextButton(
                onPressed: () => Navigator.of(context)
                    .push(MaterialPageRoute(builder: (_) => const ReportsListScreen())),
                child: const Text('View All'),
              ),
            ],
          ),
          if (reports.isEmpty)
            const _EmptyHint(
              icon: Icons.center_focus_weak_rounded,
              text: 'No crop scans yet. Head to Crop Scan to diagnose your first plant.',
            )
          else
            ...reports.take(2).map((r) => Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: severityStyleFor(r.severity).background,
                      child: Icon(severityStyleFor(r.severity).icon, color: severityStyleFor(r.severity).textColor, size: 18),
                    ),
                    title: Text(r.diseaseName, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${r.severity} • ${r.createdAt.toLocal().toString().split('.').first}'),
                  ),
                )),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Active Jobs', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              TextButton(onPressed: () => onNavigate(2), child: const Text('View All')),
            ],
          ),
          if (activeJobs.isEmpty)
            const _EmptyHint(
              icon: Icons.engineering_outlined,
              text: 'No active jobs. Book a spray worker from the Jobs tab.',
            )
          else
            ...activeJobs.take(2).map((j) => Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading: const Icon(Icons.work_outline_rounded, color: primaryGreen),
                    title: Text(j.title, style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                    subtitle: Text(j.status.label),
                    onTap: () => Navigator.of(context)
                        .push(MaterialPageRoute(builder: (_) => JobDetailScreen(jobId: j.id))),
                  ),
                )),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderSlate),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 10),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  final void Function(int tabIndex) onNavigate;
  const _QuickActions({required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: FilledButton.icon(
            onPressed: () => onNavigate(1),
            icon: const Icon(Icons.camera_alt_rounded, size: 18),
            label: const Text('Scan Crop'),
            style: FilledButton.styleFrom(
              backgroundColor: primaryGreen,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => onNavigate(2),
            icon: const Icon(Icons.engineering_rounded, size: 18),
            label: const Text('Find Workers'),
            style: OutlinedButton.styleFrom(
              foregroundColor: primaryGreen,
              side: const BorderSide(color: primaryGreen, width: 1.5),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptyHint extends StatelessWidget {
  final IconData icon;
  final String text;
  const _EmptyHint({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      margin: const EdgeInsets.only(top: 8, bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF94A3B8)),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: const TextStyle(color: Color(0xFF64748B), fontSize: 13))),
        ],
      ),
    );
  }
}
