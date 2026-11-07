import 'dart:async';

import 'package:campus_incident_app/models/app_user.dart';
import 'package:campus_incident_app/models/incident.dart';
import 'package:campus_incident_app/providers/auth_provider.dart';
import 'package:campus_incident_app/services/auth_service.dart';
import 'package:campus_incident_app/services/incident_service.dart';
import 'package:campus_incident_app/services/storage_service.dart';
// Prefixed: firebase_auth also exports a class named AuthProvider.
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:image_picker/image_picker.dart';

/// Incident service stub driven by two controllers.
class FakeIncidentService extends IncidentService {
  final StreamController<List<Incident>> all = StreamController<List<Incident>>.broadcast();
  final StreamController<List<Incident>> mine = StreamController<List<Incident>>.broadcast();
  final StreamController<Incident?> single = StreamController<Incident?>.broadcast();

  Incident? created;
  int createCount = 0;
  Duration createDelay = Duration.zero;
  String? updatedId;
  String? deletedId;
  IncidentStatus? updatedStatus;
  bool failCreate = false;

  @override
  String newIncidentId() => 'inc-test-1';

  @override
  Stream<List<Incident>> streamAllIncidents() => all.stream;

  @override
  Stream<List<Incident>> streamIncidentsByUser(String uid) => mine.stream;

  @override
  Stream<Incident?> streamIncident(String id) => single.stream;

  @override
  Future<String> createIncident(Incident incident) async {
    if (createDelay > Duration.zero) await Future<void>.delayed(createDelay);
    if (failCreate) throw StateError('The write failed.');
    createCount++;
    created = incident;
    return incident.id;
  }

  @override
  Future<void> updateStatus(String id, IncidentStatus newStatus, String staffUid) async {
    updatedId = id;
    updatedStatus = newStatus;
  }

  @override
  Future<void> deleteIncident(String id) async {
    deletedId = id;
  }

  Future<void> dispose() async {
    await all.close();
    await mine.close();
    await single.close();
  }
}

class FakeStorageService extends StorageService {
  int uploadCount = 0;

  @override
  Future<String> uploadIncidentPhoto(XFile photo, String incidentId) async {
    uploadCount++;
    return 'https://example.com/$incidentId.jpg';
  }
}

/// Auth service stub that never touches Firebase.
class FakeAuthService extends AuthService {
  bool signedOut = false;

  @override
  Stream<fb.User?> get authStateChanges => const Stream<fb.User?>.empty();

  @override
  Future<void> signOut() async {
    signedOut = true;
  }
}

/// Signed-in auth provider without a live Firebase session.
class FakeAuthProvider extends AuthProvider {
  FakeAuthProvider({this.user, FakeAuthService? authService})
      : super(authService: authService ?? FakeAuthService());

  final AppUser? user;

  @override
  AppUser? get currentUser => user;

  @override
  bool get isStaff => user?.role == UserRole.staff;

  @override
  bool get isSignedIn => user != null;

  @override
  bool get isEmailVerified => user != null;

  @override
  bool get isLoading => false;
}

AppUser makeUser({
  String uid = 'uid-1',
  UserRole role = UserRole.student,
  String fullName = 'Elijah Laddie',
  String department = 'CS',
  String location = 'Hostel A',
}) {
  return AppUser(
    uid: uid,
    fullName: fullName,
    email: 'elijah@alustudent.com',
    role: role,
    department: department,
    location: location,
    createdAt: DateTime.utc(2026, 1, 1),
  );
}

Incident makeIncident({
  required String id,
  String owner = 'uid-1',
  IncidentStatus status = IncidentStatus.submitted,
  IncidentCategory category = IncidentCategory.water,
  String title = 'Leaking tap',
  String description = 'Water everywhere',
  String location = 'Hostel C',
  int day = 1,
  String? photoUrl,
}) {
  final DateTime stamp = DateTime.utc(2026, 1, day);
  return Incident(
    id: id,
    title: title,
    description: description,
    category: category,
    location: location,
    status: status,
    reportedByUid: owner,
    reportedByName: 'Elijah Laddie',
    createdAt: stamp,
    updatedAt: stamp,
    photoUrl: photoUrl,
  );
}
