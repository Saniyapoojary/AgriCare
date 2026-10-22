import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../tflite_helper.dart';
import 'rule_engine.dart';

const _modelInputSize = 224;
const _labelsAssetPath = 'assets/models/plant_labels.txt';
const _modelAssetPath = 'assets/models/arecanut_model.tflite';

/// Transient result of a single diagnostic run, before it is persisted as a
/// DiseaseReport.
class DiagnosticResult {
  final String diseaseName;
  final String severity;
  final double confidence;
  final String treatmentTimeline;
  final DateTime timestamp;
  final double weatherHumidity;
  final double weatherRainfallMm;

  /// True when this result came from actually running the bundled TFLite
  /// model on the photo; false when it came from the random demo fallback
  /// (e.g. on web, or when no model/interpreter is available).
  final bool usedRealModel;

  DiagnosticResult({
    required this.diseaseName,
    required this.severity,
    required this.confidence,
    required this.treatmentTimeline,
    required this.timestamp,
    required this.weatherHumidity,
    required this.weatherRainfallMm,
    required this.usedRealModel,
  });
}

const _arecanutDiseases = [
  'Koleroga',
  'Koleroga', // weighted for demonstration flow
  'Bud Rot',
  'Yellow Leaf Disease',
  'Fruit Rot',
  'Anthracnose',
];

/// Runs on-device inference (via [tflite_flutter] when a real model asset is
/// bundled) with a random demo fallback so the rest of the app — severity
/// badges, spray timeline, worker matching — is fully exercisable without a
/// trained model present.
///
/// The bundled `arecanut_model.tflite` is a generic MobileNet classifier
/// trained on the PlantVillage dataset (see
/// assets/models/MODEL_ATTRIBUTION.md) — it has no arecanut-specific
/// disease classes. What it *can* meaningfully tell us is whether a leaf
/// photo looks visually healthy or diseased, so that binary signal (and its
/// confidence) drives severity; which specific arecanut disease is reported
/// still comes from the same weighted selection used in demo mode.
class TFLiteDiagnosticService {
  AppTFLiteInterpreter? _interpreter;
  List<String>? _labels;
  bool _isModelLoaded = false;

  TFLiteDiagnosticService() {
    _initModel();
  }

  Future<void> _initModel() async {
    try {
      _interpreter = await AppTFLiteInterpreter.loadModel(_modelAssetPath);
      if (_interpreter == null) {
        _isModelLoaded = false;
        return;
      }
      final raw = await rootBundle.loadString(_labelsAssetPath);
      _labels = raw.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty).toList();
      _isModelLoaded = true;
    } catch (e) {
      debugPrint('TFLite asset missing or platform unsupported. Fallback active: $e');
      _isModelLoaded = false;
    }
  }

  Future<DiagnosticResult> analyzeImage(File imageFile) async {
    if (_isModelLoaded && _interpreter != null && _labels != null) {
      try {
        return await _runRealInference(imageFile, _interpreter!, _labels!);
      } catch (e) {
        debugPrint('TFLite inference fallback triggered: $e');
      }
    }
    return _runDemoFallback();
  }

  Future<DiagnosticResult> _runRealInference(
    File imageFile,
    AppTFLiteInterpreter interpreter,
    List<String> labels,
  ) async {
    final pixels = await _preprocessImage(imageFile, _modelInputSize);
    final scores = interpreter.classify(pixels, _modelInputSize, labels.length);

    double healthyProb = 0;
    double diseasedProb = 0;
    for (var i = 0; i < scores.length && i < labels.length; i++) {
      if (labels[i].toLowerCase().contains('healthy')) {
        healthyProb += scores[i];
      } else {
        diseasedProb += scores[i];
      }
    }

    final random = Random();
    String disease;
    String severity;
    double confidence;

    if (healthyProb >= diseasedProb) {
      disease = 'Healthy';
      severity = 'Mild';
      confidence = healthyProb;
    } else {
      disease = _arecanutDiseases[random.nextInt(_arecanutDiseases.length)];
      confidence = diseasedProb;
      if (diseasedProb >= 0.85) {
        severity = 'Severe';
      } else if (diseasedProb >= 0.65) {
        severity = 'Moderate';
      } else {
        severity = 'Mild';
      }
    }

    final timeline = TreatmentRuleEngine.calculateTimeline(disease, severity);
    final humidity = 55 + random.nextDouble() * 35;
    final rainfall = random.nextDouble() * 40;

    return DiagnosticResult(
      diseaseName: disease,
      severity: severity,
      confidence: confidence.clamp(0.0, 1.0),
      treatmentTimeline: timeline,
      timestamp: DateTime.now(),
      weatherHumidity: humidity,
      weatherRainfallMm: rainfall,
      usedRealModel: true,
    );
  }

  /// Decodes and downsamples the photo to the model's expected
  /// 224x224x3 input, returning a flat row-major RGB buffer normalized to
  /// [0, 1] (matching the model's training-time preprocessing).
  Future<List<double>> _preprocessImage(File imageFile, int size) async {
    final bytes = await imageFile.readAsBytes();
    final codec = await ui.instantiateImageCodec(bytes, targetWidth: size, targetHeight: size);
    final frame = await codec.getNextFrame();
    final byteData = await frame.image.toByteData(format: ui.ImageByteFormat.rawRgba);
    if (byteData == null) {
      throw StateError('Failed to read decoded image pixels.');
    }
    final rgba = byteData.buffer.asUint8List();
    final out = Float64List(size * size * 3);
    for (var i = 0, p = 0; i < size * size; i++, p += 4) {
      out[i * 3] = rgba[p] / 255.0;
      out[i * 3 + 1] = rgba[p + 1] / 255.0;
      out[i * 3 + 2] = rgba[p + 2] / 255.0;
    }
    return out;
  }

  Future<DiagnosticResult> _runDemoFallback() async {
    // Demo/fallback prediction path — used whenever no trained model
    // interpreter is available (e.g. on web, or if inference throws).
    await Future.delayed(const Duration(milliseconds: 1200));

    final random = Random();
    final diseases = [..._arecanutDiseases, 'Healthy'];
    final disease = diseases[random.nextInt(diseases.length)];

    String severity = 'Mild';
    if (disease != 'Healthy') {
      final severities = ['Mild', 'Moderate', 'Severe'];
      severity = severities[random.nextInt(severities.length)];
    }

    final confidence = 0.89 + (random.nextDouble() * 0.09); // 89% - 98%
    final timeline = TreatmentRuleEngine.calculateTimeline(disease, severity);
    final humidity = 55 + random.nextDouble() * 35; // 55% - 90%
    final rainfall = random.nextDouble() * 40; // 0 - 40mm

    return DiagnosticResult(
      diseaseName: disease,
      severity: severity,
      confidence: confidence,
      treatmentTimeline: timeline,
      timestamp: DateTime.now(),
      weatherHumidity: humidity,
      weatherRainfallMm: rainfall,
      usedRealModel: false,
    );
  }
}
