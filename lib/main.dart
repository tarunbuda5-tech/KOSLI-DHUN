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
    return Song(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Unknown Song',
      channel: json['channel']?.toString() ?? '',
      thumbnail: json['thumbnail']?.toString() ?? '',
      youtubeUrl: json['youtubeUrl']?.toString() ?? '',
    );
  }
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

  @override
  void initState() {
    super.initState();
    loadSongs();
  }

  Future<void> loadSongs() async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://raw.githubusercontent.com/tarunbuda5-tech/KOSLI-DHUN/main/data/songs.json',
        ),
      );

      if (response.statusCode != 200) {
        throw Exception('Songs load failed');
      }

      final List<dynamic> data = jsonDecode(response.body);

      final loadedSongs = data
          .map((item) => Song.fromJson(item))
          .where((song) => song.id.isNotEmpty)
          .toList();

      if (!mounted) return;

      setState(() {
        songs = loadedSongs;
        filteredSongs = loadedSongs;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
        errorMessage = 'Songs load nahi ho paaye.';
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
        title: const Text(
          'KOSLI DHUN 🎵',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: loadSongs,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: TextField(
              controller: searchController,
              onChanged: searchSongs,
              decoration: InputDecoration(
                hintText: 'Song search karo...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          searchController.clear();
                          searchSongs('');
                        },
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
                    child: CircularProgressIndicator(),
                  )
                : errorMessage.isNotEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment:
                              MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              size: 55,
                              color: Colors.orange,
                            ),
                            const SizedBox(height: 12),
                            Text(errorMessage),
                            const SizedBox(height: 15),
                            ElevatedButton(
                              onPressed: loadSongs,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : filteredSongs.isEmpty
                        ? const Center(
                            child: Text(
                              'Koi song nahi mila 🎵',
                              style: TextStyle(fontSize: 18),
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: loadSongs,
                            child: ListView.builder(
                              padding: const EdgeInsets.only(
                                bottom: 20,
                              ),
                              itemCount: filteredSongs.length,
                              itemBuilder: (context, index) {
                                final song =
                                    filteredSongs[index];

                                return SongCard(
                                  song: song,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            PlayerPage(song: song),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}

class SongCard extends StatelessWidget {
  final Song song;
  final VoidCallback onTap;

  const SongCard({
    super.key,
    required this.song,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF171717),
      margin: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  song.thumbnail.isNotEmpty
                      ? song.thumbnail
                      : 'https://i.ytimg.com/vi/${song.id}/hqdefault.jpg',
                  width: 110,
                  height: 70,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 110,
                      height: 70,
                      color: Colors.black,
                      child: const Icon(
                        Icons.music_note,
                        color: Colors.orange,
                        size: 35,
                      ),
                    );
                  },
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
                      style: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(
                Icons.play_circle_fill,
                color: Colors.orange,
                size: 40,
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
      appBar: AppBar(
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
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    widget.song.channel,
                    style: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 15,
                    ),
                  ),

                  const SizedBox(height: 25),

                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            controller.playVideo();
                          },
                          icon: const Icon(Icons.play_arrow),
                          label: const Text('Play'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            controller.pauseVideo();
                          },
                          icon: const Icon(Icons.pause),
                          label: const Text('Pause'),
                        ),
                      ),
                    ],
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
