import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../models/playlist.dart';
import '../models/track.dart';

class StorageService {
  static const String _userKey = 'user_data';
  static const String _favoritesKey = 'favorite_tracks';
  static const String _localPlaylistsKey = 'local_playlists';
  static const String _themeKey = 'is_dark_mode';

  static StorageService? _instance;
  static StorageService get instance => _instance ??= StorageService._();
  
  StorageService._();

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  Future<void> salvarString(String chave, String? valor) async {
    await _garantirInicializado();
    if (valor == null) {
      await _prefs!.remove(chave);
    } else {
      await _prefs!.setString(chave, valor);
    }
  }

  Future<String?> carregarString(String chave) async {
    await _garantirInicializado();
    return _prefs!.getString(chave);
  }

  Future<void> salvarUsuario(User usuario) async {
    await _garantirInicializado();
    await _prefs!.setString(_userKey, jsonEncode(usuario.paraJson()));
  }

  Future<User?> carregarUsuario() async {
    await _garantirInicializado();
    final dadosUsuario = _prefs!.getString(_userKey);
    if (dadosUsuario != null) {
      return User.deJson(jsonDecode(dadosUsuario));
    }
    return null;
  }

  Future<void> salvarFavoritas(List<Track> faixas) async {
    await _garantirInicializado();
    final faixasJson = faixas.map((faixa) => faixa.paraJson()).toList();
    await _prefs!.setString(_favoritesKey, jsonEncode(faixasJson));
  }

  Future<List<Track>> carregarFavoritas() async {
    await _garantirInicializado();
    final dadosFavoritas = _prefs!.getString(_favoritesKey);
    if (dadosFavoritas != null) {
      final List<dynamic> faixasJson = jsonDecode(dadosFavoritas);
      return faixasJson.map((json) => Track.deJson(json)).toList();
    }
    return [];
  }

  Future<void> salvarPlaylistsLocais(List<Playlist> playlists) async {
    await _garantirInicializado();
    final playlistsJson = playlists.map((playlist) => playlist.paraJson()).toList();
    await _prefs!.setString(_localPlaylistsKey, jsonEncode(playlistsJson));
  }

  Future<List<Playlist>> carregarPlaylistsLocais() async {
    await _garantirInicializado();
    final dadosPlaylists = _prefs!.getString(_localPlaylistsKey);
    if (dadosPlaylists != null) {
      final List<dynamic> playlistsJson = jsonDecode(dadosPlaylists);
      return playlistsJson.map((json) => Playlist.deJson(json)).toList();
    }
    return [];
  }

  Future<void> salvarPreferenciaTema(bool ehModoEscuro) async {
    await _garantirInicializado();
    await _prefs!.setBool(_themeKey, ehModoEscuro);
  }

  Future<bool> carregarPreferenciaTema() async {
    await _garantirInicializado();
    return _prefs!.getBool(_themeKey) ?? true;
  }

  Future<void> adicionarFavorita(Track faixa) async {
    final favoritas = await carregarFavoritas();
    if (!favoritas.any((f) => f.id == faixa.id)) {
      favoritas.add(faixa.copiarCom(ehFavorito: true));
      await salvarFavoritas(favoritas);
    }
  }

  Future<void> removerFavorita(String idFaixa) async {
    final favoritas = await carregarFavoritas();
    favoritas.removeWhere((faixa) => faixa.id == idFaixa);
    await salvarFavoritas(favoritas);
  }

  Future<bool> ehFavorita(String idFaixa) async {
    final favoritas = await carregarFavoritas();
    return favoritas.any((faixa) => faixa.id == idFaixa);
  }

  Future<void> adicionarPlaylistLocal(Playlist playlist) async {
    final playlists = await carregarPlaylistsLocais();
    playlists.add(playlist.copiarCom(ehLocal: true));
    await salvarPlaylistsLocais(playlists);
  }

  Future<void> atualizarPlaylistLocal(Playlist playlist) async {
    final playlists = await carregarPlaylistsLocais();
    final indice = playlists.indexWhere((p) => p.id == playlist.id);
    if (indice != -1) {
      playlists[indice] = playlist;
      await salvarPlaylistsLocais(playlists);
    }
  }

  Future<void> removerPlaylistLocal(String idPlaylist) async {
    final playlists = await carregarPlaylistsLocais();
    playlists.removeWhere((playlist) => playlist.id == idPlaylist);
    await salvarPlaylistsLocais(playlists);
  }

  Future<void> limparTodosDados() async {
    await _garantirInicializado();
    await _prefs!.remove(_userKey);
    await _prefs!.remove(_favoritesKey);
    await _prefs!.remove(_localPlaylistsKey);
  }

  Future<void> limparFavoritas() async {
    await _prefs!.remove(_favoritesKey);
  }

  Future<void> limparPlaylistsLocais() async {
    await _prefs!.remove(_localPlaylistsKey);
  }

  Future<void> _garantirInicializado() async {
    if (_prefs == null) {
      await init();
    }
  }
}
