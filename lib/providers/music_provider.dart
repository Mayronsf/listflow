import 'package:flutter/foundation.dart';
import '../models/track.dart';
import '../models/playlist.dart';
import '../models/artist.dart';
import '../services/spotify_service.dart';
import '../services/storage_service.dart';

class MusicProvider with ChangeNotifier {
  final SpotifyService _spotify = SpotifyService();
  final StorageService _storageService = StorageService.instance;

  List<Playlist> _popularPlaylists = [];
  List<Playlist> _searchResults = [];
  List<Playlist> _localPlaylists = [];
  
  List<Track> _favoriteTracks = [];
  List<Track> _searchTracks = [];
  List<Track> _currentPlaylistTracks = [];
  List<Track> _artistTracks = [];
  List<Track> _topTracks = [];
  
  List<Artist> _searchArtists = [];
  List<Artist> _recommendedArtists = [];
  Artist? _currentArtist;
  
  bool _isLoading = false;
  bool _isSearching = false;
  
  String? _error;

  List<Playlist> get popularPlaylists => _popularPlaylists;
  List<Playlist> get searchResults => _searchResults;
  List<Playlist> get localPlaylists => _localPlaylists;
  List<Track> get favoriteTracks => _favoriteTracks;
  List<Track> get searchTracksList => _searchTracks;
  List<Track> get currentPlaylistTracks => _currentPlaylistTracks;
  List<Track> get artistTracks => _artistTracks;
  List<Track> get topTracks => _topTracks;
  List<Artist> get searchArtists => _searchArtists;
  List<Artist> get recommendedArtists => _recommendedArtists;
  Artist? get currentArtist => _currentArtist;
  bool get isLoading => _isLoading;
  bool get isSearching => _isSearching;
  String? get error => _error;

  Future<void> init() async {
    await _storageService.init();
    await loadLocalData();
    await loadPopularPlaylists();
  }

  Future<void> loadLocalData() async {
    try {
      _favoriteTracks = await _storageService.carregarFavoritas();
      _localPlaylists = await _storageService.carregarPlaylistsLocais();
      
      await _syncFavoritesPlaylist();
      
      notifyListeners();
    } catch (e) {
      _error = 'Erro ao carregar dados locais: $e';
      notifyListeners();
    }
  }

  Future<void> _syncFavoritesPlaylist() async {
    const favoritesPlaylistId = 'favorites_playlist';
    
    var favoritesPlaylist = _localPlaylists.firstWhere(
      (p) => p.id == favoritesPlaylistId,
      orElse: () => Playlist(
        id: favoritesPlaylistId,
        nome: 'Músicas Curtidas',
        descricao: 'Suas músicas favoritas',
        ehLocal: true,
        criadaEm: DateTime.now(),
        faixas: [],
      ),
    );
    
    for (final track in _favoriteTracks) {
      if (!favoritesPlaylist.contemFaixa(track.id)) {
        favoritesPlaylist = favoritesPlaylist.adicionarFaixa(track);
      }
    }
    
    final favoriteTrackIds = _favoriteTracks.map((t) => t.id).toSet();
    favoritesPlaylist = Playlist(
      id: favoritesPlaylist.id,
      nome: favoritesPlaylist.nome,
      descricao: favoritesPlaylist.descricao,
      urlCapa: favoritesPlaylist.urlCapa,
      idCriador: favoritesPlaylist.idCriador,
      nomeCriador: favoritesPlaylist.nomeCriador,
      faixas: favoritesPlaylist.faixas.where((t) => favoriteTrackIds.contains(t.id)).toList(),
      criadaEm: favoritesPlaylist.criadaEm,
      ehPublica: favoritesPlaylist.ehPublica,
      ehLocal: favoritesPlaylist.ehLocal,
    );
    
    final playlistIndex = _localPlaylists.indexWhere((p) => p.id == favoritesPlaylistId);
    if (playlistIndex != -1) {
      _localPlaylists[playlistIndex] = favoritesPlaylist;
      await _storageService.atualizarPlaylistLocal(favoritesPlaylist);
    } else {
      _localPlaylists.add(favoritesPlaylist);
      await _storageService.adicionarPlaylistLocal(favoritesPlaylist);
    }
  }

  Future<void> loadPopularPlaylists() async {
    _setLoading(true);
    try {
      _popularPlaylists = await _spotify.obterPlaylistsEmDestaque();
      _error = null;
    } catch (e) {
      _error = 'Erro ao carregar playlists: $e';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadRecommendedArtists({int limit = 20}) async {
    try {
      _recommendedArtists = await _spotify.obterArtistasRecomendados(limite: limit);
      _error = null;
    } catch (e) {
      _error = 'Erro ao carregar artistas recomendados: $e';
    } finally {
      notifyListeners();
    }
  }

  Future<void> loadTopTracks({int limit = 50}) async {
    try {
      _topTracks = await _spotify.obterTopFaixasBrasil(limite: limit);
      _error = null;
    } catch (e) {
      _error = 'Erro ao carregar faixas em alta: $e';
    } finally {
      notifyListeners();
    }
  }

  Future<void> loadPlaylistTracks(String playlistId) async {
    _setLoading(true);
    try {
      await loadLocalData();
      
      final localPlaylist = _localPlaylists.firstWhere(
        (p) => p.id == playlistId,
        orElse: () => Playlist(id: '', nome: ''),
      );
      
      if (localPlaylist.id.isNotEmpty && localPlaylist.ehLocal) {
        _currentPlaylistTracks = localPlaylist.faixas;
        _error = null;
        _setLoading(false);
        notifyListeners();
        return;
      }
      
      final tracks = await _spotify.obterFaixasDaPlaylist(playlistId);
      _currentPlaylistTracks = tracks;
      _error = null;
    } catch (e) {
      _error = 'Erro ao carregar faixas da playlist: $e';
      _currentPlaylistTracks = [];
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  Future<void> searchTracks(String query) async {
    if (query.trim().isEmpty) {
      _searchTracks = [];
      notifyListeners();
      return;
    }

    _setSearching(true);
    try {
      final result = await _spotify.buscarTudo(query);
      final items = (result['tracks']?['items'] as List?) ?? [];
      _searchTracks = items.map((t) => _spotify.faixaDoJsonSpotify(t)).toList().cast<Track>();
      _error = null;
    } catch (e) {
      _error = 'Erro na busca: $e';
    } finally {
      _setSearching(false);
    }
  }

  Future<void> searchPlaylists(String query) async {
    if (query.trim().isEmpty) {
      _searchResults = [];
      notifyListeners();
      return;
    }

    _setSearching(true);
    try {
      await loadLocalData();
      
      final queryLower = query.toLowerCase().trim();
      final List<Playlist> allResults = [];
      
      final localMatches = _localPlaylists.where((playlist) {
        final nameMatch = playlist.nome.toLowerCase().contains(queryLower);
        final descMatch = (playlist.descricao?.toLowerCase().contains(queryLower)) ?? false;
        return nameMatch || descMatch;
      }).toList();
      
      allResults.addAll(localMatches);
      
      try {
        final result = await _spotify.buscarTudo(query);
        final items = (result['playlists']?['items'] as List?) ?? [];
        final spotifyPlaylists = items.map((p) => Playlist(
          id: p['id'] ?? '',
          nome: p['name'] ?? '',
          descricao: p['description'],
          urlCapa: ((p['images'] as List?)?.isNotEmpty ?? false) ? p['images'][0]['url'] : null,
          nomeCriador: p['owner']?['display_name'] ?? p['owner']?['id'],
          faixas: const [],
          criadaEm: DateTime.now(),
        )).toList().cast<Playlist>();
        
        final localIds = localMatches.map((p) => p.id).toSet();
        for (final spotifyPlaylist in spotifyPlaylists) {
          if (!localIds.contains(spotifyPlaylist.id)) {
            allResults.add(spotifyPlaylist);
          }
        }
      } catch (e) {
        print('Erro ao buscar playlists no Spotify: $e');
      }
      
      _searchResults = allResults;
      _error = null;
    } catch (e) {
      _error = 'Erro na busca de playlists: $e';
    } finally {
      _setSearching(false);
      notifyListeners();
    }
  }

  Future<void> searchArtistsByQuery(String query) async {
    if (query.trim().isEmpty) {
      _searchArtists = [];
      notifyListeners();
      return;
    }

    _setSearching(true);
    try {
      final result = await _spotify.buscarTudo(query);
      final items = (result['artists']?['items'] as List?) ?? [];
      _searchArtists = items.map((a) => _spotify.artistaDoJsonSpotify(a)).toList().cast<Artist>();
      _error = null;
    } catch (e) {
      _error = 'Erro na busca de artistas: $e';
    } finally {
      _setSearching(false);
    }
  }

  Future<void> loadArtist(String artistId) async {
    _setLoading(true);
    try {
      final artist = await _spotify.obterArtistaPorId(artistId);
      if (artist != null) {
        _currentArtist = artist;
        final tracks = await _spotify.obterFaixasDoArtista(artistId);
        _artistTracks = tracks;
        _error = null;
      } else {
        _error = 'Artista não encontrado';
      }
    } catch (e) {
      _error = 'Erro ao carregar artista: $e';
    } finally {
      _setLoading(false);
    }
  }

  Future<Playlist> _getOrCreateFavoritesPlaylist() async {
    const favoritesPlaylistId = 'favorites_playlist';
    
    var favoritesPlaylist = _localPlaylists.firstWhere(
      (p) => p.id == favoritesPlaylistId,
      orElse: () => Playlist(id: '', nome: ''),
    );
    
    if (favoritesPlaylist.id.isEmpty) {
      favoritesPlaylist = Playlist(
        id: favoritesPlaylistId,
        nome: 'Músicas Curtidas',
        descricao: 'Suas músicas favoritas',
        ehLocal: true,
        criadaEm: DateTime.now(),
        faixas: [],
      );
      
      await _storageService.adicionarPlaylistLocal(favoritesPlaylist);
      _localPlaylists.add(favoritesPlaylist);
    }
    
    return favoritesPlaylist;
  }

  Future<void> addToFavorites(Track track) async {
    try {
      await _storageService.adicionarFavorita(track);
      _favoriteTracks.add(track.copiarCom(ehFavorito: true));
      
      final favoritesPlaylist = await _getOrCreateFavoritesPlaylist();
      if (!favoritesPlaylist.contemFaixa(track.id)) {
        final updatedPlaylist = favoritesPlaylist.adicionarFaixa(track);
        final playlistIndex = _localPlaylists.indexWhere((p) => p.id == favoritesPlaylist.id);
        if (playlistIndex != -1) {
          _localPlaylists[playlistIndex] = updatedPlaylist;
          await _storageService.atualizarPlaylistLocal(updatedPlaylist);
        }
      }
      
      notifyListeners();
    } catch (e) {
      _error = 'Erro ao adicionar aos favoritos: $e';
      notifyListeners();
    }
  }

  Future<void> removeFromFavorites(String trackId) async {
    try {
      await _storageService.removerFavorita(trackId);
      _favoriteTracks.removeWhere((track) => track.id == trackId);
      
      const favoritesPlaylistId = 'favorites_playlist';
      final playlistIndex = _localPlaylists.indexWhere((p) => p.id == favoritesPlaylistId);
      if (playlistIndex != -1) {
        final updatedPlaylist = _localPlaylists[playlistIndex].removerFaixa(trackId);
        _localPlaylists[playlistIndex] = updatedPlaylist;
        await _storageService.atualizarPlaylistLocal(updatedPlaylist);
      }
      
      notifyListeners();
    } catch (e) {
      _error = 'Erro ao remover dos favoritos: $e';
      notifyListeners();
    }
  }

  bool isFavorite(String trackId) {
    return _favoriteTracks.any((track) => track.id == trackId);
  }

  Future<void> createLocalPlaylist(String name, {String? description}) async {
    try {
      final playlist = Playlist(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        nome: name,
        descricao: description,
        ehLocal: true,
        criadaEm: DateTime.now(),
      );
      
      await _storageService.adicionarPlaylistLocal(playlist);
      _localPlaylists.add(playlist);
      notifyListeners();
    } catch (e) {
      _error = 'Erro ao criar playlist: $e';
      notifyListeners();
    }
  }

  Future<bool> createLocalPlaylistWithDetails({
    required String name,
    String description = '',
    bool isPublic = true,
    required List<Track> tracks,
  }) async {
    _setLoading(true);
    try {
      final playlistId = DateTime.now().millisecondsSinceEpoch.toString();
      
      final playlist = Playlist(
        id: playlistId,
        nome: name,
        descricao: description.isEmpty ? null : description,
        ehPublica: isPublic,
        ehLocal: true,
        faixas: tracks,
        criadaEm: DateTime.now(),
      );

      await _storageService.adicionarPlaylistLocal(playlist);
      _localPlaylists.add(playlist);
      
      await loadLocalData();

      _error = null;
      _setLoading(false);
      return true;
    } catch (e) {
      _error = 'Erro ao criar playlist: $e';
      _setLoading(false);
      return false;
    }
  }

  Future<bool> updateLocalPlaylistWithDetails({
    required String playlistId,
    required String name,
    String description = '',
    bool isPublic = true,
    required List<Track> tracks,
  }) async {
    _setLoading(true);
    try {
      final playlistIndex = _localPlaylists.indexWhere((p) => p.id == playlistId);
      if (playlistIndex == -1) {
        _error = 'Playlist não encontrada';
        _setLoading(false);
        return false;
      }

      final existingPlaylist = _localPlaylists[playlistIndex];
      
      final updatedPlaylist = Playlist(
        id: playlistId,
        nome: name,
        descricao: description.isEmpty ? null : description,
        urlCapa: existingPlaylist.ehLocal ? null : existingPlaylist.urlCapa,
        ehPublica: isPublic,
        ehLocal: true,
        faixas: tracks,
        criadaEm: existingPlaylist.criadaEm,
      );

      await _storageService.atualizarPlaylistLocal(updatedPlaylist);
      _localPlaylists[playlistIndex] = updatedPlaylist;
      
      await loadLocalData();

      _error = null;
      _setLoading(false);
      return true;
    } catch (e) {
      _error = 'Erro ao atualizar playlist: $e';
      _setLoading(false);
      return false;
    }
  }

  Future<void> addTrackToLocalPlaylist(String playlistId, Track track) async {
    try {
      final playlistIndex = _localPlaylists.indexWhere((p) => p.id == playlistId);
      if (playlistIndex != -1) {
        final updatedPlaylist = _localPlaylists[playlistIndex].adicionarFaixa(track);
        _localPlaylists[playlistIndex] = updatedPlaylist;
        await _storageService.atualizarPlaylistLocal(updatedPlaylist);
        notifyListeners();
      }
    } catch (e) {
      _error = 'Erro ao adicionar faixa à playlist: $e';
      notifyListeners();
    }
  }

  Future<void> removeTrackFromLocalPlaylist(String playlistId, String trackId) async {
    try {
      final playlistIndex = _localPlaylists.indexWhere((p) => p.id == playlistId);
      if (playlistIndex != -1) {
        final updatedPlaylist = _localPlaylists[playlistIndex].removerFaixa(trackId);
        _localPlaylists[playlistIndex] = updatedPlaylist;
        await _storageService.atualizarPlaylistLocal(updatedPlaylist);
        notifyListeners();
      }
    } catch (e) {
      _error = 'Erro ao remover faixa da playlist: $e';
      notifyListeners();
    }
  }

  Future<void> removeLocalPlaylist(String playlistId) async {
    try {
      await _storageService.removerPlaylistLocal(playlistId);
      _localPlaylists.removeWhere((playlist) => playlist.id == playlistId);
      notifyListeners();
    } catch (e) {
      _error = 'Erro ao remover playlist: $e';
      notifyListeners();
    }
  }

  Future<void> clearAllLocalData() async {
    try {
      await _storageService.limparTodosDados();
      _favoriteTracks.clear();
      _localPlaylists.clear();
      notifyListeners();
    } catch (e) {
      _error = 'Erro ao limpar dados: $e';
      notifyListeners();
    }
  }

  Future<void> clearFavorites() async {
    try {
      await _storageService.limparFavoritas();
      _favoriteTracks.clear();
      notifyListeners();
    } catch (e) {
      _error = 'Erro ao limpar favoritos: $e';
      notifyListeners();
    }
  }

  Future<void> clearLocalPlaylists() async {
    try {
      await _storageService.limparPlaylistsLocais();
      _localPlaylists.clear();
      notifyListeners();
    } catch (e) {
      _error = 'Erro ao limpar playlists: $e';
      notifyListeners();
    }
  }

  Future<void> updateUserName(String newName) async {
    try {
      print('Nome do usuário atualizado para: $newName');
      notifyListeners();
    } catch (e) {
      _error = 'Erro ao atualizar nome: $e';
      notifyListeners();
    }
  }


  void clearError() {
    _error = null;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setSearching(bool searching) {
    _isSearching = searching;
    notifyListeners();
  }

  @override
  void dispose() {
    _spotify.descartar();
    super.dispose();
  }
}
