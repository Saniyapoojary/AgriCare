import 'dart:io';

import 'package:flutter/foundation.dart';

import '../models/app_user.dart';
import '../models/disease_report.dart';
import '../models/job_request.dart';
import '../models/rating.dart';
import '../models/spray_worker.dart';
import '../services/diagnostic_service.dart';
import '../services/matching_engine.dart';
import '../services/mock_data.dart';
import '../services/reliability_scorer.dart';
import '../utils/id_generator.dart';

/// Single in-memory application store (auth, reports, jobs, worker
/// marketplace) shared across the app via Provider. Stands in for the
/// Django + PostgreSQL backend described in the project spec — every method
/// here maps to one of the documented REST endpoints, just executed
/// on-device instead of over HTTP.
class AppState extends ChangeNotifier {
  AppState() {
    workers = buildMockWorkers();
  }

  final TFLiteDiagnosticService _diagnosticService = TFLiteDiagnosticService();

  final List<AppUser> _users = [];
  AppUser? currentUser;

  late List<SprayWorker> workers;
  final List<DiseaseReport> reports = [];
  final List<JobRequest> jobs = [];

  bool get isLoggedIn => currentUser != null;

  // ---------------------------------------------------------------------
  // Auth  (POST /api/auth/register/, /api/auth/login/)
  // ---------------------------------------------------------------------

  AppUser? findUserByPhone(String phone) {
    for (final u in _users) {
      if (u.phone == phone) return u;
    }
    return null;
  }

  AppUser login(String phone) {
    final user = findUserByPhone(phone);
    if (user == null) {
      throw StateError('No account found for this phone number.');
    }
    currentUser = user;
    notifyListeners();
    return user;
  }

  AppUser register({
    required String name,
    required String phone,
    required UserRole role,
    List<String> workerSkills = const [],
    int dailyRate = 800,
  }) {
    final user = AppUser(
      id: generateId('user'),
      name: name,
      phone: phone,
      role: role,
      locationLat: defaultFarmLat,
      locationLng: defaultFarmLng,
      address: 'Sringeri Taluk, Chikmagalur District, Karnataka',
    );
    _users.add(user);

    if (role == UserRole.worker) {
      workers.add(SprayWorker(
        id: user.id,
        name: user.name,
        locationLat: user.locationLat,
        locationLng: user.locationLng,
        reliabilityScore: 70,
        roleSpecialty: workerSkills.isEmpty ? 'General Field Spraying' : '${workerSkills.first} Specialist',
        dailyRate: dailyRate,
        rating: 4.0,
        completedJobs: 0,
        cancellationRate: 0,
        experienceYears: 0,
        specializedDiseases: workerSkills,
      ));
    }

    currentUser = user;
    notifyListeners();
    return user;
  }

  void logout() {
    currentUser = null;
    notifyListeners();
  }

  SprayWorker? get currentWorkerProfile {
    if (currentUser == null) return null;
    for (final w in workers) {
      if (w.id == currentUser!.id) return w;
    }
    return null;
  }

  // ---------------------------------------------------------------------
  // Disease detection  (POST /api/predict/, GET /api/reports/)
  // ---------------------------------------------------------------------

  Future<DiseaseReport> runDiagnostic(File imageFile) async {
    final result = await _diagnosticService.analyzeImage(imageFile);
    final report = DiseaseReport(
      id: generateId('report'),
      farmerId: currentUser!.id,
      imageFile: imageFile,
      diseaseName: result.diseaseName,
      severity: result.severity,
      confidence: result.confidence,
      treatmentTimeline: result.treatmentTimeline,
      createdAt: result.timestamp,
      weatherHumidity: result.weatherHumidity,
      weatherRainfallMm: result.weatherRainfallMm,
      usedRealModel: result.usedRealModel,
    );
    reports.insert(0, report);
    notifyListeners();
    return report;
  }

  List<DiseaseReport> reportsForCurrentFarmer() {
    if (currentUser == null) return [];
    return reports.where((r) => r.farmerId == currentUser!.id).toList();
  }

  // ---------------------------------------------------------------------
  // Job lifecycle  (POST /api/jobs/, /api/jobs/{id}/matches/, /confirm/, /complete/, /rate/)
  // ---------------------------------------------------------------------

  JobRequest createJobFromReport(
    DiseaseReport report, {
    required double farmSizeAcres,
    required DateTime preferredDate,
    required double budgetMin,
    required double budgetMax,
    String? description,
  }) {
    final job = JobRequest(
      id: generateId('job'),
      reportId: report.id,
      farmerId: currentUser!.id,
      title: '${report.diseaseName} treatment — ${report.severity} severity',
      description: description ??
          'Spray treatment needed for ${report.diseaseName} (${report.severity}). '
              '${report.treatmentTimeline}',
      requiredSkill: report.diseaseName,
      farmSizeAcres: farmSizeAcres,
      preferredDate: preferredDate,
      budgetMin: budgetMin,
      budgetMax: budgetMax,
      createdAt: DateTime.now(),
    );
    report.hasLinkedJob = true;
    jobs.insert(0, job);
    generateMatches(job);
    return job;
  }

  JobRequest createDirectJobRequest({
    required String title,
    required String description,
    required String requiredSkill,
    required double farmSizeAcres,
    required DateTime preferredDate,
    required double budgetMin,
    required double budgetMax,
  }) {
    final job = JobRequest(
      id: generateId('job'),
      farmerId: currentUser!.id,
      title: title,
      description: description,
      requiredSkill: requiredSkill,
      farmSizeAcres: farmSizeAcres,
      preferredDate: preferredDate,
      budgetMin: budgetMin,
      budgetMax: budgetMax,
      createdAt: DateTime.now(),
    );
    jobs.insert(0, job);
    generateMatches(job);
    return job;
  }

  void generateMatches(JobRequest job) {
    job.matches = MatchingEngine.rankWorkers(
      job: job,
      farmerLat: currentUser?.locationLat ?? defaultFarmLat,
      farmerLng: currentUser?.locationLng ?? defaultFarmLng,
      workers: workers,
    );
    job.status = JobStatus.matched;
    notifyListeners();
  }

  void confirmWorker(JobRequest job, String workerId, {double? quotedPrice}) {
    job.confirmedWorkerId = workerId;
    for (final m in job.matches) {
      if (m.workerId == workerId) m.quotedPrice = quotedPrice ?? job.budgetMax;
    }
    job.depositStatus = DepositStatus.held;
    currentUser!.walletBalance -= job.depositAmount;
    job.status = JobStatus.confirmed;
    notifyListeners();
  }

  List<JobRequest> jobsForCurrentFarmer() {
    if (currentUser == null) return [];
    return jobs.where((j) => j.farmerId == currentUser!.id).toList();
  }

  /// Jobs suggested to the given worker that are still awaiting confirmation.
  List<JobRequest> availableJobsForWorker(String workerId) {
    return jobs.where((j) {
      if (j.status != JobStatus.matched) return false;
      return j.matches.any((m) => m.workerId == workerId);
    }).toList();
  }

  List<JobRequest> activeJobsForWorker(String workerId) {
    return jobs.where((j) {
      return j.confirmedWorkerId == workerId &&
          (j.status == JobStatus.confirmed ||
              j.status == JobStatus.inProgress ||
              j.status == JobStatus.completed);
    }).toList();
  }

  void workerAcceptJob(JobRequest job, String workerId, double quotedPrice) {
    confirmWorker(job, workerId, quotedPrice: quotedPrice);
  }

  void workerDeclineJob(JobRequest job, String workerId) {
    job.matches.removeWhere((m) => m.workerId == workerId);
    notifyListeners();
  }

  void workerStartJob(JobRequest job) {
    job.status = JobStatus.inProgress;
    notifyListeners();
  }

  void workerSubmitCompletionPhoto(JobRequest job, String photoPath) {
    job.completionPhotoPath = photoPath;
    notifyListeners();
  }

  /// Farmer confirms the job is done and submits a rating in one step —
  /// releases the escrowed deposit and updates the worker's reliability score.
  void confirmCompletionAndRate(JobRequest job, JobRating rating) {
    job.status = JobStatus.completed;
    job.rating = rating;

    if (job.depositStatus == DepositStatus.held) {
      job.depositStatus = DepositStatus.refunded;
      currentUser!.walletBalance += job.depositAmount;
    }

    final worker = _findWorker(job.confirmedWorkerId);
    if (worker != null) {
      ReliabilityScorer.applyCompletedJob(worker, rating);
    }
    notifyListeners();
  }

  void cancelJob(JobRequest job) {
    if (job.depositStatus == DepositStatus.held) {
      job.depositStatus = DepositStatus.refunded;
      currentUser!.walletBalance += job.depositAmount;
    }
    job.status = JobStatus.cancelled;
    notifyListeners();
  }

  SprayWorker? _findWorker(String? id) {
    if (id == null) return null;
    for (final w in workers) {
      if (w.id == id) return w;
    }
    return null;
  }

  SprayWorker? workerById(String id) => _findWorker(id);
}
