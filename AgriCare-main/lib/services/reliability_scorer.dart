import '../models/rating.dart';
import '../models/spray_worker.dart';

/// Recomputes a worker's reliability score after a completed, rated job.
///
/// The full system trains an XGBoost regressor over acceptance rate,
/// cancellation rate, response time, on-time arrival, avg rating, disputes
/// and jobs completed (see "ML Model 4 — Worker Reliability Scorer"). For
/// the on-device MVP we approximate that behaviour with a bounded weighted
/// update: the score drifts toward the new job's rating, with the pull
/// shrinking as completedJobs grows — mimicking how a single job's
/// influence on a trained model fades with more historical data.
class ReliabilityScorer {
  static void applyCompletedJob(SprayWorker worker, JobRating rating) {
    final ratingOutOf100 = (rating.overall / 5) * 100;
    final influence = 1 / (worker.completedJobs + 4);
    worker.reliabilityScore =
        (worker.reliabilityScore * (1 - influence) + ratingOutOf100 * influence)
            .clamp(0, 100);

    worker.rating =
        ((worker.rating * worker.completedJobs) + rating.overall) /
            (worker.completedJobs + 1);
    worker.completedJobs += 1;
  }
}
