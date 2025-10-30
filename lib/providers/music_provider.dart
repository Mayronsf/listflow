import 'package:flutter/foundation.dart';
import '../models/track.dart';
import '../models/playlist.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

/// Provider para gerenciar estado da música e playlists
class MusicProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final StorageService _storageService = StorageService.instance;

  // Estado das playlists
  List<Playlist> _popularPlaylists = [];
  List<Playlist> _searchResults = [];
  List<Playlist> _localPlaylists = [];
  
  // Estado das faixas
  List<Track> _favoriteTracks = [];
  List<Track> _searchTracks = [];
  List<Track> _currentPlaylistTracks = [];
  
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
  bool get isLoading => _isLoading;
  bool get isSearching => _isSearching;
  String? get error => _error;

  /// Inicializa o provider
  Future<void> init() async {
    await _storageService.init();
    await loadLocalData();
    await loadPopularPlaylists();
  }

  /// Carrega dados locais (favoritos e playlists locais)
  Future<void> loadLocalData() async {
    try {
      _favoriteTracks = await _storageService.loadFavorites();
      _localPlaylists = await _storageService.loadLocalPlaylists();
      notifyListeners();
    } catch (e) {
      _error = 'Erro ao carregar dados locais: $e';
      notifyListeners();
    }
  }

  /// Carrega playlists populares
  Future<void> loadPopularPlaylists() async {
    _setLoading(true);
    try {
      _popularPlaylists = await _apiService.getPopularPlaylists();
      _error = null;
    } catch (e) {
      _error = 'Erro ao carregar playlists: $e';
    } finally {
      _setLoading(false);
    }
  }

  /// Carrega faixas de uma playlist
  Future<void> loadPlaylistTracks(String playlistId) async {
    _setLoading(true);
    try {
      _currentPlaylistTracks = await _apiService.getPlaylistTracks(playlistId);
      _error = null;
    } catch (e) {
      _error = 'Erro ao carregar faixas da playlist: $e';
    } finally {
      _setLoading(false);
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
      _searchTracks = await _apiService.searchTracks(query);
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
      _searchResults = await _apiService.searchPlaylists(query);
      _error = null;
    } catch (e) {
      _error = 'Erro na busca de playlists: $e';
    } finally {
      _setSearching(false);
    }
  }

  /// Adiciona uma faixa aos favoritos
  Future<void> addToFavorites(Track track) async {
    try {
      await _storageService.addFavorite(track);
      _favoriteTracks.add(track.copyWith(isFavorite: true));
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
    _apiService.dispose();
    super.dispose();
  }
}
