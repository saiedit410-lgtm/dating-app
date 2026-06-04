import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:dating_app/features/auth/application/auth_providers.dart';
import 'package:dating_app/features/profile/application/profile_providers.dart';
import 'package:dating_app/features/profile/domain/photo_validation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'photo_manager_controller.g.dart';

/// Transient UI state for photo management (the photo list itself comes from
/// [currentUserProfileProvider]).
class PhotoManagerState {
  const PhotoManagerState({this.isProcessing = false, this.error});

  final bool isProcessing;
  final String? error;

  PhotoManagerState copyWith({
    bool? isProcessing,
    String? error,
    bool clearError = false,
  }) {
    return PhotoManagerState(
      isProcessing: isProcessing ?? this.isProcessing,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

/// Handles picking, validating, uploading, reordering and deleting photos.
@riverpod
class PhotoManagerController extends _$PhotoManagerController {
  ImagePicker _picker = ImagePicker();

  /// Overridable for tests.
  // ignore: use_setters_to_change_properties
  void debugSetPicker(ImagePicker picker) => _picker = picker;

  @override
  PhotoManagerState build() => const PhotoManagerState();

  Future<void> pickAndUpload() async {
    final String? uid = ref.read(authStateChangesProvider).value?.uid;
    if (uid == null) return;

    final XFile? file;
    try {
      file = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 2048,
        maxHeight: 2048,
        imageQuality: 90,
      );
    } on Exception {
      state = state.copyWith(error: 'Could not open the photo gallery.');
      return;
    }
    if (file == null) return; // user cancelled

    state = state.copyWith(isProcessing: true, clearError: true);
    try {
      final Uint8List bytes = await file.readAsBytes();
      final (int width, int height) = await _decodeDimensions(bytes);
      final int count =
          ref.read(currentUserProfileProvider).value?.photos.length ?? 0;

      final PhotoRejection? rejection = PhotoValidator.validate(
        fileName: file.name,
        sizeBytes: bytes.length,
        width: width,
        height: height,
        currentPhotoCount: count,
      );
      if (rejection != null) {
        state = state.copyWith(isProcessing: false, error: rejection.message);
        return;
      }

      final String contentType =
          PhotoValidator.mimeTypeForExtension(
            PhotoValidator.extensionOf(file.name),
          ) ??
          'image/jpeg';
      await ref
          .read(photoRepositoryProvider)
          .addPhoto(uid, bytes: bytes, contentType: contentType);
      state = state.copyWith(isProcessing: false);
    } catch (_) {
      state = state.copyWith(
        isProcessing: false,
        error: 'Upload failed. Please try again.',
      );
    }
  }

  Future<void> deletePhoto(String photoId) => _run(
    (String uid) => ref.read(photoRepositoryProvider).deletePhoto(uid, photoId),
  );

  Future<void> setPrimary(String photoId) => _run(
    (String uid) => ref.read(photoRepositoryProvider).setPrimary(uid, photoId),
  );

  Future<void> reorder(List<String> orderedPhotoIds) => _run(
    (String uid) =>
        ref.read(photoRepositoryProvider).reorderPhotos(uid, orderedPhotoIds),
  );

  Future<void> _run(Future<void> Function(String uid) action) async {
    final String? uid = ref.read(authStateChangesProvider).value?.uid;
    if (uid == null) return;
    state = state.copyWith(isProcessing: true, clearError: true);
    try {
      await action(uid);
      state = state.copyWith(isProcessing: false);
    } catch (_) {
      state = state.copyWith(
        isProcessing: false,
        error: 'Something went wrong. Please try again.',
      );
    }
  }

  Future<(int, int)> _decodeDimensions(Uint8List bytes) async {
    final Completer<ui.Image> completer = Completer<ui.Image>();
    ui.decodeImageFromList(bytes, completer.complete);
    final ui.Image image = await completer.future;
    final (int, int) size = (image.width, image.height);
    image.dispose();
    return size;
  }
}
