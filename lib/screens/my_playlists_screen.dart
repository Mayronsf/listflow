import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/music_provider.dart';
import '../widgets/playlist_card.dart';
import '../widgets/empty_widget.dart';
import '../widgets/error_widget.dart';
import 'playlist_detail_screen.dart';
import 'create_playlist_screen.dart';

class MyPlaylistsScreen extends StatefulWidget {
  const MyPlaylistsScreen({super.key});

  @override
  State<MyPlaylistsScreen> createState() => _MyPlaylistsScreenState();
}

class _MyPlaylistsScreenState extends State<MyPlaylistsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MusicProvider>().loadLocalData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas Playlists'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CreatePlaylistScreen(),
                ),
              ).then((_) {
                context.read<MusicProvider>().loadLocalData();
              });
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: Consumer<MusicProvider>(
        builder: (context, musicProvider, child) {
        if (musicProvider.error != null) {
          return CustomErrorWidget(
            message: musicProvider.error!,
            onRetry: () {
              musicProvider.clearError();
              musicProvider.loadLocalData();
            },
          );
        }

          if (musicProvider.localPlaylists.isEmpty) {
            return EmptyWidget(
              message: 'Nenhuma playlist criada',
              subtitle: 'Crie sua primeira playlist personalizada',
              icon: Icons.playlist_add,
              action: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CreatePlaylistScreen(),
                    ),
                  ).then((_) {
                    context.read<MusicProvider>().loadLocalData();
                  });
                },
                icon: const Icon(Icons.add),
                label: const Text('Criar Playlist'),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => musicProvider.loadLocalData(),
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.8,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: musicProvider.localPlaylists.length,
              itemBuilder: (context, index) {
                final playlist = musicProvider.localPlaylists[index];
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
                  onFavorite: () {
                    _showDeletePlaylistDialog(playlist);
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }


  void _showDeletePlaylistDialog(dynamic playlist) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Playlist'),
        content: Text('Tem certeza que deseja excluir a playlist "${playlist.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<MusicProvider>().removeLocalPlaylist(playlist.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Playlist excluída com sucesso!'),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }
}
