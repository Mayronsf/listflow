import '../models/track.dart';
import '../models/playlist.dart';

/// Serviço com dados mock para demonstração
class MockDataService {
  static List<Playlist> getMockPlaylists() {
    return [
      Playlist(
        id: '1',
        name: 'Trap Nacional 2024',
        description: 'Os melhores hits do trap brasileiro',
        coverUrl: 'https://e-cdns-images.dzcdn.net/cover/3b4a4a4a4a4a4a4a4a4a4a4a4a4a4a4a-500x500.jpg',
        creatorName: 'OpenWhyd',
        tracks: getTrapTracks(),
        createdAt: DateTime.now(),
      ),
      Playlist(
        id: '2',
        name: 'Funk Carioca Hits',
        description: 'Os maiores sucessos do funk carioca',
        coverUrl: 'https://e-cdns-images.dzcdn.net/cover/2a3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b-500x500.jpg',
        creatorName: 'FunkMaster',
        tracks: getFunkTracks(),
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      Playlist(
        id: '3',
        name: 'Sertanejo Universitário',
        description: 'O melhor do sertanejo universitário',
        coverUrl: 'https://e-cdns-images.dzcdn.net/cover/1a2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b-500x500.jpg',
        creatorName: 'SertanejoFan',
        tracks: getSertanejoTracks(),
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      Playlist(
        id: '4',
        name: 'Pagode Romântico',
        description: 'Pagode para momentos especiais',
        coverUrl: 'https://e-cdns-images.dzcdn.net/cover/4a5b5b5b5b5b5b5b5b5b5b5b5b5b5b5b-500x500.jpg',
        creatorName: 'PagodeLover',
        tracks: getPagodeTracks(),
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      Playlist(
        id: '5',
        name: 'Matuê & Veigh Hits',
        description: 'Os maiores sucessos de Matuê e Veigh',
        coverUrl: 'https://e-cdns-images.dzcdn.net/cover/5a6b6b6b6b6b6b6b6b6b6b6b6b6b6b6b-500x500.jpg',
        creatorName: 'TrapFan',
        tracks: getMatueVeighTracks(),
        createdAt: DateTime.now().subtract(const Duration(days: 4)),
      ),
    ];
  }

  static List<Track> getMockTracks() {
    return [
      Track(
        id: '1',
        title: 'Banco',
        artist: 'Matuê',
        coverUrl: 'https://e-cdns-images.dzcdn.net/cover/6a7b7b7b7b7b7b7b7b7b7b7b7b7b7b7b-500x500.jpg',
        sourceUrl: 'https://www.deezer.com/track/123456789',
        sourceType: 'deezer',
        createdAt: DateTime.now(),
      ),
      Track(
        id: '2',
        title: 'Novo Balanço',
        artist: 'Veigh',
        coverUrl: 'https://e-cdns-images.dzcdn.net/cover/7a8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b-500x500.jpg',
        sourceUrl: 'https://www.deezer.com/track/123456790',
        sourceType: 'deezer',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      Track(
        id: '3',
        title: 'Fim de Semana no Rio',
        artist: 'Teto',
        coverUrl: 'https://e-cdns-images.dzcdn.net/cover/8a9b9b9b9b9b9b9b9b9b9b9b9b9b9b9b-500x500.jpg',
        sourceUrl: 'https://www.deezer.com/track/123456791',
        sourceType: 'deezer',
        createdAt: DateTime.now().subtract(const Duration(hours: 4)),
      ),
      Track(
        id: '4',
        title: 'Vida Loka',
        artist: 'Racionais MCs',
        coverUrl: 'https://e-cdns-images.dzcdn.net/cover/9a0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b-500x500.jpg',
        sourceUrl: 'https://www.deezer.com/track/123456792',
        sourceType: 'deezer',
        createdAt: DateTime.now().subtract(const Duration(hours: 6)),
      ),
      Track(
        id: '5',
        title: 'Evidências',
        artist: 'Chitãozinho & Xororó',
        coverUrl: 'https://e-cdns-images.dzcdn.net/cover/0a1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b-500x500.jpg',
        sourceUrl: 'https://www.deezer.com/track/123456793',
        sourceType: 'deezer',
        createdAt: DateTime.now().subtract(const Duration(hours: 8)),
      ),
      Track(
        id: '6',
        title: 'Pagode Russo',
        artist: 'Exaltasamba',
        coverUrl: 'https://e-cdns-images.dzcdn.net/cover/1a2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b-500x500.jpg',
        sourceUrl: 'https://www.deezer.com/track/123456794',
        sourceType: 'deezer',
        createdAt: DateTime.now().subtract(const Duration(hours: 10)),
      ),
      Track(
        id: '7',
        title: 'Baile de Favela',
        artist: 'Mc João',
        coverUrl: 'https://e-cdns-images.dzcdn.net/cover/2a3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b-500x500.jpg',
        sourceUrl: 'https://www.deezer.com/track/123456795',
        sourceType: 'deezer',
        createdAt: DateTime.now().subtract(const Duration(hours: 12)),
      ),
      Track(
        id: '8',
        title: 'Só os Loucos Sabem',
        artist: 'Charlie Brown Jr.',
        coverUrl: 'https://e-cdns-images.dzcdn.net/cover/3a4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b-500x500.jpg',
        sourceUrl: 'https://www.deezer.com/track/123456796',
        sourceType: 'deezer',
        createdAt: DateTime.now().subtract(const Duration(hours: 14)),
      ),
    ];
  }

  static List<Track> getTrapTracks() {
    return [
      Track(
        id: 't1',
        title: 'Banco',
        artist: 'Matuê',
        coverUrl: 'https://e-cdns-images.dzcdn.net/cover/6a7b7b7b7b7b7b7b7b7b7b7b7b7b7b7b-500x500.jpg',
        sourceUrl: 'https://www.deezer.com/track/123456789',
        sourceType: 'deezer',
        createdAt: DateTime.now(),
      ),
      Track(
        id: 't2',
        title: 'Novo Balanço',
        artist: 'Veigh',
        coverUrl: 'https://e-cdns-images.dzcdn.net/cover/7a8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b-500x500.jpg',
        sourceUrl: 'https://www.deezer.com/track/123456790',
        sourceType: 'deezer',
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      Track(
        id: 't3',
        title: 'Fim de Semana no Rio',
        artist: 'Teto',
        coverUrl: 'https://e-cdns-images.dzcdn.net/cover/8a9b9b9b9b9b9b9b9b9b9b9b9b9b9b9b-500x500.jpg',
        sourceUrl: 'https://www.deezer.com/track/123456791',
        sourceType: 'deezer',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      Track(
        id: 't4',
        title: 'Máquina do Tempo',
        artist: 'Matuê',
        coverUrl: 'https://e-cdns-images.dzcdn.net/cover/6a7b7b7b7b7b7b7b7b7b7b7b7b7b7b7b-500x500.jpg',
        sourceUrl: 'https://www.deezer.com/track/123456797',
        sourceType: 'deezer',
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      ),
      Track(
        id: 't5',
        title: 'Drip',
        artist: 'Veigh',
        coverUrl: 'https://e-cdns-images.dzcdn.net/cover/7a8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b-500x500.jpg',
        sourceUrl: 'https://www.deezer.com/track/123456798',
        sourceType: 'deezer',
        createdAt: DateTime.now().subtract(const Duration(hours: 4)),
      ),
    ];
  }

  static List<Track> getFunkTracks() {
    return [
      Track(
        id: 'f1',
        title: 'Baile de Favela',
        artist: 'Mc João',
        coverUrl: 'https://e-cdns-images.dzcdn.net/cover/2a3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b-500x500.jpg',
        sourceUrl: 'https://www.deezer.com/track/123456795',
        sourceType: 'deezer',
        createdAt: DateTime.now(),
      ),
      Track(
        id: 'f2',
        title: 'Bum Bum Tam Tam',
        artist: 'Mc Fioti',
        coverUrl: 'https://e-cdns-images.dzcdn.net/cover/4a5b5b5b5b5b5b5b5b5b5b5b5b5b5b5b-500x500.jpg',
        sourceUrl: 'https://www.deezer.com/track/123456799',
        sourceType: 'deezer',
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      Track(
        id: 'f3',
        title: 'Vai Malandra',
        artist: 'Anitta',
        coverUrl: 'https://e-cdns-images.dzcdn.net/cover/5a6b6b6b6b6b6b6b6b6b6b6b6b6b6b6b-500x500.jpg',
        sourceUrl: 'https://www.deezer.com/track/123456800',
        sourceType: 'deezer',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      Track(
        id: 'f4',
        title: 'Só Quer Vrau',
        artist: 'Mc Livinho',
        coverUrl: 'https://e-cdns-images.dzcdn.net/cover/6a7b7b7b7b7b7b7b7b7b7b7b7b7b7b7b-500x500.jpg',
        sourceUrl: 'https://www.deezer.com/track/123456801',
        sourceType: 'deezer',
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      ),
    ];
  }

  static List<Track> getSertanejoTracks() {
    return [
      Track(
        id: 's1',
        title: 'Evidências',
        artist: 'Chitãozinho & Xororó',
        coverUrl: 'https://e-cdns-images.dzcdn.net/cover/0a1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b-500x500.jpg',
        sourceUrl: 'https://www.deezer.com/track/123456793',
        sourceType: 'deezer',
        createdAt: DateTime.now(),
      ),
      Track(
        id: 's2',
        title: 'Amor e Fé',
        artist: 'Henrique & Juliano',
        coverUrl: 'https://e-cdns-images.dzcdn.net/cover/1a2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b-500x500.jpg',
        sourceUrl: 'https://www.deezer.com/track/123456802',
        sourceType: 'deezer',
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      Track(
        id: 's3',
        title: 'Pot-Pourri: Só Pra Contrariar / Ainda Gosto Dela',
        artist: 'Gusttavo Lima',
        coverUrl: 'https://e-cdns-images.dzcdn.net/cover/2a3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b-500x500.jpg',
        sourceUrl: 'https://www.deezer.com/track/123456803',
        sourceType: 'deezer',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      Track(
        id: 's4',
        title: 'Fala',
        artist: 'Zé Neto & Cristiano',
        coverUrl: 'https://e-cdns-images.dzcdn.net/cover/3a4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b-500x500.jpg',
        sourceUrl: 'https://www.deezer.com/track/123456804',
        sourceType: 'deezer',
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      ),
    ];
  }

  static List<Track> getPagodeTracks() {
    return [
      Track(
        id: 'p1',
        title: 'Pagode Russo',
        artist: 'Exaltasamba',
        coverUrl: 'https://e-cdns-images.dzcdn.net/cover/1a2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b-500x500.jpg',
        sourceUrl: 'https://www.deezer.com/track/123456794',
        sourceType: 'deezer',
        createdAt: DateTime.now(),
      ),
      Track(
        id: 'p2',
        title: 'Deixa Acontecer',
        artist: 'Grupo Revelação',
        coverUrl: 'https://e-cdns-images.dzcdn.net/cover/4a5b5b5b5b5b5b5b5b5b5b5b5b5b5b5b-500x500.jpg',
        sourceUrl: 'https://www.deezer.com/track/123456805',
        sourceType: 'deezer',
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      Track(
        id: 'p3',
        title: 'Vou Fazer Você Feliz',
        artist: 'Zeca Pagodinho',
        coverUrl: 'https://e-cdns-images.dzcdn.net/cover/5a6b6b6b6b6b6b6b6b6b6b6b6b6b6b6b-500x500.jpg',
        sourceUrl: 'https://www.deezer.com/track/123456806',
        sourceType: 'deezer',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      Track(
        id: 'p4',
        title: 'Deixa Eu Te Amar',
        artist: 'Thiaguinho',
        coverUrl: 'https://e-cdns-images.dzcdn.net/cover/6a7b7b7b7b7b7b7b7b7b7b7b7b7b7b7b-500x500.jpg',
        sourceUrl: 'https://www.deezer.com/track/123456807',
        sourceType: 'deezer',
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      ),
    ];
  }

  static List<Track> getMatueVeighTracks() {
    return [
      Track(
        id: 'mv1',
        title: 'Banco',
        artist: 'Matuê',
        coverUrl: 'https://e-cdns-images.dzcdn.net/cover/6a7b7b7b7b7b7b7b7b7b7b7b7b7b7b7b-500x500.jpg',
        sourceUrl: 'https://www.deezer.com/track/123456789',
        sourceType: 'deezer',
        createdAt: DateTime.now(),
      ),
      Track(
        id: 'mv2',
        title: 'Novo Balanço',
        artist: 'Veigh',
        coverUrl: 'https://e-cdns-images.dzcdn.net/cover/7a8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b-500x500.jpg',
        sourceUrl: 'https://www.deezer.com/track/123456790',
        sourceType: 'deezer',
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      Track(
        id: 'mv3',
        title: 'Máquina do Tempo',
        artist: 'Matuê',
        coverUrl: 'https://e-cdns-images.dzcdn.net/cover/6a7b7b7b7b7b7b7b7b7b7b7b7b7b7b7b-500x500.jpg',
        sourceUrl: 'https://www.deezer.com/track/123456797',
        sourceType: 'deezer',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      Track(
        id: 'mv4',
        title: 'Drip',
        artist: 'Veigh',
        coverUrl: 'https://e-cdns-images.dzcdn.net/cover/7a8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b-500x500.jpg',
        sourceUrl: 'https://www.deezer.com/track/123456798',
        sourceType: 'deezer',
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      ),
      Track(
        id: 'mv5',
        title: 'Gorilla',
        artist: 'Matuê',
        coverUrl: 'https://e-cdns-images.dzcdn.net/cover/6a7b7b7b7b7b7b7b7b7b7b7b7b7b7b7b-500x500.jpg',
        sourceUrl: 'https://www.deezer.com/track/123456808',
        sourceType: 'deezer',
        createdAt: DateTime.now().subtract(const Duration(hours: 4)),
      ),
    ];
  }

  static List<Track> searchMockTracks(String query) {
    final allTracks = getMockTracks();
    return allTracks.where((track) {
      return track.title.toLowerCase().contains(query.toLowerCase()) ||
             track.artist.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  static List<Playlist> searchMockPlaylists(String query) {
    final allPlaylists = getMockPlaylists();
    return allPlaylists.where((playlist) {
      return playlist.name.toLowerCase().contains(query.toLowerCase()) ||
             playlist.description?.toLowerCase().contains(query.toLowerCase()) == true;
    }).toList();
  }
}