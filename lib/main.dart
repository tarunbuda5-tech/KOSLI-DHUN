import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

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
  final AudioPlayer player = AudioPlayer();

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

  Future<void> playSong(int index) async {
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

    // Yahan baad mein actual song URL add karenge.
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'KOSLI DHUN 🎵',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        backgroundColor: const Color(0xFF090909),
      ),

      body: selectedIndex == 0
          ? _homeScreen()
          : selectedIndex == 1
              ? _searchScreen()
              : _libraryScreen(),

      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        backgroundColor: const Color(0xFF111111),
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
    );
  }

  Widget _homeScreen() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Welcome to KOSLI DHUN',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 6),

        const Text(
          'Sambalpuri music, all in one place 🎶',
          style: TextStyle(
            color: Colors.white60,
            fontSize: 15,
          ),
        ),

        const SizedBox(height: 25),

        const Text(
          'Popular Songs',
          style: TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 12),

        ...List.generate(
          songs.length,
          (index) => _songCard(index),
        ),
      ],
    );
  }

  Widget _songCard(int index) {
    final song = songs[index];
    final isPlaying = playingIndex == index;

    return Card(
      color: const Color(0xFF171717),
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 6,
        ),
        leading: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: Colors.redAccent.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.music_note,
            color: Colors.redAccent,
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
            color: Colors.white60,
          ),
        ),
        trailing: IconButton(
          icon: Icon(
            isPlaying
                ? Icons.pause_circle_filled
                : Icons.play_circle_fill,
            color: Colors.redAccent,
            size: 36,
          ),
          onPressed: () {
            playSong(index);
          },
        ),
      ),
    );
  }

  Widget _searchScreen() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Search Songs 🔎',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 20),

        TextField(
          decoration: InputDecoration(
            hintText: 'Search Sambalpuri songs...',
            prefixIcon: const Icon(Icons.search),
            filled: true,
            fillColor: const Color(0xFF171717),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
        ),

        const SizedBox(height: 20),

        ...List.generate(
          songs.length,
          (index) => _songCard(index),
        ),
      ],
    );
  }

  Widget _libraryScreen() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.library_music,
            size: 70,
            color: Colors.redAccent,
          ),
          SizedBox(height: 15),
          Text(
            'Your Music Library',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Your favourite songs will appear here.',
            style: TextStyle(
              color: Colors.white60,
            ),
          ),
        ],
      ),
    );
  }
}
