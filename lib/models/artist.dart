
class Artist {
  final String id;
  final String nome;
  final String? urlCapa;
  final int? seguidores;
  final List<String> generos;
  final String? urlSpotify;

  Artist({
    required this.id,
    required this.nome,
    this.urlCapa,
    this.seguidores,
    this.generos = const [],
    this.urlSpotify,
  });

  factory Artist.deJson(Map<String, dynamic> json) {
    final images = (json['images'] as List?) ?? [];
    final cover = images.isNotEmpty ? images.first['url'] as String? : null;
    final generos = (json['genres'] as List?)?.map((g) => g.toString()).toList() ?? [];
    
    return Artist(
      id: json['id'] ?? '',
      nome: json['name'] ?? 'Artista desconhecido',
      urlCapa: cover,
      seguidores: json['followers']?['total'],
      generos: generos,
      urlSpotify: json['external_urls']?['spotify'],
    );
  }

  Map<String, dynamic> paraJson() {
    return {
      'id': id,
      'name': nome,
      'coverUrl': urlCapa,
      'followers': seguidores,
      'genres': generos,
      'spotifyUrl': urlSpotify,
    };
  }

  @override
  String toString() {
    return 'Artist(id: $id, nome: $nome)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Artist && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

