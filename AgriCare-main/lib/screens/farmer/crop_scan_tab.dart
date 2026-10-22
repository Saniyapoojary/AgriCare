import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../models/disease_report.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/severity_badge.dart';
import 'create_job_screen.dart';

class CropScanTab extends StatefulWidget {
  const CropScanTab({super.key});

  @override
  State<CropScanTab> createState() => _CropScanTabState();
}

class _CropScanTabState extends State<CropScanTab> {
  File? _selectedImage;
  bool _isAnalyzing = false;
  DiseaseReport? _result;
  bool _showHeatmap = false;

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final appState = context.read<AppState>();
    try {
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 85,
      );
      if (pickedFile == null) return;

      setState(() {
        _selectedImage = File(pickedFile.path);
        _isAnalyzing = true;
        _result = null;
        _showHeatmap = false;
      });

      final report = await appState.runDiagnostic(_selectedImage!);

      if (mounted) {
        setState(() {
          _isAnalyzing = false;
          _result = report;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isAnalyzing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error selecting image: $e'), backgroundColor: Colors.red[700]),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFF0FDF4), Color(0xFFDCFCE7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFBBF7D0)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: primaryGreen, borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('AI Arecanut Health Diagnostic Engine',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF14532D), fontSize: 14)),
                      SizedBox(height: 2),
                      Text('Classifies Koleroga, Bud Rot, Yellow Leaf Disease & more',
                          style: TextStyle(color: darkGreen, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            height: 250,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _selectedImage != null ? primaryGreen : borderSlate,
                width: _selectedImage != null ? 2.5 : 1.5,
              ),
              boxShadow: const [BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.04), blurRadius: 12, offset: Offset(0, 4))],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: _selectedImage != null
                        ? Image.file(_selectedImage!, fit: BoxFit.cover)
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: const BoxDecoration(color: Color(0xFFF0FDF4), shape: BoxShape.circle),
                                child: const Icon(Icons.add_a_photo_rounded, size: 44, color: primaryGreen),
                              ),
                              const SizedBox(height: 14),
                              Text('Upload or Take Palm Photo',
                                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: const Color(0xFF1E293B))),
                              const SizedBox(height: 4),
                              Text('Capture leaf, nut, or crown condition',
                                  style: theme.textTheme.bodySmall?.copyWith(color: const Color(0xFF64748B))),
                            ],
                          ),
                  ),
                  if (_showHeatmap && _selectedImage != null && _result != null && !_result!.isHealthy)
                    Positioned.fill(
                      child: IgnorePointer(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: RadialGradient(
                              center: Alignment.center,
                              radius: 0.85,
                              colors: [
                                Colors.red.withAlpha(140),
                                Colors.orange.withAlpha(90),
                                Colors.yellow.withAlpha(30),
                                Colors.transparent,
                              ],
                              stops: const [0.0, 0.4, 0.7, 1.0],
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (_selectedImage != null && !_isAnalyzing && _result != null) ...[
                    Positioned(
                      bottom: 12,
                      right: 12,
                      child: GestureDetector(
                        onTap: _result!.isHealthy ? null : () => setState(() => _showHeatmap = !_showHeatmap),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(color: Colors.black.withAlpha(180), borderRadius: BorderRadius.circular(20)),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _showHeatmap ? Icons.visibility_off_rounded : Icons.local_fire_department_rounded,
                                color: const Color(0xFF4ADE80),
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _result!.isHealthy
                                    ? 'Image Ready'
                                    : (_showHeatmap ? 'Hide AI Heatmap' : 'Show AI Heatmap'),
                                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => _pickImage(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt_rounded, size: 20),
                  label: const Text('Camera'),
                  style: FilledButton.styleFrom(
                    backgroundColor: primaryGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library_rounded, size: 20),
                  label: const Text('Gallery'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: primaryGreen,
                    side: const BorderSide(color: primaryGreen, width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (_isAnalyzing)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    CircularProgressIndicator(color: primaryGreen, strokeWidth: 3.5),
                    SizedBox(height: 18),
                    Text('Running Neural Diagnostics...', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1E293B))),
                    SizedBox(height: 6),
                    Text('Analyzing symptoms & calculating severity rules', style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
                  ],
                ),
              ),
            ),
          if (_result != null && !_isAnalyzing) _buildResultCard(context, _result!),
        ],
      ),
    );
  }

  Widget _buildResultCard(BuildContext context, DiseaseReport result) {
    final theme = Theme.of(context);
    final confidencePercent = (result.confidence * 100).toStringAsFixed(1);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: result.isHealthy ? const Color(0xFF86EFAC) : const Color(0xFFFCA5A5), width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.analytics_rounded, size: 16, color: primaryGreen),
                    SizedBox(width: 6),
                    Text('DIAGNOSIS REPORT',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 1.2, color: primaryGreen)),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: borderSlate),
                  ),
                  child: Text('$confidencePercent% Match',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Tooltip(
              message: result.usedRealModel
                  ? 'Health signal from an on-device MobileNet model (generic plant classifier — see assets/models/MODEL_ATTRIBUTION.md). Specific disease type is not yet arecanut-trained.'
                  : 'No on-device model available on this platform/build — showing a demo prediction.',
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: result.usedRealModel ? const Color(0xFFDBEAFE) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      result.usedRealModel ? Icons.memory_rounded : Icons.science_outlined,
                      size: 13,
                      color: result.usedRealModel ? const Color(0xFF1D4ED8) : const Color(0xFF64748B),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      result.usedRealModel ? 'On-device model screening' : 'Demo mode (no model loaded)',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: result.usedRealModel ? const Color(0xFF1D4ED8) : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        result.diseaseName,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: result.isHealthy ? primaryGreen : const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text('Arecanut Palm Infection Diagnostic', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                    ],
                  ),
                ),
                SeverityBadge(severity: result.severity),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(12), border: Border.all(color: borderSlate)),
              child: Row(
                children: [
                  const Icon(Icons.water_drop_outlined, size: 16, color: Color(0xFF2563EB)),
                  const SizedBox(width: 6),
                  Text('Humidity: ${result.weatherHumidity.toStringAsFixed(0)}%', style: const TextStyle(fontSize: 12, color: Color(0xFF334155))),
                  const SizedBox(width: 16),
                  const Icon(Icons.grain_rounded, size: 16, color: Color(0xFF0EA5E9)),
                  const SizedBox(width: 6),
                  Text('Rainfall: ${result.weatherRainfallMm.toStringAsFixed(0)}mm', style: const TextStyle(fontSize: 12, color: Color(0xFF334155))),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(14), border: Border.all(color: borderSlate)),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: const Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.schedule_rounded, color: primaryGreen, size: 20),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Recommended Treatment Timeline:',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: primaryGreen)),
                        const SizedBox(height: 4),
                        Text(result.treatmentTimeline,
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, height: 1.3, color: Color(0xFF1E293B))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            if (!result.isHealthy)
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: result.hasLinkedJob
                      ? null
                      : () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => CreateJobScreen(report: result)),
                          ),
                  icon: Icon(result.hasLinkedJob ? Icons.check_circle_rounded : Icons.engineering_rounded, size: 20),
                  label: Text(
                    result.hasLinkedJob ? 'Job Already Requested' : 'Find Spray Workers Nearby',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: primaryGreen,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: const Color(0xFF94A3B8),
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
