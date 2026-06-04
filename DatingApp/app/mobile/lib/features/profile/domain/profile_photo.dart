/// A single profile photo: its id, public download URL, and Storage path.
class ProfilePhoto {
  const ProfilePhoto({
    required this.id,
    required this.url,
    required this.storagePath,
  });

  factory ProfilePhoto.fromMap(Map<String, dynamic> map) => ProfilePhoto(
    id: map['id'] as String,
    url: map['url'] as String,
    storagePath: map['storagePath'] as String,
  );

  final String id;
  final String url;
  final String storagePath;

  Map<String, Object?> toMap() => <String, Object?>{
    'id': id,
    'url': url,
    'storagePath': storagePath,
  };

  @override
  bool operator ==(Object other) => other is ProfilePhoto && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
