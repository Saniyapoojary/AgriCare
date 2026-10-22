/// A registered spray/agricultural worker in the marketplace.
///
/// Fields intentionally mirror the `worker_profiles` table in the project
/// spec (skills, reliability_score, total_jobs_completed, avg_rating,
/// cancellation_rate, is_available) so the on-device matching engine and
/// reliability scorer have realistic inputs to operate on.
class SprayWorker {
  /// Equal to the owning AppUser.id for workers created through
  /// registration; a synthetic id for seeded demo/NPC workers.
  final String id;
  final String name;
  final double locationLat;
  final double locationLng;
  double reliabilityScore;
  final String roleSpecialty;
  final int dailyRate;
  double rating;
  int completedJobs;
  double cancellationRate;
  bool isAvailable;
  final int experienceYears;
  final List<String> specializedDiseases;

  SprayWorker({
    required this.id,
    required this.name,
    required this.locationLat,
    required this.locationLng,
    required this.reliabilityScore,
    required this.roleSpecialty,
    required this.dailyRate,
    required this.rating,
    required this.completedJobs,
    required this.cancellationRate,
    required this.experienceYears,
    required this.specializedDiseases,
    this.isAvailable = true,
  });
}
