class JobRating {
  final int punctuality;
  final int quality;
  final int communication;
  final int overall;
  final String comment;
  final DateTime createdAt;

  JobRating({
    required this.punctuality,
    required this.quality,
    required this.communication,
    required this.overall,
    required this.comment,
    required this.createdAt,
  });
}
