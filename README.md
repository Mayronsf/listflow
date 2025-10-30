# OpenWhyd Music App

Um aplicativo Flutter para curadoria musical que consome a API pública do OpenWhyd, permitindo aos usuários visualizar playlists públicas, ver detalhes das músicas e montar suas próprias playlists personalizadas.

## 🎵 Funcionalidades

- **Exploração de Música**: Visualize playlists populares do OpenWhyd
- **Detalhes das Faixas**: Veja título, artista, capa e link de origem
- **Playlists Personalizadas**: Crie e gerencie suas próprias playlists
- **Sistema de Favoritos**: Marque suas músicas favoritas
- **Busca Avançada**: Encontre músicas e playlists por termo
- **Tema Escuro/Claro**: Interface moderna e responsiva
- **Persistência Local**: Dados salvos localmente no dispositivo

## 🛠️ Tecnologias Utilizadas

- **Flutter**: Framework de desenvolvimento
- **Dart**: Linguagem de programação
- **Provider**: Gerenciamento de estado
- **HTTP**: Consumo da API
- **Shared Preferences**: Persistência local
- **Cached Network Image**: Cache de imagens
- **URL Launcher**: Abertura de links externos

## 📱 Telas do Aplicativo

### 1. Tela Inicial (HomeScreen)
- Exibe playlists populares do OpenWhyd
- Mostra faixas recentes
- Navegação para detalhes das playlists

### 2. Tela de Detalhes da Playlist (PlaylistDetailScreen)
- Lista todas as faixas da playlist
- Informações da playlist (criador, número de faixas)
- Opções para favoritar e adicionar à playlist pessoal

### 3. Tela de Busca (SearchScreen)
- Busca por faixas e playlists
- Abas separadas para faixas e playlists
- Resultados em tempo real

### 4. Tela de Minhas Playlists (MyPlaylistsScreen)
- Gerencia playlists criadas localmente
- Criação de novas playlists
- Edição e exclusão de playlists

### 5. Tela de Perfil (ProfileScreen)
- Informações do usuário
- Configurações de tema
- Estatísticas pessoais
- Opções de limpeza de dados

## 🚀 Como Executar

### Pré-requisitos
- Flutter SDK (versão 3.0.0 ou superior)
- Dart SDK
- Android Studio ou VS Code
- Dispositivo Android ou emulador

### Instalação

1. **Clone o repositório**
   ```bash
   git clone <url-do-repositorio>
   cd openwhyd_music_app
   ```

2. **Instale as dependências**
   ```bash
   flutter pub get
   ```

3. **Execute o aplicativo**
   ```bash
   flutter run
   ```

### Configuração do Android

O arquivo `android/app/src/main/AndroidManifest.xml` já está configurado com as permissões necessárias:
- `INTERNET`: Para acessar a API do OpenWhyd
- `ACCESS_NETWORK_STATE`: Para verificar conectividade

## 📁 Estrutura do Projeto

```
lib/
├── models/           # Modelos de dados
│   ├── track.dart
│   ├── playlist.dart
│   └── user.dart
├── services/         # Serviços
│   ├── api_service.dart
│   └── storage_service.dart
├── providers/        # Gerenciamento de estado
│   ├── music_provider.dart
│   └── theme_provider.dart
├── screens/          # Telas do aplicativo
│   ├── home_screen.dart
│   ├── playlist_detail_screen.dart
│   ├── search_screen.dart
│   ├── my_playlists_screen.dart
│   └── profile_screen.dart
├── widgets/          # Widgets reutilizáveis
│   ├── loading_widget.dart
│   ├── playlist_card.dart
│   ├── track_tile.dart
│   └── error_widget.dart
└── main.dart         # Arquivo principal
```

## 🎨 Design e UX

- **Material Design 3**: Interface moderna e consistente
- **Tema Escuro Padrão**: Cores roxo, azul e preto
- **Responsividade**: Adaptável a diferentes tamanhos de tela
- **Animações Suaves**: Transições fluidas entre telas
- **Feedback Visual**: Indicadores de carregamento e estados de erro

## 🔧 Configurações

### Tema
- Modo escuro por padrão
- Alternância entre tema claro e escuro
- Cores personalizadas inspiradas no Spotify/Deezer

### Persistência
- Dados salvos localmente com SharedPreferences
- Favoritos e playlists locais mantidos entre sessões
- Opção de limpeza de dados no perfil

## 📊 API Utilizada

- **Base URL**: https://openwhyd.org/
- **Documentação**: https://openwhyd.github.io/openwhyd/API
- **Endpoints Principais**:
  - `/api/post`: Listar faixas e playlists
  - `/api/playlist/:id`: Detalhes de playlist
  - `/api/search`: Buscar faixas e playlists
  - `/api/user/:id`: Playlists de usuário específico

## 🐛 Solução de Problemas

### Erro de Conectividade
- Verifique sua conexão com a internet
- A API do OpenWhyd pode estar temporariamente indisponível

### Erro de Carregamento
- Tente atualizar a tela (pull-to-refresh)
- Reinicie o aplicativo se necessário

### Dados Não Salvos
- Verifique se o SharedPreferences está funcionando
- Limpe os dados e tente novamente

## 📝 Notas de Desenvolvimento

- **Arquitetura**: MVVM com Provider
- **Gerenciamento de Estado**: Provider para reatividade
- **Tratamento de Erros**: Try-catch com feedback visual
- **Performance**: Cache de imagens e lazy loading
- **Acessibilidade**: Suporte a leitores de tela

## 🤝 Contribuição

Este é um projeto acadêmico desenvolvido por um grupo de 6 integrantes. Para contribuir:

1. Faça um fork do projeto
2. Crie uma branch para sua feature
3. Commit suas mudanças
4. Abra um Pull Request

## 📄 Licença

Este projeto é destinado a fins acadêmicos e educacionais.

## 👥 Equipe

Desenvolvido por um grupo de 6 integrantes para trabalho de faculdade com prazo de 23 dias.

---

**Desenvolvido com ❤️ usando Flutter e a API OpenWhyd**
