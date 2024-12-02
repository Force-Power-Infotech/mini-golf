import 'package:flutter/material.dart';

class LeaderBoardScreen extends StatelessWidget {
  final List<Map<String, dynamic>> players = [
    {'name': 'Player 1', 'score': 70, 'birdies': 5, 'pars': 8},
    {'name': 'Player 2', 'score': 72, 'birdies': 3, 'pars': 10},
    {'name': 'Player 3', 'score': 68, 'birdies': 6, 'pars': 9},
    {'name': 'Player 4', 'score': 74, 'birdies': 2, 'pars': 12},
    {'name': 'Player 5', 'score': 69, 'bixrdies': 4, 'pars': 11},
    {'name': 'Player 5', 'score': 69, 'bixrdies': 4, 'pars': 11},
    {'name': 'Player 5', 'score': 69, 'bixrdies': 4, 'pars': 11},
    {'name': 'Player 5', 'score': 69, 'bixrdies': 4, 'pars': 11},
    {'name': 'Player 5', 'score': 69, 'bixrdies': 4, 'pars': 11},
  ];

   LeaderBoardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Sort players by score (lowest score ranks higher)
    players.sort((a, b) => a['score'].compareTo(b['score']));

    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomScrollView(
        slivers: [
          // SliverAppBar for the leaderboard banner
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
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(
                          'https://i.ibb.co/HFns4Cq/leaderboard.png'),
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

          // Leaderboard list
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 16),
                _buildLeaderboardHeader(),
                ...players.asMap().entries.map((entry) {
                  final rank = entry.key + 1;
                  final player = entry.value;
                  return _buildLeaderboardRow(rank, player, rank <= 3);
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the header for the leaderboard.
  Widget _buildLeaderboardHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey.shade900,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text(
              'Rank',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            Text(
              'Player',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            Text(
              'Score',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            Text(
              'Birdies',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            Text(
              'Pars',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a row for a player's stats in the leaderboard.
  Widget _buildLeaderboardRow(
      int rank, Map<String, dynamic> player, bool highlight) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      decoration: BoxDecoration(
        color: highlight
            ? Colors.amber.shade700.withOpacity(0.1)
            : Colors.grey.shade800,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Text(
            '$rank',
            style: TextStyle(
              color: highlight ? Colors.amber : Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            player['name'],
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            '${player['score']}',
            style: TextStyle(
              color: highlight ? Colors.amber : Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            '${player['birdies']}',
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
          Text(
            '${player['pars']}',
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: LeaderBoardScreen(),
  ));
}
