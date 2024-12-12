import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:minigolf/api.dart';
import 'package:minigolf/class/create_team.dart';
import 'package:minigolf/connection/connection.dart';
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

  @override
  void initState() {
    super.initState();

    // Initialize confetti controller
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 3));

    // Load team data from storage
    team = Storage().getteamData();

    // Initialize players from team members
    players = team.members != null
        ? team.members!
            .map((member) => Player(
                name: member.userName ?? '',
                uID: member.userID ?? 0,
                teamID: team.teamId ?? 0))
            .toList()
        : [];
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> _incrementScore(int index) async {
    setState(() {
      players[index].score++;
    });

    try {
      final response = await ApiService().post(
        Api.baseUrl,
        data: {
          'q': 'scoring',
          'uid': players[index].uID,
          'teamId': players[index].teamID,
          'score': players[index].score,
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
    if (players[index].score > 0) {
      setState(() {
        players[index].score--;
      });

      try {
        final response = await ApiService().post(
          Api.baseUrl,
          data: {
            'q': 'scoring',
            'uid': players[index].uID,
            'teamId': players[index].teamID,
            'score': players[index].score,
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

    // Determine the winner
    Player winner = players.reduce((a, b) => a.score > b.score ? a : b);

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
            AlertDialog(
              backgroundColor: Colors.grey[850],
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
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${winner.name} is the winner!',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: players
                    .map((player) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                player.name,
                                style: TextStyle(
                                  color: player == winner
                                      ? Colors.greenAccent
                                      : Colors.white,
                                  fontSize: 16,
                                  fontWeight: player == winner
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                              Text(
                                player.score.toString(),
                                style: TextStyle(
                                  color: player == winner
                                      ? Colors.greenAccent
                                      : Colors.white,
                                  fontSize: 16,
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
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _confettiController.stop();
                  },
                  child: const Text(
                    'Close',
                    style: TextStyle(color: Colors.redAccent),
                  ),
                ),
              ],
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
        backgroundColor: Colors.black,
        title: const Text(
          'Scoring',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(30),
          ),
        ),
      ),
      backgroundColor: Colors.grey[900],
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: players.length,
          itemBuilder: (context, index) {
            return Card(
              color: Colors.grey[800],
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              margin: const EdgeInsets.symmetric(vertical: 10),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CircleAvatar(
                      radius: 25,
                      backgroundColor:
                          Colors.primaries[index % Colors.primaries.length],
                      child: Text(
                        players[index].name[0],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          players[index].name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.remove_circle,
                            color: Colors.redAccent,
                            size: 28,
                          ),
                          onPressed: () => _decrementScore(index),
                        ),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: 50,
                          height: 40,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.grey[700],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            players[index].score.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.add_circle,
                            color: Colors.greenAccent,
                            size: 28,
                          ),
                          onPressed: () => _incrementScore(index),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _endGame,
        label: const Text('End Game'),
        icon: const Icon(Icons.flag),
        backgroundColor: Colors.redAccent,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

class Player {
  String name;
  int score;
  int uID;
  int teamID;

  Player(
      {required this.name,
      this.score = 4,
      required this.uID,
      required this.teamID});
}
