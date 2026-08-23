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
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF111111),
          elevation: 0,
        ),
      ),
      home: const HomePage(),
    );
  }
}

/* =========================
   SONG MODEL
========================= */

class Song {
  final String id;
  final String title;
  final String channel;
  final String thumbnail;
  final String youtubeUrl;

  const Song({
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

/* =========================
   HOME PAGE
========================= */

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

    searchController.addListener(() {
      searchSongs(searchController.text);
    });
  }

  /* =========================
     LOAD SONGS
  ========================= */

  Future<void> loadSongs() async {
    setState(() {
      loading = true;
      errorMessage = '';
    });

    try {
      final response = await http.get(
        Uri.parse(
          'https://raw.githubusercontent.com/tarunbuda5-tech/KOSLI-DHUN/main/data/songs.json',
        ),
      );

      if (response.statusCode != 200) {
        throw Exception('Songs file not found');
      }

      final decoded = jsonDecode(response.body);

      List<dynamic> data;

      if (decoded is List) {
        data = decoded;
      } else if (decoded is Map && decoded['songs'] is List) {
        data = decoded['songs'];
      } else {
        data = [];
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

  /* =========================
     SEARCH
  ========================= */

  void searchSongs(String query) {
    final q = query.trim().toLowerCase();

    if (q.isEmpty) {
      setState(() {
        filteredSongs = songs;
      });
      return;
    }

    setState(() {
      filteredSongs = songs.where((song) {
        return song.title.toLowerCase().contains(q) ||
            song.channel.toLowerCase().contains(q);
      }).toList();
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  /* =========================
     UI
  ========================= */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
            tooltip: 'Refresh Songs',
          ),
        ],
      ),
      body: Column(
        children: [
          /* SEARCH BAR */

          Padding(
            padding: const EdgeInsets.fromLTRB(
              16,
              14,
              16,
              10,
            ),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search Sambalpuri songs...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: searchController.text.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          searchController.clear();
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

          /* TITLE */

          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            child: Row(
              children: [
                const Text(
                  'Sambalpuri Songs',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  '${filteredSongs.length}',
                  style: const TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          /* SONG LIST */

          Expanded(
            child: loading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Colors.orange,
                    ),
                  )
                : errorMessage.isNotEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisAlignment:
                                MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.cloud_off,
                                size: 60,
                                color: Colors.grey,
                              ),
                              const SizedBox(height: 15),
                              Text(
                                errorMessage,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton.icon(
                                onPressed: loadSongs,
                                icon: const Icon(Icons.refresh),
                                label: const Text('Try Again'),
                              ),
                            ],
                          ),
                        ),
                      )
                    : filteredSongs.isEmpty
                        ? const Center(
                            child: Column(
                              mainAxisAlignment:
                                  MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.music_off,
                                  size: 60,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 12),
                                Text(
                                  'No songs found',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            color: Colors.orange,
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
                                            PlayerPage(
                                          song: song,
                                        ),
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

/* =========================
   SONG CARD
========================= */

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
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              /* THUMBNAIL */

              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  width: 105,
                  height: 70,
                  child: song.thumbnail.isNotEmpty
                      ? Image.network(
                          song.thumbnail,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (context, error, stackTrace) {
                            return Container(
                              color: Colors.black,
                              child: const Icon(
                                Icons.music_note,
                                color: Colors.orange,
                                size: 32,
                              ),
                            );
                          },
                        )
                      : Container(
                          color: Colors.black,
                          child: const Icon(
                            Icons.music_note,
                            color: Colors.orange,
                            size: 32,
                          ),
                        ),
                ),
              ),

              const SizedBox(width: 12),

              /* DETAILS */

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
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      song.channel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 5),

              const CircleAvatar(
                radius: 20,
                backgroundColor: Colors.orange,
                child: Icon(
                  Icons.play_arrow,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/* =========================
   PLAYER PAGE
========================= */

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
      body: Column(
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
                const SizedBox(height: 8),
                Text(
                  widget.song.channel,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 20),

                /* PLAY BUTTON */

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      controller.playVideo();
                    },
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('PLAY SONG'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.black,
                      padding:
                          const EdgeInsets.symmetric(
                        vertical: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
