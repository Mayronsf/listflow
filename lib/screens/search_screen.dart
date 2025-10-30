import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/music_provider.dart';
import '../widgets/track_tile.dart';
import '../widgets/playlist_card.dart';
import '../widgets/loading_widget.dart';
import '../widgets/error_widget.dart';
import '../widgets/empty_widget.dart';
import 'playlist_detail_screen.dart';

/// Tela de busca
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late TabController _tabController;
  String _currentQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _performSearch(String query) {
    if (query.trim().isEmpty) return;
    
    setState(() {
      _currentQuery = query;
    });
    
    final musicProvider = context.read<MusicProvider>();
    musicProvider.searchTracks(query);
    musicProvider.searchPlaylists(query);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Buscar músicas e playlists...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.grey),
          ),
          style: const TextStyle(color: Colors.white),
          onSubmitted: _performSearch,
        ),
        actions: [
          IconButton(
            onPressed: () => _performSearch(_searchController.text),
            icon: const Icon(Icons.search),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Faixas'),
            Tab(text: 'Playlists'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTracksTab(),
          _buildPlaylistsTab(),
        ],
      ),
    );
  }

  Widget _buildTracksTab() {
    return Consumer<MusicProvider>(
      builder: (context, musicProvider, child) {
        if (_currentQuery.isEmpty) {
          return const EmptyWidget(
            message: 'Digite algo para buscar',
            subtitle: 'Encontre suas músicas favoritas',
            icon: Icons.search,
          );
        }

        if (musicProvider.isSearching) {
          return const CenterLoadingWidget(message: 'Buscando faixas...');
        }

        if (musicProvider.error != null) {
          return CustomErrorWidget(
            message: musicProvider.error!,
            onRetry: () {
              musicProvider.clearError();
              _performSearch(_currentQuery);
            },
          );
        }

        if (musicProvider.searchTracksList.isEmpty) {
          return EmptyWidget(
            message: 'Nenhuma faixa encontrada',
            subtitle: 'Tente buscar com outros termos',
            icon: Icons.music_off,
            action: ElevatedButton(
              onPressed: () => _performSearch(_currentQuery),
              child: const Text('Tentar novamente'),
            ),
          );
        }

        return ListView.builder(
          itemCount: musicProvider.searchTracksList.length,
          itemBuilder: (context, index) {
            final track = musicProvider.searchTracksList[index];
            final isFavorite = musicProvider.isFavorite(track.id);
            
            return TrackTile(
              track: track,
              isFavorite: isFavorite,
              onFavorite: () {
                if (isFavorite) {
                  musicProvider.removeFromFavorites(track.id);
                } else {
                  musicProvider.addToFavorites(track);
                }
              },
              onAddToPlaylist: () {
                _showAddToPlaylistDialog(track);
              },
            );
          },
        );
      },
    );
  }

  Widget _buildPlaylistsTab() {
    return Consumer<MusicProvider>(
      builder: (context, musicProvider, child) {
        if (_currentQuery.isEmpty) {
          return const EmptyWidget(
            message: 'Digite algo para buscar',
            subtitle: 'Encontre playlists incríveis',
            icon: Icons.search,
          );
        }

        if (musicProvider.isSearching) {
          return const CenterLoadingWidget(message: 'Buscando playlists...');
        }

        if (musicProvider.error != null) {
          return CustomErrorWidget(
            message: musicProvider.error!,
            onRetry: () {
              musicProvider.clearError();
              _performSearch(_currentQuery);
            },
          );
        }

        if (musicProvider.searchResults.isEmpty) {
          return EmptyWidget(
            message: 'Nenhuma playlist encontrada',
            subtitle: 'Tente buscar com outros termos',
            icon: Icons.playlist_play,
            action: ElevatedButton(
              onPressed: () => _performSearch(_currentQuery),
              child: const Text('Tentar novamente'),
            ),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.8,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: musicProvider.searchResults.length,
          itemBuilder: (context, index) {
            final playlist = musicProvider.searchResults[index];
            return PlaylistCard(
              playlist: playlist,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PlaylistDetailScreen(
                      playlist: playlist,
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  void _showAddToPlaylistDialog(dynamic track) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Adicionar à Playlist'),
        content: const Text('Escolha uma playlist para adicionar esta faixa:'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Implementar adição à playlist
            },
            child: const Text('Adicionar'),
          ),
        ],
      ),
    );
  }
}
