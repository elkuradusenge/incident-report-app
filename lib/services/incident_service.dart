import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/constants/firestore_collections.dart';
import '../models/incident.dart';

/// The only class that reads and writes the `incidents` collection.
class IncidentService {
  IncidentService({FirebaseFirestore? firestore}) : _injectedFirestore = firestore;

  final FirebaseFirestore? _injectedFirestore;

  FirebaseFirestore get _firestore => _injectedFirestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _incidents =>
      _firestore.collection(FirestoreCollections.incidents);

  /// Pre-generates a document id so a photo can be uploaded before the write.
  String newIncidentId() => _incidents.doc().id;

  /// Writes a new report. `createdAt`/`updatedAt` are server timestamps and the
  /// timeline always starts with a `Submitted` entry.
  Future<String> createIncident(Incident incident) async {
    final DocumentReference<Map<String, dynamic>> reference =
        incident.id.isEmpty ? _incidents.doc() : _incidents.doc(incident.id);

    final Map<String, dynamic> data = incident.toMap()
      ..['id'] = reference.id
      ..['status'] = IncidentStatus.submitted.label
      ..['createdAt'] = FieldValue.serverTimestamp()
      ..['updatedAt'] = FieldValue.serverTimestamp()
      ..['statusHistory'] = <Map<String, dynamic>>[
        StatusChange(
          status: IncidentStatus.submitted,
          changedAt: DateTime.now(),
          changedByUid: incident.reportedByUid,
        ).toMap(),
      ];

    await reference.set(data);

    return reference.id;
  }

  /// Every report, newest first.
  Stream<List<Incident>> streamAllIncidents() {
    return _incidents
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(_mapQuery);
  }

  /// Reports created by [uid]. Filtered on the server and ordered in Dart so no
  /// composite index is required.
  Stream<List<Incident>> streamIncidentsByUser(String uid) {
    return _incidents.where('reportedByUid', isEqualTo: uid).snapshots().map(_mapQuery);
  }

  Stream<Incident?> streamIncident(String id) {
    return _incidents.doc(id).snapshots().map((DocumentSnapshot<Map<String, dynamic>> snapshot) {
      final Map<String, dynamic>? data = snapshot.data();
      if (!snapshot.exists || data == null) return null;

      return Incident.fromMap(snapshot.id, data);
    });
  }

  /// Updates the status, `updatedAt` and appends to the timeline.
  Future<void> updateStatus(String id, IncidentStatus newStatus, String staffUid) async {
    await _incidents.doc(id).update(<String, Object>{
      'status': newStatus.label,
      'updatedAt': FieldValue.serverTimestamp(),
      'statusHistory': FieldValue.arrayUnion(<Map<String, dynamic>>[
        StatusChange(
          status: newStatus,
          changedAt: DateTime.now(),
          changedByUid: staffUid,
        ).toMap(),
      ]),
    });
  }

  Future<void> deleteIncident(String id) => _incidents.doc(id).delete();

  List<Incident> _mapQuery(QuerySnapshot<Map<String, dynamic>> snapshot) {
    final List<Incident> incidents = snapshot.docs
        .map((QueryDocumentSnapshot<Map<String, dynamic>> doc) => Incident.fromMap(doc.id, doc.data()))
        .toList();
    incidents.sort((Incident a, Incident b) => b.createdAt.compareTo(a.createdAt));

    return List<Incident>.unmodifiable(incidents);
  }
}
