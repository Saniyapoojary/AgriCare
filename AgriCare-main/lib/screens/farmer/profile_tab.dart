import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../auth/login_screen.dart';

class FarmerProfileTab extends StatelessWidget {
  const FarmerProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final user = appState.currentUser!;
    final reports = appState.reportsForCurrentFarmer();
    final jobs = appState.jobsForCurrentFarmer();
    final completedJobs = jobs.where((j) => j.status.name == 'completed').length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: const Color(0xFFDCFCE7),
                  child: Text(user.name.isNotEmpty ? user.name.substring(0, 1) : '?',
                      style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w800, color: primaryGreen)),
                ),
                const SizedBox(height: 12),
                Text(user.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                Text(user.phone, style: const TextStyle(color: Color(0xFF64748B))),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(color: const Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(20)),
                  child: const Text('Farmer', style: TextStyle(color: primaryGreen, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Wallet Balance', style: TextStyle(color: Color(0xFF64748B))),
                      Text('₹${user.walletBalance.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: primaryGreen)),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _StatColumn(label: 'Reports', value: '${reports.length}'),
                      _StatColumn(label: 'Jobs Booked', value: '${jobs.length}'),
                      _StatColumn(label: 'Completed', value: '$completedJobs'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: const Icon(Icons.location_on_outlined, color: primaryGreen),
              title: const Text('Farm Location'),
              subtitle: Text(user.address),
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () {
              appState.logout();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
            icon: const Icon(Icons.logout_rounded, color: Color(0xFF991B1B)),
            label: const Text('Logout', style: TextStyle(color: Color(0xFF991B1B))),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFF991B1B)),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final String label;
  final String value;
  const _StatColumn({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
        Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
      ],
    );
  }
}
