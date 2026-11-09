import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';

import '../core/config/cloudinary_config.dart';

/// Uploads incident photos to Cloudinary using an unsigned upload preset.
class CloudinaryService {
  CloudinaryService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static const int maxPhotoBytes = 5 * 1024 * 1024;

  Future<String> uploadIncidentPhoto(XFile photo, String incidentId) async {
    if (!CloudinaryConfig.isConfigured) {
      throw StateError('Cloudinary is not configured for this build.');
    }

    final List<int> bytes = await photo.readAsBytes();
    if (bytes.length > maxPhotoBytes) {
      throw StateError(
        'That photo is larger than 5 MB. Please choose a smaller one.',
      );
    }

    final http.MultipartRequest request =
        http.MultipartRequest('POST', CloudinaryConfig.uploadUri)
          ..fields['upload_preset'] = CloudinaryConfig.uploadPreset.trim()
          ..fields['folder'] = CloudinaryConfig.folder
          ..fields['public_id'] = 'incident_$incidentId'
          ..files.add(
            http.MultipartFile.fromBytes(
              'file',
              bytes,
              filename: photo.name.isEmpty ? '$incidentId.jpg' : photo.name,
              contentType: _mediaTypeOf(photo),
            ),
          );

    final http.StreamedResponse streamed = await _client.send(request);
    final http.Response response = await http.Response.fromStream(streamed);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StateError(
        'Cloudinary rejected the upload (${response.statusCode}). '
        'Check that the upload preset is unsigned and allows image uploads.',
      );
    }

    final Object? decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw StateError('Cloudinary returned an unexpected response.');
    }

    final Object? secureUrl = decoded['secure_url'];
    if (secureUrl is! String || secureUrl.isEmpty) {
      throw StateError('Cloudinary did not return an image URL.');
    }

    return secureUrl;
  }

  MediaType _mediaTypeOf(XFile photo) {
    final String? mimeType = photo.mimeType;
    if (mimeType != null && mimeType.startsWith('image/')) {
      return MediaType.parse(mimeType);
    }

    final String name = photo.name.toLowerCase();
    if (name.endsWith('.png')) return MediaType('image', 'png');
    if (name.endsWith('.webp')) return MediaType('image', 'webp');
    if (name.endsWith('.gif')) return MediaType('image', 'gif');

    return MediaType('image', 'jpeg');
  }
}
