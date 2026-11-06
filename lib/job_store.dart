import 'package:flutter/foundation.dart';

import 'notification_store.dart';

/// A job posted by a user.
class Job {
  Job({
    String? id,
    required this.title,
    required this.setup,
    required this.type,
    required this.location,
    required this.pay,
    required this.description,
    required this.postedBy,
    this.experience = 'No experience needed',
    this.workSchedule = '',
    this.accessibility = '',
    this.requirements = '',
    this.closed = false,
    DateTime? postedAt,
    this.match,
  })  : id = id ?? DateTime.now().microsecondsSinceEpoch.toString(),
        postedAt = postedAt ?? DateTime.now();

  final String id;
  final String title;
  final String setup; // Work arrangement: On-site, Remote or Hybrid
  final String type; // Full Time, Part Time or One-time task
  final String location;
  final String pay;
  final String description;

  /// For example "No experience needed" or "2+ years experience".
  final String experience;

  /// For example "Mon-Fri, 8:00 AM - 5:00 PM".
  final String workSchedule;

  /// For example "Step-free entrance, accessible restrooms". Optional.
  final String accessibility;

  /// One requirement per line. Optional.
  final String requirements;

  /// TODO (backend): replace this name with the poster's user id.
  final String postedBy;

  /// Not used right now. Kept so older code keeps working.
  final bool closed;

  final DateTime postedAt;

  /// Match score from 0 to 100. TODO (backend): fill this in when matching
  /// exists. The badge on the Job Details screen only shows when this is set.
  final int? match;

  Job copyWith({bool? closed}) {
    return Job(
      id: id,
      title: title,
      setup: setup,
      type: type,
      location: location,
      pay: pay,
      description: description,
      postedBy: postedBy,
      experience: experience,
      workSchedule: workSchedule,
      accessibility: accessibility,
      requirements: requirements,
      closed: closed ?? this.closed,
      postedAt: postedAt,
      match: match,
    );
  }
}

/// The steps of an application, in order.
const List<String> kStatusSteps = ['Under Review', 'Interview', 'Hired'];

/// Every status an application can have.
const List<String> kAllStatuses = [
  'Under Review',
  'Interview',
  'Hired',
  'Not Selected',
];

/// A job a person applied for, and how far it has gone.
class Application {
  Application({
    required this.jobId,
    required this.applicant,
    this.status = 'Under Review',
    DateTime? appliedAt,
  }) : appliedAt = appliedAt ?? DateTime.now();

  final String jobId;

  /// Who applied. TODO (backend): replace this name with the user id.
  final String applicant;

  /// One of [kAllStatuses].
  final String status;
  final DateTime appliedAt;

  /// Not Selected applications are closed. Everything else is active.
  bool get isActive => status != 'Not Selected';

  Application copyWith({String? status}) => Application(
        jobId: jobId,
        applicant: applicant,
        status: status ?? this.status,
        appliedAt: appliedAt,
      );
}

/// Temporary storage for jobs (kept in memory only).
///
/// TODO (backend): replace the body of these methods with calls to the
/// real API / database. The screens only use the members below.
class JobStore extends ChangeNotifier {
  JobStore._();
  static final JobStore instance = JobStore._();

  /// The person who is logged in. The Home screen sets this.
  /// TODO (backend): replace with the signed-in user.
  String currentUser = '';

  final List<Job> _jobs = [];
  final Set<String> _saved = {};
  final Map<String, Application> _applications = {};

  String _key(String jobId) => '$jobId|$currentUser';

  /// Newest job first.
  List<Job> get jobs => _jobs.reversed.toList();

  Job? byId(String id) {
    for (final job in _jobs) {
      if (job.id == id) return job;
    }
    return null;
  }

  void add(Job job) {
    _jobs.add(job);
    notifyListeners();
  }

  void update(Job job) {
    final index = _jobs.indexWhere((j) => j.id == job.id);
    if (index == -1) return;
    final old = _jobs[index];
    _jobs[index] = Job(
      id: job.id,
      title: job.title,
      setup: job.setup,
      type: job.type,
      location: job.location,
      pay: job.pay,
      description: job.description,
      postedBy: job.postedBy,
      experience: job.experience,
      workSchedule: job.workSchedule,
      accessibility: job.accessibility,
      requirements: job.requirements,
      closed: old.closed,
      postedAt: old.postedAt,
      match: old.match,
    );
    notifyListeners();
  }

  void remove(String id) {
    _jobs.removeWhere((j) => j.id == id);
    _saved.removeWhere((key) => key.startsWith('$id|'));
    _applications.removeWhere((key, a) => a.jobId == id);
    notifyListeners();
  }

  // Saved jobs (for the logged-in person).
  bool isSaved(String id) => _saved.contains(_key(id));

  void toggleSave(String id) {
    final key = _key(id);
    if (!_saved.remove(key)) _saved.add(key);
    notifyListeners();
  }

  // Applications (for the logged-in person).
  bool hasApplied(String id) => _applications.containsKey(_key(id));

  Application? applicationFor(String id) => _applications[_key(id)];

  /// The logged-in person's applications, newest first.
  List<Application> get applications {
    final list =
        _applications.values.where((a) => a.applicant == currentUser).toList();
    list.sort((a, b) => b.appliedAt.compareTo(a.appliedAt));
    return list;
  }

  /// The jobs the person applied for, newest application first.
  List<Job> get appliedJobs {
    final result = <Job>[];
    for (final a in applications) {
      final job = byId(a.jobId);
      if (job != null) result.add(job);
    }
    return result;
  }

  void apply(String id) {
    final key = _key(id);
    if (_applications.containsKey(key)) return;
    _applications[key] = Application(jobId: id, applicant: currentUser);
    final job = byId(id);
    if (job != null) {
      NotificationStore.instance.add(
        forUser: job.postedBy,
        title: 'New application',
        body: '$currentUser applied for ${job.title}.',
        kind: NotificationKind.application,
        jobId: id,
        otherUser: currentUser,
      );
    }
    notifyListeners();
  }

  /// TODO (backend): the status should come from the poster's decision.
  void setStatus(String id, String status) {
    final key = _key(id);
    final old = _applications[key];
    if (old == null) return;
    _applications[key] = old.copyWith(status: status);
    final job = byId(id);
    if (job != null) {
      NotificationStore.instance.add(
        forUser: old.applicant,
        title: 'Application update',
        body: '${job.title} is now: $status.',
        kind: NotificationKind.status,
        jobId: id,
      );
    }
    notifyListeners();
  }
}