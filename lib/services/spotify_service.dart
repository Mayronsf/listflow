import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/track.dart';
import '../models/playlist.dart';
import '../models/artist.dart';

class SpotifyService {
  // App config
  static const String _clientId = 'b29495122d6b4e9fa2414319de688381';
  static const String _clientSecret = '9666db64bfc64cd0a5f8af56ce773606';
  static const String _baseUrl = 'https://api.spotify.com/v1';
  static const String _authBase = 'https://accounts.spotify.com';
  static const Duration _timeout = Duration(seconds: 30);

  final http.Client _client = http.Client();

  Future<String?> _getAppAccessToken() async {
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
    }
    return null;
  }


  Map<String, String> _authHeaders(String token) => {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

  // Search tracks/artists/albums
  Future<Map<String, dynamic>> searchAll(String query, {String market = 'BR'}) async {
    final appToken = await _getAppAccessToken();
    if (appToken == null) return {};
    final resp = await _client
        .get(
          Uri.parse('$_baseUrl/search?q=${Uri.encodeComponent(query)}&type=track,artist,album&limit=20&market=$market'),
          headers: _authHeaders(appToken),
        )
        .timeout(_timeout);
    if (resp.statusCode == 200) {
      return json.decode(resp.body) as Map<String, dynamic>;
    }
    return {};
  }

  // Featured playlists (home)
  Future<List<Playlist>> getFeaturedPlaylists({String country = 'BR'}) async {
    final appToken = await _getAppAccessToken();
    if (appToken == null) return [];
    final resp = await _client
        .get(
          Uri.parse('$_baseUrl/browse/featured-playlists?country=$country&limit=20'),
          headers: _authHeaders(appToken),
        )
        .timeout(_timeout);
    if (resp.statusCode == 200) {
      final data = json.decode(resp.body);
      final items = (data['playlists']?['items'] as List?) ?? [];
      return items.map((p) => _playlistFromSpotifyJson(p)).toList().cast<Playlist>();
    }
    return [];
  }


  // Helpers: mapping
  Playlist _playlistFromSpotifyJson(Map<String, dynamic> p) {
    final images = (p['images'] as List?) ?? [];
    final cover = images.isNotEmpty ? images.first['url'] as String? : null;
    return Playlist(
      id: p['id'] ?? '',
      name: p['name'] ?? '',
      description: p['description'],
      coverUrl: cover,
      creatorName: (p['owner'] != null) ? (p['owner']['display_name'] ?? p['owner']['id']) : null,
      tracks: const [],
      createdAt: DateTime.now(),
    );
  }

  Track trackFromSpotifyJson(Map<String, dynamic> t) {
    final album = t['album'] ?? {};
    final images = (album['images'] as List?) ?? [];
    final cover = images.isNotEmpty ? images.last['url'] as String? : null;
    final external = t['external_urls']?['spotify'] as String?;
    final preview = t['preview_url'] as String?;
    final artists = (t['artists'] as List?)?.map((a) => a['name']).whereType<String>().toList() ?? [];
    return Track(
      id: t['id'] ?? '',
      title: t['name'] ?? '',
      artist: artists.join(', '),
      coverUrl: cover,
      sourceUrl: external,
      previewUrl: preview,
      sourceType: 'spotify',
      createdAt: DateTime.now(),
    );
  }


  // Converte artista do JSON do Spotify
  Artist artistFromSpotifyJson(Map<String, dynamic> a) {
    final images = (a['images'] as List?) ?? [];
    final cover = images.isNotEmpty ? images.first['url'] as String? : null;
    final genres = (a['genres'] as List?)?.map((g) => g.toString()).toList() ?? [];
    
    return Artist(
      id: a['id'] ?? '',
      name: a['name'] ?? 'Artista desconhecido',
      coverUrl: cover,
      followers: a['followers']?['total'],
      genres: genres,
      spotifyUrl: a['external_urls']?['spotify'],
    );
  }

  // Busca artista por ID e suas músicas
  Future<Artist?> getArtistById(String artistId) async {
    final appToken = await _getAppAccessToken();
    if (appToken == null) return null;
    
    final resp = await _client
        .get(
          Uri.parse('$_baseUrl/artists/$artistId'),
          headers: _authHeaders(appToken),
        )
        .timeout(_timeout);
    
    if (resp.statusCode == 200) {
      final data = json.decode(resp.body);
      return artistFromSpotifyJson(data);
    }
    return null;
  }

  // Busca músicas do artista
  Future<List<Track>> getArtistTracks(String artistId, {int limit = 20}) async {
    final appToken = await _getAppAccessToken();
    if (appToken == null) return [];
    
    final resp = await _client
        .get(
          Uri.parse('$_baseUrl/artists/$artistId/top-tracks?market=BR'),
          headers: _authHeaders(appToken),
        )
        .timeout(_timeout);
    
    if (resp.statusCode == 200) {
      final data = json.decode(resp.body);
      final tracks = (data['tracks'] as List?) ?? [];
      return tracks.map((t) => trackFromSpotifyJson(t)).toList().cast<Track>();
    }
    return [];
  }

  Future<List<Track>> getRecommendations({List<String>? seedGenres, int limit = 20}) async {
    final appToken = await _getAppAccessToken();
    if (appToken == null) return [];
    final seeds = (seedGenres ?? ['pop','hip-hop','trap']).take(5).join(',');
    final resp = await _client
        .get(
          Uri.parse('$_baseUrl/recommendations?limit=$limit&seed_genres=$seeds'),
          headers: _authHeaders(appToken),
        )
        .timeout(_timeout);
    if (resp.statusCode == 200) {
      final data = json.decode(resp.body);
      final tracks = (data['tracks'] as List?) ?? [];
      return tracks.map((t) => trackFromSpotifyJson(t)).toList().cast<Track>();
    }
    return [];
  }

  // Busca artistas recomendados/populares
  Future<List<Artist>> getRecommendedArtists({int limit = 20}) async {
    final appToken = await _getAppAccessToken();
    if (appToken == null) return [];
    
    final List<Artist> allArtists = [];
    final Set<String> seenIds = {};
    
    // Busca artistas populares usando termos de busca comuns
    // A API do Spotify retorna artistas mais populares primeiro
    final popularSearchTerms = [
      'year:2024',  // Artistas populares recentes
      'tag:new',    // Artistas novos
      'a',          // Busca ampla que retorna artistas populares
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
            final artistId = item['id'] as String?;
            if (artistId != null && !seenIds.contains(artistId)) {
              seenIds.add(artistId);
              allArtists.add(artistFromSpotifyJson(item));
              if (allArtists.length >= limit) break;
            }
          }
          
          if (allArtists.length >= limit) break;
        }
      } catch (e) {
        // Continua com o próximo termo se houver erro
        continue;
      }
    }
    
    // Se ainda não tem artistas suficientes, busca por letras comuns
    if (allArtists.length < limit) {
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
              final artistId = item['id'] as String?;
              if (artistId != null && !seenIds.contains(artistId)) {
                seenIds.add(artistId);
                allArtists.add(artistFromSpotifyJson(item));
                if (allArtists.length >= limit) break;
              }
            }
            
            if (allArtists.length >= limit) break;
          }
        } catch (e) {
          continue;
        }
      }
    }
    
    return allArtists.take(limit).toList();
  }

  // Busca faixas em alta no Brasil (Top 50 Brasil)
  Future<List<Track>> getTopTracksBrazil({int limit = 50}) async {
    final appToken = await _getAppAccessToken();
    if (appToken == null) return [];
    
    try {
      // Tenta buscar a playlist oficial "Top 50 - Brasil" do Spotify
      // O Spotify mantém playlists oficiais com o formato "Top 50 - [País]"
      final searchTerms = [
        'Top 50 - Brasil',
        'Top 50 Brasil',
        '37i9dQZEVXbMXbN3EUUhlg', // ID conhecido da playlist Top 50 Brasil (pode variar)
      ];
      
      String? playlistId;
      
      // Primeiro tenta usar o ID conhecido
      try {
        final testResp = await _client
            .get(
              Uri.parse('$_baseUrl/playlists/37i9dQZEVXbMXbN3EUUhlg?market=BR'),
              headers: _authHeaders(appToken),
            )
            .timeout(_timeout);
        
        if (testResp.statusCode == 200) {
          playlistId = '37i9dQZEVXbMXbN3EUUhlg';
        }
      } catch (e) {
        // Se falhar, tenta buscar por nome
      }
      
      // Se não encontrou pelo ID, busca por nome
      if (playlistId == null) {
        for (final term in searchTerms.take(2)) {
          try {
            final searchResp = await _client
                .get(
                  Uri.parse('$_baseUrl/search?q=${Uri.encodeComponent(term)}&type=playlist&limit=5&market=BR'),
                  headers: _authHeaders(appToken),
                )
                .timeout(_timeout);
            
            if (searchResp.statusCode == 200) {
              final searchData = json.decode(searchResp.body);
              final playlists = (searchData['playlists']?['items'] as List?) ?? [];
              
              // Procura pela playlist oficial do Spotify (geralmente tem "spotify" como owner)
              for (final playlist in playlists) {
                final owner = playlist['owner'];
                if (owner != null && (owner['id'] == 'spotify' || (owner['display_name']?.toString().toLowerCase().contains('spotify') ?? false))) {
                  playlistId = playlist['id'] as String?;
                  if (playlistId != null) break;
                }
              }
              
              // Se não encontrou oficial, pega a primeira
              if (playlistId == null && playlists.isNotEmpty) {
                playlistId = playlists.first['id'] as String?;
              }
              
              if (playlistId != null) break;
            }
          } catch (e) {
            continue;
          }
        }
      }
      
      // Se encontrou a playlist, busca as faixas
      if (playlistId != null) {
        final tracksResp = await _client
            .get(
              Uri.parse('$_baseUrl/playlists/$playlistId/tracks?limit=$limit&market=BR'),
              headers: _authHeaders(appToken),
            )
            .timeout(_timeout);
        
        if (tracksResp.statusCode == 200) {
          final tracksData = json.decode(tracksResp.body);
          final items = (tracksData['items'] as List?) ?? [];
          
          final List<Track> tracks = [];
          for (final item in items) {
            final trackData = item['track'];
            if (trackData != null && trackData is Map) {
              tracks.add(trackFromSpotifyJson(Map<String, dynamic>.from(trackData)));
            }
          }
          
          if (tracks.isNotEmpty) {
            return tracks.take(limit).toList();
          }
        }
      }
      
      // Fallback: busca músicas populares recentes
      final fallbackResp = await _client
          .get(
            Uri.parse('$_baseUrl/search?q=year:2024&type=track&limit=$limit&market=BR'),
            headers: _authHeaders(appToken),
          )
          .timeout(_timeout);
      
      if (fallbackResp.statusCode == 200) {
        final fallbackData = json.decode(fallbackResp.body);
        final items = (fallbackData['tracks']?['items'] as List?) ?? [];
        return items.map((t) => trackFromSpotifyJson(t)).toList().cast<Track>().take(limit).toList();
      }
    } catch (e) {
      // Em caso de erro, retorna lista vazia
      return [];
    }
    
    return [];
  }

  void dispose() {
    _client.close();
  }
}


