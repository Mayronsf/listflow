import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/track.dart';
import '../models/playlist.dart';
import 'mock_data_service.dart';

/// Serviço para consumir a API do Openwhyd
class ApiService {
  static const String baseUrl = 'https://openwhyd.org';
  static const Duration timeout = Duration(seconds: 30);

  final http.Client _client = http.Client();

  /// Busca playlists populares
  Future<List<Playlist>> getPopularPlaylists({int limit = 20}) async {
    try {
      final response = await _client
          .get(
            Uri.parse('$baseUrl/api/post?format=json&limit=$limit'),
            headers: {
              'Content-Type': 'application/json',
              'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
              'Accept': 'application/json',
            },
          )
          .timeout(timeout);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Playlist.fromJson(json)).toList();
      } else {
        // Fallback para dados mock se a API falhar
        print('API falhou, usando dados mock. Status: ${response.statusCode}');
        return MockDataService.getMockPlaylists();
      }
    } catch (e) {
      // Fallback para dados mock se houver erro de conexão
      print('Erro na requisição, usando dados mock: $e');
      return MockDataService.getMockPlaylists();
    }
  }

  /// Busca faixas de uma playlist específica
  Future<List<Track>> getPlaylistTracks(String playlistId) async {
    try {
      final response = await _client
          .get(
            Uri.parse('$baseUrl/api/playlist/$playlistId?format=json'),
            headers: {
              'Content-Type': 'application/json',
              'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
              'Accept': 'application/json',
            },
          )
          .timeout(timeout);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['tracks'] != null) {
          final List<dynamic> tracksData = data['tracks'];
          return tracksData.map((json) => Track.fromJson(json)).toList();
        }
        return [];
      } else {
        // Fallback para dados mock se a API falhar
        print('API de faixas da playlist falhou, usando dados mock. Status: ${response.statusCode}');
        return MockDataService.getMockTracks();
      }
    } catch (e) {
      // Fallback para dados mock se houver erro de conexão
      print('Erro ao buscar faixas da playlist, usando dados mock: $e');
      return MockDataService.getMockTracks();
    }
  }

  /// Busca faixas de um usuário específico
  Future<List<Track>> getUserTracks(String userId, {int limit = 50}) async {
    try {
      final response = await _client
          .get(
            Uri.parse('$baseUrl/api/user/$userId?format=json&limit=$limit'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(timeout);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Track.fromJson(json)).toList();
      } else {
        throw Exception('Erro ao buscar faixas do usuário: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro na requisição: $e');
    }
  }

  /// Busca faixas por termo de pesquisa
  Future<List<Track>> searchTracks(String query, {int limit = 30}) async {
    try {
      final response = await _client
          .get(
            Uri.parse('$baseUrl/api/search?q=${Uri.encodeComponent(query)}&format=json&limit=$limit'),
            headers: {
              'Content-Type': 'application/json',
              'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
              'Accept': 'application/json',
            },
          )
          .timeout(timeout);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Track.fromJson(json)).toList();
      } else {
        // Fallback para dados mock se a API falhar
        print('API de busca falhou, usando dados mock. Status: ${response.statusCode}');
        return MockDataService.searchMockTracks(query);
      }
    } catch (e) {
      // Fallback para dados mock se houver erro de conexão
      print('Erro na busca, usando dados mock: $e');
      return MockDataService.searchMockTracks(query);
    }
  }

  /// Busca playlists por termo de pesquisa
  Future<List<Playlist>> searchPlaylists(String query, {int limit = 20}) async {
    try {
      final response = await _client
          .get(
            Uri.parse('$baseUrl/api/search?q=${Uri.encodeComponent(query)}&format=json&limit=$limit'),
            headers: {
              'Content-Type': 'application/json',
              'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
              'Accept': 'application/json',
            },
          )
          .timeout(timeout);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Playlist.fromJson(json)).toList();
      } else {
        // Fallback para dados mock se a API falhar
        print('API de busca de playlists falhou, usando dados mock. Status: ${response.statusCode}');
        return MockDataService.searchMockPlaylists(query);
      }
    } catch (e) {
      // Fallback para dados mock se houver erro de conexão
      print('Erro na busca de playlists, usando dados mock: $e');
      return MockDataService.searchMockPlaylists(query);
    }
  }

  /// Busca detalhes de uma playlist específica
  Future<Playlist?> getPlaylistDetails(String playlistId) async {
    try {
      final response = await _client
          .get(
            Uri.parse('$baseUrl/api/playlist/$playlistId?format=json'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(timeout);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return Playlist.fromJson(data);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  /// Busca faixas recentes/trending
  Future<List<Track>> getRecentTracks({int limit = 30}) async {
    try {
      final response = await _client
          .get(
            Uri.parse('$baseUrl/api/post?format=json&limit=$limit&sort=recent'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(timeout);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Track.fromJson(json)).toList();
      } else {
        throw Exception('Erro ao buscar faixas recentes: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro na requisição: $e');
    }
  }

  /// Fecha o cliente HTTP
  void dispose() {
    _client.close();
  }
}
