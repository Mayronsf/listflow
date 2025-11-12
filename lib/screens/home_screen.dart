import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/music_provider.dart';
import '../models/track.dart';
import '../widgets/playlist_card.dart';
import '../widgets/artist_card.dart';
import '../widgets/playlist_cover.dart';
import '../widgets/loading_widget.dart';
import '../widgets/error_widget.dart';
import 'playlist_detail_screen.dart';
import 'artist_profile_screen.dart';
import 'create_playlist_screen.dart';

/// Tela inicial do aplicativo
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final musicProvider = context.read<MusicProvider>();
      musicProvider.loadPopularPlaylists();
      musicProvider.loadRecommendedArtists(limit: 20);
      musicProvider.loadTopTracks(limit: 50);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        title: SizedBox(
          height: 64,
          child: Image.asset(
            'img/LOGOS (2).png',
            fit: BoxFit.contain,
          ),
        ),
        centerTitle: true,
      ),
      body: Consumer<MusicProvider>(
        builder: (context, musicProvider, child) {
          if (musicProvider.isLoading) {
            return const CenterLoadingWidget(message: 'Carregando conteúdo...');
          }

        if (musicProvider.error != null) {
          return CustomErrorWidget(
            message: musicProvider.error!,
            onRetry: () {
              musicProvider.clearError();
              musicProvider.loadPopularPlaylists();
            },
          );
        }

          return RefreshIndicator(
            onRefresh: () async {
              await musicProvider.loadPopularPlaylists();
              await musicProvider.loadRecommendedArtists(limit: 20);
              await musicProvider.loadTopTracks(limit: 50);
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Seção de Recomendações de Artistas
                  if (musicProvider.recommendedArtists.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Text(
                        'Recomendações de Artistas',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 160,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: musicProvider.recommendedArtists.length,
                        itemBuilder: (context, index) {
                          final artist = musicProvider.recommendedArtists[index];
                          return ArtistCard(
                            artist: artist,
                            size: 120,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ArtistProfileScreen(artist: artist),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                  
                  // Seção de playlists populares
                  if (musicProvider.popularPlaylists.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                      child: Text(
                        'Playlists Populares',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 220,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: musicProvider.popularPlaylists.length,
                        itemBuilder: (context, index) {
                          final playlist = musicProvider.popularPlaylists[index];
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
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                  
                  // Seção de faixas em alta
                  if (musicProvider.topTracks.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Faixas em Alta',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Lista de faixas em alta
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: musicProvider.topTracks.length,
                      itemBuilder: (context, index) {
                        final track = musicProvider.topTracks[index];
                        final isFavorite = musicProvider.isFavorite(track.id);
                        
                        return ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: track.coverUrl != null
                                  ? (track.coverUrl!.startsWith('asset://')
                                      ? Image.asset(
                                          track.coverUrl!.replaceFirst('asset://', ''),
                                          fit: BoxFit.cover,
                                        )
                                      : Image.network(
                                          track.coverUrl!,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) {
                                            return const Icon(
                                              Icons.music_note,
                                              size: 30,
                                              color: Colors.grey,
                                            );
                                          },
                                        ))
                                  : const Icon(
                                      Icons.music_note,
                                      size: 30,
                                      color: Colors.grey,
                                    ),
                            ),
                          ),
                          title: Text(
                            track.title,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            track.artist,
                            style: Theme.of(context).textTheme.bodyMedium,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: () {
                                  if (isFavorite) {
                                    musicProvider.removeFromFavorites(track.id);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Música removida dos favoritos'),
                                        duration: Duration(seconds: 2),
                                      ),
                                    );
                                  } else {
                                    musicProvider.addToFavorites(track);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Música adicionada aos favoritos'),
                                        backgroundColor: Colors.green,
                                        duration: Duration(seconds: 2),
                                      ),
                                    );
                                  }
                                },
                                icon: Icon(
                                  isFavorite ? Icons.favorite : Icons.favorite_border,
                                  color: isFavorite ? Colors.red : null,
                                ),
                                iconSize: 20,
                              ),
                              IconButton(
                                onPressed: () {
                                  _showAddToPlaylistDialog(context, track);
                                },
                                icon: const Icon(Icons.playlist_add),
                                iconSize: 20,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showAddToPlaylistDialog(BuildContext context, Track track) {
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
                  // Cabeçalho
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
                  
                  // Lista de playlists
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
                              final alreadyContains = playlist.containsTrack(track.id);
                              
                              return ListTile(
                                leading: PlaylistCover(
                                  playlist: playlist,
                                  size: 50,
                                  borderRadius: 6,
                                ),
                                title: Text(playlist.name),
                                subtitle: Text('${playlist.trackCount} faixas'),
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
                                              content: Text('Música adicionada à ${playlist.name}'),
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
                  
                  // Botão para criar nova playlist
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
                          ).then((_) {
                            musicProvider.loadLocalData();
                          });
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Criar Nova Playlist'),
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
