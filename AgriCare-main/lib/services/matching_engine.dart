import '../models/job_request.dart';
import '../models/spray_worker.dart';
import 'geo_utils.dart';

/// Weighted multi-factor worker ranking, mirroring "ML Model 5 — Smart
/// Worker Matching Engine" from the project spec: distance, reliability,
/// skill match, availability and historical performance are combined into
/// a single composite score, with a SHAP-style human-readable reason.
class MatchingEngine {
  static const _distanceWeight = 0.3;
  static const _reliabilityWeight = 0.3;
  static const _skillWeight = 0.2;
  static const _availabilityWeight = 0.1;
  static const _historyWeight = 0.1;

  static List<JobMatch> rankWorkers({
    required JobRequest job,
    required double farmerLat,
    required double farmerLng,
    required List<SprayWorker> workers,
    int topN = 5,
  }) {
    final scored = <JobMatch>[];

    for (final worker in workers) {
      final distanceKm = haversineKm(
        farmerLat,
        farmerLng,
        worker.locationLat,
        worker.locationLng,
      );

      final distanceScore = (1 - (distanceKm / 20)).clamp(0.0, 1.0);
      final reliabilityScore = (worker.reliabilityScore / 100).clamp(0.0, 1.0);
      final hasSkill = worker.specializedDiseases.contains(job.requiredSkill);
      final skillScore = hasSkill ? 1.0 : 0.3;
      final availabilityScore = worker.isAvailable ? 1.0 : 0.0;
      final historyScore = (worker.completedJobs / 200).clamp(0.0, 1.0);

      final composite = distanceScore * _distanceWeight +
          reliabilityScore * _reliabilityWeight +
          skillScore * _skillWeight +
          availabilityScore * _availabilityWeight +
          historyScore * _historyWeight;

      final reason = _buildReason(
        worker: worker,
        distanceKm: distanceKm,
        hasSkill: hasSkill,
        disease: job.requiredSkill,
      );

      scored.add(JobMatch(
        workerId: worker.id,
        matchScore: composite,
        distanceKm: distanceKm,
        matchReason: reason,
        rank: 0,
      ));
    }

    scored.sort((a, b) => b.matchScore.compareTo(a.matchScore));
    final top = scored.take(topN).toList();
    for (var i = 0; i < top.length; i++) {
      top[i] = JobMatch(
        workerId: top[i].workerId,
        matchScore: top[i].matchScore,
        distanceKm: top[i].distanceKm,
        matchReason: top[i].matchReason,
        rank: i + 1,
      );
    }
    return top;
  }

  static String _buildReason({
    required SprayWorker worker,
    required double distanceKm,
    required bool hasSkill,
    required String disease,
  }) {
    final firstName = worker.name.split(' ').first;
    final parts = <String>[
      '${distanceKm.toStringAsFixed(1)}km away',
      '${worker.reliabilityScore.toStringAsFixed(0)} reliability score',
      '${worker.completedJobs} completed jobs',
    ];
    if (hasSkill) {
      parts.add('proven experience with $disease');
    }
    return '$firstName ranked highly because he/she is ${parts.join(', ')}.';
  }
}
