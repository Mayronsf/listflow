import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/artist.dart';
import '../models/track.dart';
import '../providers/music_provider.dart';
import '../widgets/empty_widget.dart';
import '../widgets/error_widget.dart';
import '../widgets/loading_widget.dart';
import '../widgets/playlist_cover.dart';
import '../widgets/track_tile.dart';
import 'create_playlist_screen.dart';

class ArtistProfileScreen extends StatefulWidget {
  final Artist artist;

  const ArtistProfileScreen({
    super.key,
    required this.artist,
  });

  @override
  State<ArtistProfileScreen> createState() => _ArtistProfileScreenState();
}

class _ArtistProfileScreenState extends State<ArtistProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MusicProvider>().loadArtist(widget.artist.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.artist.nome),
        actions: [
          if (widget.artist.urlSpotify != null)
            IconButton(
              onPressed: () async {
                await _launchSpotifyUrl(widget.artist.urlSpotify!);
              },
              icon: const Icon(Icons.open_in_new),
              tooltip: 'Abrir no Spotify',
            ),
        ],
      ),
      body: Consumer<MusicProvider>(
        builder: (context, musicProvider, child) {
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: widget.artist.urlCapa != null
                              ? CachedNetworkImage(
                                  imageUrl: widget.artist.urlCapa!,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => const Icon(
                                    Icons.person,
                                    size: 80,
                                    color: Colors.grey,
                                  ),
                                  errorWidget: (context, url, error) => const Icon(
                                    Icons.person,
                                    size: 80,
                                    color: Colors.grey,
                                  ),
                                )
                              : const Icon(
                                  Icons.person,
                                  size: 80,
                                  color: Colors.grey,
                                ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        widget.artist.nome,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      if (widget.artist.seguidores != null)
                        Text(
                          '${_formatFollowers(widget.artist.seguidores!)} seguidores',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: Colors.grey[600],
                              ),
                          textAlign: TextAlign.center,
                        ),
                      const SizedBox(height: 8),
                      if (widget.artist.generos.isNotEmpty)
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 8,
                          children: widget.artist.generos.take(5).map((genre) {
                            return Chip(
                              label: Text(genre),
                              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                            );
                          }).toList(),
                        ),
                      const SizedBox(height: 16),
                      Text(
                        '${musicProvider.artistTracks.length} músicas',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[500],
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              if (musicProvider.isLoading)
                const SliverFillRemaining(
                  child: CenterLoadingWidget(message: 'Carregando músicas...'),
                )
              else if (musicProvider.error != null)
                SliverFillRemaining(
                  child: CustomErrorWidget(
                    message: musicProvider.error!,
                    onRetry: () {
                      musicProvider.clearError();
                      musicProvider.loadArtist(widget.artist.id);
                    },
                  ),
                )
              else if (musicProvider.artistTracks.isEmpty)
                const SliverFillRemaining(
                  child: EmptyWidget(
                    message: 'Nenhuma música encontrada',
                    subtitle: 'Este artista ainda não tem músicas disponíveis',
                    icon: Icons.music_off,
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final track = musicProvider.artistTracks[index];
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
                    childCount: musicProvider.artistTracks.length,
                  ),
                ),
            ],
          );
        },
      ),
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
  Future<void> _launchSpotifyUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Não foi possível abrir o link do Spotify'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao abrir link: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}


