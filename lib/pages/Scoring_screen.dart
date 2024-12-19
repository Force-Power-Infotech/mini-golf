import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
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
  late ScrollController _scrollController;
  late int totalHoles;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
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
                uID: member.userID ?? 0,
                teamID: team.teamId ?? 0,
                totalHoles: totalHoles,
                defaultScore: 0))
            .toList()
        : [];

    // Send initial scores to API
    _sendInitialScores();
  }

  Future<void> _sendInitialScores() async {
    // Send initial scores of 0 to the server for each player
    for (var player in players) {
      try {
        final response = await ApiService().post(
          Api.baseUrl,
          data: {
            'q': 'scoring',
            'uid': player.uID,
            'teamId': player.teamID,
            'score': 0, // Initially send 0
          },
        );

        if (response?.statusCode != 200 || response?.data['error'] == true) {
          AppWidgets.errorSnackBar(
              content:
                  response?.data['message'] ?? 'Initial score update failed');
        }
      } catch (e) {
        AppWidgets.errorSnackBar(content: 'Error: $e');
      }
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> _incrementScore(int index) async {
    setState(() {
      players[index].holes[currentHole]++;
    });

    try {
      final response = await ApiService().post(
        Api.baseUrl,
        data: {
          'q': 'scoring',
          'uid': players[index].uID,
          'teamId': players[index].teamID,
          'score': players[index].holes[currentHole],
        },
      );

      if (response == null || response.data == null) {
        AppWidgets.errorSnackBar(content: 'No response from the server');
        return;
      }

      Map<String, dynamic> data = response.data;

      if (response.statusCode == 200 && data['error'] == false) {
        AppWidgets.successSnackBar(content: data['message']);
      } else {
        AppWidgets.errorSnackBar(content: data['message']);
      }
    } catch (e) {
      AppWidgets.errorSnackBar(content: 'Error: $e');
    }
  }

  Future<void> _decrementScore(int index) async {
    if (players[index].holes[currentHole] > 0) {
      setState(() {
        players[index].holes[currentHole]--;
      });

      try {
        final response = await ApiService().post(
          Api.baseUrl,
          data: {
            'q': 'scoring',
            'uid': players[index].uID,
            'teamId': players[index].teamID,
            'score': players[index].holes[currentHole],
          },
        );

        if (response == null || response.data == null) {
          AppWidgets.errorSnackBar(content: 'No response from the server');
          return;
        }

        Map<String, dynamic> data = response.data;

        if (response.statusCode == 200 && data['error'] == false) {
          AppWidgets.successSnackBar(content: data['message']);
        } else {
          AppWidgets.errorSnackBar(content: data['message']);
        }
      } catch (e) {
        AppWidgets.errorSnackBar(content: 'Error: $e');
      }
    }
  }

  void _endGame() {
    if (players.isEmpty) return;

    // Show confirmation dialog before ending the game
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
                _showResultsDialog(); // Show results dialog
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
                              padding: const EdgeInsets.symmetric(vertical: 6.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                      Navigator.of(context).pop();
                      Get.offAllNamed(Routes.playnow);
                      _confettiController.stop();
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
                    'Leaderboard',
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
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildScoreButton(
                              icon: Icons.remove_circle,
                              color: Colors.redAccent,
                              onPressed: () => _updateScore(index, -1),
                            ),
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: Colors.grey[800],
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.greenAccent,
                                  width: 2,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  '${players[index].holes[currentHole]}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            _buildScoreButton(
                              icon: Icons.add_circle,
                              color: Colors.greenAccent,
                              onPressed: () => _updateScore(index, 1),
                            ),
                          ],
                        ),
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

  Widget _buildScoreButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(30),
        child: Container(
          padding: const EdgeInsets.all(12),
          child: Icon(
            icon,
            color: color,
            size: 36,
          ),
        ),
      ),
    );
  }

  void _updateScore(int playerIndex, int change) {
    setState(() {
      int newScore = players[playerIndex].holes[currentHole] + change;
      if (newScore >= 0) {
        players[playerIndex].holes[currentHole] = newScore;
      }
    });
    _updateServerScore(playerIndex);
  }

  Future<void> _updateServerScore(int playerIndex) async {
    try {
      final response = await ApiService().post(
        Api.baseUrl,
        data: {
          'q': 'scoring',
          'uid': players[playerIndex].uID,
          'teamId': players[playerIndex].teamID,
          'score': players[playerIndex].getTotalScore(), // Send total score
        },
      );

      if (response?.statusCode == 200 && response?.data['error'] == false) {
        // Don't show success message for every update
      } else {
        AppWidgets.errorSnackBar(
            content: response?.data['message'] ?? 'Update failed');
      }
    } catch (e) {
      AppWidgets.errorSnackBar(content: 'Error: $e');
    }
  }

  Widget _buildHolesSelector() {
    return Container(
      height: 100,
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: SingleChildScrollView(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(totalHoles, (index) {
            return GestureDetector(
              onTap: () => setState(() => currentHole = index),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                width: 80,
                decoration: BoxDecoration(
                  color: currentHole == index
                      ? Colors.greenAccent
                      : Colors.grey[800],
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: currentHole == index
                      ? [
                          BoxShadow(
                            color: Colors.greenAccent.withOpacity(0.3),
                            blurRadius: 10,
                            spreadRadius: 2,
                          )
                        ]
                      : [],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Hole',
                      style: TextStyle(
                        color: currentHole == index
                            ? Colors.black
                            : Colors.white70,
                      ),
                    ),
                    Text(
                      '${index + 1}',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: currentHole == index
                            ? Colors.black
                            : Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class Player {
  String name;
  List<int> holes;
  int uID;
  int teamID;

  Player({
    required this.name,
    required this.uID,
    required this.teamID,
    required int totalHoles,
    int defaultScore = 0,
  }) : holes = List.filled(totalHoles, defaultScore); // Keep UI score as 4

  int getTotalScore() => holes.reduce((a, b) => a + b);
}
