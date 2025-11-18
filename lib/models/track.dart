class Track {
  final String id;
  final String titulo;
  final String artista;
  final String? urlCapa;
  final String? urlFonte;
  final String? urlPrevia;
  final String? tipoFonte;
  final String? idPlaylist;
  final DateTime? criadoEm;
  final bool ehFavorito;

  Track({
    required this.id,
    required this.titulo,
    required this.artista,
    this.urlCapa,
    this.urlFonte,
    this.urlPrevia,
    this.tipoFonte,
    this.idPlaylist,
    this.criadoEm,
    this.ehFavorito = false,
  });

  factory Track.deJson(Map<String, dynamic> json) {
    return Track(
      id: json['_id'] ?? json['id'] ?? '',
      titulo: json['name'] ?? json['title'] ?? 'Título desconhecido',
      artista: json['author'] ?? json['artist'] ?? 'Artista desconhecido',
      urlCapa: json['img'] ?? json['coverUrl'],
      urlFonte: json['url'] ?? json['sourceUrl'],
      urlPrevia: json['previewUrl'],
      tipoFonte: json['sourceType'] ?? _extrairTipoFonte(json['url']),
      idPlaylist: json['playlistId'],
      criadoEm: json['createdAt'] != null 
          ? DateTime.tryParse(json['createdAt']) 
          : null,
    );
  }

  Map<String, dynamic> paraJson() {
    return {
      'id': id,
      'title': titulo,
      'artist': artista,
      'coverUrl': urlCapa,
      'sourceUrl': urlFonte,
      'previewUrl': urlPrevia,
      'sourceType': tipoFonte,
      'playlistId': idPlaylist,
      'createdAt': criadoEm?.toIso8601String(),
      'isFavorite': ehFavorito,
    };
  }

  Track copiarCom({
    String? id,
    String? titulo,
    String? artista,
    String? urlCapa,
    String? urlFonte,
    String? urlPrevia,
    String? tipoFonte,
    String? idPlaylist,
    DateTime? criadoEm,
    bool? ehFavorito,
  }) {
    return Track(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      artista: artista ?? this.artista,
      urlCapa: urlCapa ?? this.urlCapa,
      urlFonte: urlFonte ?? this.urlFonte,
      urlPrevia: urlPrevia ?? this.urlPrevia,
      tipoFonte: tipoFonte ?? this.tipoFonte,
      idPlaylist: idPlaylist ?? this.idPlaylist,
      criadoEm: criadoEm ?? this.criadoEm,
      ehFavorito: ehFavorito ?? this.ehFavorito,
    );
  }

  static String? _extrairTipoFonte(String? url) {
    if (url == null) return null;
    if (url.contains('youtube.com') || url.contains('youtu.be')) return 'youtube';
    if (url.contains('soundcloud.com')) return 'soundcloud';
    if (url.contains('spotify.com')) return 'spotify';
    return 'other';
  }

  @override
  String toString() {
    return 'Track(id: $id, titulo: $titulo, artista: $artista)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Track && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
