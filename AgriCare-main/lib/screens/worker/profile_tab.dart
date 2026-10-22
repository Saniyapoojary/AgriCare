import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../auth/login_screen.dart';

class WorkerProfileTab extends StatelessWidget {
  const WorkerProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final user = appState.currentUser!;
    final worker = appState.currentWorkerProfile;

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
                  child: const Text('Spray Worker', style: TextStyle(color: primaryGreen, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          if (worker != null) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Reliability Score', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        Text('${worker.reliabilityScore.toStringAsFixed(0)}/100',
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: primaryGreen)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: worker.reliabilityScore / 100,
                        minHeight: 10,
                        backgroundColor: const Color(0xFFF1F5F9),
                        valueColor: const AlwaysStoppedAnimation(primaryGreen),
                      ),
                    ),
                    const SizedBox(height: 18),
                    _FactorBar(label: 'Avg. Rating', value: worker.rating / 5, display: '${worker.rating.toStringAsFixed(1)}/5'),
                    _FactorBar(label: 'On-time / Low Cancellation', value: 1 - worker.cancellationRate, display: '${((1 - worker.cancellationRate) * 100).toStringAsFixed(0)}%'),
                    _FactorBar(label: 'Job History', value: (worker.completedJobs / 200).clamp(0, 1), display: '${worker.completedJobs} jobs'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Specializations', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: worker.specializedDiseases
                          .map((s) => Chip(
                                label: Text(s, style: const TextStyle(fontSize: 12)),
                                backgroundColor: const Color(0xFFDCFCE7),
                                labelStyle: const TextStyle(color: primaryGreen),
                              ))
                          .toList(),
                    ),
                    const Divider(height: 28),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Daily Rate', style: TextStyle(color: Color(0xFF64748B))),
                        Text('₹${worker.dailyRate}', style: const TextStyle(fontWeight: FontWeight.bold, color: primaryGreen)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Availability', style: TextStyle(color: Color(0xFF64748B))),
                        Text(worker.isAvailable ? 'Available' : 'Busy',
                            style: TextStyle(fontWeight: FontWeight.bold, color: worker.isAvailable ? primaryGreen : const Color(0xFF991B1B))),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
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

class _FactorBar extends StatelessWidget {
  final String label;
  final double value;
  final String display;
  const _FactorBar({required this.label, required this.value, required this.display});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF334155))),
              Text(display, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: value.clamp(0, 1).toDouble(),
              minHeight: 7,
              backgroundColor: const Color(0xFFF1F5F9),
              valueColor: const AlwaysStoppedAnimation(Color(0xFF60A5FA)),
            ),
          ),
        ],
      ),
    );
  }
}
