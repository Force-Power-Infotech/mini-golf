import 'package:flutter/material.dart';
import 'package:get/get_core/get_core.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:minigolf/api.dart';
import 'package:minigolf/class/user_class.dart';
import 'package:minigolf/connection/connection.dart';
import 'package:minigolf/routes/routes.dart';
import 'package:minigolf/storage/get_storage.dart';
import 'package:minigolf/widgets/app_widgets.dart';

class PlayNowScreen extends StatefulWidget {
  const PlayNowScreen({super.key});

  @override
  State<PlayNowScreen> createState() => _PlayNowScreenState();
}

class _PlayNowScreenState extends State<PlayNowScreen> {
  List<Player> players = [];
  final AudioPlayer _audioPlayer = AudioPlayer();
  Future<void> _playSound(String soundPath) async {
    try {
      await _audioPlayer.setAsset(soundPath); // Load the sound asset
      await _audioPlayer.play(); // Play the sound
    } catch (e) {
      debugPrint('Error playing sound: $e');
    }
  }

  UserClass user = Storage().getUserData();
  Future<void> _createTeam() async {
    _playSound(
        'assets/sounds/mixkit-epic-orchestra-transition-2290.mp3'); // Play sound
    // Handle OTP submission logic here
    await ApiService().post(
      Api.baseUrl,
      data: {
        'q': 'createTeam',
        'createdBy': user.userID,
        'members': players
            .map((player) => player.name.isEmpty ? 'Unknown' : player.name)
            .toList(),
      },
    ).then((response) async {
      if (response == null || response.data == null) {
        AppWidgets.errorSnackBar(content: 'No response from server');
        return;
      }
      Map<String, dynamic> data = response.data;
      if (response.statusCode == 200 && data['error'] == false) {
        AppWidgets.successSnackBar(content: data['message']);
        Get.toNamed(Routes.scoreboard);
      } else {
        AppWidgets.errorSnackBar(content: data['message']);
      }
    }).catchError((e) {
      AppWidgets.errorSnackBar(content: 'Error: $e');
    });
  }

  void _addPlayer() {
    setState(() {
      players.add(Player(name: '', imageUrl: ''));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomScrollView(
        slivers: [
          // Keep the existing SliverAppBar
          SliverAppBar(
            expandedHeight: 400,
            backgroundColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              background: ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(50),
                  bottomRight: Radius.circular(50),
                ),
                child: Container(
                  height: MediaQuery.of(context).size.height,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image:
                          NetworkImage('https://i.ibb.co/Zz95KzQ/PLAY-now.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
            floating: true,
            snap: true,
            pinned: true,
          ),

          // Instruction Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Card(
                color: Colors.grey[900],
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Instructions",
                        style: TextStyle(
                          color: Colors.orangeAccent,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "1. Use the 'Add Player' button to add a new player.\n"
                        "2. Fill in the player's name by tapping on the input field.\n"
                        "3. Use the delete icon to remove a player if needed.",
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Player List Section
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return AnimatedPlayerCard(
                  player: players[index],
                  onRemove: () {
                    setState(() {
                      players.removeAt(index);
                    });
                  },
                );
              },
              childCount: players.length,
            ),
          ),

          // Add Player Button
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SliverFillRemaining(
              hasScrollBody: false,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.black, Colors.grey],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: _addPlayer,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                        child: const Text(
                          'Add Player',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => _createTeam(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                        child: const Text(
                          'Submit',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Player {
  String name;
  String imageUrl;

  Player({this.name = '', this.imageUrl = ''});
}

class AnimatedPlayerCard extends StatelessWidget {
  final Player player;
  final VoidCallback onRemove;

  const AnimatedPlayerCard({
    super.key,
    required this.player,
    required this.onRemove,
  });

  // Future<void> _playSound(String soundPath) async {
  //   final audioPlayer = AudioPlayer(); // Create an AudioPlayer instance
  //   try {
  //     await audioPlayer.setAsset(soundPath); // Load the sound asset
  //     await audioPlayer.play(); // Play the sound
  //   } catch (e) {
  //     debugPrint('Error playing sound: $e');
  //   } finally {
  //     audioPlayer.dispose(); // Dispose of the player after use
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(16),
          border: player.name.isEmpty
              ? Border.all(color: Colors.redAccent, width: 2)
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Circular Avatar
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.grey[800],
                backgroundImage: player.imageUrl.isNotEmpty
                    ? NetworkImage(player.imageUrl)
                    : null,
                child: player.imageUrl.isEmpty
                    ? const Icon(
                        Icons.person,
                        size: 30,
                        color: Colors.white,
                      )
                    : null,
              ),
              const SizedBox(width: 16),

              // Name Input
              Expanded(
                child: TextField(
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    labelStyle: TextStyle(color: Colors.grey),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.blueAccent),
                    ),
                  ),
                  onChanged: (value) {
                    player.name = value;
                  },
                ),
              ),

              // Remove Button
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.redAccent),
                onPressed: () async {
                  // await _playSound(
                  //     'assets/sounds/mixkit-air-in-a-hit-2161.mp3'); // Play delete sound
                  onRemove(); // Remove player
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
