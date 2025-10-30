/// Modelo para representar um usuário
class User {
  final String id;
  final String name;
  final String? email;
  final String? avatarUrl;
  final String? bio;
  final List<String> favoriteTrackIds;
  final List<String> localPlaylistIds;
  final bool isDarkMode;

  User({
    required this.id,
    required this.name,
    this.email,
    this.avatarUrl,
    this.bio,
    this.favoriteTrackIds = const [],
    this.localPlaylistIds = const [],
    this.isDarkMode = true,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Usuário',
      email: json['email'],
      avatarUrl: json['avatarUrl'],
      bio: json['bio'],
      favoriteTrackIds: List<String>.from(json['favoriteTrackIds'] ?? []),
      localPlaylistIds: List<String>.from(json['localPlaylistIds'] ?? []),
      isDarkMode: json['isDarkMode'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatarUrl': avatarUrl,
      'bio': bio,
      'favoriteTrackIds': favoriteTrackIds,
      'localPlaylistIds': localPlaylistIds,
      'isDarkMode': isDarkMode,
    };
  }

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? avatarUrl,
    String? bio,
    List<String>? favoriteTrackIds,
    List<String>? localPlaylistIds,
    bool? isDarkMode,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      favoriteTrackIds: favoriteTrackIds ?? this.favoriteTrackIds,
      localPlaylistIds: localPlaylistIds ?? this.localPlaylistIds,
      isDarkMode: isDarkMode ?? this.isDarkMode,
    );
  }

  /// Adiciona uma faixa aos favoritos
  User addFavorite(String trackId) {
    if (favoriteTrackIds.contains(trackId)) {
      return this;
    }
    return copyWith(favoriteTrackIds: [...favoriteTrackIds, trackId]);
  }

  /// Remove uma faixa dos favoritos
  User removeFavorite(String trackId) {
    return copyWith(
      favoriteTrackIds: favoriteTrackIds.where((id) => id != trackId).toList(),
    );
  }

  /// Verifica se uma faixa está nos favoritos
  bool isFavorite(String trackId) {
    return favoriteTrackIds.contains(trackId);
  }

  /// Adiciona uma playlist local
  User addLocalPlaylist(String playlistId) {
    if (localPlaylistIds.contains(playlistId)) {
      return this;
    }
    return copyWith(localPlaylistIds: [...localPlaylistIds, playlistId]);
  }

  /// Remove uma playlist local
  User removeLocalPlaylist(String playlistId) {
    return copyWith(
      localPlaylistIds: localPlaylistIds.where((id) => id != playlistId).toList(),
    );
  }

  /// Limpa todos os favoritos
  User clearFavorites() {
    return copyWith(favoriteTrackIds: []);
  }

  /// Limpa todas as playlists locais
  User clearLocalPlaylists() {
    return copyWith(localPlaylistIds: []);
  }

  @override
  String toString() {
    return 'User(id: $id, name: $name, favorites: ${favoriteTrackIds.length})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
