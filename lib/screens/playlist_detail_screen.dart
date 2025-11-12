import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/playlist.dart';
import '../providers/music_provider.dart';
import '../widgets/track_tile.dart';
import '../widgets/loading_widget.dart';
import '../widgets/error_widget.dart';
import '../widgets/empty_widget.dart';
import 'create_playlist_screen.dart';

/// Tela de detalhes de uma playlist
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
          widget.playlist.name,
          style: const TextStyle(fontSize: 18),
        ),
        actions: [
          // Botão de editar apenas para playlists locais
          if (widget.playlist.isLocal)
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
                
                // Se a playlist foi editada, recarrega os dados
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
              // Cabeçalho da playlist
              Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Capa da playlist
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: widget.playlist.coverUrl != null
                            ? (widget.playlist.coverUrl!.startsWith('file://')
                                ? Image.file(
                                    File(widget.playlist.coverUrl!.replaceFirst('file://', '')),
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Icon(
                                        Icons.music_note,
                                        size: 80,
                                        color: Colors.grey,
                                      );
                                    },
                                  )
                                : widget.playlist.coverUrl!.startsWith('asset://')
                                    ? Image.asset(
                                        widget.playlist.coverUrl!.replaceFirst('asset://', ''),
                                        fit: BoxFit.cover,
                                      )
                                    : CachedNetworkImage(
                                        imageUrl: widget.playlist.coverUrl!,
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) => const Icon(
                                          Icons.music_note,
                                          size: 80,
                                          color: Colors.grey,
                                        ),
                                        errorWidget: (context, url, error) => const Icon(
                                          Icons.music_note,
                                          size: 80,
                                          color: Colors.grey,
                                        ),
                                      ))
                            : const Icon(
                                Icons.music_note,
                                size: 80,
                                color: Colors.grey,
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Título da playlist
                    Text(
                      widget.playlist.name,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    
                    // Informações da playlist
                    if (widget.playlist.creatorName != null)
                      Text(
                        'por ${widget.playlist.creatorName}',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    const SizedBox(height: 8),
                    
                    Text(
                      '${widget.playlist.isLocal ? widget.playlist.trackCount : musicProvider.currentPlaylistTracks.length} faixas',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[500],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              
              // Lista de faixas
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
    // Se for uma playlist local, usa as tracks diretamente da playlist
    final tracksToShow = widget.playlist.isLocal && widget.playlist.tracks.isNotEmpty
        ? widget.playlist.tracks
        : musicProvider.currentPlaylistTracks;

    if (musicProvider.isLoading && !widget.playlist.isLocal) {
      return const TrackLoadingList();
    }

    if (musicProvider.error != null && !widget.playlist.isLocal) {
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
          direction: widget.playlist.isLocal 
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
          onDismissed: widget.playlist.isLocal
              ? (direction) {
                  musicProvider.removeTrackFromLocalPlaylist(
                    widget.playlist.id,
                    track.id,
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${track.title} removida da playlist'),
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
              // Implementar adição à playlist
            },
            child: const Text('Adicionar'),
          ),
        ],
      ),
    );
  }
}
