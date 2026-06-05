import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:dating_app/features/auth/application/auth_providers.dart';
import 'package:dating_app/features/profile/domain/photo_validation.dart';
import 'package:dating_app/features/verification/application/verification_providers.dart';
import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'verification_controller.g.dart';

/// Transient state for the verification submission action.
class VerificationSubmitState {
  const VerificationSubmitState({this.isSubmitting = false, this.error});

  final bool isSubmitting;
  final String? error;

  VerificationSubmitState copyWith({
    bool? isSubmitting,
    String? error,
    bool clearError = false,
  }) => VerificationSubmitState(
    isSubmitting: isSubmitting ?? this.isSubmitting,
    error: clearError ? null : (error ?? this.error),
  );
}

/// Picks a selfie, validates it (reusing [PhotoValidator]), and submits a
/// verification request.
@riverpod
class VerificationController extends _$VerificationController {
  ImagePicker _picker = ImagePicker();

  // ignore: use_setters_to_change_properties
  void debugSetPicker(ImagePicker picker) => _picker = picker;

  @override
  VerificationSubmitState build() => const VerificationSubmitState();

  Future<void> pickAndSubmit() async {
    final String? uid = ref.read(authStateChangesProvider).value?.uid;
    if (uid == null) return;

    final XFile? file;
    try {
      file = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 85,
      );
    } on Exception {
      state = state.copyWith(error: 'Could not open the photo gallery.');
      return;
    }
    if (file == null) return;

    state = state.copyWith(isSubmitting: true, clearError: true);
    try {
      final Uint8List bytes = await file.readAsBytes();
      final (int width, int height) = await _decodeDimensions(bytes);
      final PhotoRejection? rejection = PhotoValidator.validate(
        fileName: file.name,
        sizeBytes: bytes.length,
        width: width,
        height: height,
        currentPhotoCount: 0,
      );
      if (rejection != null) {
        state = state.copyWith(isSubmitting: false, error: rejection.message);
        return;
      }
      final String contentType =
          PhotoValidator.mimeTypeForExtension(
            PhotoValidator.extensionOf(file.name),
          ) ??
          'image/jpeg';
      await ref
          .read(verificationRepositoryProvider)
          .submit(uid: uid, bytes: bytes, contentType: contentType);
      state = state.copyWith(isSubmitting: false);
    } catch (_) {
      state = state.copyWith(
        isSubmitting: false,
        error: 'Could not submit verification. Please try again.',
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
