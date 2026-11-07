import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../core/constants/firestore_collections.dart';
import '../models/app_user.dart';

/// The only class that talks to Firebase Authentication and the `users` collection.
class AuthService {
  AuthService({FirebaseAuth? auth, FirebaseFirestore? firestore})
      : _injectedAuth = auth,
        _injectedFirestore = firestore;

  final FirebaseAuth? _injectedAuth;
  final FirebaseFirestore? _injectedFirestore;

  FirebaseAuth get _auth => _injectedAuth ?? FirebaseAuth.instance;
  FirebaseFirestore get _firestore => _injectedFirestore ?? FirebaseFirestore.instance;

  /// Emits on sign in, sign out and on session restore after an app restart.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<void> signIn({required String email, required String password}) async {
    await _auth.signInWithEmailAndPassword(email: email.trim(), password: password);
  }

  /// Creates the auth account (role `student`), the profile document and sends
  /// the verification email.
  Future<AppUser> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    final UserCredential credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final User user = credential.user!;
    final AppUser profile = AppUser(
      uid: user.uid,
      fullName: fullName.trim(),
      email: user.email ?? email.trim(),
      role: UserRole.student,
      department: '',
      location: '',
      createdAt: DateTime.now(),
    );

    await user.updateDisplayName(profile.fullName);
    await _firestore
        .collection(FirestoreCollections.users)
        .doc(user.uid)
        .set(profile.toMap());
    await user.sendEmailVerification();

    return profile;
  }

  /// Returns null when the user document does not exist yet.
  Future<AppUser?> fetchUserProfile(String uid) async {
    final DocumentSnapshot<Map<String, dynamic>> snapshot =
        await _firestore.collection(FirestoreCollections.users).doc(uid).get();
    final Map<String, dynamic>? data = snapshot.data();
    if (!snapshot.exists || data == null) return null;

    return AppUser.fromMap(uid, data);
  }

  Future<void> sendVerificationEmail() async {
    final User? user = _auth.currentUser;
    if (user == null) return;

    await user.sendEmailVerification();
  }

  /// Re-reads the auth user and reports whether the email is verified now.
  Future<bool> reloadEmailVerification() async {
    final User? user = _auth.currentUser;
    if (user == null) return false;

    await user.reload();

    return _auth.currentUser?.emailVerified ?? false;
  }

  Future<void> signOut() => _auth.signOut();
}
