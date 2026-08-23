import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

void main() {
  runApp(const KosliDhun());
}

class KosliDhun extends StatelessWidget {
  const KosliDhun({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'KOSLI DHUN',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0D0D0D),
        colorScheme: ColorScheme.dark(
          primary: Colors.orange,
          secondary: Colors.orangeAccent,
        ),
      ),
      home: const HomePage(),
    );
  }
}

class Song {
  final String id;
  final String title;
  final String channel;
  final String thumbnail;
  final String youtubeUrl;

  Song({
    required this.id,
    required this.title,
    required this.channel,
    required this.thumbnail,
    required this.youtubeUrl,
  });

  factory Song.fromJson(Map<String, dynamic> json) {
    final youtubeUrl = json['youtubeUrl']?.toString() ?? '';

    return Song(
      id: json['id']?.toString() ?? extractYoutubeId(youtubeUrl),
      title: json['title']?.toString() ?? 'Unknown Song',
      channel: json['channel']?.toString() ?? 'Sambalpuri Music',
      thumbnail: json['thumbnail']?.toString() ?? '',
      youtubeUrl: youtubeUrl,
    );
  }
}

String extractYoutubeId(String url) {
  if (url.isEmpty) return '';

  final uri = Uri.tryParse(url);

  if (uri != null) {
    if (uri.host.contains('youtu.be')) {
      return uri.pathSegments.isNotEmpty ? uri.pathSegments.first : '';
    }

    if (uri.host.contains('youtube.com')) {
      return uri.queryParameters['v'] ?? '';
    }
  }

  return url;
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Song> songs = [];
  List<Song> filteredSongs = [];

  bool loading = true;
  String errorMessage = '';

  final TextEditingController searchController =
      TextEditingController();

  // GitHub repository ka songs.json
  final String songsUrl =
      'https://raw.githubusercontent.com/tarunbuda5-tech/KOSLI-DHUN/main/data/songs.json';

  @override
  void initState() {
    super.initState();
    loadSongs();
  }

  Future<void> loadSongs() async {
    setState(() {
      loading = true;
      errorMessage = '';
    });

    try {
      final response = await http.get(Uri.parse(songsUrl));

      if (response.statusCode != 200) {
        throw Exception(
          'Songs file load nahi hua. Status: ${response.statusCode}',
        );
      }

      final decoded = jsonDecode(response.body);

      List<dynamic> data;

      if (decoded is List) {
        data = decoded;
      } else if (decoded is Map && decoded['songs'] is List) {
        data = decoded['songs'];
      } else {
        throw Exception('songs.json ka format galat hai.');
      }

      final loadedSongs = data
          .whereType<Map>()
          .map(
            (item) => Song.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .where((song) => song.id.isNotEmpty)
          .toList();

      setState(() {
        songs = loadedSongs;
        filteredSongs = loadedSongs;
        loading = false;
      });
    } catch (e) {
      setState(() {
        loading = false;
        errorMessage = e.toString();
      });
    }
  }

  void searchSongs(String query) {
    final text = query.toLowerCase().trim();

    setState(() {
      if (text.isEmpty) {
        filteredSongs = songs;
      } else {
        filteredSongs = songs.where((song) {
          return song.title.toLowerCase().contains(text) ||
              song.channel.toLowerCase().contains(text);
        }).toList();
      }
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0D0D),
        elevation: 0,
        title: const Row(
          children: [
            Icon(
              Icons.music_note,
              color: Colors.orange,
            ),
            SizedBox(width: 8),
            Text(
              'KOSLI DHUN',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: loadSongs,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: searchController,
              onChanged: searchSongs,
              decoration: InputDecoration(
                hintText: 'Search Sambalpuri songs...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: searchController.text.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          searchController.clear();
                          searchSongs('');
                        },
                        icon: const Icon(Icons.clear),
                      )
                    : null,
                filled: true,
                fillColor: const Color(0xFF1A1A1A),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          Expanded(
            child: loading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Colors.orange,
                    ),
                  )
                : errorMessage.isNotEmpty
                    ? _buildError()
                    : filteredSongs.isEmpty
                        ? const Center(
                            child: Text(
                              'No songs found',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                              ),
                            ),
                          )
                        : RefreshIndicator(
                            color: Colors.orange,
                            onRefresh: loadSongs,
                            child: ListView.builder(
                              padding: const EdgeInsets.only(
                                left: 12,
                                right: 12,
                                bottom: 20,
                              ),
                              itemCount: filteredSongs.length,
                              itemBuilder: (context, index) {
                                return SongCard(
                                  song: filteredSongs[index],
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.redAccent,
              size: 60,
            ),
            const SizedBox(height: 16),
            const Text(
              'Songs load nahi ho pa rahe',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: loadSongs,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SongCard extends StatelessWidget {
  final Song song;

  const SongCard({
    super.key,
    required this.song,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF181818),
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PlayerPage(song: song),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  width: 90,
                  height: 65,
                  child: song.thumbnail.isNotEmpty
                      ? Image.network(
                          song.thumbnail,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) {
                            return Container(
                              color: Colors.black,
                              child: const Icon(
                                Icons.music_note,
                                color: Colors.orange,
                                size: 30,
                              ),
                            );
                          },
                        )
                      : Container(
                          color: Colors.black,
                          child: const Icon(
                            Icons.music_note,
                            color: Colors.orange,
                            size: 30,
                          ),
                        ),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      song.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      song.channel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(
                Icons.play_circle_fill,
                color: Colors.orange,
                size: 38,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PlayerPage extends StatefulWidget {
  final Song song;

  const PlayerPage({
    super.key,
    required this.song,
  });

  @override
  State<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> {
  late YoutubePlayerController controller;

  @override
  void initState() {
    super.initState();

    controller = YoutubePlayerController.fromVideoId(
      videoId: widget.song.id,
      autoPlay: true,
      params: const YoutubePlayerParams(
        showControls: true,
        showFullscreenButton: true,
        enableCaption: true,
        strictRelatedVideos: true,
      ),
    );
  }

  @override
  void dispose() {
    controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0D0D),
        title: const Text('Now Playing'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            YoutubePlayer(
              controller: controller,
              aspectRatio: 16 / 9,
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.song.title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    widget.song.channel,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 15,
                    ),
                  ),

                  const SizedBox(height: 25),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        controller.playVideo();
                      },
                      icon: const Icon(
                        Icons.play_arrow,
                      ),
                      label: const Text(
                        'PLAY SONG',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                          vertical: 15,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
