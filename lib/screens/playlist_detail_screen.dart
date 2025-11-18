import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/playlist.dart';
import '../providers/music_provider.dart';
import '../widgets/empty_widget.dart';
import '../widgets/error_widget.dart';
import '../widgets/loading_widget.dart';
import '../widgets/playlist_cover.dart';
import '../widgets/track_tile.dart';
import 'create_playlist_screen.dart';

class PlaylistDetailScreen extends StatefulWidget {
  final Playlist playlist;

  const PlaylistDetailScreen({
    super.key,
    required this.playlist,
  });

  @override
  State<PlaylistDetailScreen> createState() => _PlaylistDetailScreenState();
}

class _PlaylistDetailScreenState extends State<PlaylistDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MusicProvider>().loadPlaylistTracks(widget.playlist.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.playlist.nome,
          style: const TextStyle(fontSize: 18),
        ),
        actions: [
          if (widget.playlist.ehLocal)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreatePlaylistScreen(
                      playlistToEdit: widget.playlist,
                    ),
                  ),
                );
                
                if (result == true && mounted) {
                  context.read<MusicProvider>().loadLocalData();
                  context.read<MusicProvider>().loadPlaylistTracks(widget.playlist.id);
                }
              },
              tooltip: 'Editar Playlist',
            ),
        ],
      ),
      body: Consumer<MusicProvider>(
        builder: (context, musicProvider, child) {
          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    PlaylistCover(
                      playlist: widget.playlist,
                      size: 200,
                      borderRadius: 12,
                    ),
                    const SizedBox(height: 16),
                    
                    Text(
                      widget.playlist.nome,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    
                    if (widget.playlist.nomeCriador != null)
                      Text(
                        'por ${widget.playlist.nomeCriador}',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    const SizedBox(height: 8),
                    
                    Text(
                      '${widget.playlist.ehLocal ? widget.playlist.quantidadeFaixas : musicProvider.currentPlaylistTracks.length} faixas',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[500],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              
              Expanded(
                child: _buildTracksList(musicProvider),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTracksList(MusicProvider musicProvider) {
    final tracksToShow = widget.playlist.ehLocal && widget.playlist.faixas.isNotEmpty
        ? widget.playlist.faixas
        : musicProvider.currentPlaylistTracks;

    if (musicProvider.isLoading && !widget.playlist.ehLocal) {
      return const TrackLoadingList();
    }

    if (musicProvider.error != null && !widget.playlist.ehLocal) {
      return CustomErrorWidget(
        message: musicProvider.error!,
        onRetry: () {
          musicProvider.clearError();
          musicProvider.loadPlaylistTracks(widget.playlist.id);
        },
      );
    }

    if (tracksToShow.isEmpty) {
      return const EmptyWidget(
        message: 'Nenhuma faixa encontrada',
        subtitle: 'Esta playlist está vazia',
        icon: Icons.music_off,
      );
    }

    return ListView.builder(
      itemCount: tracksToShow.length,
      itemBuilder: (context, index) {
        final track = tracksToShow[index];
        final isFavorite = musicProvider.isFavorite(track.id);
        
        return Dismissible(
          key: Key('${track.id}_${widget.playlist.id}'),
          direction: widget.playlist.ehLocal 
              ? DismissDirection.endToStart 
              : DismissDirection.none,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            color: Colors.red,
            child: const Icon(
              Icons.delete,
              color: Colors.white,
            ),
          ),
          onDismissed: widget.playlist.ehLocal
              ? (direction) {
                  musicProvider.removeTrackFromLocalPlaylist(
                    widget.playlist.id,
                    track.id,
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${track.titulo} removida da playlist'),
                      action: SnackBarAction(
                        label: 'Desfazer',
                        onPressed: () {
                          musicProvider.addTrackToLocalPlaylist(
                            widget.playlist.id,
                            track,
                          );
                        },
                      ),
                    ),
                  );
                }
              : null,
          child: TrackTile(
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
          ),
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
            },
            child: const Text('Adicionar'),
          ),
        ],
      ),
    );
  }
}
