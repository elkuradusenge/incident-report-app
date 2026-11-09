import 'dart:typed_data';

import 'package:campus_incident_app/models/app_user.dart';
import 'package:campus_incident_app/models/incident.dart';
import 'package:campus_incident_app/providers/incident_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';

import 'helpers/fakes.dart';

void main() {
  late FakeIncidentService service;
  late FakeStorageService storage;
  late IncidentProvider provider;

  setUp(() {
    service = FakeIncidentService();
    storage = FakeStorageService();
    provider = IncidentProvider(
      incidentService: service,
      storageService: storage,
    );
    addTearDown(() async {
      provider.dispose();
      await service.dispose();
    });
  });

  group('live lists', () {
    test('exposes all incidents and my incidents from the streams', () async {
      provider.updateUser(makeUser());
      await pumpEventQueue();

      service.all.add(<Incident>[
        makeIncident(id: 'a', day: 3),
        makeIncident(id: 'b', day: 2),
      ]);
      service.mine.add(<Incident>[makeIncident(id: 'a', day: 3)]);
      await pumpEventQueue();

      expect(provider.allIncidents.map((Incident i) => i.id), <String>[
        'a',
        'b',
      ]);
      expect(provider.myIncidents, hasLength(1));
      expect(provider.isLoading, isFalse);
    });

    test('starts empty and not loading when nobody is signed in', () async {
      provider.updateUser(null);
      await pumpEventQueue();

      expect(provider.allIncidents, isEmpty);
      expect(provider.isLoading, isFalse);
    });

    test('surfaces stream errors', () async {
      provider.updateUser(makeUser());
      await pumpEventQueue();

      // A permission failure hits both streams.
      service.all.addError(StateError('The stream broke.'));
      service.mine.addError(StateError('The stream broke.'));
      await pumpEventQueue();

      expect(provider.errorMessage, 'The stream broke.');
      expect(provider.isLoading, isFalse);
    });
  });

  group('filters', () {
    setUp(() async {
      provider.updateUser(makeUser());
      await pumpEventQueue();
      service.all.add(<Incident>[
        makeIncident(
          id: 'a',
          day: 4,
          title: 'Leaking tap',
          category: IncidentCategory.water,
          status: IncidentStatus.submitted,
        ),
        makeIncident(
          id: 'b',
          day: 3,
          title: 'Broken projector',
          category: IncidentCategory.facilities,
          status: IncidentStatus.inProgress,
          location: 'Science Block',
        ),
        makeIncident(
          id: 'c',
          day: 2,
          title: 'Flickering light',
          category: IncidentCategory.electricity,
          status: IncidentStatus.resolved,
        ),
      ]);
      await pumpEventQueue();
    });

    test('returns everything by default', () {
      expect(provider.filteredIncidents, hasLength(3));
    });

    test('filters by search across title, location and category', () {
      provider.setSearchQuery('projector');
      expect(provider.filteredIncidents.single.id, 'b');

      provider.setSearchQuery('hostel');
      expect(provider.filteredIncidents.map((Incident i) => i.id), <String>[
        'a',
        'c',
      ]);

      provider.setSearchQuery('Electricity');
      expect(provider.filteredIncidents.single.id, 'c');

      provider.setSearchQuery('nothing here');
      expect(provider.filteredIncidents, isEmpty);
    });

    test('filters by status and category together', () {
      provider.setStatusFilter(IncidentStatus.submitted);
      expect(provider.filteredIncidents.single.id, 'a');

      provider.setStatusFilter(null);
      provider.setCategoryFilter(IncidentCategory.facilities);
      expect(provider.filteredIncidents.single.id, 'b');
    });
  });

  group('counters', () {
    test('count my reports by status', () async {
      provider.updateUser(makeUser());
      await pumpEventQueue();

      service.mine.add(<Incident>[
        makeIncident(id: 'a', status: IncidentStatus.submitted),
        makeIncident(id: 'b', status: IncidentStatus.submitted),
        makeIncident(id: 'c', status: IncidentStatus.inProgress),
        makeIncident(id: 'd', status: IncidentStatus.resolved),
        makeIncident(
          id: 'e',
          owner: 'someone-else',
          status: IncidentStatus.resolved,
        ),
      ]);
      await pumpEventQueue();

      expect(provider.myReportCount, 5);
      expect(provider.mySubmittedCount, 2);
      expect(provider.myInProgressCount, 1);
      expect(provider.myResolvedCount, 2);
    });

    test('count every report in the queue for staff', () async {
      provider.updateUser(makeUser(role: UserRole.staff));
      await pumpEventQueue();

      service.all.add(<Incident>[
        makeIncident(id: 'a', owner: 'uid-1', status: IncidentStatus.submitted),
        makeIncident(
          id: 'b',
          owner: 'uid-2',
          status: IncidentStatus.inProgress,
        ),
        makeIncident(id: 'c', owner: 'uid-3', status: IncidentStatus.resolved),
        makeIncident(id: 'd', owner: 'uid-4', status: IncidentStatus.resolved),
      ]);
      await pumpEventQueue();

      expect(provider.allReportCount, 4);
      expect(provider.allSubmittedCount, 1);
      expect(provider.allInProgressCount, 1);
      expect(provider.allResolvedCount, 2);
    });
  });

  group('submitIncident', () {
    test('uploads the photo first, then creates a Submitted report', () async {
      provider.updateUser(makeUser());
      await pumpEventQueue();

      final XFile photo = XFile.fromData(
        Uint8List.fromList(<int>[1, 2, 3]),
        name: 'photo.jpg',
        mimeType: 'image/jpeg',
      );

      final Incident? created = await provider.submitIncident(
        title: '  Leaking tap ',
        description: 'Water everywhere',
        category: IncidentCategory.water,
        location: ' Hostel C ',
        photo: photo,
      );

      expect(created, isNotNull);
      expect(storage.uploadCount, 1);
      expect(created!.id, 'inc-test-1');
      expect(created.title, 'Leaking tap');
      expect(created.location, 'Hostel C');
      expect(created.photoUrl, 'https://example.com/inc-test-1.jpg');
      expect(created.status, IncidentStatus.submitted);
      expect(created.reportedByUid, 'uid-1');
      expect(created.reportedByName, 'Elijah Laddie');
      expect(created.statusHistory.single.status, IncidentStatus.submitted);
      expect(service.created?.id, 'inc-test-1');
      expect(provider.errorMessage, isNull);
    });

    test('skips the upload when no photo was picked', () async {
      provider.updateUser(makeUser());
      await pumpEventQueue();

      final Incident? created = await provider.submitIncident(
        title: 'Broken chair',
        description: 'Leg snapped',
        category: IncidentCategory.facilities,
        location: 'Block C',
      );

      expect(created, isNotNull);
      expect(storage.uploadCount, 0);
      expect(created!.photoUrl, isNull);
    });

    test('is refused for staff', () async {
      provider.updateUser(makeUser(role: UserRole.staff));
      await pumpEventQueue();

      final Incident? created = await provider.submitIncident(
        title: 'Broken chair',
        description: 'Leg snapped',
        category: IncidentCategory.facilities,
        location: 'Block C',
      );

      expect(created, isNull);
      expect(service.createCount, 0);
      expect(provider.errorMessage, contains('Staff accounts'));
    });

    test('reports a failed write', () async {
      provider.updateUser(makeUser());
      await pumpEventQueue();
      service.failCreate = true;

      final Incident? created = await provider.submitIncident(
        title: 'Broken chair',
        description: 'Leg snapped',
        category: IncidentCategory.facilities,
        location: 'Block C',
      );

      expect(created, isNull);
      expect(provider.errorMessage, 'The write failed.');
      expect(provider.isSubmitting, isFalse);
    });
  });

  group('updateStatus', () {
    test('is refused for students', () async {
      provider.updateUser(makeUser());
      await pumpEventQueue();

      final bool updated = await provider.updateStatus(
        'a',
        IncidentStatus.resolved,
      );

      expect(updated, isFalse);
      expect(service.updatedStatus, isNull);
      expect(provider.errorMessage, contains('Only staff'));
    });

    test('is allowed for staff', () async {
      provider.updateUser(makeUser(role: UserRole.staff));
      await pumpEventQueue();

      final bool updated = await provider.updateStatus(
        'a',
        IncidentStatus.resolved,
      );

      expect(updated, isTrue);
      expect(service.updatedId, 'a');
      expect(service.updatedStatus, IncidentStatus.resolved);
    });
  });

  group('delete rules', () {
    test('a student can delete only their own submitted report', () async {
      provider.updateUser(makeUser());
      await pumpEventQueue();

      final Incident mine = makeIncident(id: 'a');
      final Incident mineInProgress = makeIncident(
        id: 'b',
        status: IncidentStatus.inProgress,
      );
      final Incident someoneElse = makeIncident(id: 'c', owner: 'uid-2');

      expect(provider.canDelete(mine), isTrue);
      expect(provider.canDelete(mineInProgress), isFalse);
      expect(provider.canDelete(someoneElse), isFalse);

      expect(await provider.deleteIncident(mine), isTrue);
      expect(service.deletedId, 'a');
    });

    test('staff cannot delete any report', () async {
      provider.updateUser(makeUser(role: UserRole.staff));
      await pumpEventQueue();

      final Incident own = makeIncident(id: 'a', owner: 'uid-1');

      expect(provider.canDelete(own), isFalse);
      expect(await provider.deleteIncident(own), isFalse);
      expect(service.deletedId, isNull);
    });

    test('refuses to delete a report that moved past Submitted', () async {
      provider.updateUser(makeUser());
      await pumpEventQueue();

      final bool deleted = await provider.deleteIncident(
        makeIncident(id: 'b', status: IncidentStatus.inProgress),
      );

      expect(deleted, isFalse);
      expect(service.deletedId, isNull);
      expect(provider.errorMessage, contains('only delete'));
    });
  });
}
