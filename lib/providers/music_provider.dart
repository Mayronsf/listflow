import 'package:flutter/foundation.dart';
import '../models/track.dart';
import '../models/playlist.dart';
import '../models/artist.dart';
import '../services/spotify_service.dart';
import '../services/audio_player_service.dart';
import '../services/storage_service.dart';

/// Provider para gerenciar estado da música e playlists
class MusicProvider with ChangeNotifier {
  final SpotifyService _spotify = SpotifyService();
  final AudioPlayerService _audio = AudioPlayerService();
  final StorageService _storageService = StorageService.instance;

  // Estado das playlists
  List<Playlist> _popularPlaylists = [];
  List<Playlist> _searchResults = [];
  List<Playlist> _localPlaylists = [];
  
  // Estado das faixas
  List<Track> _favoriteTracks = [];
  List<Track> _searchTracks = [];
  List<Track> _currentPlaylistTracks = [];
  List<Track> _artistTracks = [];
  List<Track> _topTracks = [];
  
  // Estado dos artistas
  List<Artist> _searchArtists = [];
  List<Artist> _recommendedArtists = [];
  Artist? _currentArtist;
  
  // Estado de carregamento
  bool _isLoading = false;
  bool _isSearching = false;
  
  // Estado de erro
  String? _error;

  // Getters
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

  /// Inicializa o provider
  Future<void> init() async {
    await _storageService.init();
    await _audio.init();
    await loadLocalData();
    await loadPopularPlaylists();
  }

  /// Carrega dados locais (favoritos e playlists locais)
  Future<void> loadLocalData() async {
    try {
      _favoriteTracks = await _storageService.loadFavorites();
      _localPlaylists = await _storageService.loadLocalPlaylists();
      
      // Sincroniza a playlist de músicas curtidas com os favoritos
      await _syncFavoritesPlaylist();
      
      notifyListeners();
    } catch (e) {
      _error = 'Erro ao carregar dados locais: $e';
      notifyListeners();
    }
  }

  /// Sincroniza a playlist de músicas curtidas com os favoritos
  Future<void> _syncFavoritesPlaylist() async {
    const favoritesPlaylistId = 'favorites_playlist';
    
    // Busca ou cria a playlist
    var favoritesPlaylist = _localPlaylists.firstWhere(
      (p) => p.id == favoritesPlaylistId,
      orElse: () => Playlist(
        id: favoritesPlaylistId,
        name: 'Músicas Curtidas',
        description: 'Suas músicas favoritas',
        isLocal: true,
        createdAt: DateTime.now(),
        tracks: [],
      ),
    );
    
    // Adiciona todas as músicas favoritas que ainda não estão na playlist
    for (final track in _favoriteTracks) {
      if (!favoritesPlaylist.containsTrack(track.id)) {
        favoritesPlaylist = favoritesPlaylist.addTrack(track);
      }
    }
    
    // Remove músicas da playlist que não estão mais nos favoritos
    final favoriteTrackIds = _favoriteTracks.map((t) => t.id).toSet();
    favoritesPlaylist = Playlist(
      id: favoritesPlaylist.id,
      name: favoritesPlaylist.name,
      description: favoritesPlaylist.description,
      coverUrl: favoritesPlaylist.coverUrl,
      creatorId: favoritesPlaylist.creatorId,
      creatorName: favoritesPlaylist.creatorName,
      tracks: favoritesPlaylist.tracks.where((t) => favoriteTrackIds.contains(t.id)).toList(),
      createdAt: favoritesPlaylist.createdAt,
      isPublic: favoritesPlaylist.isPublic,
      isLocal: favoritesPlaylist.isLocal,
    );
    
    // Atualiza a lista local e salva
    final playlistIndex = _localPlaylists.indexWhere((p) => p.id == favoritesPlaylistId);
    if (playlistIndex != -1) {
      _localPlaylists[playlistIndex] = favoritesPlaylist;
      await _storageService.updateLocalPlaylist(favoritesPlaylist);
    } else {
      _localPlaylists.add(favoritesPlaylist);
      await _storageService.addLocalPlaylist(favoritesPlaylist);
    }
  }

  /// Carrega playlists populares
  Future<void> loadPopularPlaylists() async {
    _setLoading(true);
    try {
      _popularPlaylists = await _spotify.getFeaturedPlaylists();
      _error = null;
    } catch (e) {
      _error = 'Erro ao carregar playlists: $e';
    } finally {
      _setLoading(false);
    }
  }

  /// Carrega artistas recomendados
  Future<void> loadRecommendedArtists({int limit = 20}) async {
    try {
      _recommendedArtists = await _spotify.getRecommendedArtists(limit: limit);
      _error = null;
    } catch (e) {
      _error = 'Erro ao carregar artistas recomendados: $e';
    } finally {
      notifyListeners();
    }
  }

  /// Carrega faixas em alta no Brasil
  Future<void> loadTopTracks({int limit = 50}) async {
    try {
      _topTracks = await _spotify.getTopTracksBrazil(limit: limit);
      _error = null;
    } catch (e) {
      _error = 'Erro ao carregar faixas em alta: $e';
    } finally {
      notifyListeners();
    }
  }

  /// Carrega faixas de uma playlist
  Future<void> loadPlaylistTracks(String playlistId) async {
    _setLoading(true);
    try {
      // Primeiro, tenta buscar nas playlists locais
      await loadLocalData(); // Garante que as playlists locais estão carregadas
      
      // Busca a playlist nas locais
      final localPlaylist = _localPlaylists.firstWhere(
        (p) => p.id == playlistId,
        orElse: () => Playlist(id: '', name: ''),
      );
      
      if (localPlaylist.id.isNotEmpty && localPlaylist.isLocal) {
        // Se encontrou uma playlist local, usa as tracks dela
        _currentPlaylistTracks = localPlaylist.tracks;
        _error = null;
        _setLoading(false);
        notifyListeners();
        return;
      }
      
      // Se não encontrou nas locais, tenta buscar nas populares
      final popularPlaylist = _popularPlaylists.firstWhere(
        (p) => p.id == playlistId,
        orElse: () => Playlist(id: '', name: ''),
      );
      
      if (popularPlaylist.id.isNotEmpty) {
        _currentPlaylistTracks = popularPlaylist.tracks;
        _error = null;
        _setLoading(false);
        notifyListeners();
        return;
      }
      
      // Se não encontrou em lugar nenhum, lista vazia
      _currentPlaylistTracks = [];
      _error = null;
    } catch (e) {
      _error = 'Erro ao carregar faixas da playlist: $e';
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  /// Busca faixas
  Future<void> searchTracks(String query) async {
    if (query.trim().isEmpty) {
      _searchTracks = [];
      notifyListeners();
      return;
    }

    _setSearching(true);
    try {
      final result = await _spotify.searchAll(query);
      final items = (result['tracks']?['items'] as List?) ?? [];
      _searchTracks = items.map((t) => _spotify.trackFromSpotifyJson(t)).toList().cast<Track>();
      _error = null;
    } catch (e) {
      _error = 'Erro na busca: $e';
    } finally {
      _setSearching(false);
    }
  }

  /// Busca playlists
  Future<void> searchPlaylists(String query) async {
    if (query.trim().isEmpty) {
      _searchResults = [];
      notifyListeners();
      return;
    }

    _setSearching(true);
    try {
      // Garante que as playlists locais estão carregadas
      await loadLocalData();
      
      final queryLower = query.toLowerCase().trim();
      final List<Playlist> allResults = [];
      
      // Busca nas playlists locais primeiro
      final localMatches = _localPlaylists.where((playlist) {
        final nameMatch = playlist.name.toLowerCase().contains(queryLower);
        final descMatch = (playlist.description?.toLowerCase().contains(queryLower)) ?? false;
        return nameMatch || descMatch;
      }).toList();
      
      // Adiciona as playlists locais encontradas (prioridade)
      allResults.addAll(localMatches);
      
      // Busca no Spotify
      try {
        final result = await _spotify.searchAll(query);
        final items = (result['playlists']?['items'] as List?) ?? [];
        final spotifyPlaylists = items.map((p) => Playlist(
          id: p['id'] ?? '',
          name: p['name'] ?? '',
          description: p['description'],
          coverUrl: ((p['images'] as List?)?.isNotEmpty ?? false) ? p['images'][0]['url'] : null,
          creatorName: p['owner']?['display_name'] ?? p['owner']?['id'],
          tracks: const [],
          createdAt: DateTime.now(),
        )).toList().cast<Playlist>();
        
        // Adiciona playlists do Spotify que não são duplicadas (por ID)
        final localIds = localMatches.map((p) => p.id).toSet();
        for (final spotifyPlaylist in spotifyPlaylists) {
          if (!localIds.contains(spotifyPlaylist.id)) {
            allResults.add(spotifyPlaylist);
          }
        }
      } catch (e) {
        // Se houver erro na busca do Spotify, continua apenas com as locais
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

  /// Busca artistas
  Future<void> searchArtistsByQuery(String query) async {
    if (query.trim().isEmpty) {
      _searchArtists = [];
      notifyListeners();
      return;
    }

    _setSearching(true);
    try {
      final result = await _spotify.searchAll(query);
      final items = (result['artists']?['items'] as List?) ?? [];
      _searchArtists = items.map((a) => _spotify.artistFromSpotifyJson(a)).toList().cast<Artist>();
      _error = null;
    } catch (e) {
      _error = 'Erro na busca de artistas: $e';
    } finally {
      _setSearching(false);
    }
  }

  /// Carrega artista e suas músicas
  Future<void> loadArtist(String artistId) async {
    _setLoading(true);
    try {
      final artist = await _spotify.getArtistById(artistId);
      if (artist != null) {
        _currentArtist = artist;
        final tracks = await _spotify.getArtistTracks(artistId);
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

  /// Obtém ou cria a playlist de músicas curtidas
  Future<Playlist> _getOrCreateFavoritesPlaylist() async {
    const favoritesPlaylistId = 'favorites_playlist';
    
    // Busca a playlist nas locais
    var favoritesPlaylist = _localPlaylists.firstWhere(
      (p) => p.id == favoritesPlaylistId,
      orElse: () => Playlist(id: '', name: ''),
    );
    
    // Se não encontrou, cria uma nova
    if (favoritesPlaylist.id.isEmpty) {
      favoritesPlaylist = Playlist(
        id: favoritesPlaylistId,
        name: 'Músicas Curtidas',
        description: 'Suas músicas favoritas',
        isLocal: true,
        createdAt: DateTime.now(),
        tracks: [],
      );
      
      await _storageService.addLocalPlaylist(favoritesPlaylist);
      _localPlaylists.add(favoritesPlaylist);
    }
    
    return favoritesPlaylist;
  }

  /// Adiciona uma faixa aos favoritos
  Future<void> addToFavorites(Track track) async {
    try {
      await _storageService.addFavorite(track);
      _favoriteTracks.add(track.copyWith(isFavorite: true));
      
      // Adiciona à playlist de músicas curtidas
      final favoritesPlaylist = await _getOrCreateFavoritesPlaylist();
      if (!favoritesPlaylist.containsTrack(track.id)) {
        final updatedPlaylist = favoritesPlaylist.addTrack(track);
        final playlistIndex = _localPlaylists.indexWhere((p) => p.id == favoritesPlaylist.id);
        if (playlistIndex != -1) {
          _localPlaylists[playlistIndex] = updatedPlaylist;
          await _storageService.updateLocalPlaylist(updatedPlaylist);
        }
      }
      
      notifyListeners();
    } catch (e) {
      _error = 'Erro ao adicionar aos favoritos: $e';
      notifyListeners();
    }
  }

  /// Remove uma faixa dos favoritos
  Future<void> removeFromFavorites(String trackId) async {
    try {
      await _storageService.removeFavorite(trackId);
      _favoriteTracks.removeWhere((track) => track.id == trackId);
      
      // Remove da playlist de músicas curtidas
      const favoritesPlaylistId = 'favorites_playlist';
      final playlistIndex = _localPlaylists.indexWhere((p) => p.id == favoritesPlaylistId);
      if (playlistIndex != -1) {
        final updatedPlaylist = _localPlaylists[playlistIndex].removeTrack(trackId);
        _localPlaylists[playlistIndex] = updatedPlaylist;
        await _storageService.updateLocalPlaylist(updatedPlaylist);
      }
      
      notifyListeners();
    } catch (e) {
      _error = 'Erro ao remover dos favoritos: $e';
      notifyListeners();
    }
  }

  /// Verifica se uma faixa está nos favoritos
  bool isFavorite(String trackId) {
    return _favoriteTracks.any((track) => track.id == trackId);
  }

  /// Cria uma nova playlist local
  Future<void> createLocalPlaylist(String name, {String? description}) async {
    try {
      final playlist = Playlist(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        description: description,
        isLocal: true,
        createdAt: DateTime.now(),
      );
      
      await _storageService.addLocalPlaylist(playlist);
      _localPlaylists.add(playlist);
      notifyListeners();
    } catch (e) {
      _error = 'Erro ao criar playlist: $e';
      notifyListeners();
    }
  }

  /// Cria uma playlist local com capa e músicas
  Future<bool> createLocalPlaylistWithDetails({
    required String name,
    String description = '',
    bool isPublic = true,
    required List<Track> tracks,
  }) async {
    _setLoading(true);
    try {
      final playlistId = DateTime.now().millisecondsSinceEpoch.toString();
      
      // Cria a playlist com as tracks
      final playlist = Playlist(
        id: playlistId,
        name: name,
        description: description.isEmpty ? null : description,
        isPublic: isPublic,
        isLocal: true,
        tracks: tracks,
        createdAt: DateTime.now(),
      );

      await _storageService.addLocalPlaylist(playlist);
      _localPlaylists.add(playlist);
      
      // Recarrega as playlists locais
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

  /// Atualiza uma playlist local com novos detalhes
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
      
      // Atualiza a playlist
      final updatedPlaylist = Playlist(
        id: playlistId,
        name: name,
        description: description.isEmpty ? null : description,
        coverUrl: existingPlaylist.isLocal ? null : existingPlaylist.coverUrl,
        isPublic: isPublic,
        isLocal: true,
        tracks: tracks,
        createdAt: existingPlaylist.createdAt, // Mantém a data de criação original
      );

      await _storageService.updateLocalPlaylist(updatedPlaylist);
      _localPlaylists[playlistIndex] = updatedPlaylist;
      
      // Recarrega as playlists locais
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

  /// Adiciona uma faixa a uma playlist local
  Future<void> addTrackToLocalPlaylist(String playlistId, Track track) async {
    try {
      final playlistIndex = _localPlaylists.indexWhere((p) => p.id == playlistId);
      if (playlistIndex != -1) {
        final updatedPlaylist = _localPlaylists[playlistIndex].addTrack(track);
        _localPlaylists[playlistIndex] = updatedPlaylist;
        await _storageService.updateLocalPlaylist(updatedPlaylist);
        notifyListeners();
      }
    } catch (e) {
      _error = 'Erro ao adicionar faixa à playlist: $e';
      notifyListeners();
    }
  }

  /// Remove uma faixa de uma playlist local
  Future<void> removeTrackFromLocalPlaylist(String playlistId, String trackId) async {
    try {
      final playlistIndex = _localPlaylists.indexWhere((p) => p.id == playlistId);
      if (playlistIndex != -1) {
        final updatedPlaylist = _localPlaylists[playlistIndex].removeTrack(trackId);
        _localPlaylists[playlistIndex] = updatedPlaylist;
        await _storageService.updateLocalPlaylist(updatedPlaylist);
        notifyListeners();
      }
    } catch (e) {
      _error = 'Erro ao remover faixa da playlist: $e';
      notifyListeners();
    }
  }

  /// Remove uma playlist local
  Future<void> removeLocalPlaylist(String playlistId) async {
    try {
      await _storageService.removeLocalPlaylist(playlistId);
      _localPlaylists.removeWhere((playlist) => playlist.id == playlistId);
      notifyListeners();
    } catch (e) {
      _error = 'Erro ao remover playlist: $e';
      notifyListeners();
    }
  }

  /// Limpa todos os dados locais
  Future<void> clearAllLocalData() async {
    try {
      await _storageService.clearAllData();
      _favoriteTracks.clear();
      _localPlaylists.clear();
      notifyListeners();
    } catch (e) {
      _error = 'Erro ao limpar dados: $e';
      notifyListeners();
    }
  }

  /// Limpa apenas os favoritos
  Future<void> clearFavorites() async {
    try {
      await _storageService.clearFavorites();
      _favoriteTracks.clear();
      notifyListeners();
    } catch (e) {
      _error = 'Erro ao limpar favoritos: $e';
      notifyListeners();
    }
  }

  /// Limpa apenas as playlists locais
  Future<void> clearLocalPlaylists() async {
    try {
      await _storageService.clearLocalPlaylists();
      _localPlaylists.clear();
      notifyListeners();
    } catch (e) {
      _error = 'Erro ao limpar playlists: $e';
      notifyListeners();
    }
  }

  /// Atualiza o nome do usuário
  Future<void> updateUserName(String newName) async {
    try {
      // Aqui você pode implementar a lógica para salvar o nome do usuário
      // Por enquanto, vamos apenas simular a atualização
      print('Nome do usuário atualizado para: $newName');
      notifyListeners();
    } catch (e) {
      _error = 'Erro ao atualizar nome: $e';
      notifyListeners();
    }
  }


  /// Limpa o erro
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Define estado de carregamento
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Define estado de busca
  void _setSearching(bool searching) {
    _isSearching = searching;
    notifyListeners();
  }

  @override
  void dispose() {
    _spotify.dispose();
    _audio.dispose();
    super.dispose();
  }

  // --- Preview controls ---
  Track? _currentTrack;
  Track? get currentTrack => _currentTrack;
  bool get isPlaying => _audio.isPlaying;

  Future<void> playPreview(Track track) async {
    if (track.previewUrl == null) return;
    _currentTrack = track;
    await _audio.playUrl(track.previewUrl!);
    notifyListeners();
  }

  Future<void> pausePreview() async {
    await _audio.pause();
    notifyListeners();
  }

  Future<void> stopPreview() async {
    await _audio.stop();
    _currentTrack = null;
    notifyListeners();
  }
}
