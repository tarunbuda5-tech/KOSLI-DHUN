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

  Song({
    required this.id,
    required this.title,
    required this.channel,
    required this.thumbnail,
  });

  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Unknown Song',
      channel: json['channel']?.toString() ?? '',
      thumbnail: json['thumbnail']?.toString() ?? '',
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
  final searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadSongs();

    searchController.addListener(() {
      searchSongs(searchController.text);
    });
  }

  Future<void> loadSongs() async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://raw.githubusercontent.com/tarunbuda5-tech/KOSLI-DHUN/main/data/songs.json',
        ),
      );

      if (response.statusCode != 200) {
        throw Exception();
      }

      final data = jsonDecode(response.body);

      List<dynamic> list;

      if (data is List) {
        list = data;
      } else if (data is Map && data['songs'] is List) {
        list = data['songs'];
      } else {
        list = [];
      }

      final result = list
          .whereType<Map>()
          .map(
            (e) => Song.fromJson(
              Map<String, dynamic>.from(e),
            ),
          )
          .where((song) => song.id.isNotEmpty)
          .toList();

      if (!mounted) return;

      setState(() {
        songs = result;
        filteredSongs = result;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
      });
    }
  }

  void searchSongs(String text) {
    final query = text.toLowerCase().trim();

    setState(() {
      if (query.isEmpty) {
        filteredSongs = songs;
      } else {
        filteredSongs = songs.where((song) {
          return song.title.toLowerCase().contains(query) ||
              song.channel.toLowerCase().contains(query);
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
        title: const Text(
          '🎵 KOSLI DHUN',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
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
            padding: const EdgeInsets.all(15),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search Sambalpuri Songs...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: const Color(0xFF1A1A1A),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
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
                : filteredSongs.isEmpty
                    ? const Center(
                        child: Text(
                          'No songs found',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 18,
                          ),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: loadSongs,
                        color: Colors.orange,
                        child: ListView.builder(
                          itemCount: filteredSongs.length,
                          itemBuilder: (context, index) {
                            final song = filteredSongs[index];

                            return Card(
                              color: const Color(0xFF171717),
                              margin: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              child: ListTile(
                                contentPadding:
                                    const EdgeInsets.all(8),
                                leading: ClipRRect(
                                  borderRadius:
                                      BorderRadius.circular(10),
                                  child: SizedBox(
                                    width: 90,
                                    height: 65,
                                    child: Image.network(
                                      song.thumbnail,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stack) {
                                        return const Icon(
                                          Icons.music_note,
                                          size: 40,
                                          color: Colors.orange,
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                title: Text(
                                  song.title,
                                  maxLines: 2,
                                  overflow:
                                      TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  song.channel,
                                  maxLines: 1,
                                  overflow:
                                      TextOverflow.ellipsis,
                                ),
                                trailing: const CircleAvatar(
                                  backgroundColor: Colors.orange,
                                  child: Icon(
                                    Icons.play_arrow,
                                    color: Colors.black,
                                  ),
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          PlayerPage(song: song),
                                    ),
                                  );
                                },
                              ),
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
            child: Text(
              widget.song.title,
              style: const TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
            ),
            child: Text(
              widget.song.channel,
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
