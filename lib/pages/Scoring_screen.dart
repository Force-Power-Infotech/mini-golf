import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart'; // Add the confetti package

class ScoringScreen extends StatefulWidget {
  @override
  _ScoringScreenState createState() => _ScoringScreenState();
}

class _ScoringScreenState extends State<ScoringScreen> {
  List<Player> players = [
    Player(name: 'Player 1', score: 0),
    Player(name: 'Player 2', score: 0),
    Player(name: 'Player 3', score: 0),
  ];
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 3));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _incrementScore(int index) {
    setState(() {
      players[index].score++;
    });
  }

  void _decrementScore(int index) {
    setState(() {
      if (players[index].score > 0) {
        players[index].score--;
      }
    });
  }

  void _endGame() {
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
                colors: [Colors.red, Colors.green, Colors.blue, Colors.yellow],
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

  Player({required this.name, required this.score});
}
