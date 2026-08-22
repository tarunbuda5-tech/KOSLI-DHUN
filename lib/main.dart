import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const KosliDhunApp());
}

class KosliDhunApp extends StatelessWidget {
  const KosliDhunApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'KOSLI DHUN',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0B0B0B),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.orange,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> songs = [];
  List<dynamic> filteredSongs = [];
  bool loading = true;
  String searchText = '';

  @override
  void initState() {
    super.initState();
    loadSongs();
  }

  Future<void> loadSongs() async {
    try {
      final jsonString = await rootBundle.loadString('data/songs.json');
      final data = json.decode(jsonString);

      if (data is List) {
        setState(() {
          songs = data;
          filteredSongs = data;
          loading = false;
        });
      }
    } catch (e) {
      setState(() {
        loading = false;
      });
    }
  }

  void searchSongs(String value) {
    setState(() {
      searchText = value.toLowerCase();

      filteredSongs = songs.where((song) {
        final title = (song['title'] ?? '').toString().toLowerCase();
        final channel = (song['channel'] ?? '').toString().toLowerCase();

        return title.contains(searchText) ||
            channel.contains(searchText);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'KOSLI DHUN',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    onChanged: searchSongs,
                    decoration: InputDecoration(
                      hintText: 'Search Sambalpuri songs...',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white10,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),

                Expanded(
                  child: filteredSongs.isEmpty
                      ? const Center(
                          child: Text(
                            'No songs found',
                            style: TextStyle(fontSize: 18),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                          ),
                          itemCount: filteredSongs.length,
                          itemBuilder: (context, index) {
                            final song = filteredSongs[index];

                            final title =
                                (song['title'] ?? 'Unknown Song')
                                    .toString();

                            final channel =
                                (song['channel'] ?? 'Unknown Artist')
                                    .toString();

                            final thumbnail =
                                (song['thumbnail'] ?? '')
                                    .toString();

                            return Card(
                              margin: const EdgeInsets.only(bottom: 10),
                              color: Colors.white10,
                              child: ListTile(
                                contentPadding:
                                    const EdgeInsets.all(8),
                                leading: ClipRRect(
                                  borderRadius:
                                      BorderRadius.circular(10),
                                  child: thumbnail.isNotEmpty
                                      ? Image.network(
                                          thumbnail,
                                          width: 70,
                                          height: 70,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stack) {
                                            return Container(
                                              width: 70,
                                              height: 70,
                                              color: Colors.white12,
                                              child: const Icon(
                                                Icons.music_note,
                                                size: 32,
                                              ),
                                            );
                                          },
                                        )
                                      : Container(
                                          width: 70,
                                          height: 70,
                                          color: Colors.white12,
                                          child: const Icon(
                                            Icons.music_note,
                                            size: 32,
                                          ),
                                        ),
                                ),
                                title: Text(
                                  title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Padding(
                                  padding:
                                      const EdgeInsets.only(top: 5),
                                  child: Text(
                                    channel,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                trailing: const Icon(
                                  Icons.play_circle_fill,
                                  color: Colors.orange,
                                  size: 36,
                                ),
                                onTap: () {
                                  showSongDetails(song);
                                },
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }

  void showSongDetails(dynamic song) {
    final title = (song['title'] ?? 'Unknown Song').toString();
    final channel = (song['channel'] ?? 'Unknown Artist').toString();
    final youtubeUrl =
        (song['youtubeUrl'] ?? '').toString();

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF151515),
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  channel,
                  style: const TextStyle(
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Clipboard.setData(
                        ClipboardData(text: youtubeUrl),
                      );

                      Navigator.pop(context);

                      ScaffoldMessenger.of(this.context)
                          .showSnackBar(
                        const SnackBar(
                          content: Text(
                            'YouTube link copied',
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.link),
                    label: const Text('Copy YouTube Link'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
