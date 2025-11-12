import 'track.dart';

/// Modelo para representar uma playlist
class Playlist {
  final String id;
  final String name;
  final String? description;
  final String? coverUrl;
  final String? creatorId;
  final String? creatorName;
  final List<Track> tracks;
  final DateTime? createdAt;
  final bool isPublic;
  final bool isLocal; // Se foi criada localmente pelo usuário

  Playlist({
    required this.id,
    required this.name,
    this.description,
    this.coverUrl,
    this.creatorId,
    this.creatorName,
    this.tracks = const [],
    this.createdAt,
    this.isPublic = true,
    this.isLocal = false,
  });

  factory Playlist.fromJson(Map<String, dynamic> json) {
    List<Track> tracksList = [];
    if (json['tracks'] != null) {
      tracksList = (json['tracks'] as List)
          .map((track) => Track.fromJson(track))
          .toList();
    }

    return Playlist(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? 'Playlist sem nome',
      description: json['description'],
      coverUrl: json['img'] ?? json['coverUrl'],
      creatorId: json['uId'] ?? json['creatorId'],
      creatorName: json['uName'] ?? json['creatorName'],
      tracks: tracksList,
      createdAt: json['createdAt'] != null 
          ? DateTime.tryParse(json['createdAt']) 
          : null,
      isPublic: json['isPublic'] ?? true,
      isLocal: json['isLocal'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'coverUrl': coverUrl,
      'creatorId': creatorId,
      'creatorName': creatorName,
      'tracks': tracks.map((track) => track.toJson()).toList(),
      'createdAt': createdAt?.toIso8601String(),
      'isPublic': isPublic,
      'isLocal': isLocal,
    };
  }

  Playlist copyWith({
    String? id,
    String? name,
    String? description,
    String? coverUrl,
    String? creatorId,
    String? creatorName,
    List<Track>? tracks,
    DateTime? createdAt,
    bool? isPublic,
    bool? isLocal,
  }) {
    return Playlist(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      coverUrl: coverUrl ?? this.coverUrl,
      creatorId: creatorId ?? this.creatorId,
      creatorName: creatorName ?? this.creatorName,
      tracks: tracks ?? this.tracks,
      createdAt: createdAt ?? this.createdAt,
      isPublic: isPublic ?? this.isPublic,
      isLocal: isLocal ?? this.isLocal,
    );
  }

  /// Adiciona uma faixa à playlist
  Playlist addTrack(Track track) {
    if (tracks.any((t) => t.id == track.id)) {
      return this; // Faixa já existe
    }
    return copyWith(tracks: [...tracks, track]);
  }

  /// Remove uma faixa da playlist
  Playlist removeTrack(String trackId) {
    return copyWith(
      tracks: tracks.where((track) => track.id != trackId).toList(),
    );
  }

  /// Verifica se a playlist contém uma faixa específica
  bool containsTrack(String trackId) {
    return tracks.any((track) => track.id == trackId);
  }

  /// Retorna o número de faixas na playlist
  int get trackCount => tracks.length;

  @override
  String toString() {
    return 'Playlist(id: $id, name: $name, trackCount: $trackCount)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Playlist && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
