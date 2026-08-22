import 'package:flutter/material.dart';

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
        scaffoldBackgroundColor: const Color(0xFF090909),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFF1744),
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
  int selectedIndex = 0;
  int? playingIndex;

  final List<Map<String, String>> songs = [
    {
      'title': 'Sambalpuri Hit Song',
      'artist': 'KOSLI DHUN',
    },
    {
      'title': 'Sambalpuri Love',
      'artist': 'Sambalpuri Artist',
    },
    {
      'title': 'Old Sambalpuri Hit',
      'artist': 'Classic Collection',
    },
    {
      'title': 'New Sambalpuri Beat',
      'artist': 'KOSLI DHUN',
    },
    {
      'title': 'Sambalpuri Romantic',
      'artist': 'Kosli Artist',
    },
  ];

  void playSong(int index) {
    setState(() {
      playingIndex = index;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Playing: ${songs[index]['title']}',
        ),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF090909),
        title: const Text(
          'KOSLI DHUN 🎵',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              setState(() {
                selectedIndex = 1;
              });
            },
          ),
        ],
      ),

      body: selectedIndex == 0
          ? homeScreen()
          : selectedIndex == 1
              ? searchScreen()
              : libraryScreen(),

      bottomNavigationBar: NavigationBar(
        backgroundColor: const Color(0xFF111111),
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          NavigationDestination(
            icon: Icon(Icons.library_music_outlined),
            selectedIcon: Icon(Icons.library_music),
            label: 'Library',
          ),
        ],
      ),

      bottomSheet: playingIndex != null
          ? miniPlayer()
          : null,
    );
  }

  Widget homeScreen() {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 100),
        children: [
          const Text(
            'Welcome to',
            style: TextStyle(
              color: Colors.white60,
              fontSize: 15,
            ),
          ),

          const SizedBox(height: 3),

          const Text(
            'Sambalpuri Music 🎶',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              gradient: const LinearGradient(
                colors: [
                  Color(0xFFFF1744),
                  Color(0xFF8B001F),
                ],
              ),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'KOSLI DHUN',
                  style: TextStyle(
                    fontSize: 27,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Your Sambalpuri Music Destination',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          const Text(
            '🔥 Popular Songs',
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          ...List.generate(
            songs.length,
            (index) => songCard(index),
          ),
        ],
      ),
    );
  }

  Widget songCard(int index) {
    final song = songs[index];
    final isPlaying = playingIndex == index;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF151515),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 5,
        ),

        leading: Container(
          width: 55,
          height: 55,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: const LinearGradient(
              colors: [
                Color(0xFFFF1744),
                Color(0xFF6A0019),
              ],
            ),
          ),
          child: const Icon(
            Icons.music_note,
            color: Colors.white,
            size: 28,
          ),
        ),

        title: Text(
          song['title']!,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        subtitle: Text(
          song['artist']!,
          style: const TextStyle(
            color: Colors.white54,
          ),
        ),

        trailing: IconButton(
          icon: Icon(
            isPlaying
                ? Icons.pause_circle_filled
                : Icons.play_circle_fill,
            color: const Color(0xFFFF1744),
            size: 34,
          ),
          onPressed: () {
            playSong(index);
          },
        ),
      ),
    );
  }

  Widget searchScreen() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: 'Search Sambalpuri songs...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: const Color(0xFF181818),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: ListView.builder(
                itemCount: songs.length,
                itemBuilder: (context, index) {
                  return songCard(index);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget libraryScreen() {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Your Library',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),

          libraryTile(
            Icons.favorite,
            'Favourite Songs',
            'Your liked songs',
          ),

          libraryTile(
            Icons.history,
            'Recently Played',
            'Songs you recently played',
          ),

          libraryTile(
            Icons.download,
            'Downloads',
            'Your downloaded music',
          ),
        ],
      ),
    );
  }

  Widget libraryTile(
    IconData icon,
    String title,
    String subtitle,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF151515),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: const Color(0xFFFF1744),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
        ),
      ),
    );
  }

  Widget miniPlayer() {
    final song = songs[playingIndex!];

    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: const BoxDecoration(
        color: Color(0xFF202020),
        border: Border(
          top: BorderSide(
            color: Color(0xFF333333),
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: const Color(0xFFFF1744),
            ),
            child: const Icon(Icons.music_note),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  song['title']!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  song['artist']!,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          IconButton(
            icon: const Icon(
              Icons.pause_circle,
              color: Color(0xFFFF1744),
            ),
            onPressed: () {
              setState(() {
                playingIndex = null;
              });
            },
          ),
        ],
      ),
    );
  }
}
