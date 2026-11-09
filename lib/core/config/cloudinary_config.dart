/// Cloudinary settings for unsigned incident image uploads.
///
/// The `wp2qiyr6` cloud and its unsigned `incident_unsigned` preset are the
/// defaults. Override them at build/run time when needed, for example:
///
/// ```
/// flutter run \
///   --dart-define=CLOUDINARY_CLOUD_NAME=your-cloud \
///   --dart-define=CLOUDINARY_UPLOAD_PRESET=incident_unsigned
/// ```
///
/// or copy `dart_defines.example.json` to `dart_defines.json` and run with
/// `--dart-define-from-file=dart_defines.json`.
abstract final class CloudinaryConfig {
  static const String cloudName = String.fromEnvironment(
    'CLOUDINARY_CLOUD_NAME',
    defaultValue: 'wp2qiyr6',
  );
  static const String uploadPreset = String.fromEnvironment(
    'CLOUDINARY_UPLOAD_PRESET',
    defaultValue: 'incident_unsigned',
  );
  static const String folder = String.fromEnvironment(
    'CLOUDINARY_FOLDER',
    defaultValue: 'incident_photos',
  );

  /// Uploads go straight to Cloudinary only when both values are provided.
  /// Otherwise [StorageService] keeps using Firebase Storage.
  static bool get isConfigured =>
      cloudName.trim().isNotEmpty && uploadPreset.trim().isNotEmpty;

  static Uri get uploadUri => Uri.parse(
    'https://api.cloudinary.com/v1_1/${cloudName.trim()}/image/upload',
  );
}
