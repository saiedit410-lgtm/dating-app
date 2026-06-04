/// Constraints and validation for profile photo uploads.
class PhotoConstraints {
  const PhotoConstraints._();

  static const int minPhotos = 1;
  static const int maxPhotos = 6;

  /// Max upload size: 8 MB.
  static const int maxBytes = 8 * 1024 * 1024;

  /// Min/max pixel dimensions (square-ish guardrails).
  static const int minDimension = 200;
  static const int maxDimension = 6000;

  static const Set<String> allowedExtensions = <String>{
    'jpg',
    'jpeg',
    'png',
    'webp',
  };

  static const Set<String> allowedMimeTypes = <String>{
    'image/jpeg',
    'image/jpg',
    'image/png',
    'image/webp',
  };
}

/// Reasons a candidate photo can be rejected.
enum PhotoRejection {
  tooMany,
  unsupportedType,
  tooLarge,
  tooSmallDimensions,
  tooLargeDimensions;

  String get message => switch (this) {
    PhotoRejection.tooMany =>
      'You can add up to ${PhotoConstraints.maxPhotos} photos.',
    PhotoRejection.unsupportedType =>
      'Use a JPG, PNG, or WEBP image.',
    PhotoRejection.tooLarge =>
      'Images must be under ${PhotoConstraints.maxBytes ~/ (1024 * 1024)} MB.',
    PhotoRejection.tooSmallDimensions =>
      'Image is too small (min ${PhotoConstraints.minDimension}px).',
    PhotoRejection.tooLargeDimensions =>
      'Image is too large (max ${PhotoConstraints.maxDimension}px).',
  };
}

/// Pure validation for a candidate photo. Returns null when acceptable.
class PhotoValidator {
  const PhotoValidator._();

  /// Resolves a lowercase file extension (no dot) from a file name.
  static String extensionOf(String fileName) {
    final int dot = fileName.lastIndexOf('.');
    if (dot < 0 || dot == fileName.length - 1) return '';
    return fileName.substring(dot + 1).toLowerCase();
  }

  /// Maps a file extension to a canonical image MIME type, or null.
  static String? mimeTypeForExtension(String extension) =>
      switch (extension.toLowerCase()) {
        'jpg' || 'jpeg' => 'image/jpeg',
        'png' => 'image/png',
        'webp' => 'image/webp',
        _ => null,
      };

  static PhotoRejection? validate({
    required String fileName,
    required int sizeBytes,
    required int width,
    required int height,
    required int currentPhotoCount,
  }) {
    if (currentPhotoCount >= PhotoConstraints.maxPhotos) {
      return PhotoRejection.tooMany;
    }
    if (!PhotoConstraints.allowedExtensions.contains(extensionOf(fileName))) {
      return PhotoRejection.unsupportedType;
    }
    if (sizeBytes > PhotoConstraints.maxBytes) return PhotoRejection.tooLarge;
    if (width < PhotoConstraints.minDimension ||
        height < PhotoConstraints.minDimension) {
      return PhotoRejection.tooSmallDimensions;
    }
    if (width > PhotoConstraints.maxDimension ||
        height > PhotoConstraints.maxDimension) {
      return PhotoRejection.tooLargeDimensions;
    }
    return null;
  }
}
