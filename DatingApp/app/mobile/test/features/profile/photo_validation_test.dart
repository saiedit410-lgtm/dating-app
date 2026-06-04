import 'package:dating_app/features/profile/domain/photo_validation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PhotoValidator.extensionOf / mimeTypeForExtension', () {
    test('extracts lowercase extension', () {
      expect(PhotoValidator.extensionOf('Selfie.JPG'), 'jpg');
      expect(PhotoValidator.extensionOf('a.b.png'), 'png');
      expect(PhotoValidator.extensionOf('noext'), '');
    });

    test('maps supported extensions to MIME types', () {
      expect(PhotoValidator.mimeTypeForExtension('jpeg'), 'image/jpeg');
      expect(PhotoValidator.mimeTypeForExtension('png'), 'image/png');
      expect(PhotoValidator.mimeTypeForExtension('webp'), 'image/webp');
      expect(PhotoValidator.mimeTypeForExtension('gif'), isNull);
    });
  });

  group('PhotoValidator.validate', () {
    PhotoRejection? run({
      String name = 'pic.jpg',
      int size = 1024,
      int width = 800,
      int height = 800,
      int count = 0,
    }) => PhotoValidator.validate(
      fileName: name,
      sizeBytes: size,
      width: width,
      height: height,
      currentPhotoCount: count,
    );

    test('accepts a valid image', () => expect(run(), isNull));

    test('rejects when at the max', () {
      expect(run(count: PhotoConstraints.maxPhotos), PhotoRejection.tooMany);
    });

    test('rejects unsupported types', () {
      expect(run(name: 'pic.gif'), PhotoRejection.unsupportedType);
    });

    test('rejects oversized files', () {
      expect(
        run(size: PhotoConstraints.maxBytes + 1),
        PhotoRejection.tooLarge,
      );
    });

    test('rejects too-small and too-large dimensions', () {
      expect(run(width: 100, height: 100), PhotoRejection.tooSmallDimensions);
      expect(
        run(width: PhotoConstraints.maxDimension + 1, height: 800),
        PhotoRejection.tooLargeDimensions,
      );
    });
  });
}
