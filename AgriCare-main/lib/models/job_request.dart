import 'rating.dart';

/// Lifecycle of a job request, matching the `job_requests.status` enum
/// in the project spec: open -> matched -> confirmed -> in_progress -> completed
/// (or cancelled at any point before completion).
enum JobStatus { open, matched, confirmed, inProgress, completed, cancelled }

enum DepositStatus { none, held, refunded, forfeited }

/// A single ranked worker suggestion produced by the matching engine for a job.
class JobMatch {
  final String workerId;
  final double matchScore;
  final double distanceKm;
  final String matchReason;
  final int rank;
  double? quotedPrice;

  JobMatch({
    required this.workerId,
    required this.matchScore,
    required this.distanceKm,
    required this.matchReason,
    required this.rank,
    this.quotedPrice,
  });
}

class JobRequest {
  final String id;
  final String? reportId;
  final String farmerId;
  final String title;
  final String description;
  final String requiredSkill;
  final double farmSizeAcres;
  final DateTime preferredDate;
  final double budgetMin;
  final double budgetMax;
  final DateTime createdAt;

  JobStatus status;
  List<JobMatch> matches;
  String? confirmedWorkerId;
  double depositAmount;
  DepositStatus depositStatus;
  String? completionPhotoPath;
  JobRating? rating;

  JobRequest({
    required this.id,
    this.reportId,
    required this.farmerId,
    required this.title,
    required this.description,
    required this.requiredSkill,
    required this.farmSizeAcres,
    required this.preferredDate,
    required this.budgetMin,
    required this.budgetMax,
    required this.createdAt,
    this.status = JobStatus.open,
    List<JobMatch>? matches,
    this.confirmedWorkerId,
    this.depositAmount = 200,
    this.depositStatus = DepositStatus.none,
    this.completionPhotoPath,
    this.rating,
  }) : matches = matches ?? [];
}

extension JobStatusLabel on JobStatus {
  String get label {
    switch (this) {
      case JobStatus.open:
        return 'Open';
      case JobStatus.matched:
        return 'Matched';
      case JobStatus.confirmed:
        return 'Confirmed';
      case JobStatus.inProgress:
        return 'In Progress';
      case JobStatus.completed:
        return 'Completed';
      case JobStatus.cancelled:
        return 'Cancelled';
    }
  }
}
