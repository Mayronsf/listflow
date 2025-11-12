/// Modelo para representar um artista
class Artist {
  final String id;
  final String name;
  final String? coverUrl;
  final int? followers;
  final List<String> genres;
  final String? spotifyUrl;

  Artist({
    required this.id,
    required this.name,
    this.coverUrl,
    this.followers,
    this.genres = const [],
    this.spotifyUrl,
  });

  factory Artist.fromJson(Map<String, dynamic> json) {
    final images = (json['images'] as List?) ?? [];
    final cover = images.isNotEmpty ? images.first['url'] as String? : null;
    final genres = (json['genres'] as List?)?.map((g) => g.toString()).toList() ?? [];
    
    return Artist(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Artista desconhecido',
      coverUrl: cover,
      followers: json['followers']?['total'],
      genres: genres,
      spotifyUrl: json['external_urls']?['spotify'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'coverUrl': coverUrl,
      'followers': followers,
      'genres': genres,
      'spotifyUrl': spotifyUrl,
    };
  }

  @override
  String toString() {
    return 'Artist(id: $id, name: $name)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Artist && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

