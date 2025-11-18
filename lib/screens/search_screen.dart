import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/track.dart';
import '../providers/music_provider.dart';
import '../widgets/empty_widget.dart';
import '../widgets/error_widget.dart';
import '../widgets/loading_widget.dart';
import '../widgets/playlist_card.dart';
import '../widgets/playlist_cover.dart';
import '../widgets/track_tile.dart';
import 'artist_profile_screen.dart';
import 'create_playlist_screen.dart';
import 'playlist_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late TabController _tabController;
  String _currentQuery = '';
  Duration _debounceDuration = const Duration(milliseconds: 350);
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _debounce?.cancel();
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
    musicProvider.searchArtistsByQuery(query);
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
          onChanged: (q) {
            setState(() { _currentQuery = q; });
            _debounce?.cancel();
            _debounce = Timer(_debounceDuration, () => _performSearch(q));
          },
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
            Tab(text: 'Artistas'),
            Tab(text: 'Playlists'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTracksTab(),
          _buildArtistsTab(),
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

  Widget _buildArtistsTab() {
    return Consumer<MusicProvider>(
      builder: (context, musicProvider, child) {
        if (_currentQuery.isEmpty) {
          return const EmptyWidget(
            message: 'Digite algo para buscar',
            subtitle: 'Encontre seus artistas favoritos',
            icon: Icons.person,
          );
        }

        if (musicProvider.isSearching) {
          return const CenterLoadingWidget(message: 'Buscando artistas...');
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

        if (musicProvider.searchArtists.isEmpty) {
          return EmptyWidget(
            message: 'Nenhum artista encontrado',
            subtitle: 'Tente buscar com outros termos',
            icon: Icons.person_off,
            action: ElevatedButton(
              onPressed: () => _performSearch(_currentQuery),
              child: const Text('Tentar novamente'),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: musicProvider.searchArtists.length,
          itemBuilder: (context, index) {
            final artist = musicProvider.searchArtists[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.grey[300],
                  backgroundImage: artist.urlCapa != null
                      ? CachedNetworkImageProvider(artist.urlCapa!)
                      : null,
                  child: artist.urlCapa == null
                      ? const Icon(Icons.person, size: 30)
                      : null,
                ),
                title: Text(
                  artist.nome,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: artist.generos.isNotEmpty
                    ? Text(artist.generos.take(3).join(', '))
                    : artist.seguidores != null
                        ? Text('${_formatFollowers(artist.seguidores!)} seguidores')
                        : null,
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ArtistProfileScreen(artist: artist),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  String _formatFollowers(int followers) {
    if (followers >= 1000000) {
      return '${(followers / 1000000).toStringAsFixed(1)}M';
    } else if (followers >= 1000) {
      return '${(followers / 1000).toStringAsFixed(1)}K';
    }
    return followers.toString();
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

  void _showAddToPlaylistDialog(Track track) {
    showDialog(
      context: context,
      builder: (context) => Consumer<MusicProvider>(
        builder: (context, musicProvider, child) {
          return Dialog(
            child: Container(
              constraints: const BoxConstraints(maxHeight: 500),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Text(
                          'Adicionar à Playlist',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                  const Divider(),
                  
                  Flexible(
                    child: musicProvider.localPlaylists.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.playlist_add,
                                  size: 64,
                                  color: Colors.grey,
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'Nenhuma playlist criada',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Crie uma playlist para começar',
                                  style: TextStyle(
                                    color: Colors.grey,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            itemCount: musicProvider.localPlaylists.length,
                            itemBuilder: (context, index) {
                              final playlist = musicProvider.localPlaylists[index];
                              final alreadyContains = playlist.contemFaixa(track.id);
                              
                              return ListTile(
                                leading: PlaylistCover(
                                  playlist: playlist,
                                  size: 50,
                                  borderRadius: 6,
                                ),
                                title: Text(playlist.nome),
                                subtitle: Text('${playlist.quantidadeFaixas} faixas'),
                                trailing: alreadyContains
                                    ? const Icon(Icons.check, color: Colors.green)
                                    : const Icon(Icons.add),
                                onTap: alreadyContains
                                    ? null
                                    : () async {
                                        await musicProvider.addTrackToLocalPlaylist(
                                          playlist.id,
                                          track,
                                        );
                                        if (context.mounted) {
                                          Navigator.pop(context);
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('Música adicionada à ${playlist.nome}'),
                                              backgroundColor: Colors.green,
                                            ),
                                          );
                                        }
                                      },
                              );
                            },
                          ),
                  ),
                  
                  const Divider(),
                  
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CreatePlaylistScreen(
                                initialTracks: [track],
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Criar Nova Playlist'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
