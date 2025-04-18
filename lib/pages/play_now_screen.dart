import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:minigolf/api.dart';
import 'package:minigolf/class/create_team.dart';
import 'package:minigolf/class/slot_details.dart'; // Import the shared SlotDetails class
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
  List<TextEditingController> playerControllers = [];
  final TextEditingController _teamNameController = TextEditingController();
  final AudioPlayer _audioPlayer = AudioPlayer();
  int selectedHoles = 9; // Default number of holes
  UserClass user = Storage().getUserData();
  String _teamName = ''; // Add teamName as state variable
  SlotDetails? slotDetails;
  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();
    // Get slots data from arguments
    Map<String, dynamic>? args = Get.arguments;
    if (args != null) {
      dynamic slotDetailsArg = args['slotDetails'];
      selectedDate = args['selectedDate'];
      if (slotDetailsArg != null) {
        try {
          // Create a new slot details object using the from factory
          slotDetails = SlotDetails.from(slotDetailsArg);
          
          // Pre-populate players from slot details if available
          final slotPlayerNames =
              slotDetails!.name.split(',').map((e) => e.trim()).toList();
          players = slotPlayerNames
              .map((name) => Player(
                    name: name,
                    imageUrl: name,
                    companyName: slotDetails!.companyName,
                  ))
              .toList();

          // Add the current user as the first player if not already in the list
          if (!players.any((p) => p.name == user.name)) {
            players.insert(
                0,
                Player(
                  name: user.name ?? '',
                  imageUrl: user.name ?? '',
                ));
          }

          // Initialize controllers for each player
          for (var player in players) {
            playerControllers.add(TextEditingController(text: player.name));
          }
        } catch (e) {
          print('Error converting SlotDetails: $e');
          // Fall back to just adding the current user
          players.add(Player(name: user.name ?? '', imageUrl: user.name ?? ''));
          playerControllers.add(TextEditingController(text: user.name ?? ''));
        }
      } else {
        // Add the current user as the first player
        players.add(Player(name: user.name ?? '', imageUrl: user.name ?? ''));
        playerControllers.add(TextEditingController(text: user.name ?? ''));
      }
    } else {
      // Add the current user as the first player
      players.add(Player(name: user.name ?? '', imageUrl: user.name ?? ''));
      playerControllers.add(TextEditingController(text: user.name ?? ''));
    }
  }

  Future<void> _playSound(String soundPath) async {
    try {
      await _audioPlayer.setAsset(soundPath); // Load the sound asset
      await _audioPlayer.play(); // Play the sound
    } catch (e) {
      debugPrint('Error playing sound: $e');
    }
  }

  void updateCompanyName(int index, String value) {
    setState(() {
      players[index].companyName = value;
    });
  }

  Future<void> _createTeam() async {
    // Validate that all players have names
    if (players.any((player) => player.name.trim().isEmpty)) {
      AppWidgets.errorSnackBar(content: 'All players must have names');
      return;
    }

    try {
      // Make API call to create team
      final response = await ApiService().post(
        Api.baseUrl,
        data: {
          'q': 'createTeam',
          'userID': user.userID,
          'teamName': _teamNameController.text.trim(),
          'members': players
              .map((player) => {
                    'userName': player.name,
                    'userID': '',
                  })
              .toList(),
          'slotID': slotDetails?.id,
          'bookingDate': selectedDate?.toIso8601String(),
          'timeSlot': slotDetails?.timeSlot,
        },
      );

      if (response?.statusCode == 200 && response?.data['error'] == false) {
        // Create TeamClass instance
        final team = TeamClass.fromJson({
          'teamId': response?.data['teamId'],
          'teamName': _teamNameController.text.trim(),
          'members': players
              .map((player) => {
                    'userName': player.name,
                    'userID': '',
                  })
              .toList(),
        });

        // Store team data
        Storage().storeTeamDate(team);

        // Play success sound
        await _playSound('assets/sounds/mixkit-long-pop-2358.mp3');

        // Navigate to scoring screen
        Get.toNamed(Routes.scoreboard, arguments: {'holes': selectedHoles});
      } else {
        AppWidgets.errorSnackBar(
            content: response?.data['message'] ?? 'Failed to create team');
      }
    } catch (e) {
      AppWidgets.errorSnackBar(content: 'Error creating team: $e');
    }
  }

  void _addPlayer() {
    setState(() {
      players.add(Player());
      playerControllers.add(TextEditingController());
    });
  }

  @override
  void dispose() {
    _teamNameController.dispose();
    for (var controller in playerControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void updateTeamName(String value) {
    setState(() {
      _teamName = value;
    });
  }

  void updatePlayerName(int index, String value) {
    setState(() {
      players[index].name = value;
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Setup Game', style: TextStyle(color: Colors.white)),
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
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            child: ElevatedButton(
              onPressed: _createTeam,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                elevation: 3,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.play_arrow, size: 20),
                  SizedBox(width: 4),
                  Text(
                    'Start',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHoleSelector(),

                  // Players Section Header
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Players',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.add,
                              color: Colors.black, size: 20),
                          label: const Text('Add Player'),
                          onPressed: _addPlayer,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Player List
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: players.length,
                    itemBuilder: (context, index) {
                      return AnimatedPlayerCard(
                        player: players[index],
                        onRemove: index == 0
                            ? null
                            : () {
                                setState(() => players.removeAt(index));
                                playerControllers.removeAt(index);
                              },
                        isCurrentUser: index == 0,
                        teamNameController: _teamNameController,
                      );
                    },
                  ),
                ],
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
  String companyName;

  Player({this.name = '', this.imageUrl = '', this.companyName = ''});
}

class AnimatedPlayerCard extends StatelessWidget {
  final Player player;
  final VoidCallback? onRemove;
  final bool isCurrentUser;
  final TextEditingController? teamNameController;

  const AnimatedPlayerCard({
    super.key,
    required this.player,
    this.onRemove,
    this.isCurrentUser = false,
    this.teamNameController,
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
          child: Column(
            children: [
              Row(
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
                      backgroundColor: isCurrentUser
                          ? Colors.orange
                          : const Color(0xFF3A3A3A),
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (isCurrentUser)
                          TextField(
                            controller: teamNameController,
                            onChanged: (value) => context
                                .findAncestorStateOfType<_PlayNowScreenState>()
                                ?.updateTeamName(value),
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: 'Team Name (optional)',
                              labelStyle: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 14,
                              ),
                              enabledBorder: UnderlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.grey[700]!),
                              ),
                              focusedBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.orange),
                              ),
                            ),
                          ),
                        Builder(
                          builder: (context) {
                            final state = context
                                .findAncestorStateOfType<_PlayNowScreenState>();
                            final index = state?.players.indexOf(player) ?? 0;
                            return Column(
                              children: [
                                TextField(
                                  controller: state?.playerControllers[index],
                                  enabled: !isCurrentUser,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: isCurrentUser
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                  decoration: InputDecoration(
                                    labelText: isCurrentUser
                                        ? 'Current Player'
                                        : 'Player Name',
                                    labelStyle: TextStyle(
                                      color: Colors.grey[400],
                                      fontSize: 14,
                                    ),
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.grey[700]!),
                                    ),
                                    focusedBorder: const UnderlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.orange),
                                    ),
                                  ),
                                  onChanged: (value) =>
                                      state?.updatePlayerName(index, value),
                                ),
                                TextField(
                                  style: const TextStyle(color: Colors.white),
                                  decoration: InputDecoration(
                                    labelText: 'Company Name (optional)',
                                    labelStyle: TextStyle(
                                      color: Colors.grey[400],
                                      fontSize: 14,
                                    ),
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.grey[700]!),
                                    ),
                                    focusedBorder: const UnderlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.orange),
                                    ),
                                  ),
                                  onChanged: (value) =>
                                      state?.updateCompanyName(index, value),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  if (onRemove != null)
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                      onPressed: onRemove,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
