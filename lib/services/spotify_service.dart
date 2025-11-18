import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/track.dart';
import '../models/playlist.dart';
import '../models/artist.dart';

class SpotifyService {
  static const String _clientId = '0a508f9d317d4f11b6a7e88b6a8759ec';
  static const String _clientSecret = 'd41314292a854b479a5528d84efafc3f';
  static const String _baseUrl = 'https://api.spotify.com/v1';
  static const String _authBase = 'https://accounts.spotify.com';
  static const Duration _timeout = Duration(seconds: 30);

  final http.Client _client = http.Client();

  Future<String?> _getAppAccessToken() async {
    try {
      final basic = base64Encode(utf8.encode('$_clientId:$_clientSecret'));
      final resp = await http
          .post(
            Uri.parse('$_authBase/api/token'),
            headers: {
              'Authorization': 'Basic $basic',
              'Content-Type': 'application/x-www-form-urlencoded',
            },
            body: {'grant_type': 'client_credentials'},
          )
          .timeout(_timeout);
      if (resp.statusCode == 200) {
        final jsonBody = json.decode(resp.body);
        return jsonBody['access_token'] as String?;
      } else {
        print('❌ Erro ao obter token do Spotify: ${resp.statusCode}');
        print('Resposta: ${resp.body}');
        return null;
      }
    } catch (e) {
      print('❌ Exceção ao obter token do Spotify: $e');
      return null;
    }
  }


  Map<String, String> _authHeaders(String token) => {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

  Future<Map<String, dynamic>> buscarTudo(String query, {String mercado = 'BR'}) async {
    final appToken = await _getAppAccessToken();
    if (appToken == null) return {};
    final resp = await _client
        .get(
          Uri.parse('$_baseUrl/search?q=${Uri.encodeComponent(query)}&type=track,artist,album&limit=20&market=$mercado'),
          headers: _authHeaders(appToken),
        )
        .timeout(_timeout);
    if (resp.statusCode == 200) {
      return json.decode(resp.body) as Map<String, dynamic>;
    }
    return {};
  }

  Future<List<Playlist>> obterPlaylistsEmDestaque({String pais = 'BR'}) async {
    try {
      final appToken = await _getAppAccessToken();
      if (appToken == null) {
        print('❌ Token não disponível para buscar playlists em destaque');
        return [];
      }
      
      final searchTerms = [
        'Top Brasil',
        'Hits Brasil',
        'Pop Brasil',
        'Sertanejo',
        'Funk Brasil',
        'MPB',
      ];
      
      final List<Playlist> todasPlaylists = [];
      final Set<String> idsVistos = {};
      
      for (final term in searchTerms) {
        try {
          final resp = await _client
              .get(
                Uri.parse('$_baseUrl/search?q=${Uri.encodeComponent(term)}&type=playlist&limit=10&market=$pais'),
                headers: _authHeaders(appToken),
              )
              .timeout(_timeout);
          
          if (resp.statusCode == 200) {
            final data = json.decode(resp.body);
            final items = (data['playlists']?['items'] as List?) ?? [];
            
            for (final item in items) {
              final playlistId = item['id'] as String?;
              if (playlistId != null && !idsVistos.contains(playlistId)) {
                idsVistos.add(playlistId);
                todasPlaylists.add(_playlistDoJsonSpotify(item));
                if (todasPlaylists.length >= 20) break;
              }
            }
            
            if (todasPlaylists.length >= 20) break;
          }
        } catch (e) {
          continue;
        }
      }
      
      print('✅ ${todasPlaylists.length} playlists populares carregadas');
      return todasPlaylists.take(20).toList();
    } catch (e) {
      print('❌ Exceção ao buscar playlists: $e');
      return [];
    }
  }


  Playlist _playlistDoJsonSpotify(Map<String, dynamic> p) {
    final images = (p['images'] as List?) ?? [];
    final cover = images.isNotEmpty ? images.first['url'] as String? : null;
    return Playlist(
      id: p['id'] ?? '',
      nome: p['name'] ?? '',
      descricao: p['description'],
      urlCapa: cover,
      nomeCriador: (p['owner'] != null) ? (p['owner']['display_name'] ?? p['owner']['id']) : null,
      faixas: const [],
      criadaEm: DateTime.now(),
    );
  }

  Track faixaDoJsonSpotify(Map<String, dynamic> t) {
    final album = t['album'] ?? {};
    final images = (album['images'] as List?) ?? [];
    final cover = images.isNotEmpty ? images.last['url'] as String? : null;
    final external = t['external_urls']?['spotify'] as String?;
    final preview = t['preview_url'] as String?;
    final artists = (t['artists'] as List?)?.map((a) => a['name']).whereType<String>().toList() ?? [];
    
    return Track(
      id: t['id'] ?? '',
      titulo: t['name'] ?? '',
      artista: artists.join(', '),
      urlCapa: cover,
      urlFonte: external,
      urlPrevia: preview,
      tipoFonte: 'spotify',
      criadoEm: DateTime.now(),
    );
  }


  Artist artistaDoJsonSpotify(Map<String, dynamic> a) {
    final images = (a['images'] as List?) ?? [];
    final cover = images.isNotEmpty ? images.first['url'] as String? : null;
    final generos = (a['genres'] as List?)?.map((g) => g.toString()).toList() ?? [];
    
    return Artist(
      id: a['id'] ?? '',
      nome: a['name'] ?? 'Artista desconhecido',
      urlCapa: cover,
      seguidores: a['followers']?['total'],
      generos: generos,
      urlSpotify: a['external_urls']?['spotify'],
    );
  }

  Future<Artist?> obterArtistaPorId(String idArtista) async {
    final appToken = await _getAppAccessToken();
    if (appToken == null) return null;
    
    final resp = await _client
        .get(
          Uri.parse('$_baseUrl/artists/$idArtista'),
          headers: _authHeaders(appToken),
        )
        .timeout(_timeout);
    
    if (resp.statusCode == 200) {
      final data = json.decode(resp.body);
      return artistaDoJsonSpotify(data);
    }
    return null;
  }

  Future<List<Track>> obterFaixasDoArtista(String idArtista, {int limite = 20}) async {
    final appToken = await _getAppAccessToken();
    if (appToken == null) return [];
    
    final resp = await _client
        .get(
          Uri.parse('$_baseUrl/artists/$idArtista/top-tracks?market=BR'),
          headers: _authHeaders(appToken),
        )
        .timeout(_timeout);
    
    if (resp.statusCode == 200) {
      final data = json.decode(resp.body);
      final faixas = (data['tracks'] as List?) ?? [];
      return faixas.map((t) => faixaDoJsonSpotify(t)).toList().cast<Track>();
    }
    return [];
  }

  Future<List<Track>> obterFaixasDaPlaylist(String idPlaylist, {int limite = 100}) async {
    try {
      final appToken = await _getAppAccessToken();
      if (appToken == null) {
        print('❌ Token não disponível para buscar faixas da playlist');
        return [];
      }
      
      final resp = await _client
          .get(
            Uri.parse('$_baseUrl/playlists/$idPlaylist/tracks?limit=$limite&market=BR'),
            headers: _authHeaders(appToken),
          )
          .timeout(_timeout);
      
      if (resp.statusCode == 200) {
        final data = json.decode(resp.body);
        final items = (data['items'] as List?) ?? [];
        
        final List<Track> faixas = [];
        for (final item in items) {
          final dadosFaixa = item['track'];
          if (dadosFaixa != null && dadosFaixa is Map) {
            faixas.add(faixaDoJsonSpotify(Map<String, dynamic>.from(dadosFaixa)));
          }
        }
        
        print('✅ ${faixas.length} faixas carregadas da playlist $idPlaylist');
        return faixas;
      } else {
        print('❌ Erro ao buscar faixas da playlist: ${resp.statusCode}');
        print('Resposta: ${resp.body}');
        return [];
      }
    } catch (e) {
      print('❌ Exceção ao buscar faixas da playlist: $e');
      return [];
    }
  }

  Future<List<Track>> obterRecomendacoes({List<String>? generosBase, int limite = 20}) async {
    final appToken = await _getAppAccessToken();
    if (appToken == null) return [];
    final sementes = (generosBase ?? ['pop','hip-hop','trap']).take(5).join(',');
    final resp = await _client
        .get(
          Uri.parse('$_baseUrl/recommendations?limit=$limite&seed_genres=$sementes'),
          headers: _authHeaders(appToken),
        )
        .timeout(_timeout);
    if (resp.statusCode == 200) {
      final data = json.decode(resp.body);
      final faixas = (data['tracks'] as List?) ?? [];
      return faixas.map((t) => faixaDoJsonSpotify(t)).toList().cast<Track>();
    }
    return [];
  }

  Future<List<Artist>> obterArtistasRecomendados({int limite = 20}) async {
    final appToken = await _getAppAccessToken();
    if (appToken == null) return [];
    
    final List<Artist> todosArtistas = [];
    final Set<String> idsVistos = {};
    
    final popularSearchTerms = [
      'year:2024',
      'tag:new',
      'a',
    ];
    
    for (final term in popularSearchTerms) {
      try {
        final resp = await _client
            .get(
              Uri.parse('$_baseUrl/search?q=${Uri.encodeComponent(term)}&type=artist&limit=20&market=BR'),
              headers: _authHeaders(appToken),
            )
            .timeout(_timeout);
        
        if (resp.statusCode == 200) {
          final data = json.decode(resp.body);
          final items = (data['artists']?['items'] as List?) ?? [];
          
          for (final item in items) {
            final idArtista = item['id'] as String?;
            if (idArtista != null && !idsVistos.contains(idArtista)) {
              idsVistos.add(idArtista);
              todosArtistas.add(artistaDoJsonSpotify(item));
              if (todosArtistas.length >= limite) break;
            }
          }
          
          if (todosArtistas.length >= limite) break;
        }
      } catch (e) {
        continue;
      }
    }
    
    if (todosArtistas.length < limite) {
      final commonLetters = ['a', 'e', 'i', 'o', 'u'];
      for (final letter in commonLetters) {
        try {
          final resp = await _client
              .get(
                Uri.parse('$_baseUrl/search?q=$letter&type=artist&limit=20&market=BR'),
                headers: _authHeaders(appToken),
              )
              .timeout(_timeout);
          
          if (resp.statusCode == 200) {
            final data = json.decode(resp.body);
            final items = (data['artists']?['items'] as List?) ?? [];
            
            for (final item in items) {
              final idArtista = item['id'] as String?;
              if (idArtista != null && !idsVistos.contains(idArtista)) {
                idsVistos.add(idArtista);
                todosArtistas.add(artistaDoJsonSpotify(item));
                if (todosArtistas.length >= limite) break;
              }
            }
            
            if (todosArtistas.length >= limite) break;
          }
        } catch (e) {
          continue;
        }
      }
    }
    
    return todosArtistas.take(limite).toList();
  }

  Future<List<Track>> obterTopFaixasBrasil({int limite = 50}) async {
    final appToken = await _getAppAccessToken();
    if (appToken == null) return [];
    
    try {
      final searchTerms = [
        'year:2024 genre:sertanejo',
        'year:2024 genre:brazilian',
        'year:2024 genre:funk',
        'year:2024 genre:mpb',
        'year:2024 genre:pop',
      ];
      
      
      final List<Track> todasFaixas = [];
      final Set<String> idsVistos = {};
      
      for (final term in searchTerms) {
        try {
          final resp = await _client
              .get(
                Uri.parse('$_baseUrl/search?q=${Uri.encodeComponent(term)}&type=track&limit=20&market=BR'),
                headers: _authHeaders(appToken),
              )
              .timeout(_timeout);
          
          if (resp.statusCode == 200) {
            final data = json.decode(resp.body);
            final items = (data['tracks']?['items'] as List?) ?? [];
            
            for (final item in items) {
              final idFaixa = item['id'] as String?;
              if (idFaixa != null && !idsVistos.contains(idFaixa)) {
                idsVistos.add(idFaixa);
                todasFaixas.add(faixaDoJsonSpotify(item));
                if (todasFaixas.length >= limite) break;
              }
            }
            
            if (todasFaixas.length >= limite) break;
          }
        } catch (e) {
          continue;
        }
      }
      
      print('✅ ${todasFaixas.length} músicas em alta carregadas');
      return todasFaixas.take(limite).toList();
    } catch (e) {
      print('❌ Exceção ao buscar músicas em alta: $e');
      return [];
    }
  }

  void descartar() {
    _client.close();
  }
}

