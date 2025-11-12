/// Modelo para representar uma faixa musical
class Track {
  final String id;
  final String title;
  final String artist;
  final String? coverUrl;
  final String? sourceUrl;
  final String? previewUrl;
  final String? sourceType; // youtube, soundcloud, etc.
  final String? playlistId;
  final DateTime? createdAt;
  final bool isFavorite;

  Track({
    required this.id,
    required this.title,
    required this.artist,
    this.coverUrl,
    this.sourceUrl,
    this.previewUrl,
    this.sourceType,
    this.playlistId,
    this.createdAt,
    this.isFavorite = false,
  });

  factory Track.fromJson(Map<String, dynamic> json) {
    return Track(
      id: json['_id'] ?? json['id'] ?? '',
      title: json['name'] ?? json['title'] ?? 'Título desconhecido',
      artist: json['author'] ?? json['artist'] ?? 'Artista desconhecido',
      coverUrl: json['img'] ?? json['coverUrl'],
      sourceUrl: json['url'] ?? json['sourceUrl'],
      previewUrl: json['previewUrl'],
      sourceType: json['sourceType'] ?? _extractSourceType(json['url']),
      playlistId: json['playlistId'],
      createdAt: json['createdAt'] != null 
          ? DateTime.tryParse(json['createdAt']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'coverUrl': coverUrl,
      'sourceUrl': sourceUrl,
      'previewUrl': previewUrl,
      'sourceType': sourceType,
      'playlistId': playlistId,
      'createdAt': createdAt?.toIso8601String(),
      'isFavorite': isFavorite,
    };
  }

  Track copyWith({
    String? id,
    String? title,
    String? artist,
    String? coverUrl,
    String? sourceUrl,
    String? previewUrl,
    String? sourceType,
    String? playlistId,
    DateTime? createdAt,
    bool? isFavorite,
  }) {
    return Track(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      coverUrl: coverUrl ?? this.coverUrl,
      sourceUrl: sourceUrl ?? this.sourceUrl,
      previewUrl: previewUrl ?? this.previewUrl,
      sourceType: sourceType ?? this.sourceType,
      playlistId: playlistId ?? this.playlistId,
      createdAt: createdAt ?? this.createdAt,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  static String? _extractSourceType(String? url) {
    if (url == null) return null;
    if (url.contains('youtube.com') || url.contains('youtu.be')) return 'youtube';
    if (url.contains('soundcloud.com')) return 'soundcloud';
    if (url.contains('spotify.com')) return 'spotify';
    return 'other';
  }

  @override
  String toString() {
    return 'Track(id: $id, title: $title, artist: $artist)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Track && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
