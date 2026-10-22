import 'dart:io';

/// Result of a single crop diagnostic scan, persisted into the farmer's report history.
class DiseaseReport {
  final String id;
  final String farmerId;
  final File? imageFile;
  final String diseaseName;
  final String severity;
  final double confidence;
  final String treatmentTimeline;
  final DateTime createdAt;

  /// Mock weather signals shown alongside the report, mirroring the
  /// weather_humidity / weather_rainfall fields used by the spray-timeline
  /// rule engine in the project spec.
  final double weatherHumidity;
  final double weatherRainfallMm;

  /// Whether a follow-up job request has already been created from this report.
  bool hasLinkedJob;

  /// True when this scan actually ran through the on-device TFLite model
  /// (see MODEL_ATTRIBUTION.md); false when it came from the demo fallback.
  final bool usedRealModel;

  DiseaseReport({
    required this.id,
    required this.farmerId,
    required this.imageFile,
    required this.diseaseName,
    required this.severity,
    required this.confidence,
    required this.treatmentTimeline,
    required this.createdAt,
    required this.weatherHumidity,
    required this.weatherRainfallMm,
    this.hasLinkedJob = false,
    this.usedRealModel = false,
  });

  bool get isHealthy => diseaseName == 'Healthy';
}
