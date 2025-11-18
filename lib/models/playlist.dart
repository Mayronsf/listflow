import 'track.dart';

class Playlist {
  final String id;
  final String nome;
  final String? descricao;
  final String? urlCapa;
  final String? idCriador;
  final String? nomeCriador;
  final List<Track> faixas;
  final DateTime? criadaEm;
  final bool ehPublica;
  final bool ehLocal;

  Playlist({
    required this.id,
    required this.nome,
    this.descricao,
    this.urlCapa,
    this.idCriador,
    this.nomeCriador,
    this.faixas = const [],
    this.criadaEm,
    this.ehPublica = true,
    this.ehLocal = false,
  });

  factory Playlist.deJson(Map<String, dynamic> json) {
    List<Track> listaFaixas = [];
    if (json['tracks'] != null) {
      listaFaixas = (json['tracks'] as List)
          .map((track) => Track.deJson(track))
          .toList();
    }

    return Playlist(
      id: json['_id'] ?? json['id'] ?? '',
      nome: json['name'] ?? 'Playlist sem nome',
      descricao: json['description'],
      urlCapa: json['img'] ?? json['coverUrl'],
      idCriador: json['uId'] ?? json['creatorId'],
      nomeCriador: json['uName'] ?? json['creatorName'],
      faixas: listaFaixas,
      criadaEm: json['createdAt'] != null 
          ? DateTime.tryParse(json['createdAt']) 
          : null,
      ehPublica: json['isPublic'] ?? true,
      ehLocal: json['isLocal'] ?? false,
    );
  }

  Map<String, dynamic> paraJson() {
    return {
      'id': id,
      'name': nome,
      'description': descricao,
      'coverUrl': urlCapa,
      'creatorId': idCriador,
      'creatorName': nomeCriador,
      'tracks': faixas.map((faixa) => faixa.paraJson()).toList(),
      'createdAt': criadaEm?.toIso8601String(),
      'isPublic': ehPublica,
      'isLocal': ehLocal,
    };
  }

  Playlist copiarCom({
    String? id,
    String? nome,
    String? descricao,
    String? urlCapa,
    String? idCriador,
    String? nomeCriador,
    List<Track>? faixas,
    DateTime? criadaEm,
    bool? ehPublica,
    bool? ehLocal,
  }) {
    return Playlist(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      descricao: descricao ?? this.descricao,
      urlCapa: urlCapa ?? this.urlCapa,
      idCriador: idCriador ?? this.idCriador,
      nomeCriador: nomeCriador ?? this.nomeCriador,
      faixas: faixas ?? this.faixas,
      criadaEm: criadaEm ?? this.criadaEm,
      ehPublica: ehPublica ?? this.ehPublica,
      ehLocal: ehLocal ?? this.ehLocal,
    );
  }


  Playlist adicionarFaixa(Track faixa) {
    if (faixas.any((f) => f.id == faixa.id)) {
      return this;
    }
    return copiarCom(faixas: [...faixas, faixa]);
  }

  Playlist removerFaixa(String idFaixa) {
    return copiarCom(
      faixas: faixas.where((faixa) => faixa.id != idFaixa).toList(),
    );
  }

  bool contemFaixa(String idFaixa) {
    return faixas.any((faixa) => faixa.id == idFaixa);
  }

  int get quantidadeFaixas => faixas.length;

  @override
  String toString() {
    return 'Playlist(id: $id, nome: $nome, quantidadeFaixas: $quantidadeFaixas)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Playlist && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
