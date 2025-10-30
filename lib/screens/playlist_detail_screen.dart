import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/playlist.dart';
import '../providers/music_provider.dart';
import '../widgets/track_tile.dart';
import '../widgets/loading_widget.dart';
import '../widgets/error_widget.dart';
import '../widgets/empty_widget.dart';

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
          IconButton(
            onPressed: () {
              // Implementar compartilhar
            },
            icon: const Icon(Icons.share),
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
                            ? Image.network(
                                widget.playlist.coverUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(
                                    Icons.music_note,
                                    size: 80,
                                    color: Colors.grey,
                                  );
                                },
                              )
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
                      '${musicProvider.currentPlaylistTracks.length} faixas',
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
    if (musicProvider.isLoading) {
      return const TrackLoadingList();
    }

        if (musicProvider.error != null) {
          return CustomErrorWidget(
            message: musicProvider.error!,
            onRetry: () {
              musicProvider.clearError();
              musicProvider.loadPlaylistTracks(widget.playlist.id);
            },
          );
        }

    if (musicProvider.currentPlaylistTracks.isEmpty) {
      return const EmptyWidget(
        message: 'Nenhuma faixa encontrada',
        subtitle: 'Esta playlist está vazia',
        icon: Icons.music_off,
      );
    }

    return ListView.builder(
      itemCount: musicProvider.currentPlaylistTracks.length,
      itemBuilder: (context, index) {
        final track = musicProvider.currentPlaylistTracks[index];
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
