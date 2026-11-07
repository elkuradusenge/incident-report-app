import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

/// The only class that talks to Firebase Storage.
class StorageService {
  StorageService({FirebaseStorage? storage}) : _injectedStorage = storage;

  final FirebaseStorage? _injectedStorage;

  FirebaseStorage get _storage => _injectedStorage ?? FirebaseStorage.instance;

  static const String incidentPhotoFolder = 'incident_photos';
  static const int maxPhotoBytes = 5 * 1024 * 1024;

  /// Uploads [photo] to `incident_photos/{uid}/{incidentId}.jpg` and returns its
  /// download URL.
  ///
  /// Bytes are used instead of a file path so the same code works in Chrome and
  /// on Android/iOS.
  Future<String> uploadIncidentPhoto(XFile photo, String incidentId) async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw StateError('Please sign in again before uploading a photo.');
    }

    final Uint8List bytes = await photo.readAsBytes();
    if (bytes.length > maxPhotoBytes) {
      throw StateError('That photo is larger than 5 MB. Please choose a smaller one.');
    }

    final Reference reference = _storage.ref('$incidentPhotoFolder/${user.uid}/$incidentId.jpg');
    final TaskSnapshot snapshot = await reference.putData(
      bytes,
      SettableMetadata(contentType: _contentTypeOf(photo)),
    );

    return snapshot.ref.getDownloadURL();
  }

  String _contentTypeOf(XFile photo) {
    final String? mimeType = photo.mimeType;
    if (mimeType != null && mimeType.startsWith('image/')) return mimeType;

    final String name = photo.name.toLowerCase();
    if (name.endsWith('.png')) return 'image/png';
    if (name.endsWith('.webp')) return 'image/webp';
    if (name.endsWith('.gif')) return 'image/gif';

    return 'image/jpeg';
  }
}
