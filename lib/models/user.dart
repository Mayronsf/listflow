class User {
  final String id;
  final String nome;
  final String? email;
  final String? urlAvatar;
  final String? bio;
  final List<String> idsFaixasFavoritas;
  final List<String> idsPlaylistsLocais;
  final bool ehModoEscuro;

  User({
    required this.id,
    required this.nome,
    this.email,
    this.urlAvatar,
    this.bio,
    this.idsFaixasFavoritas = const [],
    this.idsPlaylistsLocais = const [],
    this.ehModoEscuro = true,
  });

  factory User.deJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      nome: json['name'] ?? 'Usuário',
      email: json['email'],
      urlAvatar: json['avatarUrl'],
      bio: json['bio'],
      idsFaixasFavoritas: List<String>.from(json['favoriteTrackIds'] ?? []),
      idsPlaylistsLocais: List<String>.from(json['localPlaylistIds'] ?? []),
      ehModoEscuro: json['isDarkMode'] ?? true,
    );
  }

  Map<String, dynamic> paraJson() {
    return {
      'id': id,
      'name': nome,
      'email': email,
      'avatarUrl': urlAvatar,
      'bio': bio,
      'favoriteTrackIds': idsFaixasFavoritas,
      'localPlaylistIds': idsPlaylistsLocais,
      'isDarkMode': ehModoEscuro,
    };
  }

  User copiarCom({
    String? id,
    String? nome,
    String? email,
    String? urlAvatar,
    String? bio,
    List<String>? idsFaixasFavoritas,
    List<String>? idsPlaylistsLocais,
    bool? ehModoEscuro,
  }) {
    return User(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      email: email ?? this.email,
      urlAvatar: urlAvatar ?? this.urlAvatar,
      bio: bio ?? this.bio,
      idsFaixasFavoritas: idsFaixasFavoritas ?? this.idsFaixasFavoritas,
      idsPlaylistsLocais: idsPlaylistsLocais ?? this.idsPlaylistsLocais,
      ehModoEscuro: ehModoEscuro ?? this.ehModoEscuro,
    );
  }

  User adicionarFavorito(String idFaixa) {
    if (idsFaixasFavoritas.contains(idFaixa)) {
      return this;
    }
    return copiarCom(idsFaixasFavoritas: [...idsFaixasFavoritas, idFaixa]);
  }

  User removerFavorito(String idFaixa) {
    return copiarCom(
      idsFaixasFavoritas: idsFaixasFavoritas.where((id) => id != idFaixa).toList(),
    );
  }

  bool ehFavorito(String idFaixa) {
    return idsFaixasFavoritas.contains(idFaixa);
  }

  User adicionarPlaylistLocal(String idPlaylist) {
    if (idsPlaylistsLocais.contains(idPlaylist)) {
      return this;
    }
    return copiarCom(idsPlaylistsLocais: [...idsPlaylistsLocais, idPlaylist]);
  }

  User removerPlaylistLocal(String idPlaylist) {
    return copiarCom(
      idsPlaylistsLocais: idsPlaylistsLocais.where((id) => id != idPlaylist).toList(),
    );
  }

  User limparFavoritos() {
    return copiarCom(idsFaixasFavoritas: []);
  }

  User limparPlaylistsLocais() {
    return copiarCom(idsPlaylistsLocais: []);
  }

  @override
  String toString() {
    return 'User(id: $id, nome: $nome, favoritos: ${idsFaixasFavoritas.length})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
