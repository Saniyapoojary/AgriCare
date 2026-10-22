import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/disease_report.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/severity_badge.dart';
import 'job_detail_screen.dart';

class CreateJobScreen extends StatefulWidget {
  final DiseaseReport report;
  const CreateJobScreen({super.key, required this.report});

  @override
  State<CreateJobScreen> createState() => _CreateJobScreenState();
}

class _CreateJobScreenState extends State<CreateJobScreen> {
  final _farmSizeCtrl = TextEditingController(text: '1.5');
  final _budgetMinCtrl = TextEditingController(text: '600');
  final _budgetMaxCtrl = TextEditingController(text: '900');
  DateTime _preferredDate = DateTime.now().add(const Duration(days: 2));
  bool _submitting = false;

  @override
  void dispose() {
    _farmSizeCtrl.dispose();
    _budgetMinCtrl.dispose();
    _budgetMaxCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _preferredDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 60)),
    );
    if (picked != null) setState(() => _preferredDate = picked);
  }

  void _submit() {
    setState(() => _submitting = true);
    final appState = context.read<AppState>();
    final job = appState.createJobFromReport(
      widget.report,
      farmSizeAcres: double.tryParse(_farmSizeCtrl.text) ?? 1.0,
      preferredDate: _preferredDate,
      budgetMin: double.tryParse(_budgetMinCtrl.text) ?? 500,
      budgetMax: double.tryParse(_budgetMaxCtrl.text) ?? 900,
    );
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => JobDetailScreen(jobId: job.id)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final report = widget.report;
    return Scaffold(
      appBar: AppBar(title: const Text('Request Spray Workers')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: severityStyleFor(report.severity).background,
                  child: Icon(severityStyleFor(report.severity).icon, color: severityStyleFor(report.severity).textColor),
                ),
                title: Text(report.diseaseName, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('${report.severity} • ${report.treatmentTimeline}'),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Farm Size (acres)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 8),
            TextField(controller: _farmSizeCtrl, keyboardType: const TextInputType.numberWithOptions(decimal: true)),
            const SizedBox(height: 18),
            const Text('Preferred Date', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 8),
            InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: borderSlate),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded, size: 18, color: primaryGreen),
                    const SizedBox(width: 10),
                    Text(_preferredDate.toLocal().toString().split(' ').first),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            const Text('Budget Range (₹/day)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _budgetMinCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Min'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _budgetMaxCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Max'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: const Color(0xFFF0FDF4), borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFBBF7D0))),
              child: const Row(
                children: [
                  Icon(Icons.auto_awesome_rounded, color: primaryGreen, size: 18),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Our matching engine will rank the top 5 nearby workers by distance, reliability, skill match, availability and history.',
                      style: TextStyle(fontSize: 12, color: darkGreen),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _submitting ? null : _submit,
              style: FilledButton.styleFrom(
                backgroundColor: primaryGreen,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('Find Matching Workers', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
