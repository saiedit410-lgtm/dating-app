import 'package:dating_app/features/profile/application/photo_manager_controller.dart';
import 'package:dating_app/features/profile/application/profile_providers.dart';
import 'package:dating_app/features/profile/domain/photo_validation.dart';
import 'package:dating_app/features/profile/domain/profile_photo.dart';
import 'package:dating_app/shared/extensions/build_context_x.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Manage profile photos: add (1–6), reorder, set primary, and delete.
class PhotoManagerScreen extends ConsumerWidget {
  const PhotoManagerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<PhotoManagerState>(photoManagerControllerProvider, (
      PhotoManagerState? previous,
      PhotoManagerState next,
    ) {
      if (next.error != null) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(next.error!)));
      }
    });

    final PhotoManagerState state = ref.watch(photoManagerControllerProvider);
    final List<ProfilePhoto> photos =
        ref.watch(currentUserProfileProvider).value?.photos ??
        const <ProfilePhoto>[];
    final bool canAdd =
        photos.length < PhotoConstraints.maxPhotos && !state.isProcessing;
    final PhotoManagerController controller = ref.read(
      photoManagerControllerProvider.notifier,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your photos'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: state.isProcessing
              ? const LinearProgressIndicator()
              : const SizedBox(height: 4),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Add ${PhotoConstraints.minPhotos}–${PhotoConstraints.maxPhotos} '
                'photos. Drag to reorder; the first photo is your primary.',
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            Expanded(
              child: photos.isEmpty
                  ? _EmptyState(onAdd: canAdd ? controller.pickAndUpload : null)
                  : ReorderableListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: photos.length,
                      onReorderItem: (int oldIndex, int newIndex) {
                        if (state.isProcessing) return;
                        final List<String> ids = photos
                            .map((ProfilePhoto p) => p.id)
                            .toList();
                        // onReorderItem passes a newIndex already adjusted for
                        // the item removed at oldIndex.
                        final String moved = ids.removeAt(oldIndex);
                        ids.insert(newIndex, moved);
                        controller.reorder(ids);
                      },
                      itemBuilder: (BuildContext context, int index) {
                        final ProfilePhoto photo = photos[index];
                        return _PhotoTile(
                          key: ValueKey<String>(photo.id),
                          photo: photo,
                          isPrimary: index == 0,
                          enabled: !state.isProcessing,
                          onSetPrimary: () => controller.setPrimary(photo.id),
                          onDelete: () => controller.deletePhoto(photo.id),
                        );
                      },
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: FilledButton.icon(
                onPressed: canAdd ? controller.pickAndUpload : null,
                icon: const Icon(Icons.add_a_photo_outlined),
                label: Text(
                  photos.length >= PhotoConstraints.maxPhotos
                      ? 'Maximum ${PhotoConstraints.maxPhotos} photos'
                      : 'Add photo (${photos.length}/${PhotoConstraints.maxPhotos})',
                ),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PhotoTile extends StatelessWidget {
  const _PhotoTile({
    super.key,
    required this.photo,
    required this.isPrimary,
    required this.enabled,
    required this.onSetPrimary,
    required this.onDelete,
  });

  final ProfilePhoto photo;
  final bool isPrimary;
  final bool enabled;
  final VoidCallback onSetPrimary;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            photo.url,
            width: 56,
            height: 56,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => Container(
              width: 56,
              height: 56,
              color: context.colorScheme.surfaceContainerHighest,
              child: const Icon(Icons.broken_image_outlined),
            ),
          ),
        ),
        title: Text(isPrimary ? 'Primary photo' : 'Photo'),
        subtitle: isPrimary
            ? const Text('Shown first on your profile')
            : null,
        trailing: PopupMenuButton<String>(
          enabled: enabled,
          onSelected: (String value) {
            if (value == 'primary') onSetPrimary();
            if (value == 'delete') onDelete();
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            if (!isPrimary)
              const PopupMenuItem<String>(
                value: 'primary',
                child: Text('Set as primary'),
              ),
            const PopupMenuItem<String>(
              value: 'delete',
              child: Text('Delete'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({this.onAdd});

  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.photo_library_outlined,
              size: 64,
              color: context.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text('No photos yet', style: context.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              'Add at least one photo so others can see you.',
              textAlign: TextAlign.center,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add_a_photo_outlined),
              label: const Text('Add photo'),
            ),
          ],
        ),
      ),
    );
  }
}
