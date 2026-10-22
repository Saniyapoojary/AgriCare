import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/disease_report.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/severity_badge.dart';
import 'create_job_screen.dart';

class ReportsListScreen extends StatelessWidget {
  const ReportsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final reports = context.watch<AppState>().reportsForCurrentFarmer();
    return Scaffold(
      appBar: AppBar(title: const Text('Diagnostic Reports')),
      body: reports.isEmpty
          ? const Center(child: Text('No reports yet.', style: TextStyle(color: Color(0xFF64748B))))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: reports.length,
              itemBuilder: (context, i) {
                final r = reports[i];
                final style = severityStyleFor(r.severity);
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(14),
                    leading: CircleAvatar(backgroundColor: style.background, child: Icon(style.icon, color: style.textColor)),
                    title: Text(r.diseaseName, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(
                      '${r.severity} • ${(r.confidence * 100).toStringAsFixed(0)}% confidence\n'
                      '${r.createdAt.toLocal().toString().split('.').first}',
                    ),
                    isThreeLine: true,
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ReportDetailScreen(report: r))),
                  ),
                );
              },
            ),
    );
  }
}

class ReportDetailScreen extends StatelessWidget {
  final DiseaseReport report;
  const ReportDetailScreen({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    final style = severityStyleFor(report.severity);
    return Scaffold(
      appBar: AppBar(title: Text(report.diseaseName)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (report.imageFile != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Image.file(report.imageFile!, height: 220, width: double.infinity, fit: BoxFit.cover),
              ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(report.diseaseName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                SeverityBadge(severity: report.severity),
              ],
            ),
            const SizedBox(height: 4),
            Text('${(report.confidence * 100).toStringAsFixed(1)}% model confidence',
                style: const TextStyle(color: Color(0xFF64748B))),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: report.usedRealModel ? const Color(0xFFDBEAFE) : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    report.usedRealModel ? Icons.memory_rounded : Icons.science_outlined,
                    size: 13,
                    color: report.usedRealModel ? const Color(0xFF1D4ED8) : const Color(0xFF64748B),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    report.usedRealModel ? 'On-device model screening' : 'Demo mode (no model loaded)',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: report.usedRealModel ? const Color(0xFF1D4ED8) : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(14), border: Border.all(color: borderSlate)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Recommended Treatment Timeline', style: TextStyle(fontWeight: FontWeight.bold, color: primaryGreen, fontSize: 12)),
                  const SizedBox(height: 6),
                  Text(report.treatmentTimeline, style: const TextStyle(fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Icon(style.icon, size: 16, color: const Color(0xFF2563EB)),
                const SizedBox(width: 6),
                Text('Humidity: ${report.weatherHumidity.toStringAsFixed(0)}%', style: const TextStyle(fontSize: 13)),
                const SizedBox(width: 16),
                const Icon(Icons.grain_rounded, size: 16, color: Color(0xFF0EA5E9)),
                const SizedBox(width: 6),
                Text('Rainfall: ${report.weatherRainfallMm.toStringAsFixed(0)}mm', style: const TextStyle(fontSize: 13)),
              ],
            ),
            const SizedBox(height: 24),
            if (!report.isHealthy)
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: report.hasLinkedJob
                      ? null
                      : () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => CreateJobScreen(report: report))),
                  icon: Icon(report.hasLinkedJob ? Icons.check_circle_rounded : Icons.engineering_rounded),
                  label: Text(report.hasLinkedJob ? 'Job Already Requested' : 'Find Spray Workers'),
                  style: FilledButton.styleFrom(
                    backgroundColor: primaryGreen,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
