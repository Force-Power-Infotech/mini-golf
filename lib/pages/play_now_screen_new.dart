import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
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
  final int defaultHoles = 9; // Fixed default value of 9 holes
  // Create a default guest user
  UserClass user = UserClass(
    userID: 0,
    name: 'Guest Player',
    error: false,
    active: true,
  );
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeScreen();
  }

  void _initializeScreen() {
    // For web platform, extract and store boardId from URL
    if (kIsWeb) {
      try {
        String? boardId = Uri.base.queryParameters['boardId'];
        if (boardId != null && boardId.isNotEmpty) {
          Storage().storeBoardId(boardId);
          debugPrint('Board ID from URL: $boardId');
        }
      } catch (e) {
        debugPrint('Error extracting boardId: $e');
      }
    }

    // Store default user data (guest)
    Storage().storeUserDate(user);

    // Don't add any default players - let the user add them

    // Check for available slots
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAvailableSlots();
    });
  }

  // Method to check for available slots
  Future<void> _checkAvailableSlots() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Get boardId if available
      String? boardId = Storage().getBoardId();

      // Call the API to check for available slots
      final response = await ApiService().post(
        Api.baseUrl,
        data: {
          'q': 'checkAvailableSlots',
          'boardId': boardId,
        },
      );

      if (response == null) {
        debugPrint('No response from server when checking slots');
        _showNoSlotsMessage("Unable to check available slots");
        return;
      }

      Map<String, dynamic> data = response.data;

      if (response.statusCode == 200 && data['error'] == false) {
        if (data['availableSlots'] != null &&
            data['availableSlots'] is List &&
            (data['availableSlots'] as List).isNotEmpty) {
          // If slots are available, show popup
          _showAvailableSlotsPopup(data['availableSlots']);
        } else {
          // If no slots are available, show message
          _showNoSlotsMessage("No slots available");
        }
      } else {
        // If there was an error, show message
        _showNoSlotsMessage(data['message'] ?? "Error checking slots");
      }
    } catch (e) {
      debugPrint('Error checking slots: $e');
      _showNoSlotsMessage("Error: $e");
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // Method to show a message when no slots are available
  void _showNoSlotsMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red.shade800,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  // Method to show available slots popup
  void _showAvailableSlotsPopup(List availableSlots) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.black87,
          title: const Text('Available Slots',
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: availableSlots.length,
              itemBuilder: (context, index) {
                final slot = availableSlots[index];
                return ListTile(
                  title: Text(
                    slot['name'] ?? 'Slot ${index + 1}',
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    'Time: ${slot['time'] ?? 'Available'}',
                    style: TextStyle(color: Colors.grey[400]),
                  ),
                  onTap: () {
                    // Select this slot
                    Navigator.of(context).pop();
                    _selectSlot(slot);
                  },
                );
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              child:
                  const Text('Close', style: TextStyle(color: Colors.orange)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Method to handle slot selection
  void _selectSlot(dynamic slot) {
    // Process the selected slot
    debugPrint('Selected slot: $slot');

    // Update the UI or state with the selected slot info if needed
    setState(() {
      // You can update any state variables related to the selected slot here
    });
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
    // Check if there are any players added
    if (players.isEmpty) {
      AppWidgets.errorSnackBar(content: 'Please add at least one player');
      return;
    }

    // Check if any player has an empty name
    bool hasEmptyName = players.any((player) => player.name.trim().isEmpty);
    if (hasEmptyName) {
      AppWidgets.errorSnackBar(content: 'All players must have names');
      return;
    }

    String? boardId = Storage().getBoardId();

    // Show loading indicator
    setState(() {
      isLoading = true;
    });

    try {
      final response = await ApiService().post(
        Api.baseUrl,
        data: {
          'q': 'createTeam',
          'createdBy': user.userID,
          'members':
              players.map((player) => '"${player.name}"').toList().toString(),
          'numberOfHoles': defaultHoles,
          'boardId': boardId, // Add the boardId to the API call
        },
      );

      if (response == null) {
        AppWidgets.errorSnackBar(content: 'No response from server');
        return;
      }

      Map<String, dynamic> data = response.data;

      if (response.statusCode == 200 && data['error'] == false) {
        // If team creation is successful
        Storage().storeTeamDate(TeamClass.fromJson(data));
        AppWidgets.successSnackBar(content: data['message']);

        // Navigate to scoreboard with holes parameter
        Get.toNamed(Routes.scoreboard, arguments: {'holes': defaultHoles});
      } else {
        AppWidgets.errorSnackBar(
            content: data['message'] ?? 'Failed to create team');
      }
    } catch (e) {
      AppWidgets.errorSnackBar(content: 'Error: $e');
    } finally {
      // Hide loading indicator
      setState(() {
        isLoading = false;
      });
    }
  }

  void _addPlayer() {
    setState(() {
      players.add(Player());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        elevation: 4,
        centerTitle: true,
        title: const Text(
          'MINI GOLF SETUP',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
            letterSpacing: 1.2,
          ),
        ),
      ),
      body: Stack(
        children: [
          // Main scrolling content
          Padding(
            padding: const EdgeInsets.only(bottom: 80), // Space for button
            child: ListView(
              children: [
                // Game Info Header
                Container(
                  margin: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2E2E2E), Color(0xFF202020)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border: Border.all(
                      color: Colors.orange.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Game Settings',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Set up your players below',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          )
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.golf_course,
                              color: Colors.orange,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '$defaultHoles Holes',
                              style: const TextStyle(
                                color: Colors.orange,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Players Section Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Players',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.person_add,
                            color: Colors.black, size: 20),
                        label: const Text('Add Player',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        onPressed: _addPlayer,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4,
                        ),
                      ),
                    ],
                  ),
                ),

                // Player List
                players.isEmpty
                    ? Container(
                        margin: const EdgeInsets.all(20),
                        padding: const EdgeInsets.all(30),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF252525), Color(0xFF1D1D1D)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderRadius: BorderRadius.circular(15),
                          border:
                              Border.all(color: Colors.orange.withOpacity(0.3)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.group_add,
                              color: Colors.orange.withOpacity(0.7),
                              size: 60,
                            ),
                            const SizedBox(height: 15),
                            const Text(
                              'No Players Added',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'Tap the "Add Player" button to add players to your game',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: players.length,
                        itemBuilder: (context, index) {
                          return AnimatedPlayerCard(
                            player: players[index],
                            onRemove: () {
                              setState(() => players.removeAt(index));
                            },
                            isCurrentUser: false,
                          );
                        },
                      ),

                // Add spacing at the bottom
                const SizedBox(height: 100),
              ],
            ),
          ),

          // Loading overlay
          if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.7),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                ),
              ),
            ),

          // Start Game button fixed at bottom
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 15, 20, 25),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1A1A1A), Colors.black],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.6),
                    blurRadius: 15,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: players.isEmpty ? null : _createTeam,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00C853), // Green
                  disabledBackgroundColor: Colors.grey.shade800,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 6,
                  shadowColor: Colors.green.withOpacity(0.5),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.golf_course,
                      size: 28,
                      color: players.isEmpty ? Colors.grey : Colors.white,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      players.isEmpty ? 'ADD PLAYERS TO START' : 'START GAME',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                        color: players.isEmpty ? Colors.grey : Colors.white,
                      ),
                    ),
                  ],
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
          borderRadius: BorderRadius.circular(16),
          border: player.name.isEmpty
              ? Border.all(color: Colors.redAccent, width: 2)
              : Border.all(
                  color: isCurrentUser
                      ? Colors.orange.withOpacity(0.5)
                      : Colors.transparent),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 3),
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
                  enabled: true,
                  autofocus: player.name.isEmpty,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight:
                        isCurrentUser ? FontWeight.bold : FontWeight.normal,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Player Name',
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
