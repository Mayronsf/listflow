import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../models/playlist.dart';
import '../models/track.dart';

/// Serviço para persistência local de dados
class StorageService {
  static const String _userKey = 'user_data';
  static const String _favoritesKey = 'favorite_tracks';
  static const String _localPlaylistsKey = 'local_playlists';
  static const String _themeKey = 'is_dark_mode';

  static StorageService? _instance;
  static StorageService get instance => _instance ??= StorageService._();
  
  StorageService._();

  SharedPreferences? _prefs;

  /// Inicializa o serviço
  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Salva dados do usuário
  Future<void> saveUser(User user) async {
    await _ensureInitialized();
    await _prefs!.setString(_userKey, jsonEncode(user.toJson()));
  }

  /// Carrega dados do usuário
  Future<User?> loadUser() async {
    await _ensureInitialized();
    final userData = _prefs!.getString(_userKey);
    if (userData != null) {
      return User.fromJson(jsonDecode(userData));
    }
    return null;
  }

  /// Salva faixas favoritas
  Future<void> saveFavorites(List<Track> tracks) async {
    await _ensureInitialized();
    final tracksJson = tracks.map((track) => track.toJson()).toList();
    await _prefs!.setString(_favoritesKey, jsonEncode(tracksJson));
  }

  /// Carrega faixas favoritas
  Future<List<Track>> loadFavorites() async {
    await _ensureInitialized();
    final favoritesData = _prefs!.getString(_favoritesKey);
    if (favoritesData != null) {
      final List<dynamic> tracksJson = jsonDecode(favoritesData);
      return tracksJson.map((json) => Track.fromJson(json)).toList();
    }
    return [];
  }

  /// Salva playlists locais
  Future<void> saveLocalPlaylists(List<Playlist> playlists) async {
    await _ensureInitialized();
    final playlistsJson = playlists.map((playlist) => playlist.toJson()).toList();
    await _prefs!.setString(_localPlaylistsKey, jsonEncode(playlistsJson));
  }

  /// Carrega playlists locais
  Future<List<Playlist>> loadLocalPlaylists() async {
    await _ensureInitialized();
    final playlistsData = _prefs!.getString(_localPlaylistsKey);
    if (playlistsData != null) {
      final List<dynamic> playlistsJson = jsonDecode(playlistsData);
      return playlistsJson.map((json) => Playlist.fromJson(json)).toList();
    }
    return [];
  }

  /// Salva preferência de tema
  Future<void> saveThemePreference(bool isDarkMode) async {
    await _ensureInitialized();
    await _prefs!.setBool(_themeKey, isDarkMode);
  }

  /// Carrega preferência de tema
  Future<bool> loadThemePreference() async {
    await _ensureInitialized();
    return _prefs!.getBool(_themeKey) ?? true; // Padrão: modo escuro
  }

  /// Adiciona uma faixa aos favoritos
  Future<void> addFavorite(Track track) async {
    final favorites = await loadFavorites();
    if (!favorites.any((t) => t.id == track.id)) {
      favorites.add(track.copyWith(isFavorite: true));
      await saveFavorites(favorites);
    }
  }

  /// Remove uma faixa dos favoritos
  Future<void> removeFavorite(String trackId) async {
    final favorites = await loadFavorites();
    favorites.removeWhere((track) => track.id == trackId);
    await saveFavorites(favorites);
  }

  /// Verifica se uma faixa está nos favoritos
  Future<bool> isFavorite(String trackId) async {
    final favorites = await loadFavorites();
    return favorites.any((track) => track.id == trackId);
  }

  /// Adiciona uma playlist local
  Future<void> addLocalPlaylist(Playlist playlist) async {
    final playlists = await loadLocalPlaylists();
    playlists.add(playlist.copyWith(isLocal: true));
    await saveLocalPlaylists(playlists);
  }

  /// Atualiza uma playlist local
  Future<void> updateLocalPlaylist(Playlist playlist) async {
    final playlists = await loadLocalPlaylists();
    final index = playlists.indexWhere((p) => p.id == playlist.id);
    if (index != -1) {
      playlists[index] = playlist;
      await saveLocalPlaylists(playlists);
    }
  }

  /// Remove uma playlist local
  Future<void> removeLocalPlaylist(String playlistId) async {
    final playlists = await loadLocalPlaylists();
    playlists.removeWhere((playlist) => playlist.id == playlistId);
    await saveLocalPlaylists(playlists);
  }

  /// Limpa todos os dados locais
  Future<void> clearAllData() async {
    await _ensureInitialized();
    await _prefs!.remove(_userKey);
    await _prefs!.remove(_favoritesKey);
    await _prefs!.remove(_localPlaylistsKey);
  }

  /// Limpa apenas os favoritos
  Future<void> clearFavorites() async {
    await _prefs!.remove(_favoritesKey);
  }

  /// Limpa apenas as playlists locais
  Future<void> clearLocalPlaylists() async {
    await _prefs!.remove(_localPlaylistsKey);
  }

  /// Garante que o serviço está inicializado
  Future<void> _ensureInitialized() async {
    if (_prefs == null) {
      await init();
    }
  }
}
