import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/music_provider.dart';
import '../widgets/playlist_card.dart';
import '../widgets/loading_widget.dart';
import '../widgets/error_widget.dart';
import '../widgets/empty_widget.dart';
import 'playlist_detail_screen.dart';

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
      context.read<MusicProvider>().loadPopularPlaylists();
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
            return const CenterLoadingWidget(message: 'Carregando playlists...');
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

          if (musicProvider.popularPlaylists.isEmpty) {
            return const EmptyWidget(
              message: 'Nenhuma playlist encontrada',
              subtitle: 'Tente novamente mais tarde',
              icon: Icons.music_off,
            );
          }

          return RefreshIndicator(
            onRefresh: () => musicProvider.loadPopularPlaylists(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Seção de playlists populares
                  Padding(
                    padding: const EdgeInsets.all(16),
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
                  
                  // Seção de faixas recentes
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Faixas Recentes',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Lista de faixas recentes
                  if (musicProvider.currentPlaylistTracks.isNotEmpty)
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: musicProvider.currentPlaylistTracks.length,
                      itemBuilder: (context, index) {
                        final track = musicProvider.currentPlaylistTracks[index];
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
                                  // Implementar favoritar
                                },
                                icon: const Icon(Icons.favorite_border),
                                iconSize: 20,
                              ),
                              IconButton(
                                onPressed: () {
                                  // Implementar adicionar à playlist
                                },
                                icon: const Icon(Icons.playlist_add),
                                iconSize: 20,
                              ),
                            ],
                          ),
                        );
                      },
                    )
                  else
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'Nenhuma faixa recente disponível',
                        style: TextStyle(color: Colors.grey),
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
