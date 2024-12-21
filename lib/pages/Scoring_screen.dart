import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:minigolf/api.dart';
import 'package:minigolf/class/create_team.dart';
import 'package:minigolf/connection/connection.dart';
import 'package:minigolf/routes/routes.dart';
import 'package:minigolf/storage/get_storage.dart';
import 'package:minigolf/widgets/app_widgets.dart';

class ScoringScreen extends StatefulWidget {
  const ScoringScreen({super.key});

  @override
  State<ScoringScreen> createState() => _ScoringScreenState();
}

class _ScoringScreenState extends State<ScoringScreen> {
  late ConfettiController _confettiController;
  late TeamClass team;
  late List<Player> players;
  int currentHole = 0;
  // late ScrollController _scrollController;
  late int totalHoles;

  // Add these new variables
  bool hasUnsavedChanges = false;
  final String storageKey = 'game_scores';

  @override
  void initState() {
    super.initState();
    // _scrollController = ScrollController();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 3));

    // Get holes count from arguments
    totalHoles = Get.arguments?['holes'] ?? 3;

    // Load team data
    team = Storage().getTeamData();

    // Initialize players with default score of 4
    players = team.members != null
        ? team.members!
            .map((member) => Player(
                name: member.userName ?? '',
                uID: member.userID ?? '',
                teamID: team.teamId ?? '',
                totalHoles: totalHoles,
                defaultScore: 0))
            .toList()
        : [];

    // Send initial scores to API
    // _sendInitialScores();

    // Load saved scores
    _loadSavedScores();
  }

  // Future<void> _sendInitialScores() async {
  //   // Send initial scores of 0 to the server for each player
  //   for (var player in players) {
  //     try {
  //       final response = await ApiService().post(
  //         Api.baseUrl,
  //         data: {
  //           'q': 'scoring',
  //           'uid': player.uID,
  //           'teamId': player.teamID,
  //           'score': 0, // Initially send 0
  //         },
  //       );

  //       if (response?.statusCode != 200 || response?.data['error'] == true) {
  //         AppWidgets.errorSnackBar(
  //             content:
  //                 response?.data['message'] ?? 'Initial score update failed');
  //       }
  //     } catch (e) {
  //       AppWidgets.errorSnackBar(content: 'Error: $e');
  //     }
  //   }
  // }

  void _loadSavedScores() {
    try {
      final savedData = Storage().read(storageKey);
      if (savedData != null) {
        final List<dynamic> scores = savedData;
        for (int i = 0; i < players.length; i++) {
          if (i < scores.length) {
            players[i].holes = List<int>.from(scores[i]['holes']);
          }
        }
        setState(() {});
      }
    } catch (e) {
      debugPrint('Error loading saved scores: $e');
    }
  }

  Future<void> _saveScores() async {
    try {
      // Save to local storage using new write method
      List<Map<String, dynamic>> scoresData = players
          .map((player) => {
                'uid': player.uID,
                'holes': player.holes,
              })
          .toList();

      await Storage().write(storageKey, scoresData);

      // Send to API
      for (var player in players) {
        final response = await ApiService().post(
          Api.baseUrl,
          data: {
            'q': 'scoring',
            'uid': player.uID,
            'teamId': player.teamID,
            'score': player.getTotalScore(),
          },
        );

        if (response?.statusCode != 200) {
          throw Exception('Failed to save score to server');
        }
      }

      setState(() => hasUnsavedChanges = false);
      AppWidgets.successSnackBar(content: 'Scores saved successfully');
    } catch (e) {
      AppWidgets.errorSnackBar(content: 'Error saving scores: $e');
    }
  }

  Future<bool> _confirmSaveScores() async {
    if (!hasUnsavedChanges) return true;

    bool? result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[850],
        title:
            const Text('Save Scores?', style: TextStyle(color: Colors.white)),
        content: const Text('Would you like to save the current scores?',
            style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child:
                const Text('Don\'t Save', style: TextStyle(color: Colors.red)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style:
                ElevatedButton.styleFrom(backgroundColor: Colors.greenAccent),
            child: const Text('Save', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );

    if (result ?? false) {
      await _saveScores();
    }
    return true;
  }

  void _handleHoleChange(int newHole) async {
    if (await _confirmSaveScores()) {
      setState(() => currentHole = newHole);
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  // Future<void> _incrementScore(int index) async {
  //   setState(() {
  //     players[index].holes[currentHole]++;
  //   });

  //   try {
  //     final response = await ApiService().post(
  //       Api.baseUrl,
  //       data: {
  //         'q': 'scoring',
  //         'uid': players[index].uID,
  //         'teamId': players[index].teamID,
  //         'score': players[index].holes[currentHole],
  //       },
  //     );

  //     if (response == null || response.data == null) {
  //       AppWidgets.errorSnackBar(content: 'No response from the server');
  //       return;
  //     }

  //     Map<String, dynamic> data = response.data;

  //     if (response.statusCode == 200 && data['error'] == false) {
  //       AppWidgets.successSnackBar(content: data['message']);
  //     } else {
  //       AppWidgets.errorSnackBar(content: data['message']);
  //     }
  //   } catch (e) {
  //     AppWidgets.errorSnackBar(content: 'Error: $e');
  //   }
  // }

  // Future<void> _decrementScore(int index) async {
  //   if (players[index].holes[currentHole] > 0) {
  //     setState(() {
  //       players[index].holes[currentHole]--;
  //     });

  //     try {
  //       final response = await ApiService().post(
  //         Api.baseUrl,
  //         data: {
  //           'q': 'scoring',
  //           'uid': players[index].uID,
  //           'teamId': players[index].teamID,
  //           'score': players[index].holes[currentHole],
  //         },
  //       );

  //       if (response == null || response.data == null) {
  //         AppWidgets.errorSnackBar(content: 'No response from the server');
  //         return;
  //       }

  //       Map<String, dynamic> data = response.data;

  //       if (response.statusCode == 200 && data['error'] == false) {
  //         AppWidgets.successSnackBar(content: data['message']);
  //       } else {
  //         AppWidgets.errorSnackBar(content: data['message']);
  //       }
  //     } catch (e) {
  //       AppWidgets.errorSnackBar(content: 'Error: $e');
  //     }
  //   }
  // }

  void _endGame() {
    if (players.isEmpty) return;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.grey[850],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'End Game?',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            'Are you sure you want to end the game? This action will display the results and cannot be undone.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.greenAccent),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                _showResultsDialog();
                // Clear saved scores
                Storage().remove(storageKey);
              },
              child: const Text(
                'End Game',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showResultsDialog() {
    // Determine the winner
    Player winner =
        players.reduce((a, b) => a.getTotalScore() < b.getTotalScore() ? a : b);

    // Start the confetti animation
    _confettiController.play();

    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing by tapping outside
      builder: (context) {
        return Stack(
          children: [
            // Confetti overlay
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                emissionFrequency: 0.05,
                numberOfParticles: 30,
                colors: const [
                  Colors.red,
                  Colors.green,
                  Colors.blue,
                  Colors.yellow,
                ],
              ),
            ),
            Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 400),
                child: AlertDialog(
                  backgroundColor: Colors.black87,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  title: Column(
                    children: [
                      const Text(
                        '🎉 Congratulations! 🎉',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.greenAccent,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        '${winner.name} is the Winner!',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Divider(
                        color: Colors.white.withOpacity(0.3),
                        thickness: 1,
                      ),
                    ],
                  ),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: players
                          .map((player) => Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 6.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      player.name,
                                      style: TextStyle(
                                        color: player == winner
                                            ? Colors.greenAccent
                                            : Colors.white,
                                        fontSize: 18,
                                        fontWeight: player == winner
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                    ),
                                    Text(
                                      player.getTotalScore().toString(),
                                      style: TextStyle(
                                        color: player == winner
                                            ? Colors.greenAccent
                                            : Colors.white,
                                        fontSize: 18,
                                        fontWeight: player == winner
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  ],
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                  actionsAlignment: MainAxisAlignment.center,
                  actions: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.greenAccent,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      onPressed: () {
                        _confettiController.stop();
                        // Clear saved scores and navigate
                        Storage().remove(storageKey);
                        Get.offAllNamed(Routes.home);
                      },
                      child: const Text(
                        'Close',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black87,
        elevation: 2,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        centerTitle: true,
        actions: [
          TextButton.icon(
            onPressed: hasUnsavedChanges ? _saveScores : null,
            icon: const Icon(Icons.save, color: Colors.greenAccent),
            label:
                const Text('Save', style: TextStyle(color: Colors.greenAccent)),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () => Get.toNamed(Routes.groupwiseleaderboard),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.greenAccent.withOpacity(0.15),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon:
                      const Icon(Icons.leaderboard, color: Colors.greenAccent),
                  label: const Text(
                    '',
                    style: TextStyle(
                      color: Colors.greenAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: _endGame,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent.withOpacity(0.15),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.stop_circle, color: Colors.redAccent),
                  label: const Text(
                    'End Game',
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      backgroundColor: const Color(0xFF1A1A1A),
      body: Column(
        children: [
          _buildHolesSelector(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: players.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.grey[900]!, Colors.grey[850]!],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
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
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 25,
                              backgroundColor: Colors
                                  .primaries[index % Colors.primaries.length],
                              child: Text(
                                players[index].name[0],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    players[index].name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    'Total: ${players[index].getTotalScore()}',
                                    style: const TextStyle(
                                      color: Colors.greenAccent,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.black12,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: _buildScoreInputTabs(index),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      // floatingActionButton: FloatingActionButton.extended(
      //   onPressed: _endGame,
      //   label: const Text('End Game'),
      //   icon: const Icon(Icons.flag),
      //   backgroundColor: Colors.greenAccent,
      // ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  // Widget _buildScoreButton({
  //   required IconData icon,
  //   required Color color,
  //   required VoidCallback onPressed,
  // }) {
  //   return Material(
  //     color: Colors.transparent,
  //     child: InkWell(
  //       onTap: onPressed,
  //       borderRadius: BorderRadius.circular(30),
  //       child: Container(
  //         padding: const EdgeInsets.all(12),
  //         child: Icon(
  //           icon,
  //           color: color,
  //           size: 36,
  //         ),
  //       ),
  //     ),
  //   );
  // }

  // void _updateScore(int playerIndex, int change) {
  //   setState(() {
  //     int newScore = players[playerIndex].holes[currentHole] + change;
  //     if (newScore >= 0) {
  //       players[playerIndex].holes[currentHole] = newScore;
  //     }
  //   });
  //   _updateServerScore(playerIndex);
  // }

  // Future<void> _updateServerScore(int playerIndex) async {
  //   try {
  //     final response = await ApiService().post(
  //       Api.baseUrl,
  //       data: {
  //         'q': 'scoring',
  //         'uid': players[playerIndex].uID,
  //         'teamId': players[playerIndex].teamID,
  //         'score': players[playerIndex].getTotalScore(), // Send total score
  //       },
  //     );

  //     if (response?.statusCode == 200 && response?.data['error'] == false) {
  //       // Don't show success message for every update
  //     } else {
  //       AppWidgets.errorSnackBar(
  //           content: response?.data['message'] ?? 'Update failed');
  //     }
  //   } catch (e) {
  //     AppWidgets.errorSnackBar(content: 'Error: $e');
  //   }
  // }

  Widget _buildHolesSelector() {
    return Container(
      height: 60,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: totalHoles,
        itemBuilder: (context, index) {
          final isSelected = currentHole == index;
          return GestureDetector(
            onTap: () => _handleHoleChange(index),
            child: Container(
              width: 50,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: isSelected ? Colors.greenAccent : Colors.grey[800],
                borderRadius: BorderRadius.circular(10),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: Colors.greenAccent.withOpacity(0.3),
                          blurRadius: 8,
                          spreadRadius: 1,
                        )
                      ]
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${index + 1}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.black : Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildScoreInputTabs(int playerIndex) {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 9,
        itemBuilder: (context, score) {
          final number = score + 1;
          final isSelected = players[playerIndex].holes[currentHole] == number;

          return GestureDetector(
            onTap: () {
              setState(() {
                players[playerIndex].holes[currentHole] = number;
                hasUnsavedChanges = true;
              });
            },
            child: Container(
              width: 40,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: isSelected ? Colors.greenAccent : Colors.grey[800],
                borderRadius: BorderRadius.circular(10),
                border: isSelected
                    ? Border.all(color: Colors.white, width: 2)
                    : null,
              ),
              child: Center(
                child: Text(
                  '$number',
                  style: TextStyle(
                    color: isSelected ? Colors.black : Colors.white70,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class Player {
  String name;
  List<int> holes;
  String uID;
  String teamID;

  Player({
    required this.name,
    required this.uID,
    required this.teamID,
    required int totalHoles,
    int defaultScore = 0,
  }) : holes = List.filled(totalHoles, defaultScore); // Keep UI score as 4

  int getTotalScore() => holes.reduce((a, b) => a + b);
}
