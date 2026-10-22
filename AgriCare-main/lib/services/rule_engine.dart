/// Maps disease + severity to a recommended spraying/treatment timeline.
/// Mirrors the "Spraying Timeline — Rule Engine (v1)" table in the project spec.
class TreatmentRuleEngine {
  static String calculateTimeline(String disease, String severity) {
    if (disease == 'Koleroga') {
      if (severity == 'Severe') {
        return 'Emergency: Spray Bordeaux mixture within 24 hours.';
      } else if (severity == 'Moderate') {
        return 'Spray fungicide within 3–5 days.';
      } else {
        return 'Apply preventive organic spray within 7 days.';
      }
    } else if (disease == 'Yellow Leaf Disease') {
      return 'No chemical cure — consult local Krishi Vigyan Kendra (KVK) officer.';
    } else if (disease == 'Healthy') {
      return 'No chemical treatment needed. Inspect monthly.';
    } else if (disease == 'Bud Rot') {
      if (severity == 'Severe') {
        return 'Emergency: Remove affected crown and apply copper oxychloride within 24 hours.';
      } else if (severity == 'Moderate') {
        return 'Apply copper fungicide and isolate infected palms within 3 days.';
      } else {
        return 'Inspect crown thoroughly and apply preventive fungicide within 5 days.';
      }
    } else if (disease == 'Fruit Rot') {
      if (severity == 'Severe') {
        return 'Emergency: Collect fallen nuts & spray 1% Bordeaux mixture within 48 hours.';
      } else {
        return 'Apply preventive spray of 1% Bordeaux mixture at 15-day intervals.';
      }
    } else if (disease == 'Anthracnose') {
      if (severity == 'Severe') {
        return 'Apply systemic fungicide (Carbendazim) immediately within 48 hours.';
      } else {
        return 'Spray recommended copper fungicide within 5 days.';
      }
    }
    return 'Inspect crop condition with local agricultural extension worker.';
  }

  /// Skill tag required from a spray worker for a given disease, used by the
  /// matching engine's skill-match factor (checked against
  /// SprayWorker.specializedDiseases).
  static String requiredSkillFor(String disease) => disease;
}
