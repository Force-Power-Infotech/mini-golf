import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:minigolf/api.dart';
import 'package:minigolf/class/create_team.dart';
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
  int selectedHoles = 3; // Default number of holes
  UserClass user = Storage().getUserData();

  @override
  void initState() {
    super.initState();
    // Add the current user as the first player
    players.add(Player(name: user.name ?? '', imageUrl: user.name ?? ''));
  }

  Future<void> _playSound(String soundPath) async {
    try {
      await _audioPlayer.setAsset(soundPath); // Load the sound asset
      await _audioPlayer.play(); // Play the sound
    } catch (e) {
      debugPrint('Error playing sound: $e');
    }
  }

  Future<void> _createTeam() async {
    String? boardId = Storage().getBoardId();

    await ApiService().post(
      Api.baseUrl,
      data: {
        'q': 'createTeam',
        'createdBy': user.userID,
        'members':
            players.map((player) => '"${player.name}"').toList().toString(),
        'numberOfHoles': selectedHoles,
        'boardId': boardId, // Add the boardId to the API call
      },
    ).then((response) async {
      if (response == null) {
        AppWidgets.errorSnackBar(content: 'No response from server');
        return;
      }
      Map<String, dynamic> data = response.data;
      if (response.statusCode == 200 && data['error'] == false) {
        Storage().storeTeamDate(TeamClass.fromJson(data));
        AppWidgets.successSnackBar(content: data['message']);
        Get.toNamed(Routes.scoreboard, arguments: {'holes': selectedHoles});
      } else {
        AppWidgets.errorSnackBar(content: data['message']);
      }
    }).catchError((e) {
      AppWidgets.errorSnackBar(content: 'Error: $e');
    });
  }

  void _addPlayer() {
    setState(() {
      players.add(Player());
    });
  }

  Widget _buildHoleSelector() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2E2E2E),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Number of Holes',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildCounterButton(
                icon: Icons.remove,
                onTap: () {
                  if (selectedHoles > 1) {
                    setState(() => selectedHoles--);
                    _playSound('assets/sounds/click.mp3');
                  }
                },
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                width: 100,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  transitionBuilder:
                      (Widget child, Animation<double> animation) {
                    return ScaleTransition(scale: animation, child: child);
                  },
                  child: Text(
                    '$selectedHoles',
                    key: ValueKey<int>(selectedHoles),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              _buildCounterButton(
                icon: Icons.add,
                onTap: () {
                  if (selectedHoles < 18) {
                    setState(() => selectedHoles++);
                    _playSound('assets/sounds/click.mp3');
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCounterButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.orange,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.orange.withOpacity(0.3),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Icon(
          icon,
          color: Colors.black,
          size: 24,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: MediaQuery.of(context).size.height * 0.6,
            pinned: true,
            backgroundColor: Colors.transparent,
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Get.back(),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                child: Image.asset(
                  'assets/images/play_now_header.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                // Player List Section
                Container(
                  margin: const EdgeInsets.only(top: 20),
                  height: MediaQuery.of(context).size.height * 0.45,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: players.length,
                    itemBuilder: (context, index) {
                      return AnimatedPlayerCard(
                        player: players[index],
                        onRemove: index == 0
                            ? null
                            : () {
                                setState(() {
                                  players.removeAt(index);
                                });
                              },
                        isCurrentUser: index == 0,
                      );
                    },
                  ),
                ),

                // Add Hole Selector here
                _buildHoleSelector(),

                // Action Buttons
                Container(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        icon: const Icon(Icons.add, color: Colors.black),
                        label: const Text('Add Player'),
                        onPressed: _addPlayer,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 8,
                        ),
                      ),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.play_arrow, color: Colors.white),
                        label: const Text('Start Game'),
                        onPressed: _createTeam,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00C853),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 8,
                        ),
                      ),
                    ],
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

class Player {
  String name;
  String imageUrl;

  Player({this.name = '', this.imageUrl = ''});
}

class AnimatedPlayerCard extends StatelessWidget {
  final Player player;
  final VoidCallback? onRemove;
  final bool isCurrentUser;

  const AnimatedPlayerCard({
    super.key,
    required this.player,
    this.onRemove,
    this.isCurrentUser = false,
  });

  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    final initials = name
        .trim()
        .split(' ')
        .map((word) => word.isNotEmpty ? word[0].toUpperCase() : '')
        .join('');
    return initials.isEmpty
        ? '?'
        : initials.substring(0, min(2, initials.length));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color:
              isCurrentUser ? const Color(0xFF2E2E2E) : const Color(0xFF252525),
          borderRadius: BorderRadius.circular(24),
          border: player.name.isEmpty
              ? Border.all(color: Colors.redAccent, width: 2)
              : Border.all(
                  color: isCurrentUser
                      ? Colors.orange.withOpacity(0.5)
                      : Colors.transparent),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 30,
                  backgroundColor:
                      isCurrentUser ? Colors.orange : const Color(0xFF3A3A3A),
                  child: Text(
                    _getInitials(player.name),
                    style: TextStyle(
                      color: isCurrentUser ? Colors.black : Colors.white70,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  controller: TextEditingController(text: player.name),
                  enabled: !isCurrentUser,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight:
                        isCurrentUser ? FontWeight.bold : FontWeight.normal,
                  ),
                  decoration: InputDecoration(
                    labelText: isCurrentUser ? 'Current Player' : 'Player Name',
                    labelStyle: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 14,
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey[700]!),
                    ),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.orange),
                    ),
                  ),
                  onChanged: (value) => player.name = value,
                ),
              ),
              if (onRemove != null)
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                  onPressed: onRemove,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
